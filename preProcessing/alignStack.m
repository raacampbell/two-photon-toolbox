function varargout=alignStack(moving,target,varargin)
% Apply 2-D translation correction to image-stack
%
%
% function [registered,out]=alignStack(moving,target,params,...)
%
%
%% Purpose
% Performs motion correction on an image stack (moving). This is a
% generalised version of correctTranslation (which applies only
% translation correction). This function can conduct one of a
% number of a different translation correction routines. It accepts
% inputs in a standardised way across routines and provides outputs
% in a standardised way. Parameters for particular motion
% correction functions can be supplied here has a structure. See
% the function files themselves (below) for valid registration
% parameters. Default options will be defined in the registration
% routine itself. 
% 
% Automatically run in parallel if the user has multiple cores and
% enabled these. Likely you need 4 or more cores to make this
% worthwhile. 
%
%
%% Usage
% alignStack(moving) 
% alignStack(moving,[]) 
%
% Uses the first frame as a reference for all subsequent frames. The
% argument "moving" can be:
% a. A 3-d matrix of images to be motion corrected. 
% b. A twoPhoton object, in which case the image-stack is
%    extracted and processed. If data has a length >1 then all
%    elements of the structure are processed.
%
% alignStack(moving,[],[],'PARAM1', val1, 'PARAM2', val2)
%  Conducts correction with optional paramater value pairs as
%  defined below. First frame is used as target image.
%
% alignStack(moving,target,[],'PARAM1', val1, 'PARAM2', val2)
%  Conducts correction with optional paramater value pairs as
%  defined below. User-defined target image. 
%
%
% 'target' - the image with respect to which the xcorr will be
%        performed. Equals 1 by default. 
%        a. If target is a scalar then correct moving with respect
%           to moving(:,:,target).
%        b. If target has length==2 then correct moving with respect
%           to moving(:,:,target(1):target(2)).
%        c. If target is a 2-d matrix then correct moving with
%           respect to this.   
%        d. If target is a coefficients structure (output of one of
%           the apply_* functions) the these are used to conduct
%           the transformation. The algorithm identity stored in
%           the coefficients structure will be used. 
%
% 'algorithm' - the algorithm used to conduct the registration:
%
%     'ffttrans' - fft-based sub-pixel translation correction in x and
%     y. No rotation correction. Implemented by
%     ../registrationFunctions/apply_ffttrans.m This is the default.
%
%     'demon' - CPU-based non-rigid fluid-like registration.  Options
%     for rigid, affine, and non-rigid; as well as various other
%     parameters such as fluidity.  see apply_demon.m
%
%     'elastix' - elastix is an elaborate image registration suite
%     written in C++. A Matlab wrapper is provided for it. see
%     apply_elastix
%
%     'gkerr' - Greenberg & Kerr 2-photon optimised correction. 
%               See apply_gkerr.m Using coefficients to conduct a
%               translation isn't supported since corrections
%               cannot be generalised across frames. 
%
%     'symmetric' - GPU-based non-rigid registration. Doesn't have
%                 many options. See apply_symmetric.m Using
%                 coefficients to conduct a translation isn't
%                 supported since this function is the least
%                 useful. 
%
%       
% 'verbose' -  [0 by default] - if 1 then it plots the
%          performance of the registration. 
%
% 'params' - structure containing parameter values (structure
%          fields) and parameter values (structure field values)
%          for the image registation routines. If not specified,
%          defaults are used. See individual files for the defaults
%          and possible options. Only parameters the user wants to
%          alter need to be defined in the structure.
%
% 'commit' - 0 by default. If 0 then paramters are saved to the 
%          twoPhoton structure (in the process property) and 
%          re-applied whenever the data are loaded. This is
%          encouraged so the user can assess the transform. The
%          regParams function can be used to commit the alignment
%          once we're happy with it. 
%
% 'addParams' - 1 by default. If 0, then the parameter structure is
%               not updated. This is used by the regParams
%               function. 
%
%
%% Outputs
% * registered is the motion-corrected image stack. 
% * out provides more detailed outputs, including coefficients. 
%
%
%% Examples
%
% 1. Run a quick alignment of all frames with respect to the first frame:
%    aligned=alignStack(data(1).imageStack);
%    playMovie(data(1).imageStack-aligned) %visualise the difference
%
% 2. Run a quick alignment of all frames with respect to the mean
%    of the first five frames: 
%    aligned=alignStack(data(1).imageStack,[1,5]);
%
% 3. Run a quick alignment of all frames with respect to an
%    arbitrary image of the same size:
%    aligned=alignStack(data(1).imageStack, mean(data(1).imageStack(:,:,1:2:10),3));
%
% 4. Go through the 2-photon data structure and, within each trial,
%    align all frames with respect to the mean of the first five
%    frames of that trial. Report progress to screen:
%    alignStack(data, [1,5], 'verbose', 1)
%    
%    The meta-data required to register the image-stacks are in
%    data.process.registration{1} and the registration is applied
%    each time the data are loaded from the disk. To "commit" the
%    registration, over-writing the raw data, you would:
%    regParams(data,'action','commit')
%
% 5. Same as (3), but using demon registration instead of the
%    default, fft-based, translation correction. Expect this to be
%    substantially slower; it will benefit from being run on a
%    machine with multiple cores.
%    alignStack(data, [1,5], 'verbose', 1, 'algorithm', 'demon')
%
% 6. Run a non-rigid demon registration on one image-stack (will 
%    probably produce weird results, BTW):
%    P.Registration='NonRigid';
%    aligned=alignStack(data(1).imageStack,[1,5],'algorithm','demon','params',P)
%    playMovie(aligned) %oops! won't do that again!
%
%
%
% Rob Campbell, August - 2012
%
% Also see:
% regParams, apply_elastix, apply_ffttrans, apply_demon,
% apply_gkerr, apply_symmetric, alignRepeats


%----------------------------------------------------------------------
%Parse Inputs
if nargin<2 | isempty(target)
    target=1;
end

IN=inputParser;

addRequired(IN,'moving')
addOptional(IN,'verbose',0,@isnumeric);
addOptional(IN,'addParams',1,@isnumeric);
addOptional(IN,'params',[],@isstruct);
addOptional(IN,'commit',0,@isnumeric);

defaultAlg='ffttrans';
validAlg = {'ffttrans','elastix','symmetric','demon','gkerr'};
checkAlg = @(x) any(validatestring(x,validAlg));
addOptional(IN,'algorithm',defaultAlg,checkAlg);

parse(IN,moving,varargin{:})
addParams=IN.Results.addParams;
verbose=IN.Results.verbose;
algorithm=IN.Results.algorithm;
params=IN.Results.params;
commit=IN.Results.commit;

if isempty(algorithm), algorithm='ffttrans'; end

if numCores>0
    parallel=1;
elseif numCores==0
    parallel=0;
end

%To relay options to correction function
params(1).verbose=verbose;
params(1).parallel=parallel;

call=[{target},varargin]; %We will store this in the data structure


% This function can handle either a matrix or a 2-photon data structure.
if strcmp(class(moving),'twoPhoton')
  data=moving;
  
  for ii=1:length(data)
      if verbose & length(data)>1
          fprintf('%d/%d ',ii,length(data))
      end
    moving=data(ii).imageStack(:,:,:,:,:);
    [registered,tmpout]=alignStack(moving,target,varargin{:});


    %disp('alignStack: THIS NEEDS TESTING! WHAT DO WITH muStack?')
    tmpout.call.(mfilename)=call;
    out(ii)=tmpout;
    if addParams
        regParams(data(ii),'add',out(ii));
    end
    
    if commit
        regParams(data(ii),'action','commit')
        saveRawData(data(ii),registered,0)
    end
  end
  
  if ndims(moving)>3
      fprintf(['alignStack: WARNING!\nalignStack does not currently handle ' ...
               'data with multiple depths or multiple channels! '])
  end
  

  if nargin>0, varargout{1}=data; end 
  if nargin>1, varargout{2}=out; end

  return
end

%----------------------------------------------------------------------
%Motion will be corrected with respect to the target image. Extract
%target image or coefficicents here. See help for details. 
if isvector(target) & length(target)==2
  target=mean(moving(:,:,target(1):target(2)),3);
elseif isnumeric(target) & length(target)==1
  target=moving(:,:,target);
elseif isnumeric(target) & ndims(target)==2
    %are they the same size?
    if any(size(target)-[size(moving,1),size(moving,2)])
        error('Target and moving images are different dimensions')        
    end
elseif isnumeric(target) & ndims(target)==3
    target=mean(target,3);
    disp('alignStack - WARNING: averaging 3D target matrix to 2D')
elseif isstruct(target)
    if length(target)>1
        disp('alignStack Warning: coeficient structure has length >1')
        target=target(:);
    end    
    algorithm=target.routine;
    if strcmp('symmetric',algorithm) | strcmp('gkerr',algorithm)
        error('Using coefficients from %s registration not supported',...
              algorithm)
    end
else
    error('Target is an unexpected format:')
    disp(target)
end




%----------------------------------------------------------------------
%Run the registration
switch algorithm
  case 'ffttrans'
    [registered,out]=apply_ffttrans(moving,target,params);
  case 'symmetric'
    [registered,out]=apply_symmetric(moving,target,params);
  case 'elastix'
    [registered,out]=apply_elastix(moving,target,params);
  case 'demon'
    [registered,out]=apply_demon(moving,target,params);
  case 'gkerr'
    [registered,out]=apply_gkerr(moving,target,params);
  otherwise    
    fprintf('Not performing translation \n')
  return
end


for ii=1:length(out)
    out(ii).alignStackParams=params;
end




%----------------------------------------------------------------------
if isfield(out,'target')
    if verbose
        try
            plotTranslation(out)
        catch
            disp('Failed to plot translation results')
        end
        
    end
end


if nargin>0, varargout{1}=registered; end
if nargin>1, varargout{2}=out; end

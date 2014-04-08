function [data,out]=alignRepeats(data,varargin)
% Conduct translation correction across trials
%
% function [data,out]=alignRepeats(data,...)
%
% Purpose:
% Attempt to align recordings obtained over many stimulus repeats.
%
% Automatically run in parallel if the user has multiple cores and
% enabled these. Likely you need 4 or more cores to make this
% worthwhile. 

% Align with default parameters:
% alignRepeats(data)
%
% Inputs:
% * data - The twoPhoton data object
%
%
% Align with defaults over-ridden by parameter/values pairs:
% alignRepeats(data,'param1',value1)
%
% Prameter/value pairs:
% 'verbose' 1 by default. 
%
% 'reg' which registration to use. e.g. if the stacks were
% registered with an FFT then elastix b-spline, then data.info.muStack will
% have a 3rd dimension with a length of 3: un-registered,
% translated, then elastix + translation. You can choose which
% level to use. If the registration was "comitted" (see regParams)
% then you won't have access to all three. Only the combined
% transform. 
%
% 'params' - structure containing parameter values (structure
%          fields) and parameter values (structure field values)
%          for the image registation routines. If not specified,
%          defaults are used. See individual files for the defaults
%          and possible options. Only parameters the user wants to
%          alter need to be defined in the structure.
%
% 'reference' which mean stack (i.e. stimulus presentation) is to
%             be the target image for alignment. 
%
% 'reg' - Which set of registered stacks to use? If there are
%       multiple alignments done on the stack (e.g. translation
%       then b-spline), the user gets a choice as to which level of
%       alignment to use. This is only possible if the alignments
%       have not been comitted to disk. e.g. If reg is 0 then the
%       un-aligned stacks are used. The default is to use ALL
%       alignment steps. 
%
% 'algorithm' the registration algorithm to use (see help alignStack)
%
% Outputs:
% out - a structure containing the before and after results of the
%       correction. 
%
% Rob Campbell, August 2012
%
% NOTES:
% 1. Only corrects channel 2 right now.  [04/08/2012]
% 2. This function works but it's not finalised. 
%
%
% Also see:
% alignStack, regParams, 



%----------------------------------------------------------------------
if length(data)==1
    fprintf('alignRepeats: data has a length of 1. Exiting.\n')
    return
end

IN=inputParser;
addRequired(IN,'data')

addOptional(IN,'verbose',1,@isnumeric);
addOptional(IN,'reference',1,@isnumeric);
addOptional(IN,'params',[],@isstruct);

defaultAlg='ffttrans';
validAlg = {'ffttrans','elastix','symmetric','demon','gkerr'};
checkAlg = @(x) any(validatestring(x,validAlg));
addOptional(IN,'algorithm',defaultAlg,checkAlg);

regSteps=length(data(1).process.registration{data(1).process.regSeries});
addOptional(IN,'reg',regSteps,@isnumeric);


parse(IN,data,varargin{:})

verbose=IN.Results.verbose;
reference=IN.Results.reference;
params=IN.Results.params;
algorithm=IN.Results.algorithm;
reg=IN.Results.reg;

if numCores>0
    parallel=1;
elseif numCores==0
    parallel=0;
end

%To relay options to correction function
params(1).verbose=verbose;
params(1).parallel=parallel;

%----------------------------------------------------------------------
%get the grand mean over all presentations
for ii=1:length(data)
    if ndims(data(ii).info.muStack)>3
        disp('Error! Can only handle one channel and one depth!')
    end
    grandMean(:,:,ii)=data(ii).info.muStack(:,:,reg+1);
end
out.before=grandMean;


%First correct translation 
if verbose
    fprintf('Calculating average transform\n')
end


%Align means from each stimulus presentation with the first
%presentation
[out.after,OUT]=alignStack(grandMean,reference,...                           
                           'verbose',verbose,...
                           'algorithm',algorithm,...
                           'params',params);



if verbose    
    fprintf('Applying coefficients\n')
end

%Make sure we only do the desired registrations
regParams(data,'do_until',reg)
for ii=1:length(data)
    TMP=OUT;
    TMP.coef=OUT.coef(ii);
    TMP.coef.routine=TMP.routine; 
    TMP.reference=reference; 
    TMP.regClass='repeats';
    [~,thisOut]=alignStack(data(ii),TMP.coef,...                            
                            'verbose',verbose,...
                            'params',params);    

    %Now we add the transform to our pre-processing stream
    %    this.call.(mfilename)=varargin;
    %regParams(data(ii),'add',thisOut)

    %Tack this into the end of the mean image stack
    rp=responsePeriodFrames(data(ii));
    im=thisOut.after;
    nonResp=[1:rp(1)-2,rp(2)+2:size(im,3)];
    data(ii).info.muStack(:,:,end+1)=mean(im(:,:,nonResp),3);
end


if verbose, fprintf('\n'), end




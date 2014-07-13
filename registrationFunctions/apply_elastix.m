function varargout=apply_elastix(movingStack,target,params)
% elastix image registration wrapper
%
% function [registered,out]=apply_elastix(movingStack,target,params)
%
% Purpose
% Apply elastix registration (rigid, affine, or non-rigid)
% correction to movingStack (which may be a single image or an
% image time-series. movingStack is aligned to target. This 
% function will *not* align 3-D stacks. 
%
%
% Inputs
% movingStack - A single image or an image time-series which will
%               be aligned with targetImage. 
%
% target - The image used as the reference to which to align
%          movingImage. If target is a coefficients structure
%          produced by this function (contained in the second
%          output argument) then it applies this to movingStack.
%
% params - structure containing parameter values for the
%          registration. This can have a length>1, in which case
%          these structures are treated as a request for multiple
%          sequential registrations. The identity of the transform
%          type is defined here. The possible values for fields in
%          the the structure can be found in elastix_parameter_write
%          In addition, the parameters struction can contain the
%          following fields. If these are not defined, default
%          values are used. These need only be present in
%          the first element of the structure. 
%
% params.parallel - 1 by default. Runs registrations in parallel,
%           subject to standard constraints (Toolbox availablility,
%           labs already connected, etc). 
%
% params.verbose - 1 by default. If 0 the analysis is run silently. If
%          2, more information is provided. 
%
% params.keepTMP - 0 by default. If 1, the temporary data directories
%          created by the wrapper are not deleted. 
%
%
% Rob Campbell - August 2012
%
% Notes: 
% 1. You will need to download the elastix binaries (or compile the source)
% from: http://elastix.isi.uu.nl/ There are versions for all
% platforms. 
% 2. Not yet tested on Windows. Works on Mac and Linux. For Windows
% you will need to install Elastix and somehow add it to your
% path. 
% 3. Read the elastix website and elastix_parameter_write.m to
% learn more about the parameters that can be modified. There are
% many registration options available and you will likely need to
% do a bit of hacking in these files in order to get the most out
% of it.


%----------------------------------------------------------------------
% *** Handle default options ***
options.parallel=1;
options.verbose=1;
options.keepTMP=0; 

if nargin<3, params=struct; end
F=fields(options);

for ii=1:length(F)
    if isfield(params,F{ii}) & ~isempty(params(1).(F{ii}))
        options.(F{ii})=params(1).(F{ii});
    end
end


options.parallel=tryParallel(options.parallel); %disable parallel execution if there's a problem


%----------------------------------------------------------------------
% *** Call the registration routine ***
%
% It's called recursively here if there's an image-stack. This
% makes the registration code neater since it need not be aware of
% the image stack. 
if size(movingStack,3)>1
    
    registered=nan(size(movingStack));


    if options.parallel
        if isstruct(target) & length(target)>1
            parfor ii=1:size(movingStack,3)
                if options.verbose
                    fprintf('* %d * \n',ii);
                end
                [registered(:,:,ii),out(ii)]= ...
                    apply_elastix(movingStack(:,:,ii),target(ii), params);
            end
        else                        
            parfor ii=1:size(movingStack,3)
                if options.verbose
                    fprintf('* %d * \n',ii);
                end
                [registered(:,:,ii),out(ii)]= ...
                    apply_elastix(movingStack(:,:,ii),target, params);
            end
        end

    else

        if isstruct(target) & length(target)>1
            tmpTarget=target;
        end
        for ii=1:size(movingStack,3)
            if options.verbose
                fprintf('* %d * \n',ii);
            end
            if isstruct(target) & length(target)>1
                target=tmpTarget(ii);
            end            
            [registered(:,:,ii),out(ii)]=...
                apply_elastix(movingStack(:,:,ii),target,params);
        end        

    end

    if nargout>0
        varargout{1}=registered;    
    end
   if nargout>1
        tmp.before=movingStack;
        tmp.after=registered;
        tmp.routine=regexprep(mfilename,'apply_','');
        tmp.params=params;
        if isnumeric(target), tmp.target=target; end
        for ii=1:size(movingStack,3)
            tmp.coef(ii)=out(ii).coef;
        end
        varargout{2}=tmp;
    end

        
    return
end




%----------------------------------------------------------------------
% *** Conduct the registration ***

% ONE
% Make temporary directory into which we will write the image files
% and associated registration files
tmpDir=sprintf('elastixTMP_%s_%d',...
               datestr(now,'yymmddHHMMSS'),round(rand*1E8));

if ~mkdir(tmpDir); error('Can''t make temporary data directory'), end


% TWO
% Create and move the images
movingFname=[tmpDir,'_moving'];
mha_write(movingStack,movingFname);
if ~movefile([movingFname,'.*'],tmpDir); error('Can''t move files'), end

%create target only if we're registering to an image. parameters
%may have been supplied instead
if isnumeric(target)
    targetFname=[tmpDir,'_target'];
    mha_write(target,targetFname);
    if ~movefile([targetFname,'.*'],tmpDir); error('Can''t move files'), end
end





% THREE
% Handle parameter files
% a. Remove irrelevant options
if ~isempty(params)
    F=fields(options);
    for ii=1:length(F)
        if isfield(params,F{ii}) & ~isempty(params(1).(F{ii}))
            params=rmfield(params,F{ii});
        end
    end
end

%b. Build parameter file
% In the case of a new registration, the options in the params
% structure will automatically be used in place of defaults. In the
% case of a transformation based upon provided parameters, we
% simply write the supplied parameters to disk. 
if isnumeric(target)
    for ii=1:length(params)
        paramFname{ii}=sprintf('%s_parameters_%d.txt',tmpDir,ii);
        elastix_parameter_write(paramFname{ii},params(ii))
        if ~movefile(paramFname{ii},tmpDir)
            error('Can''t move parameter files')
        end
    end
elseif isstruct(target)
    %The first transform is the initial one and subsequent ones (if
    %they exist) look to it. So we need to modify this field so
    %that transformix looks for the correct file. 
    tp=target.parameters;
    for ii=1:length(tp)
        paramFname{ii}=sprintf('%s_parameters_%d.txt',tmpDir,ii);
        if ii>1
            tp{ii}.InitialTransformParametersFileName=...
                [tmpDir,'/',paramFname{1}];
        end
        
        elastix_paramStruct2txt(paramFname{ii},tp{ii})
        if ~movefile(paramFname{ii},tmpDir)
            error('Can''t move parameter files')
        end
        
        %d=dir([tmpDir,'/*_parameters_*']);
        %fprintf('Number of param files in directory %s: %d\n',...
        %        tmpDir,length(d))
    end
    
end


%sometimes the registration directory doesn't exist by this
%point. Don't know why. Add a short pause just in case this helps. 
pause(0.3)



% FOUR
% Build the the appropriate command
if isnumeric(target)
    CMD=sprintf('elastix -f %s/%s.mhd -m %s/%s.mhd -out %s ',...
                tmpDir,targetFname,tmpDir,movingFname,tmpDir);
    
    %Loop through, adding each parameter file in turn to the string
    for ii=1:length(paramFname)
        CMD=[CMD,sprintf('-p %s/%s ', tmpDir, paramFname{ii})];
    end

elseif isstruct(target)
    CMD=sprintf('transformix -in %s/%s.mhd -out %s -tp %s/%s',...
                tmpDir,movingFname,tmpDir,tmpDir,paramFname{end});
end


if ~options.verbose & ~ispc
    CMD=[CMD,' > /dev/null'];
end


% FIVE
% Run the command and report back if it failed
[status,result]=system(CMD);
    out.coef.routine=regexprep(mfilename,'apply_','');
if status
    if status
        fprintf('\n\t*** Transform Failed! ***\n%s\n',result)
    else
        disp(result)
    end
    registered=nan;
else
    %Read the transformed images
    d=dir([tmpDir,'/result*mhd']);
    for ii=1:length(d)
        registered(:,:,ii)=mha_read([tmpDir,'/',d(ii).name]);
    end

    
    %Read Log File and transformation parameters
    if isnumeric(target)
        d=dir([tmpDir,'/TransformParameters*']);
        for ii=1:length(d)
            out.coef.parameters{ii}=elastix_parameter_read([tmpDir,'/',d(ii).name]);
        end
        out.log=readWholeTextFile([tmpDir,'/elastix.log']);
    elseif isstruct(target)
        out.log=readWholeTextFile([tmpDir,'/transformix.log']);
        out.coef.parameters={tp{:}}; %Think that's what's needed
    end
    
end



%Clean up if desired
if ~options.keepTMP
    delete([tmpDir,'/*'])
    rmdir(tmpDir)
end



%----------------------------------------------------------------------

if nargout>0
    %By default we return only the final registered image. 
    varargout{1}=registered(:,:,end); 
end

if nargout>1
    %All stages of the registration (if created) are returned here.
    out.before=movingStack;
    out.after=squeeze(registered(:,:,end));
    tmp.routine=regexprep(mfilename,'apply_','');
    out.coef.routine=tmp.routine;
    out.target=target;    
    out.params=params;
    varargout{2}=out;
end

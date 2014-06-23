function varargout=apply_demon(movingStack,target,params)
% function varargout=apply_demon(movingStack,target,params)
%
% Purpose
% Apply demon registration (affine and fluid-like non-rigid)
% correction to movingStack (which may be a single image or an
% image time-series. movingStack is aligned to target. 
%
% Note that the non-rigid registration applied by this function tends
% to produce very large artefacts. Adjusting the parameters doesn't
% seem to help so the non-rigid registrations are probably the only
% ones that are worth using. Also, it may not cope well with noisy
% images and may decrease peak dF/F and broaden the response time.
%
% Inputs
% movingStack - A single image or an image time-series which will
%               be aligned with target. 
% target - The image used as the reference to which to align
%          movingImage. If target is a coefficients structure then
%          it applies this to movingStack.
% params - structure containing parameter values (structure
%          fields) and parameter values (structure field values)
%          for the image registation routines. If not specified,
%          defaults are used. See the register_images function that
%          does the demon registration for a full overview of what
%          paramaters are possible. Only parameters the user wants to
%          alter need to be defined in the structure.
%
%
% Example
% p.Registration="NonRigid";
% im=data(1).imageStack;
% registered=apply_demon(im,mean(im(:,:,1:4),3),p);
%
%
% Rob Campbell - August 2012
%
% Notes: 
% You will need to download and compile the demon image registration from:
% www.mathworks.fr/matlabcentral/fileexchange/21451


% This function is a wrapper which allows us to conduct the fft-based
% translation correction. We will register each frame with the
% baseline image to within 0.1 pixels by specifying an upsampling
% parameter of 10. Setting this to <2 will screw up the align over
% reps. Very little speed gain will be achieved by changing this
% value.



%----------------------------------------------------------------------
% Handle default options and parameters
p.Registration='affine'; %Non-rigid produces artefacts
%p.Similarity='p';
%options.Alpha=4;
%options.SigmaFluid=4;%made no difference at 2 or 8
%options.SigmaDiff=5;%made no difference
p.verbose=0;
p.parallel=1;

if nargin>2
    f=fields(params);
    for ii=1:length(f)
        p.(f{ii})=params.(f{ii});
    end
end

p.parallel=tryParallel(p.parallel); %disable parallel execution if there's a problem

verbose=p.verbose;
parallel=p.parallel;


%----------------------------------------------------------------------
% Call the registration routine
%
% It's called recursively here if there's an image-stack. This
% makes the registration code neater since it need not be aware of
% the image stack. 
if size(movingStack,3)>1
    
    if p.verbose & ~p.parallel
        chalk(sprintf('Applying demon correction [%s]',...
                      repmat('.',1,size(movingStack,3))))
        fprintf(repmat('\b',1,size(movingStack,3)+1))
        tic
    end
    if p.verbose & p.parallel
        fprintf('Conducting parallel %s demon registration\n', ...
                p.Registration)
    end
    

    registered=ones(size(movingStack));
    if p.parallel
        if isstruct(target) & length(target)>1
            parfor ii=1:size(movingStack,3)
                [registered(:,:,ii),out(ii)]=...
                    apply_demon(movingStack(:,:,ii),target(ii),p);
            end
        else
            parfor ii=1:size(movingStack,3)
                [registered(:,:,ii),out(ii)]=...
                    apply_demon(movingStack(:,:,ii),target,p);
            end
        end
            
    else
        if isstruct(target) & length(target)>1
            target=tmpTarget(ii);
        end            

        for ii=1:size(movingStack,3)
            [registered(:,:,ii),out(ii)]=...
                apply_demon(movingStack(:,:,ii),target,p);
        end
    end

    %Handle the output arguments
    if nargout>0, varargout{1}=registered; end
    if nargout>1
        tmp.before=movingStack;
        tmp.after=registered;
        tmp.routine=regexprep(mfilename,'apply_','');
        tmp.params=p;
        if isnumeric(target), tmp.target=target; end
        for ii=1:size(movingStack,3)
            tmp.coef(ii)=out(ii).coef;
        end
        varargout{2}=tmp;
    end
    if p.verbose & ~p.parallel
        fprintf('\t %2.2f s\n',toc)
    elseif p.verbose
        fprintf('Applied translation correction to %d frames\n',...
                size(movingStack,3))
    end
    return
end





%----------------------------------------------------------------------
% Conduct the registration
if p.verbose & ~p.parallel, fprintf('*'), end
p.verbose=0; %To keep the demon quiet

% Compute coefficients and register movingStack to target if target
% is an image of the same size. If target is a set of coefficients
% then translate movingStack by the specified parameters. 

%EITHER Register images
movingStack=double(movingStack);

if isnumeric(target) 
    target=double(target);
            [registered, coef.Bx, coef.By] = ...
                        register_images(movingStack,target,p);
end


%OR Translate movingStack based on coefficients in target structure
if isstruct(target)
    
    Bx=target.Bx;
    By=target.By;
    coef=target;
    target=[];
    registered=movepixels(movingStack,Bx,By,[], 3);
    
end

%----------------------------------------------------------------------
if nargout>0
    varargout{1}=registered;
end

if nargout>0
    out.before=movingStack;
    out.after=registered;
    out.target=target;
    out.params=p;
    out.routine=regexprep(mfilename,'apply_','');
    out.coef=coef;
    out.params=p;
    varargout{2}=out;
end

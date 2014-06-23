function varargout=apply_ffttrans(movingStack,target,params)
% function [registered,out]=apply_ffttrans(movingStack,target,params)
%
% Purpose
% Apply fft-based translation correction to movingStack (which may
% be a single image or an image time-series. movingStack is aligned
% to target. 
%
% Inputs
% movingStack - A single image or an image time-series which will
%               be aligned with target. 
%
% target - The image used as the reference to which to align
%          movingImage. If target is a coefficients structure
%          produced by this function (contained in the second
%          output argument) then it applies this to movingStack.
%
% params - structure containing parameter values (structure
%          fields) and parameter values (structure field values)
%          for the image registation routines. If not specified,
%          defaults are used. See individual files for the defaults
%          and possible options. Only parameters the user wants to
%          alter need to be defined in the structure.
%
%
% Rob Campbell - August 2012
%
% For details on the algorithm:
% http://www.mathworks.com/matlabcentral/fileexchange/18401


% This function is a wrapper which allows us to conduct the fft-based
% translation correction. We will register each frame with the
% baseline image to within 0.1 pixels by specifying an upsampling
% parameter of 10. Setting this to <2 will screw up the align over
% reps. Very little speed gain will be achieved by changing this
% value.

%----------------------------------------------------------------------
% Handle default options and parameters
p.usfac=2; %upsampling factor higher values can produce finer
           %registrations but they also will smear the shot
           %noise. A value of 1 is not sub-pixel and can induce jittering
p.parallel=1;
p.verbose=0;
if nargin>2
    f=fields(params);
    for ii=1:length(f)
        p.(f{ii})=params.(f{ii});
    end
end

p.parallel=tryParallel(p.parallel); %disable parallel execution if there's a problem




%----------------------------------------------------------------------
% Call the registration routine
%
% It's called recursively here if there's an image-stack. This
% makes the registration code neater since it need not be aware of
% the image stack. 
if size(movingStack,3)>1

    if p.verbose & ~p.parallel
        chalk(sprintf('Applying translation correction [%s]',...
                      repmat('.',1,size(movingStack,3))),1)
        fprintf(repmat('\b',1,1+size(movingStack,3)))
        
    end
    if p.verbose, tic, end

    %Expand the target structure if it has a length of 1 so we can
    %apply the same transformation to all frames of a movie. 

    registered=ones(size(movingStack));
    if p.parallel
        if isstruct(target) & length(target)>1
            parfor ii=1:size(movingStack,3)
                [registered(:,:,ii),out(ii)]=...
                    apply_ffttrans(movingStack(:,:,ii),target(ii),p);
            end
        else
            parfor ii=1:size(movingStack,3)
                [registered(:,:,ii),out(ii)]=...
                    apply_ffttrans(movingStack(:,:,ii),target,p);
            end
        end
        
    else
        if isstruct(target) & length(target)>1
            tmpTarget=target;
        end

        for ii=1:size(movingStack,3)
            if isstruct(target) & length(target)>1
                target=tmpTarget(ii);
            end            
            [registered(:,:,ii),out(ii)]=...
                apply_ffttrans(movingStack(:,:,ii),target,p);
        end
    end

    %re-scale so the range of the movingstack is the same
    registered=registered/max(registered(:));
    registered=registered*max(movingStack(:));

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

% Compute coefficients and register movingStack to target if target
% is an image of the same size. If target is a set of coefficients
% then translate movingStack by the specified parameters. 

%EITHER Register images
if isnumeric(target) 
    if ~any(size(movingStack)-size(target)) 
        targetFFT=fft2(target);
        movingFFT=fft2(movingStack);
        [output,Greg,phase] = ...
            dftregistration(targetFFT,movingFFT,p.usfac);
        OffsetPixel=output([3,4]);
        registered=abs(ifft2(Greg));
    else
        fprintf('Failed to register moving image to target image\n\n\n')
        return
    end

end

%OR Translate movingStack based on coefficients in target structure
if isstruct(target)
    
    %Extract coefficients 
    OffsetPixel=target.OffsetPixel;
    phase=target.diffPhase;
    target=[];

    row_shift=OffsetPixel(1);
    col_shift=OffsetPixel(2);

    movingFFT=fft2(movingStack);

    [nr,nc,~]=size(movingStack);
    Nr = ifftshift([-fix(nr/2):ceil(nr/2)-1]);
    Nc = ifftshift([-fix(nc/2):ceil(nc/2)-1]);    
    [Nc,Nr] = meshgrid(Nc,Nr);

    registered=movingFFT.*exp(i*2*pi*(-row_shift*Nr/nr-col_shift*Nc/nc));
    registered=registered.*exp(-i*phase); 
    registered=abs(ifft2(registered));

end










%----------------------------------------------------------------------
if nargout>0
    varargout{1}=registered;
end

if nargout>1
    out.before=movingStack;
    out.after=registered;
    out.target=target;
    out.routine=regexprep(mfilename,'apply_','');
    out.coef.diffPhase=phase;
    out.coef.OffsetPixel=OffsetPixel;
    out.params=p;
    varargout{2}=out;
end

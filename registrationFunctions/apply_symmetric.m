function varargout=apply_symmetric(movingStack,target,params)
% function varargout=apply_symmetric(movingStack,target,params)
%
% Purpose
% Apply GPU-based non-rigid correction to movingStack (which may
% be a single image or an image time-series. movingStack is aligned
% to target. **This calls the non-symmetric version of the routine**
%
% Inputs
% movingStack  -A single image or an image time-series which will
%               be aligned with target. 
% target - The image used as the reference to which to align
%          movingImage. Does not currently accept a coefficients
%          structure as "target." If the routine becomes useful in
%          the future, this may be added. 
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
%  http://www.mathworks.com/matlabcentral/fileexchange/37685


%----------------------------------------------------------------------
% Handle default options and parameters
p.rho=0.5;
p.lambda=0.1;
p.maxiter=1000;
p.verbose=0;

f=fields(params);
for ii=1:length(f)
    p.(f{ii})=params.(f{ii});
end



%----------------------------------------------------------------------
imSize=size(movingStack);
OffsetPixel=nan(imSize(3),2);
cFFT=fft2(target);
registered=nan(imSize);
diffPhase=ones(1,imSize(3));

if p.verbose
    chalk(sprintf('Applying CUDA-based correction [%s]',...
                  repmat('.',1,imSize(3))))
    fprintf(repmat('\b',1,imSize(3)+1))
    tic
end

target=double(target);
movingStack=double(movingStack);
for ii=1:imSize(3)
    if p.verbose, fprintf('*'), end
    [coef(ii).F_C, coef(ii).F_R, registered(:,:,ii)]=...
     register2(target,movingStack(:,:,ii),p.rho,p.lambda,p.maxiter);
end



if p.verbose
    fprintf('\t %2.2f s\n',toc)
end

%----------------------------------------------------------------------
if nargout>0
    varargout{1}=registered;
end

if nargout>1
    out.before=movingStack;
    out.after=registered;
    out.target=target;
    out.coef=coef;
    out.coef.routine=regexprep(mfilename,'apply_','');
    varargout{2}=out;
end

%% apply_demon
%
% |function varargout=apply_demon(movingStack,target,params)|
%
%% Purpose
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
%% Inputs
% * |movingStack| - A single image or an image time-series which will
%               be aligned with target. 
% * |target| - The image used as the reference to which to align
%          movingImage. If target is a coefficients structure then
%          it applies this to movingStack.
% * |params| - structure containing parameter values (structure
%          fields) and parameter values (structure field values)
%          for the image registation routines. If not specified,
%          defaults are used. See the register_images function that
%          does the demon registration for a full overview of what
%          paramaters are possible. Only parameters the user wants to
%          alter need to be defined in the structure.
%
%% Example
%   p.Registration="NonRigid";
%   im=data(1).imageStack;
%   registered=apply_demon(im,mean(im(:,:,1:4),3),p);
%
%
%% Notes
% You will need to download and compile the demon image registration from:
% <www.mathworks.fr/matlabcentral/fileexchange/21451 www.mathworks.fr/matlabcentral/fileexchange/21451>


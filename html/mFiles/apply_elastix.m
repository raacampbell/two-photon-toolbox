%% apply_elastix
%
% |function [registered,out]=apply_elastix(movingStack,target,params)|
%
%% Purpose
% Apply elastix registration (rigid, affine, or non-rigid)
% correction to movingStack (which may be a single image or an
% image time-series. movingStack is aligned to target. 
%
%
%% Inputs
% * |movingStack| - A single image or an image time-series which will
%               be aligned with targetImage. 
% * |target| - The image used as the reference to which to align
%          movingImage. If target is a coefficients structure
%          produced by this function (contained in the second
%          output argument) then it applies this to movingStack.
% * |params| - structure containing parameter values for the
%          registration. This can have a length>1, in which case
%          these structures are treated as a request for multiple
%          sequential registrations. The identity of the transform
%          type is defined here. The possible values for fields in
%          the the structure can be found in elastix_parameter_write
%          In addition, the parameters struction can contain the
%          following fields. If these are not defined, default
%          values are used. These need only be present in
%          the first element of the structure. 
% * |params.parallel| - 1 by default. Runs registrations in parallel,
%           subject to standard constraints (Toolbox availablility,
%           labs already connected, etc). 
% * |params.verbose| - 1 by default. If 0 the analysis is run silently. If
%          2, more information is provided. 
% * |params.keepTMP| - 0 by default. If 1, the temporary data directories
%          created by the wrapper are not deleted. 
%
%
%% Notes
% # You will need to download the elastix binaries (or compile the source)
% from: http://elastix.isi.uu.nl/ There are versions for all
% platforms. 
% # Not yet tested on Windows. Works on Mac and Linux. For Windows
% you will need to install Elastix and somehow add it to your
% path. 
% # Read the elastix website and <elastix_parameter_write.html |elastix_parameter_write|> 
% to learn more about the parameters that can be modified. There are
% many registration options available and you will likely need to
% do a bit of hacking in these files in order to get the most out
% of it.

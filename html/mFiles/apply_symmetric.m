%% apply_symmetric
%
% |function varargout=apply_symmetric(movingStack,target,params)|
%
%% Purpose
% Apply GPU-based non-rigid correction to movingStack (which may
% be a single image or an image time-series. movingStack is aligned
% to target. **This calls the non-symmetric version of the routine**
%
%% Inputs
% * |movingStack|  -A single image or an image time-series which will
%               be aligned with target. 
% * |target| - The image used as the reference to which to align
%          movingImage. Does not currently accept a coefficients
%          structure as "target." If the routine becomes useful in
%          the future, this may be added. 
% * |params| - structure containing parameter values (structure
%          fields) and parameter values (structure field values)
%          for the image registation routines. If not specified,
%          defaults are used. See individual files for the defaults
%          and possible options. Only parameters the user wants to
%          alter need to be defined in the structure.
%
%% Algorithm
%  http://www.mathworks.com/matlabcentral/fileexchange/37685


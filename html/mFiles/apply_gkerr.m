%% apply_gkerr
%
% |function [registered,out]=apply_gkerr(movingStack,target,params)|
%
%% Purpose
% Apply Greenberg & Kerr 2-photon correction to movingStack (which may
% be a single image or an image time-series. movingStack is aligned
% to target. 
%
%% Inputs
% * |movingStack| - A single image or an image time-series which will
%               be aligned with target. 
% * |target| - The image used as the reference to which to align
%          movingImage. 
%
%
%% Run with options
% |apply_gkerr(movingStack,target,'Param1',value1,'Param2',value2)|
%
% Options with defaults defined as parameter/value pairs:
% 
% * 'tdivn'      - size(Template,2)/2
% * 'conv_critn' - 1e-1
% * 'cor_critn'  - 0.975
% * 'numloops'   - 50
% * 't1pxl'      - 2e-6
% * 'verbose'    - 0
%
%
%% Credits
% Journal of Neuroscience Methods 176(2009) 1-15. Original implementation by Ko Ho from Tom Mrsic-Flogel's lab. Called here with very minor modifications in correctstack_GandKerr


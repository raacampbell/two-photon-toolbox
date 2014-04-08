%% apply_ffttrans
%
% |function [registered,out]=apply_ffttrans(movingStack,target,params)|
%
%% Purpose
% Apply fft-based translation correction to movingStack (which may
% be a single image or an image time-series. movingStack is aligned
% to target. 
%
%% Inputs
% * |movingStack| - A single image or an image time-series which will
%               be aligned with target. 
% * |target| - The image used as the reference to which to align
%          movingImage. If target is a coefficients structure
%          produced by this function (contained in the second
%          output argument) then it applies this to movingStack.
% * |params| - structure containing parameter values (structure
%          fields) and parameter values (structure field values)
%          for the image registation routines. If not specified,
%          defaults are used. See individual files for the defaults
%          and possible options. Only parameters the user wants to
%          alter need to be defined in the structure.
%
%% Algorithm
% http://www.mathworks.com/matlabcentral/fileexchange/18401

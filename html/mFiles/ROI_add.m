%% ROI_add
% Append a new ROI to the ROI structure of the twoPhoton object
%
% |function data=ROI_add(data,notes)|
%
%% Purpose
%  Add a new region of interest to the data structure. 
%
%% Inputs
% * |data| - the twoPhoton object
% * |notes| - an optional text string with which to identify the
%          ROI. If this text string already exists, then this ROI is
%          updated (replaced) with the one the user now selects.
%
%% Outputs
% * |data| -  the data structure with added ROI. This means that 
% |length(data.ROI)| increases by 1 following application of this function. 

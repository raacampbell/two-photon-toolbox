%% whichROIsAreSignificant
% Show how many times each ROI (e.g. cell body) responded significantly
%
% |function whichROIsAreSignificant(data,ROIindex)|
%
%% Purpose
% Loop through the twoPhoton array and group together responses to
% each odour then make a color plot showing how many times each KC
% responded significantly to each odour. 
%
%% Inputs
% * |data| - twoPhoton object
% * |ROIindex| - the index of the ROI structure for which stats should
% be calculated. By default it finds the field named 'soma' and
% calculates stats for that. This variable is optional and can be
% an index or a string (it looks up the ROI names in ROI.notes).
%
%
%% Example
%
cd ~/work/Matlab_Scripts/ImagingAnalysis/examples/
load KCexample.mat
whichROIsAreSignificant(data)

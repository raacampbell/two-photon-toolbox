%% roiTimeCourse
% mean pixel intensity over time from a defined ROI
%
% |function timeCourse=roiTimeCourse(imageStack,ROI)|
%
%% Purpose
% Calculates mean pixel intensity over time in a defined ROI from
% an imageStack time series.
%
%% Inputs
% * |imageStack| - a 3-D matrix (stack) of frames with time as the 3rd
%  dimension.
% * |ROI| - a 2-D mask of dimensions |size(imageStack)| by
%  |size(imageStack,2)|.
%
%% Outputs
% * |timeCourse| - a vector of mean pixel intensities within the ROI
%              taken along the 3rd dimension of imageStack. 
%
%% Example 
cd ~/work/Matlab_Scripts/ImagingAnalysis/examples/
load KCexample.mat
plot(roiTimeCourse(data(5).imageStack, ...
                   data(5).ROI(1).roi))
%% Also See
% <responseTimeCourse.html |responseTimeCourse|>

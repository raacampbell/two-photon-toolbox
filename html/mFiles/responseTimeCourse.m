%% responseTimeCourse
% Plot response time course of an ROI
%
% |function out=responseTimeCourse(data,roiIndex,doPlot)|
%
%% Purpose
% Plots the response time course (both dF/F and raw mean) over the
% whole ROI over time. Different ROIs can be specified. Note that
% the dF/F is calculated *over the whole roi*, not pixelwise as in
% |data.dff|. This approach is less noisy. The response time course
% is also smoothed. 
%
%% Inputs
% * |data| - one element of the twoPhoton data structure
% * |roiIndex| - if it's a scalar then this corresponds to data.ROI(roiIndex)
%   It can also be a matrix of size: size(data.imageStack(:,:,1))
%   If roiIndex is missing or empty then it is 1 by
%   default. Note that all matrix elements >1 are simply
%   set to 1, so you can feed the select KC matrix into
%   this function if needed. 
% * |doPlot| - show the plots (optional, 1 by default; 0 supresses
%   plotting)
%
%% Outputs
% * |out| - structure containing plotted data. 
%
%% Example
cd ~/work/Matlab_Scripts/ImagingAnalysis/examples/
load KCexample.mat
responseTimeCourse(data(1))

%% Also see
% <roiTimeCourse.html |roiTimeCourse|>

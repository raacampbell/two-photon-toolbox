%% showSelectedKCs
% Overlay selected KCs onto a mean image of the stack
%
% |function showSelectedKCs(data,label)|
%
%% Purpose
% Overlay the selected neuronal cell body ROIs onto a mean image of
% the brain. 
%
%% Inputs
% * |data| - twoPhoton object following processing with selectKCs
% * |label| - optional [zero by default]. If 1 then add numeric labels
%   to each circled KC/ROI. 
%
%% Example
cd ~/work/Matlab_Scripts/ImagingAnalysis/examples
load KCexample.mat
set(gcf,'inverthardcopy','off')
showSelectedKCs(data(1))

%% Also See
% <kcMaskPlot.html |kcMaskPlot|>

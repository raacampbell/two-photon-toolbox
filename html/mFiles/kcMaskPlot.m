%% kcMaskPlot
% Show activation of each cell in the mask using different colours.   
%
% |function kcMaskPlot(data)|
%
%% Purpose
% Plot the outline of the main ROI and overlay the locations of the
% selected KCs. Fill those cells which responded
% signficantly. Colour-code the fills according to response
% magnitude of each cell. 
%
%% Inputs
% * |data| - one trial of the |twoPhoton| object which has been
% processed by <KCdFF.html KCdFF> (i.e. you have run
% <addKC_stats.html addKC_stats>). 
%
%% Example
cd ~/work/Matlab_Scripts/ImagingAnalysis/examples
load KCexample.mat
set(gcf,'inverthardcopy','off')
kcMaskPlot(data(1))

%% Also See
% <showSelectedKCs.html |showSelectedKCs|>
  

%% neuronMeanVar
% mean and variance within stimulus for each cell
%
% |function out=neuronMeanVar(data,doPlot)|
%
%% Purpose
% Calculate the mean and variance within stimulus for each
% neuron. Segregate neurons according to whether they were deemed
% significant or non-significant. 
%
%% Inputs
% * |data| - the twoPhoton data structrue
% * |doPlot| - optional, 1 by default
%
%% Ouputs
% * |out| - a structure containing the data plotted.
%
% The structure contains the following fields:
%
% * |plotData| - This is the matrix plotted by
% <plotKCtuningCurves.html |plotKCtuningCurves|>.
% * |rawData| - The raw data on which the tuning curves were
% based. 
% * |sigResponses| - A matrix of nans the same size as |rawData|
% with ones representing significant frames. 
% * |neuronIndex| - In the matrices above neurons are sorted by
% signficance. The original indecies of the neurons are stored in
% this vector. 
% * |std| - SD of response magnitude for each neuron. 
% * |nSig| - Number of significant frames for each neuron for each
% stimulus. 
% * |n| - number of neurons
% * |sigInd| - Indecies of significantly responding neurons. In
% this instance, a neuron is deemed significant if it responds
% significantly to one stimulus at least half the time.
% * |s| - The number of signficantly responding cells. 
% * |propSig| - The proportion of cells to respond signficantly. 
% * |thresh| - The significance threshold
%
% Note that the output of this function is more or less like
% plotKCtuningCurves output with some additional fields.  
%
%% Example
cd ~/work/Matlab_Scripts/ImagingAnalysis/examples
load KCexample.mat
clf
neuronMeanVar(data);
%%
% Red points are those from significantly responding neurons. 
%
%% Also Seea
% <nNeurons2p.html |nNeurons2p|>, <ROI_responseMatrix.html
% |ROI_responseMatrix|>, <plotROItuningCurves.html |plotROItuningCurves|>

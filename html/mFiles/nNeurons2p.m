%% nNeurons2p
% Return neural summary statistics 
%
% |function out=nNeurons2p(data)|
%
%% Purpose
% Return summary statistics for the number of neurons, etc, from
% the data array. *Note*: This function simple statistics, such as the total
% number of significant respones, etc. It also works from individual
% elements of the structure. To obtain more elaborate results one might
% want to use neuronMeanVar, which attempts to gauge neuron significance based
% upon the number of significant responses to the same odour, etc. 
%
% This is a very simple-minded function. A more elaborate version
% of the same thing can be found in <neuronMeanVar.html |neuronMeanVar|>.
%
%% Inputs
% * |data| - |twoPhoton| data structure.
%
%% Outputs
% * |out| - structure containing relevant information:
%
% * |out.n| - Number of neurons
% * |out.sigNeurons| - indecies of significantly responding
% neurons. These are neurons which responded significantly at least
% once. 
% * |out.pSig| - proportion of neurons to respond significantly 
%



cd ~/work/Matlab_Scripts/ImagingAnalysis/examples/
load KCexample.mat
nNeurons2p(data)

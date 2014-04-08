%% odour3Dplot
% 3-D PC plot of each stimulus
%
% |function odour3Dplot(data,corrdist,odourColors,odourIndex)|
%
% Make a 3-D plot of the neural responses in MDS space. 
% This function can be called from odourDendrogram to provide a 3-D
% plot where colours are related to the dendrogram linkage
% level (|odourIndex|). With the |odourIndex| not defined, colours are
% related to odour indentity. 
%
%
%% Inputs: 
% * |data| - is the twoPhoton object
% * |corrdist| - [optional, can be empty] is the distance matrix we will work with. 
% * |odourColors| - [optional] is the colour scheme 
% * |odourIndex| - [optional] is the colour from the scheme to applied to each odour
%
%% Example
cd ~/work/Matlab_Scripts/ImagingAnalysis/examples
load KCexample.mat
clf
odour3Dplot(data);

%% Also See
% <odourDendrogram.html |odourDendrogram|>


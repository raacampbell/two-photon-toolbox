%% odourDendrogram
% dendrogram showing response relatedness
%
% |function odourDendrogram(data,linkageLevel)|
%
% How are responses to different odours/stimuli related? Visualise this
% using a dendrogram and MDS. 
%
%% Inputs
% * |data| - the twoPhoton object once we have run
% <addKC_stats.html |addKC_stats|> on it. 
%
%% Example
cd ~/work/Matlab_Scripts/ImagingAnalysis/examples
load KCexample.mat
clf
odourDendrogram(data,2);
%%
% Numbers in square brackets indicate the number of significantly
% responding neurons on that trial. 
%
%% Also See
% <odour3Dplot.html |odour3Dplot|>

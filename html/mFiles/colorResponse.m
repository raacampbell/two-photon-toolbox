%% colorResponse
% colour-coded maximum intensity projection of a time-series
%
% |function colorResponse(data)|
%
%% Purpose
% Makes a max intensity projection of the dF/F over time and color
% codes it according to time then super-imposes it over the raw
% image. The colour scale isn't particularly meaningful but the
% images are pretty. 
%
%% Example
% Comparing three ways of showing the same data:
cd ~/work/Matlab_Scripts/ImagingAnalysis/examples
load KCexample.mat
%%
% The mean response (also see |data(1).info.muStack|)
clf, colormap gray
imagesc(mean(data(1).imageStack,3)), axis equal off
%%
% Mean dF/F
imagesc(mean(data(1).dff,3)), axis equal off
%%
% The "color response"
colorResponse(data(1))


%% Also See
% <colorDepth.html |colorDepth|>

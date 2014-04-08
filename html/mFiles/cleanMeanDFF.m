%% cleanMeanDFF
% Calculate a reduced-noise mean dF/F during the response 
%
% |function muInt=cleanMeanDFF(data)|
%
%% Purpose
% Calculate the mean dF/F during the response period. This function
% tries to clean this up as best as possible using smoothing and
% statistical criteria.  
%
%% Inputs
% * |data| - one trial extracted from the |twoPhoton| object
%
%% Outputs
% * |muInt| - a 2-d matrix containing the response image
%
%% Example

cd ~/work/Matlab_Scripts/ImagingAnalysis/examples/
load KCexample.mat

im=data(1).dff;
clf
subplot(1,2,1)
imagesc(mean(im,3)), axis equal off
title('raw mean dF/F')
subplot(1,2,2)
imagesc(cleanMeanDFF(data(1))), axis equal off
title('clean dF/F')
colormap gray

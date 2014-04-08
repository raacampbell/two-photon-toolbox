%% imageStackCorr
% plots correlation between 1st and later frames from one trial
%
% |function out = imageStackCorr(imageStack)|
%
%% Purpose
% plots the correlation between the first frame and later frames
% from one stimulus presentation. This is used to help diagnose
% motion artefacts
%
%% Inputs
% |imageStack| - an image-stack
%
% |ref| - the image with respect to which the xcorr will be
% performed. 
%
% * If ref is a scalar then correct imStack with respect to
% |imStack(:,:,ref)|
% * If ref has length==2 then correct imStack with respect to
% |imStack(:,:,ref(1):ref(2))|
% * If ref is a 2-d matrix then correct imStack with respect to
% this.   
%
%% Outputs
% |out| - the change in correlation over time (starting from frame 2)

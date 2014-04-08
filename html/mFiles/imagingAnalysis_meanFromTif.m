%% meanFromTif
% Calculate mean of a multi-image tiff 
%
% |function mu=meanFromTiff(fname)|
%
% Purpose
% Calculate the mean of an image stack stored in a tiff by loading
% each frame individually. This means we don't have to load a
% single large tiff in one go. 

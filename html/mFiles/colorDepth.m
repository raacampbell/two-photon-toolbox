%% colorDepth
% Produce colour-coded depth plot of a z-stack
%
% function imageMatrix=colorDepth(imageMatrix,cmap,bitDepth)
%
%% Purpose
% A clone of the colour-coded PrairieView depth view. Different
% depths are coded as different colours. When applied to a time
% series, can be used to highlight neural activation times as
% different colours. 
%
%% Inputs
% * |imageMatrix| - a 3-D matrix containing an image-stack or
% z-stack. 
% * |cmap| -[optional] a colormap matrix. If not defined, a jet
% colour scheme is used. 
% * |bitDepth| - [optional] zero by default. If zero, imageMatrix
% contains numbers from zero to one only. If imageMatrix contains
% non-normalised raw data then we can use bitDepth to normalise by
% the bit depth. 
% 
%% Output
% |imageMatrix| - [optional] returns the image matrix. 
%
%% Also See
% <colorResponse.html |colorResponse|>

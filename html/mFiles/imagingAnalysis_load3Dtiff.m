%% load3Dtiff
% Load multi-image tiff from disk 
% 
% |function [imageStack,imageInfo]=load3Dtiff(FileName)|
%
%% Purpose
% Load a 3D stack (e.g. those exported by ImageJ) as a 3-D matrix. 
% If you have multiple channels then you may need to separate these
% manually since ImageJ will interleave them. 
%
%% Inputs
% * |FileName| - a string specifying the full path to the tif you wish
% to import.  
%
%% Outputs
% * |imageStack| - a 3-D matrix of frames extracted from the file. 
% * |imageInfo| - lots of information about the images [optional]
%
%% Notes
% We will output a matrix of singles since double precision
% isn't needed and takes up twice the space. You may, therefore,
% need to convert to double from time to time.

%% importSItree
% Import data from multiple ScanImage data directories 
%
% |function importedFiles=importSItree(directory)|
%
%% Purpose
% Imports data from all ScanImage data sub-directories within a
% directory. ScanImage saves each stimulus repeat in its own tiff
% file. importScanImage will import just one tiff file. This
% function treats all tiffs in the same directory as a single
% session/experiment. So it imports them and pools them into the same
% data structure. 
%
%% Inputs
% * |directory| - An optional string specifying the full path to the
%  data. e.g. '/home/work/imaging/Fly001/' This directory should
%  contain one or more sub-directories each containing at least one
%  ScanImage tif file. If no input is specified then a file
%  dialogue is presented. 
%
%% Outputs
%  A list of imported files. This function saves data to mat files within
%  the specified directory. 
%
%% Warnings
%  May not work on a non-unix filesystem.   

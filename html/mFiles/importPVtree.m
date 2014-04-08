%% importPVtree
% Import data from multiple Prairie view data directories 
%
%  |function importedFiles=importPVtree(directory)|
%
%% Purpose
% Imports data from all the Prairie data sub-directories within a
% directory. 
%
%% Inputs
% * |directory| - an *optional* string specifying the full path to the
% data. e.g. '/home/work/imaging/Fly001/' This directory should
% contain one or more sub-directories each containing tif files and a
% single .xml describing the imaging session. If no input is
% specified then a file dialogue is presented. 
%
%% Outputs
% A list of imported files. This function saves data to mat files within
% the specified directory. 
%
%% Note
% May not work on a non-unix filesystem  


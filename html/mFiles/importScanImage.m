%% importScanImage
% Import a tiff generated by ScanImage
%
% |function data=importScanImage(fname,index)|
%
%% Purpose
% ScanImage saves each trial as a separate multi-image tiff. This
% file imports one of these tiffs, saving it as a .mat file for
% using with subsequent functions. It also creates a data structure
% which can be turned into a twoPhoton object.
%
%% Inputs
% * |fname| - a string indicating which file to load. ** If fname is a 
%   directory, then the function imports all tiff files in that directory. 
% * |index| - the index in the structure into which this data will be
%   stored. index is optional and ==1 by default.
%
%% Examples:
% # Import all SI tiffs in the current directory
% |data=importScanImage| or  |data=importScanImage(pwd)|
% # Import just one tiff file
% |data=import('rep001.tif')|
% # Import just one tiff file and treat is at the second repeat
% |data=import('rep001.tif',2)|
% # Finally, if the user enters a twoPhoton object as the first
% argument then we 


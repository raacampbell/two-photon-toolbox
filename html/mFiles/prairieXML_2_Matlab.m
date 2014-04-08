%% prairieXML_2_Matlab
% Import PrairieView XML and image-stacks to Matlab
%    
% |function data=prairieXML_2_Matlab(FileName)|
%
%% Purpose
% Imports the data in a PraireView XML file (tested with versions
% 3 and 4) and associated image files. Creates a data structure
% with the data. Tested with 1 and 2 channel data. Works with both
% T-Series and Z-Series. Doesn't import line-scan data. 
%  
%% Inputs
% * |FileName| [optional] - a string specifying the name of the XML
%  file to import. The raw-data tiff files and the XML file should
%  be in the current directory. If run no arguments are given, the
%  function tries to find an XML file in the current directory. 
%  extractInfoOnly [optional] - if 1 we only extract information
%  and not import images. 0 by default. 
%
%% Outputs  
% * |data| - this function returns an object of class twoPhoton that
%  contains the meta data present in the XML file. The image stacks
%  are saved in the current directory as mat files. Each mat file
%  contains data from one image stack as a 3-D matrix (if we have
%  only one channel and depth). These are names rawDataX.mat, where
%  'X' represents the index of the recording. The twoPhoton
%  structure transparently accesses the rawData files.
%    
%% Notes
% Confocal and 2-photon image stacks will be indexed images (typically
% 12 or 16 bit). Many functions in the MathWorks Image Processing
% toolbox expect the image to be a matrix of doubles with pixel
% intensities between 0 and 1. This function will therefore normalise
% the image so imageStack it is no longer indexed. We divide by the
% bit depth of the image. *However* we will output a matrix of
% singles since double precision isn't needed and takes up twice the
% space. You therefore need to convert to double from time to time.
%
%% Also See
% <generateDFFobject.html |generateDFFobject|>,
% <twoPImportBatch.html |twoPImportBatch|>

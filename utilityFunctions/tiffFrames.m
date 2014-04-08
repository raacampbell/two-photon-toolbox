function j=tiffFrames(fname)
%Iteratively find the number of slices in a tiff
%
% Inputs
% * fname - file name of tiff in question
%  
% from Eran Mukamel, 2009
% Modified April 9, 2013 for compatibility with MATLAB 2012b

j = length(imfinfo(fn));
   

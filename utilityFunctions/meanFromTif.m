function mu=meanFromTif(fname)
% Calculate mean of a multi-image tiff 
%
% function mu=meanFromTiff(fname)  
%
% Purpose
% Calculate the mean of an image stack stored in a tiff by loading
% each frame individually. This means we don't have to load a
% single large tiff in one go. 
%
% Rob Campbell
  

frames=tiffFrames(fname);


mu=double(imread(fname,1));
for ii=2:frames
  mu=mu+double(imread(fname,ii));
end

mu=mu/frames;

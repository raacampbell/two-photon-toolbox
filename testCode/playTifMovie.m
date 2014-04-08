function playTifMovie(fname)
% Play the frames in a tiff from disk as a movie
%
% function playTifMovie(fname)
%
% Inputs
% * fname - full path to multi-frame tiff 
%
%

frames=tiffFrames(fname);

for i=1:frames
  imagesc(imread(fname,i));
  axis off
  drawnow
end



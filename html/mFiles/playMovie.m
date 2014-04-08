%% playMovie
% Play a movie of an imageStack
% 
% |function playMovie(imageStack,frameRate,loop,noClear)|
%
%% Purpose
% Plays a movie of the image data in the 3-d matrix 'imageStack' image
% stack where 3rd dimension may be time or z.
%
%% Inputs
% * |imageStack| - a 3-D matrix
%   if a cell array of equally sized matrices then these are joined
%   together and displayed simultaneously
% * |frameRate| - [optional, 0.05 by default] how fast to attempt to
% play the movie.  (if frameRate is a string then save the movie in the
% current directory).
% * |loop| - [optional, 1 by default]. if loop is true then play
% movie continuously.
% * noClear [optional, 0 by default] - don't clear the figure window

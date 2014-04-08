%% patch2blender
% Convert image stack to blender format
%
% |function patch2blender(v,f,fname)|
%
%% Purpose
% Save a set of vertice coordinates and faces from a patch object
% as a Wavefront/Alias Obj file that can be read by blender. 
%  
%% Inputs
% * v is a Nx3 matrix of vertex coordinates.
% * f is a Mx3 matrix of vertex indices. 
% * fname is the filename to save the obj file.
%
%% Example
%  [f,v]=isosurface(imageStack,0);
%  patch2blender(v,f,'gyroid.obj')


function plotKCvolume(stats,nCells,radius)
% Produces schematized plot of cell body positions in 3D space
%
% function plotKCvolume(stats,nCells,radius)
%
% Inputs
% stats  - output of findNuclei containing the centroids of identified KCs
% nCells - optional, limit plotting to the first nCells in the series
% radius - optional, radius of plotted spheres in pixels.  Either a scalar
%          pixel value or 'scaled' may be specified.  'Scaled' state maps 
%          the sphere radius to the detected size of the cell.  Default 
%          is 4px.

if nargin < 3
    radius = 4; %4 pixel radius for spheres
end

if nargin < 2
    nCells = length(stats);
end

clf
if strmatch('scaled',radius)
    for i=1:nCells
        volume = stats.props(i).Area;
        radius = round((volume/((4/3)*pi))^(1/3));
        [x y z] = sphere(5);
        x = x*radius;
        y = y*radius;
        z = z*radius;
        ctrs = round(stats.centroid(i,:));
        col = (i/nCells)*ones(size(z));
        surf(x+ctrs(1),y+ctrs(2),z+ctrs(3),col)
        hold on
    end
    
else
    [x y z] = sphere(5);
    x = x*radius;
    y = y*radius;
    z = z*radius;
    

    for i=1:nCells
        ctrs = round(stats.centroid(i,:));
        col = (i/nCells)*ones(size(z));
        surf(x+ctrs(1),y+ctrs(2),z+ctrs(3),col)
        hold on
    end
end

shading('flat')
light('Position',[1024 1024 1000],'Style','infinite');
lighting('flat')
daspect([1 1 1])

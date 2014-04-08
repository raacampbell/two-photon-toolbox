%% pixelFlow 
% Downslope flow direction for DEM pixels
%
%% Description
% |[R, S] = pixelFlow(E, i, j, d1, d2)| computes the flow direction and slope
% for specified pixels (|i| and |j|) of a digital elevation model (|E|). |E| is
% a matrix of elevation values.  |i| and |j|, which must be the same size, are
% the row and column coordinates of the specified pixels.  |d1| and |d2| are the
% horizontal and vertical pixel center spacing.  |d1| and |d2| are optional; if
% omitted, a value of 1.0 is assumed.
%
% The specified pixels cannot be on the border of |E|.  In other words, |i|
% must be greater than 1 and less than |size(E, 1)|, and |j| must be greater
% than 1 and less than |size(E, 2)|.
%
% |R|, which is the same size as |i| and |j|, contains the pixel flow direction
% in radians.  Pixel flow direction is measured counter clockwise from the
% east-pointing horizontal axis.  |R| is NaN for each pixel that has no
% downhill neighbors. 
%
% |S|, which is the same size as |i| and |j|, is the downward slope along the
% pixel flow direction.  Negative values indicate that the corresponding
% pixels have no downhill neighbors.
%
% *Note:* Connected groups of NaN pixels touching the border are treated as
% being at a higher elevation than all the other pixels in |E|.
%
%% Reference
% Tarboton, "A new method for the determination of flow
% directions and upslope areas in grid digital elevation models," _Water
% Resources Research_, vol. 33, no. 2, pages 309-319, February 1997. 
%
%% Examples
% Flow from the center pixel goes to the right, so the pixel flow
% direction is 0 radians.
%
E1 = [2 1 0; 2 1 0; 2 1 0]
R1 = pixelFlow(E1, 2, 2)

%%
% Flow from the center pixel goes to the upper right, so the pixel
% flow direction is pi/4 radians.
%
E2 = [2 1 0; 3 2 1; 4 3 2]
R2 = pixelFlow(E2, 2, 2)

%%
% The center pixel has no downhill neighbors, so the pixel flow
% direction is NaN.
%
E3 = [2 2 2; 2 1 2; 2 2 2]
R3 = pixelFlow(E3, 2, 2)

%% See also
% <demFlow_help.html |demFlow|>, <facetFlow_help.html |facetFlow|>.

%% 
% Copyright 2007-2009 The MathWorks, Inc.
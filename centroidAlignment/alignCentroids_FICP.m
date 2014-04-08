function shifted=alignCentroids_FICP(A,B,doPlot)
% Align centroids in B with those in A. Returns matrix B such that
% it is aligned with A. 
%
% function shifted=alignCentroids_FICP(A,B,doPlot)
%
% Uses a finite iterative closest point algorith which allows the
% basic 10 degrees of freedom: translation (3), rotation (9), and
% scale (1); plus the optional posibility of an affine transform
% which adds shear. This routine does not expect the same number of
% data points in the two groups. 
%
% Inputs
% * A and B are 3 by n matrices
% * doPlot [0 be default] displays the alignment.
% 
%

if nargin<3, doPlot=0; end

Options.Registration='Affine';
[shifted,R]=ICP_finite(A,B);

if doPlot
    clf
    subplot(1,2,1), plotSets(A,B)
    subplot(1,2,2), plotSets(A,shifted)
end





function plotSets(A,B)


plot3(A(:,1),A(:,2),A(:,3),'ok'), view(3)
hold on
plot3(B(:,1),B(:,2),B(:,3),'.r'), view(3)
hold off
%axis equal 
box on


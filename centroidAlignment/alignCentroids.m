function shifted=alignCentroids(A,B,doPlot)
% Align centroids in B with those in A. Returns matrix B such that
% it is aligned with A. 
%
% function shifted=alignCentroids(A,B,doPlot)
%
% Inputs
% * A and B are 3 by n matrices
% * doPlot [0 be default] displays the alignment.
% 


%A and B must be the same lengths
sA=size(A,1);
sB=size(B,1);
delta=sA-sB;

if delta>0
    B=[B;rand(delta,3)];
    %    B=[B;repmat(mean(B,1),delta,1)];
elseif delta<0
    delta=abs(delta);
    A(end+delta,:)=repmat(mean(A,1),delta,1);
end

if size(A,2)==3, A=A'; end
if size(B,2)==3, B=B'; end
[s,R,T,err]=absoluteOrientationQuaternion(B,A);


shifted=transform(B,s,R,T);

clf
subplot(1,2,1), plotSets(A,B)
title(sprintf('error=%0.1f',residualError(A,B)))
subplot(1,2,2), plotSets(A,shifted)
title(sprintf('error=%0.1f',err))


function out=transform(in,s,R,T)
out=s*R*in+repmat(T(:),1,size(in,2));


function plotSets(A,B)

plot3(A(1,:),A(2,:),A(3,:),'ok'), view(3)
hold on
plot3(B(1,:),B(2,:),B(3,:),'.r'), view(3)
hold off
axis equal 
box on


%Compute the residual error as done in the absoluteOrientation function
function err=residualError(A,B)
err =0;
for ii=1:size(A,2)
  d = B(:,ii) - A(:,ii);
  err = err + norm(d);
end      


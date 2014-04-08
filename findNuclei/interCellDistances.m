function stats = interCellDistances(stats)
% Calculates all pairwise distances between centroids
%
%  function dist = interCellDistances(stats)
%
% Inputs
% stats   - output of findNuclei from which we extract the centroids
%           of identified cells
%
% Outputs
% stats   - We add to the stats structure all pairwise distances between
%           centroids, in microns, as computed by pdist.
%
% e.g. to find the furthest pair
%  d=interCellDistances;
%  f=find(d.distances(:)==max(d.distances(:)));
%  [ii,jj]=ind2sub(size(d.distances),f);
%  plot(d.centroid(:,1),d.centroid(:,2),'ok')                 
%  hold on 
%  plot(d.centroid(ii,1),d.centroid(ii,2),'ro') 
%  plot(d.centroid(jj,1),d.centroid(jj,2),'ro') 
%  hold off
%
% Rob Campbell - August 2010


%The centroids
cens=stats.centroid;

%Convert centroid pixel positions to microns
cens = cens.*repmat(stats.resolution(1:size(cens,2)),length(cens),1);


%Calculate the distance between centroids
dist = squareform(pdist(cens));


dist=triu(dist);
dist(dist==0)=nan; %No actual distances will be zero. 


stats.distances=single(dist);

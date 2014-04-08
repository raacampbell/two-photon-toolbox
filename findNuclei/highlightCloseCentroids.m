function stats=highlightCloseCentroids(stats,diams,doPlot)
% Highlight centroids which seem to be too close together. 
%
% function stats=highlightCloseCentroids(stats,diams,doPlot)
% 
% Adds indecies of centroids which may need merging
% 
% Rob Campbell - August 2010

if nargin<2 | isempty(diams), diams=0.5; end
if nargin<3, doPlot=[]; end


if doPlot
    clf
    plot3(stats.centroid(:,1),...
          stats.centroid(:,2),...
          stats.centroid(:,3),...
          '.k')
    box on
end





f=find(stats.distances(:)<stats.cellDiam*diams);

[II,JJ]=ind2sub(size(stats.distances),f);
ind=[II,JJ];

stats.closeCentroids=ind;

if doPlot
    hold on
    for ii=1:length(f)
        plot3(stats.centroid(ind(ii,:),1),...
              stats.centroid(ind(ii,:),2),...
              stats.centroid(ind(ii,:),3),...
              'or')
    end
    hold off
    title(sprintf('%d cells may need merging',length(f)))
end


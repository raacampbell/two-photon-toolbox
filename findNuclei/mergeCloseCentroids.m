function stats=mergeCloseCentroids(stats)
%
%
% function stats=mergeCloseCentroids(stats)
%
%
% Merge the centroids which appear to be close



for ii=1:length(stats)

    ind=stats(ii).closeCentroids;
    if isempty(ind), continue, end
    
    for jj=1:size(ind,1)
        mu=mean(stats(ii).centroid(ind(jj,:),:),1);
        stats(ii).centroid(ind(jj,1),:)=mu;
    end
    
    stats(ii).centroid(ind(:,2),:)=[];
    stats(ii).closeCentroids=[];

end

    

dfunction showTSeriesNuclei(imageStack,stats)
% function showTSeriesNuclei(data,stats)
%
% stats is output of the findNuclei function


clf
imagesc(mean(imageStack,3))

hold on
for ii=1:length(stats)
    plot(stats(ii).centroid(:,1),stats(ii).centroid(:,2),'.r');
    
    if ~isempty(stats(ii).closeCentroids)
        plot(stats(ii).centroid(stats(ii).closeCentroids,1),...
             stats(ii).centroid(stats(ii).closeCentroids,2), ...
             '.g');
    end
end
hold off

colormap gray

axis equal off


function [stats,mu]=alignTZseries(stats)
% function stats=alignTZseries(stats)
%
% Align a TZ-series


%Show some before and after stats

clf
subplot(1,2,1), mu=meanDrift(stats);
drawnow

for ii=2:length(stats)
    shifted=alignCentroids_FICP(stats(ii-1).centroid,...
                                stats(ii).centroid);
    
    stats(ii).centroid=shifted;
end

subplot(1,2,2), meanDrift(stats);


function mu=meanDrift(stats)
mu=[];
for ii=1:length(stats);
    mu=[mu;mean(stats(ii).centroid,1)];
end

hold on
plot(mu(:,1)-mean(mu(:,1)),'-r')
plot(mu(:,2)-mean(mu(:,2)),'-b')
plot(mu(:,3)-mean(mu(:,3)),'-k')
hold off

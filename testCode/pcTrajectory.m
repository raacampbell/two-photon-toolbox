function pcTrajectory(data)
%  function pcTrajectory(data)
%
% Purpose
% very simple function which plots the trajectory of the neural
% population in PC space to one odour. 
%
% Inputs
% data - the twoPhoton object (one instance only)
%
% 
% Rob Campbell, September 2009
  
  
kc=data.KCstats.kcDFF;

[eigenvectors,weights,eigenvalues]=princomp(kc');







clf
colors=jet(size(weights,1));
hilightStyle={'or','markersize',15,'linewidth',3};

subplot(1,2,1)
timeCourse=roiTimeCourse(data.imageStack,data.ROI.roi);
plot(timeCourse,'ok-','markerfacecolor','k');
fMax=find(max(timeCourse)==timeCourse);
hold on
plot(fMax,timeCourse(fMax),hilightStyle{:})
hold off


subplot(1,2,2)
hold on
plot(weights(:,1),weights(:,2),'-k')
scatter(weights(:,1),weights(:,2),40,colors,'filled');
plot(weights(fMax,1),weights(fMax,2),hilightStyle{:})
hold off
xlabel('PC 1')
ylabel('PC 2')

box on

set(gca,'color',ones(1,3)*0.5)

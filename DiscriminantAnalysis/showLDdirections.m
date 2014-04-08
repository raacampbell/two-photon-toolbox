function showLDdirections(stats)
%  function showLDdirections(stats)
%
% Make a plot of the directions of the linear discriminants. Each
% axis defining the direction is a weighting for one KC. 
%
% Inputs
% stats: from classifyKCs. 
% e.g. 
%  showLDdirections(stats.discrimFull)
%  showLDdirections(stats.noise(1))
%
% Rob Campbell, August 2009

  
side=ceil(sqrt(length(stats.LDspace)));

J=jet(length(stats.LDspace));

clf
set(gcf,'color','w')
for i=1:length(stats.LDspace)
  
  subplot(side,side,i)
  plot(stats.LDspace(i).ldAxis,'color',J(i,:))
  title(sprintf('%s/%s',stats.LDspace(i).id1,stats.LDspace(i).id2))
  set(gca,'color',ones(1,3)*0.5,'XTick',[])
  xlim([0,length(stats.LDspace(i).ldAxis)])
  
end


function whichKCsAreSignificant(data)
% Show how many times each KC responded significantly
%
% function whichKCsAreSignificant(data)  
%
% Purpose
% Loop through the twoPhoton array and group together responses to
% each odour then make a color plot showing how many times each KC
% responded significantly to each odour. 
%
% Rob Campbell, October 2009
  
  
  
for i=1:length(data)
  odours{i}=data(i).stim.odour;
end

stimuli=unique(odours);

results=zeros(length(stimuli),size(data(1).KCstats.kcDFF,1));

clf


for i=1:length(stimuli)
  ind=strmatch(stimuli{i},odours,'exact');  
  m(i)=length(ind);
  for j=1:length(ind)
    kcs=data(ind(j)).KCstats.sigResponses;
    results(i,kcs)=results(i,kcs)+1;
  end

 % subplot(length(stimuli),1,i)
 % bar(1:size(results,2),results(i,:))
end



corrdist = pdist(results', 'euclidean'); 
corrlink = linkage(corrdist,'single');
[H,b,perm] = dendrogram(corrlink,0);

clf
imagesc(results(:,perm))
xlabel('KC')
set(gca,'clim',[0,length(ind)],...
        'TickDir','out',...
        'YTick',1:length(stimuli),...
        'YTickLabel',stimuli,'XTick',[])
colorbar

hold on
for i=1:size(perm,2)
  plot([i,i]-0.5,ylim,'-k')
end
hold off

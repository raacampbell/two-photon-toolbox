function whichROIsAreSignificant(data,ROIindex)
% Show how many times each ROI (e.g. cell body) responded significantly
%
% function whichROIsAreSignificant(data,ROIindex)
%
% Purpose
% Loop through the twoPhoton array and group together responses to
% each odour then make a color plot showing how many times each KC
% responded significantly to each odour. 
%
% Inputs
% ROIindex - the index of the ROI structure for which stats should
% be calculated. By default it finds the field named 'soma' and
% calculates stats for that. This variable is optional and can be
% an index or a string (it looks up the ROI names in ROI.notes).

% Rob Campbell, October 2009
  
  
if nargin<2, ROIindex='soma'; end
if ischar(ROIindex)
    ROIindex=strmatch(ROIindex,{data(1).ROI.notes});
end


for i=1:length(data)
  odours{i}=data(i).stim.odour;
end

stimuli=unique(odours);

results=zeros(length(stimuli),size(data(1).ROI(ROIindex).stats.dff,1));

clf


for i=1:length(stimuli)
  ind=strmatch(stimuli{i},odours,'exact');  
  m(i)=length(ind);
  for j=1:length(ind)
    roi=data(ind(j)).ROI(ROIindex).stats.sigResponses;
    results(i,roi)=results(i,roi)+1;
  end
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




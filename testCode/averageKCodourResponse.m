function cellMeans=averageKCodourResponse(data,stats)
% function averageKCodourResponse(data)
%
% Compare OSN and KC data

%start and end frames over which to average  
sF=ceil(data(1).stim.stimLatency/data(1).info.framePeriod);
eF=(4+data(1).stim.stimDuration+data(1).stim.stimLatency)/data(1).info.framePeriod;
eF=floor(eF);
  
for i=1:length(data)
  odours{i}=data(i).stim.odour;
end
Uodours=unique(odours);


mu=ones([size(data(1).KCstats.kcDFF),length(Uodours)]);  
cellMeans=ones(size(data(1).KCstats.kcDFF,1),length(Uodours));
allStim=[];
odourInd=[];
for i=1:length(Uodours)
  
  ind=strmatch(Uodours{i},odours);
  odourInd=[odourInd,ind];
  %Mean of all odours
  kcDFF=ones([size(data(1).KCstats.kcDFF),length(ind)]);  
  for j=1:size(kcDFF,3)
    kcDFF(:,:,j)=data(ind(j)).KCstats.kcDFF;
    allStim=[allStim,mean(kcDFF(:,sF:eF,j),2)];
  end  
  mu(:,:,i)=mean(kcDFF,3);

  cellMeans(:,i)=mean(mu(:,sF:eF,i),2);

  

  %allowing each rep to be on a different column

  

end





%grid won't work if number of odour presentations differs between stimuli
glyphplot(allStim(:,odourInd)',...
          'grid',[length(Uodours),length(ind)],...
          'obslabels',odours(odourInd))%,'Standardize','PCA')

[x,i]=sort(sum(cellMeans,1));
cellMeans=cellMeans(:,i);
Uodours=Uodours(i);


glyphplot(cellMeans','obslabels',Uodours)%,'Standardize','PCA')


%face plot
subplot(1,2,1)
[a,b,c]=princomp(cellMeans');
glyphplot(b(:,1:17),'glyph','face','obslabels',Uodours)
title('KC PCA')
box on

subplot(1,2,2)
[a,b,c]=princomp(stats.OSN);
glyphplot(b(:,1:17),'glyph','face','obslabels',Uodours)
title('OSN PCA')
box on




clf
%correlation plots
subplot(1,2,1)
stimuli=unique(stats.trueClass);
CO=corrcoef(stats.OSN');
%CO=squareform(pdist(stats.OSN,'cosine'));
%CO=dp(stats.OSN);
imagesc(CO)
title(sprintf('OSN MI=%2.2f',confMatrix_MI(CO)))
embelishPlot

subplot(1,2,2)
CK=corrcoef(cellMeans);
%CK=dp(cellMeans');
imagesc(CK)
title(sprintf('KC MI=%2.2f',confMatrix_MI(CK)))
embelishPlot

return
subplot(1,3,3)
obs=sum((CO(:)-CK(:)).^2);
n=1000;
simu=ones(1,n);
for i=1:n
  r=randperm(size(cellMeans,2));
  tmp=corrcoef(cellMeans(:,r));
%  imagesc(tmp);embelishPlot;drawnow;pause(0.1)
  simu(i)=sum((tmp(:)-CO(:)).^2);
end
hist(simu,25)
h=findobj(gca,'type','patch');
set(h,'facecolor','k','edgecolor','k')
hold on
plot([obs,obs],ylim,'r--','linewidth',2)
hold off
L=sum(simu>obs)/n;
title(sprintf('%2.2f%% are greater',L*100))

function embelishPlot
  
  axis xy square
  set(gca,'YTickLabel',stimuli,'XTickLabel',...
          repmat(' ',length(stimuli),1))
  
  for i=1:length(stimuli)
    text(i,0.2,stimuli{i},'rotation',-20)
  end
    
%    set(gca,'clim',[0,1])
    colorbar

end



end

function out=dp(in)

out=ones(size(in,1));
for i=1:size(in,1)
    for j=1:size(in,1)        
        out(i,j)=cos(dot(in(i,:),in(j,:)));
       % out(i,j)=(sum(in(i,:).*in(j,:)));
    end
end

end

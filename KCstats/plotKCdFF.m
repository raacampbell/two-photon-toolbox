function plotKCdFF(data,sortType,stats)
% Summary plot of the data produced by KCdFF. 
%
% function plotKCdFF(data,sortType,stats)
%
% Purpose
% Makes pretty summary plot of the data produced by KCdFF. 
% 
% Inputs  
% * data - one instance of the twoPhoton object
% * sortType [optional, 'sigRank' by default] - 
%    how to sort the KC responses in the colour plot. 
%    'sigRank' - by the number of frames significantly above
%                baseline.
%    'pattern' - by response pattern.
%    'none'    - no sorting.     
% * stats - kc dF/F data can be specified here if it isn't present in
%         data.KCstats
%     
%
% Rob Campbell, October 2009



if nargin<2
    sortType='sigRank';
end
if nargin<3
    stats=data.KCstats;
end



overlayMean=0; %If 1 we overlay the mean into the colour plot



switch lower(sortType)
  case 'sigrank'
    [ind,firstSig]=sortBySig(stats);
    kcDFF=stats.kcDFF(ind,:);
  case 'pattern'
    %First separate significant from non-significant
    [ind,firstSig]=sortBySig(stats);
    kcDFF=stats.kcDFF(ind,:);
    %Now arrange significant ones by similarity
    sigNeurons=kcDFF(firstSig:end,:);
    corrdist = pdist(sigNeurons, 'euclidean'); 
    corrlink = linkage(corrdist,'average');
    [H,b,perm] = dendrogram(corrlink,0,'orientation','left');
    kcDFF(firstSig:end,:)=sigNeurons(perm,:);
    


  case 'none'
    kcDFF=stats.kcDFF;
    firstSig=[];
  otherwise
    fprintf('%s is an unknown value for sortType. Not sorting. \n',sortType)
    kcDFF=stats.kcDFF;
    firstSig=[];
end


fp=data.info.framePeriod;
y=[0:size(stats.kcDFF,1)]' * ones(1,size(stats.kcDFF,2));
X=(0:size(stats.kcDFF,2)-1)*fp;
x=ones(1+size(stats.kcDFF,1),1) * X;
kcDFF(end+1,:)=nan;

clf

subplot(2,2,[1,3])
pcolor(x,y,kcDFF)
axis ij  
shading flat, colormap jet
  
%C=colorbar;
%set(get(C,'YLabel'),'String','dF/F')
xlabel('time [s]')
ylabel('#KC ordered by significance')
  
Y=ylim;
hold on
tmp=data.stim.stimLatency;
plot([tmp,tmp],Y,'k-','linewidth',2.5)
plot([tmp,tmp],Y,'w--','linewidth',2)
tmp=(data.stim.stimLatency+data.stim.stimDuration);
plot([tmp,tmp],Y,'k-','linewidth',2.5)
plot([tmp,tmp],Y,'w--','linewidth',2)

xl=xlim;
if ~isempty(firstSig)
    plot(xl,[firstSig-1,firstSig-1],'r--','linewidth',2);
end

hold off
if overlayMean
    imageStack=data.imageStack;
    axes('position',get(gca,'position'));
    hold on
    Y=sum(stats.kcDFF,1);
    msize=4;
    plot(X, zscore(Y),'-g.','linewidth',1,'markerfacecolor','g','markersize',msize)
    Y=roiTimeCourse(imageStack,data.ROI.roi);
    plot(X, zscore(Y),'-r.','linewidth',1,'markerfacecolor','r','markersize',msize)
    hold off
    set(gca,'color','none')
    xlim(xl)
    axis off
    Y=ylim;
    ylim([Y(1),Y(2)*1.5])
    legend({'\Sigma(dF/F)_{kc}','raw image mean'},'location','northeast')
end



%Non-significant neurons
subplot(2,2,2)
hold on
tmp=1:size(stats.kcDFF);
tmp(stats.sigResponses)=[];
plot(x(tmp,:)',stats.kcDFF(tmp,:)','-','color',ones(1,3)*0.5,...
    'linesmoothing','on')


      
ax=gca;
embelishPlot
hold off

%Significant neurons
subplot(2,2,4)
hold on
colors=jet(length(stats.sigResponses));

for i=1:length(stats.sigResponses)
  plot(x(stats.sigResponses(i),:),stats.kcDFF(stats.sigResponses(i),:)',...
       '-','color',colors(i,:),'linewidth',1,'linesmoothing','on')  
end
  

title(sprintf('%d/%d significant responses',...
              length(stats.sigResponses),size(stats.kcDFF,1)))

Y=ylim;
embelishPlot
hold off
set(gca,'color',ones(1,3)*0.3)
set(ax,'Ylim',Y)

  
  
  
  
  
function embelishPlot
  sF=data.stim.stimLatency;
  eF=(data.stim.stimLatency+data.stim.stimDuration);
  Y=ylim;
  P=patch([sF,sF,eF,eF],[Y(1),Y(2),Y(2),Y(1)],1);
  set(P,'facecolor','g','edgecolor','none','facealpha',0.5)

  box on
  set(gca,'linewidth',2)
  xlabel('time [s]')
  ylabel('dF/F')
  xlim([0,max(x(:))])
end



function [ind,firstSig]=sortBySig(stats)
    %Sort by significance rank
    [sr,ind]=sort(stats.sigRank);
    %The first significant response
    f=find((sr>stats.alpha));
    if ~isempty(f)
        firstSig=f(1);
    else
        firstSig=[];
    end


end


end

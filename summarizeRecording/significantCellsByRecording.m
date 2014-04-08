function makeSVG=significantCellsByRecording(data)
% function makeSVG=significantCellsByRecording(data) 
%
% returns whether or not the report generating function should save an SVG
% or a tiff
 

 
[odours,U,indO]=getOdourNames(data);
for i=1:length(U), n(i)=length(indO{i}); end



clf
fsize=14;
plotDat=ones(max(n),length(U))*nan;

ROIindex=strmatch('soma',{data(1).ROI.notes});


for i=1:length(U)
  f=indO{i};
  for j=1:length(f)
    plotDat(j,i)=length(data(f(j)).ROI(ROIindex).stats.sigResponses )/...
        length(data(f(j)).ROI(ROIindex).stats.sigRank);
  end
end
  
if size(plotDat,2)>3 %make surface plot if appropriate
  imagesc(plotDat)
  set(gca,'xtick',[1:size(plotDat,2)],'xticklabel',[],...
          'ytick',[1:size(plotDat,1)],...
          'tickdir','out','fontsize',fsize)
  ylabel('repeat')
  makeSVG=0;
  
  %Overlay stimulus index onto the grid
  
  for i=1:length(U)
    f=strmatch(U{i},odours);
    for j=1:length(f)
      ind=f(j);
      text(i+0.02,j+0.02,num2str(ind),'fontweight','bold','fontsize',14,'color','w')
      text(i,j,num2str(ind),'fontweight','bold','fontsize',14)
    end
  end
  
  %add odour labels 
  for i=1:length(U)
    text(i,size(plotDat,1)+0.25,U{i},'rotation',-35,'fontweight','bold','color','g')
  end
  colorbar
  
    
  
else
  styles={'k',[1,1,1]*0.6;...
          'r',[1,0.5,0.5];...
          'b',[0.5,0.5,1]};

  plot(plotDat,'o-','linewidth',1.3)

  set(0, 'ShowHiddenHandles','off') %make certain there's been no fuck up
                                    %from plot2svg
  c=get(gca,'children');
  
  for i=1:size(plotDat,2);
    set(c(i),'color',styles{i,1},'markerfacecolor',styles{i,2})
  end
  legend(U)
  set(gca,'xtick',[1:size(plotDat,1)],'fontsize',fsize)
  ylabel('proportion of significant neurons')
  xlabel('repeat')
  xlim([0.75,size(plotDat,1)+0.25])
  y=ylim;ylim([y(1)-0.5,y(2)+0.5])
  makeSVG=0;
end




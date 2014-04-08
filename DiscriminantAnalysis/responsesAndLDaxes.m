function responsesAndLDaxes(data,stats)
% function responsesAndLDaxes(data,stats)
%
% Purpose
% Show the evoked KC responses for all stimulus presentations with
% data grouped by presentation. Overlay the LD directions onto
% these data. 
%
% Inputs
% data - twoPhoton object with KC stats
% stats - LDA analysis structure,
%
%
% Rob Campbell, August 2009
  
error(nargchk(2,2,nargin))
stimIndex=stats.stimIndex;
stats=stats.xValidMu; %so we plot the non-cross-validated
                      %version 

odour=stats.trueClass;
Uodours=unique(odour);

full=ROI_responseMatrix(data,[],[],[],[],0);
full=full(stimIndex,:); %Group by odour

bin=ROI_responseMatrix(data,[],'binary',[],[],0);
bin=bin(stimIndex,:);


%now sort these by the number of active neurons
s=sum(bin,1);
[x,cellInd]=sort(s,'descend');
bin=bin(:,cellInd); full=full(:,cellInd);




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Overlay the direction of each LD onto the responses to each odour. 

clf
set(gcf,'color',ones(1,3)*0.5)

%Each odour will be a different sub-plot that we shall define using
%axes to make better use of space. 
height=(1/length(Uodours))*0.92;
width=0.45;
bottom=0.05;
left=0.03;
colors=jet(length(Uodours));
for i=1:length(Uodours)

  f=strmatch(Uodours{i},odour);

  yPos=[bottom+height*(i-1), height];
  
  ax(i)=axes('position',[left,yPos(1),width,yPos(2)]);
  imagesc(full(f,:))
  embelishPlot
  addLDs
  if i==1
    xlabel('#KC (sorted by number of significant responses)')
  end
  


  axes('position',[2*left+width,yPos(1),width,yPos(2)])
  imagesc(bin(f,:))
  embelishPlot
  addLDs 
  if i==1
    xlabel('#KC (sorted by number of significant responses)')
  end
  

end

%Make sure the scales are all the same for the left-hand (full
%matrix plots)
CL=get(ax,'CLim');
CL=[min([CL{:}]),max([CL{:}])];
set(ax,'CLim',CL)
colormap gray

%----------------------------------------------------------------------


function embelishPlot
  box on
  set(gca,'YTick',[],'XTick',[])
end

function addLDs
  ind=[strmatch(Uodours{i},{stats.LDspace.id1});...
       strmatch(Uodours{i},{stats.LDspace.id2})];

  
  %Identify which odours are being seperated by this LD
  tmp=[{stats.LDspace(ind).id1}',{stats.LDspace(ind).id2}'];
  [ii,jj]=ind2sub(size(tmp),strmatch(Uodours{i},tmp));
  jj=~(jj-1)+1; %surely there has to be an easier way of doing this!


  for p=1:length(jj)
    tmp(p,1)=tmp(p,jj(p));  
  end
  tmp=tmp(:,1);
  
  axes('position',get(gca,'position'));
  hold on

  for j=1:length(ind)
    plot(stats.LDspace(ind(j)).ldAxis(cellInd),'-',...
         'color',colors(strmatch(tmp{j},Uodours),:),...
         'LineWidth',2);
  end

  hold off
  set(gca,'YTick',[],'XTick',[],'color','none')
  xlim([0.5,length(stats.LDspace(ind(j)).ldAxis)]);
  ylabel(Uodours{i},'color',colors(i,:),'FontWeight','Bold')
end
  
  
end %Main function end
  

function overallActivity(data)
% function overallActivity(data)
%
% PURPOSE
% Work out the mean activity over the ROI during each stimulus
% response then sort and plot.
%  
% INPUTS  
% data - the product of generateDeltaFoverF
%
% Rob Campbell - June 2009
  

  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ONE: filter
%Firstly, we have some dff values which are stupidly extreme, so we
%fix those on a frame by frame basis by a combination of pixel
%removal and averaging:
hi=6;lo=0; 



for i=1:length(data)
  mu(i)=getDFF(data(i));
  labels{i}=data(i).odour;
end

[x,i]=sort(mu);

mu=mu(i);
labels=labels(i);

bar(1:length(mu),mu)
h=findobj(gca,'type','patch');
set(h,'edgecolor','none','facecolor','k')

for i=1:length(labels)  
  text(i,0,labels{i},'rotation',90,...
       'color','r')  
end


 
 
 
 
 
 
 

 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function muInt=getDFF(data)

%Select only the period during the response
startFrame=mean([data.stimLatency])/data.info.framePeriod;
endFrame=((4+mean([data.stimDuration]))/data.info.framePeriod)+startFrame;

startFrame=floor(startFrame);
endFrame=ceil(endFrame);
%Note! assigning this way stops the workspace from changing
tmp.baselineImage=data.baselineImage;
tmp.imageStack=data.imageStack(:,:,startFrame:endFrame);
tmp.dff=data.dff(startFrame:endFrame);
tmp.roi=data.ROI.roi;

muInt=mean(tmp.dff(:));

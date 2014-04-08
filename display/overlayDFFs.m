function overlayDFFs(dataA,dataB)
% Overlay significant dF/F pixels from two recordings and plot
%
% function overlayDFFs(dataA,dataB)
%
% Purpose
% Mean Significant dF/F pixels from structures in dataA are
% overlaid with those from dataB (using different colours) and all
% are plotted on top of the the dataA(1).baselineImage.
%  
% If dataA or dataB have length>1 then the routine will average the
% dF/F in each element of the structure. 
%
%
% Inputs  
% * data - the product of generateDeltaFoverF
%
% Rob Campbell, March 2009



%NEEDS UPDATING!
 
dataA=filterData(dataA);
dataB=filterData(dataB);

muIntA=meanIntensity(dataA);
muIntB=meanIntensity(dataB);


im=repmat(muIntA,[1,1,3]);
im(:,:,1)=muIntB;
im(:,:,3)=0;
%im(:,:,3)=im(:,:,3)*0.2;
%im(:,:,3)=im(:,:,3)+muIntB*0.2;
imshow(im)



border=bwboundaries(dataB(1).roi);
hold on
for j=1:length(border)   
  plot(border{j}(:,2),border{j}(:,1),'w-')    
end
hold off

%THAT'S IT FOR NOW!
return
prettyOverlay(tmp(1),muInt); %use first baseline image
set(gcf,'name',data(1).info.XMLfile)




  


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tmp=filterData(data);


%filter
%Firstly, we have some dff values which are stupidly extreme, so we
%fix those on a frame by frame basis by a combination of pixel
%removal and averaging:

hi=10;lo=0; 

%Select only the period during the response
startFrame=mean([data.stimLatency])/data(1).info.framePeriod;
endFrame=(mean([data.stimDuration])/data(1).info.framePeriod)+startFrame;
startFrame=floor(startFrame);
endFrame=ceil(endFrame);
for i=1:length(data)
  tmp(i).baselineImage=data(i).baselineImage;
  tmp(i).imageStack=data(i).imageStack(:,:,startFrame:endFrame);
  tmp(i).dff=data(i).DeltaFOverFImage(:,:,startFrame:endFrame);
  tmp(i).StdThreshDFF=data(i).StdThreshDFF(:,:,startFrame:endFrame);
  tmp(i).roi=data(i).ROI.roi;
end


for n=1:length(tmp)
  for i=1:size(tmp(n).dff,3)
    thisFrame=tmp(n).dff(:,:,i);
    f=find(thisFrame>hi | thisFrame<lo);
    thisFrame(f)=0;
    thisFrame=imfilter(thisFrame,fspecial('gaussian',8,0.15));
    tmp(n).dff(:,:,i)= thisFrame;
  end  
end



%clean up the df/f
for n=1:length(tmp)  
  tmp(n).dff=tmp(n).dff.*tmp(n).StdThreshDFF;
end  





%----------------------------------------------------------------------
function muInt=meanIntensity(data)
muInt=ones([size(data(1).dff,1),size(data(1).dff,2),length(data)]);
for i=1:length(data)
  muInt(:,:,i)=mean(data(i).dff,3);
end
muInt=mean(muInt,3);





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function prettyOverlay(data,muInt)

  baseLine=mat2im(data.baselineImage,gray(100));

  


  %make the bottom P% of dF/F changes vanish
  P=5;
  climits=[min(muInt(:)),max(muInt(:))];

  DF=[zeros(P,3);jet(100-P)];
  muInt=mat2im(muInt,DF);

  %Just in case:
  for i=1:3
    muInt(:,:,i)=muInt(:,:,i).*data.roi;
  end

  
  %Combine the two images. 
  im=(muInt+baseLine);
  im=im/max(im(:));

  subimage(im)
  axis off, box on
  

  border=bwboundaries(data.roi);
  hold on
  for j=1:length(border)
    plot(border{j}(:,2),border{j}(:,1),'g-')    
  end
  hold off


  
  
  %Make a customized colorbar for the dF/F
  pos=get(gca,'position'); % L B W H
  ax=axes('position',[pos(1)+pos(3)*0.99,...
                      pos(2)+pos(4)*0.1,...
                      pos(3)*0.1,...
                      pos(4)*0.8]);
  

  colBar=ones(length(DF),1,3);
  colBar(:,1,:)=DF;
  colBarWidth=round(length(colBar)*0.08);
  colBar=repmat(colBar,[1,colBarWidth,1]);

  subimage(colBar)
  axis xy
  
  L=length(colBar);
  ticks=[1:L/8:L];
  ticks=round(ticks);
  
  scale=[climits(1):climits(2)/L:climits(2)];

  tickLabels=round((scale(ticks)*1E2))/1E2;

  set(gca,'YAxisLocation','right',...
          'XTick',[],...
          'YTick',ticks,...
          'YTickLabel',tickLabels)
  title('dF/F')

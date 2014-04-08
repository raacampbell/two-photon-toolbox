function OUT=meanDFFimages(data)
% function OUT=meanDFFimages(data)
%
% make a nice plot of the mean dff images from each element in the
% Object array so that we can quickly see how much it's moved, etc.
%
%
  
N=length(data);
side=ceil(sqrt(N));


fp=data(1).info.framePeriod;
sl=round(data(1).stimLatency/fp);
sd=round(data(1).stimDuration/fp)+sl;
sl=sl+4; %skip some of the first few framaes after onset
sd=sd+(7/fp);%analyse this much time after the stimulus;

OUT=ones([size(data(1).imageStack,1),...
          size(data(1).imageStack,2),N]);         
for i=1:N
  dff=data(i).dff(sl:sd);
  dff=filterDFF(dff);
  
  subplot(side,side,i)
  muDff=mean(dff,3);
  imagesc(muDff)
  axis equal off
  title(i)
  colorbar
  drawnow
  
  OUT(:,:,i)=muDff;
end

colormap jet





function dff=filterDFF(dff)
hi=4.5;lo=-2.5;
for i=1:size(dff,3)
  thisFrame=dff(:,:,i);
  f=find(thisFrame>hi | thisFrame<lo);
  thisFrame(f)=0;

%% Various de-noising approaches we can try
%  thisFrame=medfilt2(thisFrame,[2,2]);
%  thisFrame=waveletDenoise(thisFrame);
   thisFrame=imfilter(thisFrame,fspecial('gaussian',8,0.25));
  
  dff(:,:,i)= thisFrame;
end

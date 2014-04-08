function colorResponse(data)
% colour-coded maximum intensity projection of a time-series
%
% function colorResponse(data)
%
% Makes a max intensity projection of the dF/F over time and color
% codes it according to time then super-imposes it over the raw
% image. The colour scale isn't particularly meaningful but the
% images are pretty. 
%
% Rob Campbell, 2009

%Unsure where the noise somes from in the final image. Weird red
%bits... hmmm. 


imageStack=data.imageStack;
filt=fspecial('disk',2);
imageStack=convn(imageStack,filt,'same');
imageStack=Kalman_Stack_Filter(imageStack,0.76);


baseline=data.baselineImage;  
df=zeros(size(imageStack));
for i=1:size(imageStack,3)
  tmp=imageStack(:,:,i)-baseline;
  df(:,:,i)=tmp;
end
imageStack=df;



%c=hot(size(imageStack,3));
c=jet(size(imageStack,3));


imageStack=repmat(imageStack,[1,1,1,3]);
for i=1:size(imageStack,3)
  color=c(i,:);
  for j=1:3, 
    tmp=imageStack(:,:,i,j)*color(j);
    imageStack(:,:,i,j)=tmp; 
  end
end




%Max intensity projection
imageStack=max(imageStack,[],3);


%Convert to the right range to display the image
imageStack=imageStack-min(imageStack(:));
imageStack=imageStack/max(imageStack(:));
imageStack=squeeze(imageStack);

filt=fspecial('gaussian',8,0.7);
for i=1:3
  imageStack(:,:,i)=imfilter(imageStack(:,:,i),filt);
end

%Overlay the fancy coloured image over the baseline image
f=find(imageStack==0);
baseline=repmat(baseline, [1,1,1,3]);
imageStack(f)=baseline(f);


imshow(imageStack)



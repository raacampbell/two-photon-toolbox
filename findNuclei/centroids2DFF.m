function centroids2DFF(data,stats)
%
% function centroids2DFF(data,stats)
%
% stats is the final centroid positions using trackCells? 
  
disp('Or make the traditional mask and feed to KCdFF')
%check the following produces same result as KCdFF. Check speed of
%this looped algorithm against KCdFF

c=stats.centroid;
im=data.imageStack;
timeCourse=ones(length(c),size(im,3));
s=size(im);



%generate the mask
masks=zeros(s(1),s(2));
for ii=1:length(c)
    masks=masks+getdisk(im,c(ii,:),stats.cellDiam/2)*ii;
end


%now work out the dF/F for each cell in the same way we did with KCdFF
numFrames = s(3); 
Umasks=unique(masks);
Umasks(Umasks==0)=[];
numCells = length(Umasks(:));




if strmatch('TSeries ZSeries',data.info.type)
  disp('not yet')
  return
elseif strmatch('TSeries',data.info.type)
  
  
  im=reshape(im,[size(im,1)*size(im,2),numFrames]);
  
  for i = 1:length(Umasks)
    m=Umasks(i);  
    f=find(masks==m);
    mu = mean( im(f,:) );
    
    F=mean(mu(data.preFrames));
    dff=(mu-F)/F;
    
    dff=dff-mean(dff(data.preFrames));
    kcDFF(i,:)=dff; 
  end
  
  imagesc(kcDFF)
end




function currmask=getdisk(im,point,radius)
theta = -pi:0.1:pi ;
Xcrds = fix (point(1,1) + radius * cos(theta) );
Ycrds = fix (point(1,2) + radius * sin(theta) );
currmask = roipoly(im, Xcrds, Ycrds);





function timeCourse=centroids2timecourse(data,stats)
%
% function centroids2timecourse(data,stats)

c=stats.centroid;
im=data(1).imageStack;
timeCourse=ones(length(c),size(im,3));
s=size(im);


blank=ones(s(1:2));


%now work out the dF/F for each cell in the same way we did with KCdFF
numFrames = s(3); 


im=data(1).imageStack;

if strmatch('TSeries ZSeries',data(1).info.type) %3D

  masks=stats.masks;
  timeCourse=ones(length(c),length(data));
  for I=1:length(data)
      fprintf('Volume %d/%d\n',I,length(data))
      im=data(I).imageStack;

      im=reshape(im,[size(im,1)*size(im,2),s(3)]); %TEMPORARY

      
      for depth=1:s(3)  
          Umasks=unique(masks(:,:,depth));
          Umasks(Umasks==0)=[];
          numCells = length(Umasks(:));
          
          for ii = 1:length(Umasks)
              m=Umasks(ii);
              f=find(masks(:,:,depth)==m);
              timeCourse(m,I) = mean( im(f,depth,:) );
          end
      end
      
      data(I).stim=timeCourse; %TEMPORARY
  end
  
  imagesc(timeCourse)



elseif strmatch('TSeries',data(1).info.type) %2D


  %generate the mask
  masks=zeros(s(1),s(2));

  for ii=1:length(c)
    masks=masks+getdisk(blank,c(ii,:),stats.cellDiam/2)*ii;
  end

  Umasks=unique(masks);
  Umasks(Umasks==0)=[];
  numCells = length(Umasks(:));

  
  im=reshape(im,[size(im,1)*size(im,2),numFrames]);
  
  for ii = 1:length(Umasks)
    m=Umasks(ii);  
    f=find(masks==m);
    timeCourse(ii,:) = mean( im(f,:) );
  end
  
  imagesc(timeCourse)
end




function currmask=getdisk(im,point,radius)
theta = -pi:0.1:pi ;
Xcrds = fix (point(1,1) + radius * cos(theta) );
Ycrds = fix (point(1,2) + radius * sin(theta) );
currmask = roipoly(im, Xcrds, Ycrds);





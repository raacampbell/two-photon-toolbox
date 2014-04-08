function f=prettyMovie(data)
% function f=prettyMovie(data)
%
% Purpose
% Create a nicely formated movie which can be used for
% presentations, etc. 
%
%
% Rob Campbell
  
imageStack=data.imageStack.*...
    repmat(data.ROI(1).roi,[1,1,size(data.imageStack,3)]);

clf
imagesc(imageStack(:,:,1))
axis off, axis equal


cmap=zeros(100,3);
cmap(:,2)=(1:1:100)/100;

S=size(imageStack,3);
colormap(cmap)

%hold on
%p=plot(165,195,'wo','markersize',40,'linewidth',2);
%hold off

%Make a movie of 17 and 18 which show the same cell lighting up.
fp=data.info.framePeriod;
time=[0:fp:fp*size(imageStack,3)-fp];
t=text(20,20,sprintf('t=%0.2gs',time(1)),'color','w','fontweight','bold');

  for frame=1:size(imageStack,3)
    chil=get(gca,'children');
    set(chil(end),'CData',imageStack(:,:,frame))
    title(sprintf('Frame %d/%d',frame,S))

    set(t,'string',sprintf('t=%2.2fs',time(frame)))

    if time(frame)>4 & time(frame)<5.5
      set(t,'color','r')
    else
      set(t,'color','w')
    end
    
    drawnow
    f(frame)=getframe;
    
  end

%movie(f,10)

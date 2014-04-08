function f=makeMovie(data)
% make a movie of the raw data for a recording

%uncomment following to smooth
imageStack=data.imageStack;%.*repmat(data.ROI(1).roi,[1,1,size(data.imageStack,3)]);


clf
imagesc(imageStack(:,:,1))
axis off, axis equal


cmap=zeros(100,3);
cmap(:,2)=(1:1:100)/100;

S=size(imageStack,3);
colormap(cmap)

hold on

%add a scalebar
mic=data.info.micronsPerPixel_YAxis;
scale=10/mic;
Y=ylim;
Y=Y(2)*0.9;
plot([20,20+scale],[Y,Y],'w-','linewidth',4)
text(20,Y-10,'10 \mum','color','w')
hold off


fp=data.info.framePeriod;
time=[0:fp:fp*size(imageStack,3)-fp];
t=text(20,20,sprintf('t=%0.2gs',time(1)),'color','w','fontweight','bold',...
    'FontSize',15);


  for frame=1:size(imageStack,3)
    chil=get(gca,'children');
    set(chil(end),'CData',imageStack(:,:,frame))
    title(sprintf('Frame %d/%d',frame,S))

    set(t,'string',sprintf('t=%2.2fs',time(frame)))
    
    drawnow
    f(frame)=getframe;
    
  end

%movie(f,10)

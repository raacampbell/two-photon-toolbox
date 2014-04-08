function MOV=makeMovieOfObject(data)
% function MOV=makeMovieOfObject(data)  
%
% Plot all responses to all odours in the object on one image and
% animate it. Return the movie object.
%
%
  
clf  
nframes=size(data(1).imageStack,3);
N=length(data);

side=ceil(sqrt(N));

F=fspecial('gaussian',10,1.5);

MOV=avifile('mymovie.avi','fps',10,'quality',100);

cutOff=3;
for frame=15:nframes-1

  %average adjacent frames
  for i=1:N;
    set(gcf,'name',num2str(frame))
    subplot(side,side,i)
    im=data(i).dff(frame-1:frame+1);
    im(im>cutOff)=0;
    im=mean(im,3);
    im=conv2(im,F,'same');
    im(1,1)=cutOff;
    imagesc(im)
    axis off equal
    text(10,30,data(i).odour,'color','w','fontweight','bold')
  end
  
  MOV=addframe(MOV,getframe(gcf));

  
end

MOV=close(MOV);

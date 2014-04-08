function makeAllMovies(data)
% function makeAllMovies(data)
%
% Make an avifile of each response in the current directory.
%
  
clf  
nframes=size(data(1).imageStack,3);
N=length(data);

F=fspecial('gaussian',10,1.5);



cutOff=3;
for i=1:N
  fname=[num2str(i),'_',data(i).odour,'.avi'];  
  MOV=avifile(fname,'fps',10,'quality',100);  
  for frame=15:nframes-1
    
    set(gcf,'name',num2str(frame))
    im=data(i).dff(frame:frame+1);
    im(im>cutOff)=0;
    im=mean(im,3);
    im=conv2(im,F,'same');
    im(1,1)=cutOff;
    imagesc(im)
    axis off equal
    text(10,30,data(i).odour,'color','w','fontweight','bold')
    MOV=addframe(MOV,getframe(gcf));
  end
  MOV=close(MOV);  
end



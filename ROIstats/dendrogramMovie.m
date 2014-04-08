function dendrogramMovie(fname)
% Turn the dendrogram plot into an animated gif

  
frames=1:2:360;

f = getframe(gcf);
[im,map] = rgb2ind(f.cdata,256,'nodither');
im(1,1,1,length(frames)) = 0; %pre-alocate

n=1;
for i=frames
  
  set(gca,'view',[i,45]);    
  f=getframe(gcf);    
  im(:,:,1,n) = rgb2ind(f.cdata,map,'nodither');

  n=n+1;

end


imwrite(im,map,fname,'DelayTime',0,'LoopCount',inf) %g443800


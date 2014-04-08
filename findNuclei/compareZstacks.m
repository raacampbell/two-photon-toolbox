function compareZstacks(a,b,depth)
% function compareZstacks(a,b,depth)
%
% make side by side movies of z-stacks a and b at a given depth.
%
%


ii=1;
subplot(1,2,1)
im1=imagesc(squeeze(a(:,:,ii,depth)));
axis equal off

subplot(1,2,2)
im2=imagesc(squeeze(b(:,:,ii,depth)));
axis equal off

while 1
    
    for ii=1:size(a,3)
        
        set(im1,'cdata',squeeze(a(:,:,ii,depth)))
        axis equal off
        
        set(im2,'cdata',squeeze(b(:,:,ii,depth)))
        axis equal off
        
        drawnow 
        pause(0.05)
    end
    
end



function K=compareVolAndRaw(stats)

lim=[100,300];

for ii=1:length(stats)
    IM(:,:,ii)=stats(ii).vol(lim(1):lim(2),lim(1):lim(2),10);
end

K=Kalman_Stack_Filter(IM);
%K=ceil(K/max(K(:)));
return
while 1
    for ii=1:length(stats)
        subplot(1,2,1)
        imagesc(IM(:,:,ii))
        axis equal
        
        subplot(1,2,2)
        imagesc(K(:,:,ii))
        axis equal
        
        drawnow
        pause(0.05)
    end
end

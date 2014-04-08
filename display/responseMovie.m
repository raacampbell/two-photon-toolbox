function responseMovie(data,roiIndex,framePeriod)



%Check input arguments
error(nargchk(1,3,nargin));
if nargin<2, roiIndex=[]; end
if isempty(roiIndex), roiIndex=1; end
if nargin<3, framePeriod=0.04; end

%Get the ROI
if isscalar(roiIndex)
    ROI=data.ROI(roiIndex).roi;
else
    ROI=roiIndex;
    ROI(ROI>1)=1; 
end


clf
axes('Position',[0.1,0.75,0.35,0.20]);
out=responseTimeCourse(data,ROI);
hold on
curFrame=plot([0,0],ylim,'-g','linewidth',2);
title('')
xlabel('')


%Raw stack
im=axes('Position',[0.02,0.02,0.5,0.5]);
imageStack=out.imageStack;

imagesc(imageStack(:,:,1))
axis equal tight
set(im,'XTick',[],'YTick',[],'LineWidth',3)
colormap gray

scale=[min(imageStack(:)),max(imageStack(:))];
S=size(imageStack,3);




%dff stack
if 0
imDff=axes('Position',[0.52,0.02,0.5,0.5]);
dff=data.dff;

imagesc(dff(:,:,1))
axis equal tight
set(imDff,'XTick',[],'YTick',[],'LineWidth',3)
colormap gray
scale=[min(dff(:)),max(dff(:))];

end


%Now we're going to animate the thing

%Find the frames at the start and end of the response period
stim=responsePeriodFrames(data);
fp=data.info.framePeriod;
while 1
    for frame=1:S

        chil=get(im,'children');
        set(chil(end),'CData',imageStack(:,:,frame))
        set(gca,'CLim',scale)
        title(sprintf('Frame %d/%d',frame,S))
        drawnow

        %        chil=get(imDff,'children');
        %set(chil(end),'CData',imageStack(:,:,frame))
        %set(gca,'CLim',scale)
        %title(sprintf('Frame %d/%d',frame,S))
        %drawnow


        if frame==stim(1)
            set(im,'ycolor','r','xcolor','r')
         
        end
        if frame==stim(2)
            set(im,'ycolor','k','xcolor','k')
        end
        
            
        set(curFrame,'XData',[frame,frame]*fp)
        drawnow
        
        pause(framePeriod)
    end
end


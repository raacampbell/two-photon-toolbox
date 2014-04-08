function overlayCentroidsAnimated(Zstack,kcMasks,depth)
% Animate through all recorded volumes for one depth. Scroll through a z-stack or t-series with over-laid cell centroids
%
% function overlayCentroidsAnimated(Zstack,kcMasks)
%
%    
% Inputs
% data - output of makeZstack (which has the channel dimension
%        removed since it returns channel 1 only). 
% kcMasks - the masks matrix which was added to the data object
%           using centroids2masks. 
% depth - integer defining the depth to show.     
%
% Rob Campbell, Sept 2010
    

    


Zstack=squeeze(mean(Zstack,3));
Zstack=squeeze(Zstack(:,:,depth,:));
kcMasks=double(kcMasks);


clf


AX=axes('position',[0.05,0.07,0.88,0.88]);
IM=pcolor(Zstack(:,:,1));
shading flat
axis equal tight off ij


%Overlay mask on a seperate set of axes
pos=get(AX,'position');
maskAX=axes('position',pos);
set(maskAX,'color','none')

tmp=kcMasks(:,:,depth);
tmp(tmp==0)=nan;
tmp(tmp>1)=0.98;


M=pcolor(tmp);
shading flat
axis equal tight off ij

chil=get(maskAX,'children');
chil=chil(strmatch('surface',get(chil,'type')));
set(chil,'FaceAlpha',0.35)



%Now set up the color scale
%0.98 -> red
%0.99 -> green
%1.00 -> blue
cmap=gray(100);
cmap(end+1,:)=[1,0,0];
cmap(end+1,:)=[0,1,0];
cmap(end+1,:)=[0,0,1];

set(AX,'clim',[0,1.05])
set(maskAX,'clim',[0,1])
colormap(cmap);


while 1
    
    for ii=1:size(Zstack,3)
        set(IM,'CData',Zstack(:,:,ii))
        pause(0.1)
        drawnow
    end

end


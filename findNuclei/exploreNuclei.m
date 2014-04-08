function imageStack=exploreNuclei(data,zSlice)
% Scroll through a z-stack or t-series with over-laid cell centroids
%
% function exploreNuclei(data,zSlice)
%
%    
% Inputs
% data - data structure. Multiple structures can be entered and
%        image stacks are concatenated if this is done. 
% zSlice - the z-slice to show over time
% Just feed in a data structure which contains the masks, and it
% will show you the depth plot by default (average over time,
% dimension 3). Alterntively, zSlice is a scalar defining which
% sclice from the array to plot over time. e.g. dim=7 will show
% slice 7 over time. 
%
% Rob Campbell
    

    
clf

AX=axes('position',[0.05,0.07,0.88,0.88]);


imageStack=[];
mask=[];

for ii=1:length(data)
    
    im=double(squeeze(data(ii).imageStack(:,:,:,1,:))); %RFP
    
    m=double(data(ii).KCmasks);
    m(m>0)=1;  
    
    if nargin==1
        im=squeeze(mean(im,3));
        zSlice=[];
    else
        im=squeeze(im(:,:,:,zSlice));
        m=repmat(m(:,:,zSlice),[1,1,size(im,3)]);
    end

    
    if length(data)>1
        mask=[mask;permute(m,[3,1,2])];
        imageStack=[imageStack;permute(im,[3,1,2])];
    end
    
    
end


if length(data)>1
    imageStack=permute(imageStack,[2,3,1]);
    mask=permute(mask,[2,3,1]);

else
    imageStack=im;
    mask=m;
end
clear m im

IM=pcolor(imageStack(:,:,1));
shading flat
axis equal tight off ij

%Overlay mask on a seperate set of axes
pos=get(AX,'position');
maskAX=axes('position',pos);
set(maskAX,'color','none')


tmp=mask(:,:,1);
tmp(tmp==0)=nan;

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




L=size(imageStack,3);
H=uicontrol('Style', 'slider', 'position',[15,20,625.8,20.5],....
            'Max',L,'Min',1,'Value',1, ...
            'SliderStep',[1/(L-1),1/(L-1)],'callback',@slider_cb);

slider_cb(1)

function slider_cb(varargin)
    V=round(get(H,'value'));
    set(IM,'CData',imageStack(:,:,V))
    
    %(0.98,red; 0.99,green; 1.00,blue)        
    tmp=mask(:,:,V)*0.98;
    if V>1 & isempty(zSlice)
        tmp=tmp+mask(:,:,V-1);
    end
    if V<size(mask,3) & isempty(zSlice)
        tmp=tmp+mask(:,:,V+1);
    end
    tmp(tmp>1)=0.99;
    tmp(tmp==0)=nan;
    set(M,'CData',tmp)
    
    
    title(sprintf('Frame %d/%d',V,L))
end






    
    

end


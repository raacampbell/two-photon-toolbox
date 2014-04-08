function zExplorer(imageStack)
% Scroll through a z-stack with a slider
%
% function zExplorer(imageStack)    
%
% Purpose: scroll through a z-stack with a slider.
%    
% Inputs
% imageStack - a 3-D matrix of x and y pixels at z
% depths. Obviously, z may be time or space.     
% 
%
% Rob Campbell
    
    
clf

AX=axes('position',[0.05,0.07,0.88,0.88]);

IM=imagesc(imageStack(:,:,1));
axis off equal
colormap gray

L=size(imageStack,3);
H=uicontrol('Style', 'slider', 'position',[15,20,625.8,20.5],....
            'Max',L,'Min',1,'Value',1, ...
            'SliderStep',[1/(L-1),1/(L-1)],'callback',@slider_cb);

function slider_cb(varargin)
    V=round(get(H,'value'));
    set(IM,'CData',imageStack(:,:,V))
    title(sprintf('Frame %d/%d',V,L))
end


end



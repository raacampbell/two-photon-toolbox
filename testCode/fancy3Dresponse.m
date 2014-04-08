function F=fancy3Dresponse(data)
% function fancy3Dresponse(data)
%
% Inputs
% data  - one element of the data structure. 
%
%
% Rob Campbell - March 2011



radius = 4; %4 pixel radius for spheres


clf

data=data(1);
centroids=data.ROI.centroids;
nCells=size(centroids,1);

xScale=data.info.micronsPerPixel_XAxis;
yScale=data.info.micronsPerPixel_YAxis;


[x y z] = sphere(10);
x = x*radius;
y = y*radius;
z = z*radius;

%subplot(1,2,1)

for ii=1:nCells
    
    ctrs =centroids(ii,:);
    ctrs(3)=ctrs(3)*-1;
    col = (ii/nCells)*ones(size(z));
    %    surf(x+ctrs(1),y+ctrs(2),z+ctrs(3)*20,col)
    ptch=surf2patch(x+ctrs(1),y+ctrs(2),z+ctrs(3)*20,1);
    p(ii)=patch(ptch);
end

%set(p,'FaceColor','flat','EdgeColor','None')

set(p,'FaceAlpha',0.5)
shading('flat')
light('Position',[1024 1024 1000],'Style','infinite');
lighting('flat')
%daspect([1 1 1])
view(3)
axis equal off


%N=neuronMeanVar(data);
%pd=N.plotData;
%pd=pd-min(pd);
%pd=pd./max(pd);
%for ii=1:length(pd)
%    set(p(ii),'FaceAlpha',pd(ii));
%end
set(p,'FaceAlpha',0.15)


dff=data.ROI.stats.dff(1:end,:);
dff=dff-min(dff(:));
dff=dff./max(dff(:));
dff(dff<0.15)=0.15;

n=1;
col=jet(100);
col(35:100,:)=repmat(col(80,:),66,1);
col(1:15,:)=repmat(col(1,:),15,1);

for t=1:size(dff,2)
    %if t>3, set(p,'FaceColor',[1,0,0]), else
        set(p,'FaceColor',[0,0,1]),
        %end
    
    title(sprintf('%d/%d',t,size(dff,2)))
    for ii=1:size(dff,1)
        mag=dff(ii,t);
        ind=round(mag*100);
        if ind<15, ind=1; end
        set(p(ii),'FaceAlpha',mag,...
                  'FaceColor',col(ind,:))
        
        if mod(ii,10)==0
            rotate(p,[0,0,1],0.5)        
            F(n) = getframe;n=n+1;
            set(gcf,'Name',sprintf('%d/%d',ii,size(dff,1)))
            drawnow
        end
        
    end

end



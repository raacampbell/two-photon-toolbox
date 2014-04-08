function F=fancy3DresponseDelta(data,odours)
% function F=fancy3DresponseDelta(data,odours)
%
% Makes a 3D movie of the difference in the mean difference in the
% responses of cells to two different odours. 
%
% Inputs
% data  - one element of the data structure. 
% odours - a cell array of two strings defining the odours to
% analyse. 
%
% Rob Campbell - March 2011



radius = 4; %4 pixel radius for spheres


clf
axes('position',[0,0,1,1])
centroids=data(1).ROI.centroids;
nCells=size(centroids,1);

xScale=data(1).info.micronsPerPixel_XAxis;
yScale=data(1).info.micronsPerPixel_YAxis;


[X,Y,Z] = sphere(20);


N=neuronMeanVar(data);
A=N.plotData(strmatch(odours{1},N.odors,'exact'),:);
B=N.plotData(strmatch(odours{2},N.odors,'exact'),:);

delta=abs(A-B);

alpha=delta./max(delta);
threshAlpha=0.30;
alpha(alpha<0.30)=threshAlpha;
%f=find(alpha>0.2);length(f);alpha(f)=0.95;

R=redblue(300);
R(1:200,:)=[];
n=1;
for ii=1:1:nCells
    
    if alpha(ii)<0.15,  radius=1.5; end
    if alpha(ii)>=0.15, radius=3.0; end
    if alpha(ii)>0.40,  radius=4.0; end
    if alpha(ii)>0.60,  radius=6.0; end
    if alpha(ii)>0.80,  radius=8.0; end
    
    x = X*radius;
    y = Y*radius;
    z = Z*radius;


    ind=N.neuronIndex(ii);
    ctrs =centroids(ind,:);
    ctrs(3)=ctrs(3)*-1;
    col = (ii/nCells)*ones(size(z));
    %    surf(x+ctrs(1),y+ctrs(2),z+ctrs(3)*20,col)
    ptch=surf2patch(x+ctrs(1),y+ctrs(2),z+ctrs(3)*20,1);

    
    p(n)=patch(ptch,'FaceAlpha',alpha(ii),...
               'FaceColor',[0,0,1]);
    if alpha(ii)>threshAlpha
        r=round(100*alpha(ii));
        set(p(n),'FaceColor',R(r,:));
        if alpha(ii)<0.75
            set(p(n),'FaceAlpha',0.75)
        end
        
    end
    
    n=n+1;
end

%set(p,'FaceColor',[1,0,0],'EdgeColor','none')

set(p,'EdgeColor','None')

%light('Position',[1024 1024 1000],'Style','infinite');
camlight('headlight')
lighting('Gouraud')
view(3)
axis equal off


n=1;
skip=2;
angle=150;
for ii=1:skip:angle
    rotate(p,[0,0,1],skip)        
    set(gcf,'Name',sprintf('%d/%d',n,round(angle/skip)))
    drawnow
    F(n) = getframe(gca);n=n+1;
end



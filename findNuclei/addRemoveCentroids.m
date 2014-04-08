function addRemoveCentroids(data,indecies)
% Scroll through a z-stack or t-series with over-laid cell centroids
%
% function addRemoveCentroids(data,ind)
%
%    
% Inputs
% data - data structure. Multiple structures can be entered and
%        image stacks are concatenated if this is done. 
% indecies - use these indecies only. Need to feed this in here because
% the function loads from the _Zstacks.mat file to make the movie. 
%
% Rob Campbell
    

    
fprintf(' <-\t up a slice\n ->\t down a slice\n')
fprintf(' L mouse add point\n R mouse remove point\n')
fprintf(' M mouse animate\n E \t exit\n')

clf
AX=axes('position',[0.05,0.07,0.88,0.88]);

zSlice=1;

sRoi=strmatch('soma',{data(1).ROI.notes});
centroids=data(1).ROI(sRoi).centroids;


fname=strrep(data(1).info.XMLfile,'.xml','_Zstacks.mat');
if exist(fname,'file')
    load(fname)
else
    zStack=saveZdepths(data);
end

zStack=permute(zStack,[1,2,4,3]);

if nargin<2
    indecies=1:size(zStack,4);
end

zStack=zStack(:,:,:,indecies);



L=size(zStack,3);
IM=imagesc(squeeze(zStack(:,:,zSlice,1)));
shading flat
axis equal tight off ij
colormap gray
tit=title(sprintf('Frame %d/%d',zSlice,L));


%Overlay centroids on a seperate set of axes, otherwise GInput
%works slowly
xlimits=xlim; xlim(xlimits)
ylimits=ylim; ylim(ylimits)
pos=get(AX,'position');
maskAX=axes('position',pos);
set(maskAX,'color','none')
axis equal tight off ij

hold on
P(1)=plot(nan,nan,'ob');

f=find(centroids(:,4)==zSlice);
if ~isempty(f)
    P(2)=plot(centroids(f,1),centroids(f,2),'or');
end


f=find(centroids(:,4)==zSlice+1);
if ~isempty(f)
    P(3)=plot(centroids(f,1),centroids(f,2),'ob');
end
hold off


xlim(xlimits), ylim(ylimits)



zSlice=1;

% Adds and removes data points with the mouse
% Given the handle of the plot, h, addRemoveGInput will either add a
% data point (upon left button press) or remove the datapoint closest
% to the clicked location clicked (upon right button press). Middle
% mouse quits
%
% The closest datapoint is determined by minimizing the
% distance which is weighted by the scale of the figure,
% such that if your figure is [0:1:0:1000], the distance
% is
%
%    sqrt(((X-x)./1).^2+((Y-y)./1000).^2);
%
% Based on MagnetGInput by Michael Robbins

if nargin<2 N=1; end;



set(IM,'CData',zStack(:,:,zSlice,1))

f=find(centroids(:,4)==zSlice);
if P(2)>0
    set(P(2),'XData',centroids(f,1),'YData',centroids(f,2))
end



if zSlice>1
    f=find(centroids(:,4)==zSlice-1);
    set(P(1),'XData',centroids(f,1),'YData',centroids(f,2))
end
if zSlice<size(zStack,3)
    f=find(centroids(:,4)==zSlice+1);
    set(P(3),'XData',centroids(f,1),'YData',centroids(f,2))
else
    set(P(3),'XData',nan,'YData',nan)
end

set(tit,'string',sprintf('Frame %d/%d; %d cells',zSlice,L,length(centroids)));


XScale=diff(get(gca,'XLim'));
YScale=diff(get(gca,'YLim'));

out.removedPoints=[];
out.removedIndecies=[];
out.addedPoints=[];

%to keep the axes from changing when points are removed
xlim(xlim)
ylim(ylim)

while 1
    [x,y,button]=ginput(1);

    
    out.removedPoints=[];
    out.removedIndecies=[];
    out.addedPoints=[];

    if P(2)>0
        X=get(P(2),'XData');
        Y=get(P(2),'YData');
    else
        X=[];
        Y=[];
    end
    


    if button==3 %Right button: remove nearest point
        r=sqrt(((X-x)./XScale).^2+((Y-y)./YScale).^2);
        [temp,ind]=min(r);
        xclick=x;
        yclick=y;

        %Remove
        out.removedPoints=[X(ind),Y(ind)];
        out.removedIndecies=ind;
        
        hold on 
        PP=plot(X(ind),Y(ind),'ro','markerfacecolor','r');
        hold off
        pause(0.05)
        delete(PP)

        updateCentroids(P(2),out);
        updateImage



    elseif button==1 %Left button: add point at mouse location
        out.addedPoints=[x,y];
        Y=[Y,y];
        X=[X,x];
        if P(2)>1
            set(P(2),'XData',X,'YData',Y)
        else
            P(2)=plot(X,Y)
        end
        
            
        updateCentroids(P(2),out);
        updateImage
        
    elseif button==2 %Middle button: animate
        for ii=1:size(zStack,4)
            set(IM,'CData',zStack(:,:,zSlice,ii))
            drawnow       
        end
        updateImage

        
    elseif button==28 %Left keyboard arrow
        zSlice=zSlice-1;
        if zSlice<1, zSlice=size(zStack,3); end
        updateImage
        
    elseif button==29 %Right keyboard arrow
        zSlice=zSlice+1;
        if zSlice>size(zStack,3), zSlice=1; end
        updateImage

    elseif button==101 %E quits
        disp('Done!')
        break
    end


end

function updateImage
    set(IM,'CData',zStack(:,:,zSlice,1))

    
    f=find(centroids(:,4)==zSlice);
    set(P(2),'XData',centroids(f,1),'YData',centroids(f,2))

    if zSlice>1
        f=find(centroids(:,4)==zSlice-1);
        set(P(1),'XData',centroids(f,1),'YData',centroids(f,2))
    end
    if zSlice<size(zStack,3)
        f=find(centroids(:,4)==zSlice+1);
        set(P(3),'XData',centroids(f,1),'YData',centroids(f,2))
    else
        set(P(3),'XData',nan,'YData',nan)
    end
    if zSlice==1
        set(P(1),'XData',nan,'YData',nan)
    end
    
    
    set(tit,'string',sprintf('Frame %d/%d; %d cells',zSlice,L,length(centroids)));
end


function updateCentroids(h,out)
    
    %Add new centroids
    if ~isempty(out.addedPoints) %add new points
        out.addedPoints(:,3:4)=[zSlice,zSlice];
        centroids=[centroids;out.addedPoints];
    elseif ~isempty(out.removedIndecies) %take away points
        %Find centroids from this slice
        f=find(centroids(:,4)==zSlice);
        tmp=centroids(f,:);

        centroids(f,:)=[]; %Remove these centroids from the list
        tmp(out.removedIndecies,:)=[]; %remove the correct index
        centroids=[centroids;tmp]; %re-create
    end
    
    
    for ii=1:length(indecies)
        data(indecies(ii)).ROI(sRoi).centroids=centroids;
    end

    
end




end%Main function

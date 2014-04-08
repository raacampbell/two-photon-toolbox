function odour3Dplot(data,corrdist,odourColors,odourIndex,simplePlot)
% 3-D PC plot of each stimulus
%
% function odour3Dplot(data,corrdist,odourColors,odourIndex,simplePlot)
%
% Make a 3-D plot of the neural responses in MDS space. 
% This function can be called from odourDendrogram to provide a 3-D
% plot where colours are related to the dendrogram linkage
% level (odourIndex). With the odourIndex not defined, colours are
% related to odour indentity. 
%
%
% INPUTS: 
%  * data is the twoPhoton object
%  * corrdist [optional, can be empty] is the distance matrix we will work with. 
%  * odourColors [optional] is the colour scheme 
%  * odourIndex [optional] is the colour from the scheme to applied to each odour
%  * simplePlot [optional] - zero by default. If 1 then spheres are
%                            the same size and no odour labels are plotted.
%
% Rob Campbell, 28th October 2009
  


if nargin<2 | isempty(corrdist)
    dataMatrix=kcResponseMatrix(data,[],[],[],0);
    corrdist = pdist(dataMatrix, 'cosine');
end


if nargin<3 | isempty(odourColors)
    for i=1:length(data)
        odours{i}=data(i).stim.odour;
    end
    U=unique(odours);    
    tmp=hsv(length(U)+1);    
    for i=1:length(odours)
        ind=strmatch(data(i).stim.odour,U,'exact');
        odourColors(i,:)=tmp(ind,:);
    end
    odourIndex=1:length(data);

end


if length(odourIndex)~=length(data)
    disp('** Warning odour index is incorrect. Setting to default **')
    odourIndex=1:length(data);
end

if nargin<5
    simplePlot=0;
end

    

%------------------------------------------------------
%Work out the MDS
opt=statset('maxiter',7000);
[score,stress]=mdscale(corrdist,3,'criterion', 'metricsstress',...
                                       'Options',opt);
%[score,stress]=cmdscale(corrdist);


hold on

funky=1; %if false you get disks if true you get spheres
colormap(odourColors)
odourColors=odourColors+0.2;
odourColors=odourColors/max(odourColors(:));
Xdiff=range(score(:,2)); %we will use this to set the size of the blobs WRT to the MDS axes


if funky
    [X,Y,Z]=sphere(15);
end

for i=1:length(score)
    ind=find(odourIndex==i);
    if ~simplePlot
        msize=length(data(i).KCstats.sigResponses)+2;
    else
        msize=14;
    end
    
    
    if ~funky
        plot3(score(i,1),score(i,2),score(i,3),'ko',...
            'markerfacecolor',odourColors(ind,:),...
            'markersize',msize);
        shift=Xdiff*msize*0.001;
        t=text(score(i,1)+shift,score(i,2)+shift,score(i,3)+shift,data(i).stim.odour);
        set(t,'color',odourColors(ind,:)*0.65,'fontweight','bold');
    end
    
    if funky

        scale=Xdiff*msize*0.0025+0.005;
        
        surf(X*scale+score(i,1),Y*scale+score(i,2),Z*scale+score(i,3),...
            'cdata',ones(size(X))*ind)        
        shading flat


        if ~simplePlot
            shift=(Y*scale); shift=max(shift(:));
            t=text(score(i,1)+shift,score(i,2)+shift,score(i,3)+shift,data(i).stim.odour);
            set(t,'color',odourColors(ind,:),'fontweight','bold');
        end
        
        
    end
    
end

camlight('headlight')
hold off
box on
set(gca,'color',ones(1,3)*0.6,'XTick',[],'YTick',[],'ZTick',[],...
    'cameraviewangle',6.5)
xlabel('dimension 1'),ylabel('dimension 2'),zlabel('dimension 3')
%title('MDS Space','fontsize',15)
view(3)
axis equal

set(gcf,'renderer','opengl')
set(findobj(gca,'type','surface'),...
    'FaceLighting','gouraud',...
    'facealpha',0.65,...
    'AmbientStrength',.4,'DiffuseStrength',.9,...
    'SpecularStrength',.9,'SpecularExponent',20,...
    'BackFaceLighting','unlit')

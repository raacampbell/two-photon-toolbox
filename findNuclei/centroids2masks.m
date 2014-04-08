function varargout=centroids2masks(data,centroids)
% function [masks,centroids]=Centroids2masks(data,centroids)
% Generate cell ROIs from centroid positions. Rounds centroid
% positions to nearest z-layer. Can also add masks to data array. 
%
% If length(data)>1, then loop through it, updating the masks to the
% structure. Assumes centroids are the same in each recording.
%
% Rob Campbell

if nargin<2,  centroids=data(1).centroids; end

if length(data)>1
    [masks,centroids]=centroids2masks(data(1),centroids);
    for ii=1:length(data)
        if isempty( strmatch('KCmasks',properties(data(ii))) )
                addprop(data(ii),'KCmasks');
        end    
        if isempty( strmatch('centroids',properties(data(ii))) )
                addprop(data(ii),'centroids');
        end    

        if isempty(data(ii).ROI)
            r=1;
        else
            r=strmatch('soma',{data(ii).ROI.notes});
            if isempty(r), r=length(data(ii).ROI)+1; end            
        end
        
        data(ii).ROI(r).level=nan;
        data(ii).ROI(r).roi=masks;
        data(ii).ROI(r).notes='soma';
        data(ii).ROI(r).backgroundLevel=0;
        data(ii).ROI(r).centroids=centroids;

        end
        if nargout>=1, varargout{1}=masks; end
        if nargout>=2, varargout{2}=centroids; end

    return
end

    


verbose=0;

%Do we have Z-Stack or a T-Series?
if strmatch('TSeries ZSeries',data.info.type)
    TSeries=0;
elseif strmatch('TSeries',data.info.type)
    TSeries=1;
elseif strmatch('ZSeries',data.info.type)
    TSeries=0;
end





%Calculate masks
if TSeries, chalk(''), end  %clear last message


lengthZ=length(data.info.positionCurrent_XAxis);
masks=zeros([data.info.pixelsPerLine,...
             data.info.linesPerFrame,...
             lengthZ]);

if ~TSeries
    n=1;
    textprogressbar('Making mask ')
    textprogressbar(0)
    
    if size(centroids,2)<4
        centroids(:,4)=1:length(centroids);
        doDepth=1;
    else
        doDepth=0;
    end
    
    for depth=1:lengthZ
        
        if doDepth
            cF=find(round(centroids(:,3))==depth);
            centroids(cF,4)=depth;
        else
            cF=find(centroids(:,4)==depth);
        end

        cTMP=centroids(cF,:);
        [masks,n,cTMP]=addMasks(data,cTMP,masks,n,depth);
        centroids(cF,:)=cTMP; %to replace overlapping-ROI centroids with nans
        textprogressbar(round((depth/lengthZ)*100))


        
        if verbose
            uM=unique(masks(:,:,depth));
            uM(uM==0)=[];
            uM=length(uM);
            fprintf('\n%d/%d There are n=%d centroids and n=%d masks\n',...
                    depth,lengthZ, ...
                    sum(~isnan(centroids(cF,1))),uM )
            
            imagesc(masks(:,:,depth))
            hold on
            plot(centroids(cF,1),centroids(cF,2),'or', ...
                 'markerfacecolor','w')
            hold off
            axis equal tight off
            drawnow
        end
    
    end
    textprogressbar(' done')
else
    [masks,n,centroids]=addMasks(data,centroids,masks,1,1);
end

if verbose
    Um=unique(masks(:)); Um(Um==0)=[];
    fprintf('There are n=%d centroids and n=%d masks\n',...
            length(centroids),length(Um) )
end

masks=uint16(masks);


% Report removed centroids. I don't know why I still get touching ROIs
% even though these ought to be removed here. 
f=isnan(sum(centroids,2));
initialL=length(centroids);
if sum(f)>0
    centroids(f,:)=[];
    fprintf('Removed %d/%d centroids to avoid overlapping ROIs\n',...
            sum(f),initialL)            
end


if nargout>=1, varargout{1}=masks; end
if nargout>=2, varargout{2}=centroids; end


%---------------------------------------------------------------------%
function [masks,n,centroids]=addMasks(data,centroids,masks,n,depth)
blank=ones(size(masks,1),size(masks,2));
for ii=1:size(centroids,1)
    [II,JJ]=find(getdisk(blank,centroids(ii,1:2),data.centroidProps.cellDiam/2));

    %Don't add if it will overly another cell
    tmp=masks(II,JJ,depth);
    if sum(tmp(:))>0
        centroids(ii,:)=nan;
    else        
        masks(II,JJ,depth)=n; 
        n=n+1;    
    end

end


%----------------------------------------------------------------------
function currmask=getdisk(im,point,radius)
theta = -pi:0.1:pi ;
Xcrds = fix (point(1,1) + radius * cos(theta) );
Ycrds = fix (point(1,2) + radius * sin(theta) );
currmask = roipoly(im, Xcrds, Ycrds);

    


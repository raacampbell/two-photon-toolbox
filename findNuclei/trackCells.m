function out=trackCells(stats,data,out)
% Identify cell bodies based upon a t-series or a TZ-series
%
% function out=trackCells(stats,data,out)
%
% stats - output of findNuclei
%
% can feed in "out" back in order to display it without
% re-calculating. Like other such functions, the twoPhoton data
% object in the workspace is modified automatically, without
% needing to output it. 
% 
% Rob Campbell
%


verbose=0;

out.intensityThreshold=0.01; %Remove any centroids where the mean
                             %intensity is less then this value
% The following pulls out the GFP
im=squeeze(mean(data(1).imageStack(:,:,data(1).preFrames),3));



if nargin<3
    if ~stats(1).tseries
        chalk('Finding Centroids\n',1)
    end
    
    C=[];
    I=[];
    
    %pool all centroids over all time volumes
    for ii=1:length(stats)
        C=[stats(ii).centroid;C];
        L=length(stats(ii).centroid);
        I=[repmat(ii,L,1),transpose(1:L);I];
    end
    
    
    %Convert centroid pixel positions to microns
    C = C.*repmat(stats(1).resolution(1:size(C,2)),length(C),1);
    
    
 
    
    %the maximum distance over which points will be
    %considered to have arisen from the same cell. In a good 2-D
    %t-series this should be <=2 (that's um). For the Z-series,
    %there is greater spread in z. A rough value of 5 may work for
    %now but later we'll need to modify this code to deal
    %seperately with distances in x/y and in z. 
    xyThresh=1.5; 
    zThresh=4; 

    
    
    
    out.centroid=[];
    out.tseries=stats(1).tseries;
    tmpC=C;
    tmpI=I;
    
    
    ii=1;
    while length(tmpC)>2
        
        %Remove this row
        f=find(tmpI(:,1)==I(ii,1) & tmpI(:,2)==I(ii,2));
        tmpI(f,:)=[];
        tmpC(f,:)=[];
        
        
        try %I don't understand why it fails. Use try/catch for now
            %They should be close in x/y
            xyD = sum((tmpC - repmat(C(ii,:),length(tmpC),1)).^2,2);
            xyD = sqrt(xyD);
            
            %And we'll be a little more tolerant about z
            if size(tmpC,2)>2
                zD = (tmpC(:,3) - repmat(C(ii,3),length(tmpC),1)).^2;
                xyD = sqrt(xyD);
            end
            
        catch
            break
        end
        
        f=find(xyD<=xyThresh & zD<=zThresh);
        
        if ~isempty(f)
            out.centroid=[out.centroid;mean(tmpC(f,:),1)];
            tmpC(f,:)=[];
            tmpI(f,:)=[];
        end
        
        ii=ii+1;
        
    end
    
    
    %Add some useful variables to the structure
    out.imSize=size(im);
    out.resolution=stats(1).resolution;    
    out.cellDiam=stats(1).cellDiam;
    out.index=stats(1).index;
    
    %Merge centroids which are too close together. This may result
    %in errors since it could put a centroid half way between two
    %cells. Another possibility is just to remove these centroids. 
    %First return to pixels
    out.centroid=out.centroid./...
        repmat(out.resolution(1:size(out.centroid,2)),...
               length(out.centroid),1);

    out=interCellDistances(out);        %add the inter-cell distances
    out=highlightCloseCentroids(out,1); %mark centroids which are close
    
    merge=1;
    if merge
        out=mergeCloseCentroids(out);
        out=interCellDistances(out);
        c=out.centroid;
    end
    
    
end

return
%Get masks
initialL=length(out.centroid);
[out.masks,out.centroid]=centroids2masks(data,out.centroid);




%----------------------------------------------------------------------
%Remove ROIs with low signal 

%Work out the dF/F for each cell
masks=out.masks(:);
Umasks=unique(out.masks);
Umasks(Umasks==0)=[];
numCells = length(Umasks(:));

kcDFF = ones(numCells,1);

mu=ones(1,length(Umasks));
for ii = 1:length(Umasks)
    m=Umasks(ii);  
    mu(ii) = mean(im(find(out.masks==m)));
    if mu(ii)<out.intensityThreshold
        out.masks(out.masks==ii)=0;
    end    
end
f=find(mu<out.intensityThreshold);


if ~isempty(f)
    fprintf('Removed %d/%d centroids due to low signal strength\n',...
            length(f),initialL)            
    out.centroid(f,:)=[];
    %    out=interCellDistances(out);
    mu(f)=[];
end

%subplot(1,2,1),hist(mu,200)
%Umasks=unique(out.masks);
%Umasks(Umasks==0)=[];
%subplot(1,2,2)
%plot(out.centroid(:,4)-single(Umasks),'-r','linewidth',2)
%xlabel('# centroid')

return




%----------------------------------------------------------------------
% Plot the results
if ~stats(1).tseries
    subplot(1,2,1)
    TZseriesPlot(stats,1)
    hold on
    p3(out.centroid,{'or','markerfacecolor','r'})
    hold off

else
    clf
    subplot(1,2,1)
    hold on
    plot(out.centroid(:,1),...
         out.centroid(:,2),...
         'or', 'markerfacecolor',[1,0,0])

    for ii=1:length(stats)
        plot(stats(ii).centroid(:,1),...
             stats(ii).centroid(:,2),'.k')
    end
    hold off
    box on
        
end

subplot(1,2,2)
hist(out.distances(:),100)
xlabel('Inter-centroids distances [\mum]')









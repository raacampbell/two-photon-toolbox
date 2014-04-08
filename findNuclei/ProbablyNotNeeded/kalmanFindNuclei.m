function stats = kalmanFindNuclei(stats)
% function stats = kalmanFindNuclei(stats)
%
% This takes a vector of TZseries centroid stats structures and
% performs a kalman filter on the same frame across volumes. Then
% thresholds and works out the centroids again.



textprogressbar('Kalman filtering ')
s=size(stats(1).vol);
IM=nan([s(1:2),length(stats)]);
for SLICE=1:s(3)
    
    for FRAME=1:length(stats)    
        IM(:,:,FRAME)=stats(FRAME).vol(:,:,SLICE);
    end

    IM=Kalman_Stack_Filter(IM);    
    IM=IM/max(IM(:));
    
    %re-insert filtered versions
    for FRAME=1:length(stats)    
        stats(FRAME).vol(:,:,SLICE)=logical(im2bw(IM(:,:,FRAME),0.1));
    end
    
    textprogressbar(round( (SLICE/s(3))*100))
end
textprogressbar(' done ')


textprogressbar('Calculating centroids ')
for ii=1:length(stats)
    
    %[stats.vol stats.num]=bwlabeln(tmp);
    props=regionprops(stats(ii).vol);
    f=find([props.Area]<=3);
    props(f)=[];
    
    %Reshape the centroids into a nice matrix
    stats(ii).centroid=reshape([props.Centroid]',...
                               length(props(1).Centroid),...
                               length(props))';
    textprogressbar(round( (ii/length(stats))*100))
end
textprogressbar(' done ')



return


%K=ceil(K/max(K(:)));



threshold=0.5; %could implement GUI for interactive thresholding

chalk('Loading data',1)
chalk('')

%------------------------------------------------------------
% Process image-stack on a slice by slice basis. First filter to
% enhance cell bodies and then threshold
textprogressbar('Finding nuclei ')

dim=size(imageStack);
tmp=nan(dim);


%If it's a t-series, remove region outside ROI so that the very
%dark guys can't be picked up
if ~isempty(data(1).ROI)    
    for ii=1:dim(3)
        imageStack(:,:,ii)=imageStack(:,:,ii).*data(1).ROI.roi;
    end
end


verbose=0;
for ii=1:dim(3)
    xc = normxcorr2(template,imageStack(:,:,ii));
    if verbose
        subplot(1,2,1)
        imagesc(imageStack(:,:,ii)); colormap gray

        subplot(1,2,2)
        imagesc(xc); colormap jet, colorbar
        pause
    end
    
    trimxc=xc(trimSize:end-trimSize-mod(cellDiam,2),...
              trimSize:end-trimSize-mod(cellDiam,2));

    tmp(:,:,ii) = logical(im2bw(trimxc, threshold)); 
    %If it's a T-Series then we want to analyse the data on a frame
    %by frame basis, so let's do that here
    if TSeries
        [stats(ii).vol stats(ii).num]=bwlabel(tmp(:,:,ii));
        stats(ii).vol=single(stats(ii).vol);
        props=regionprops(stats(ii).vol);

        %Reshape the centroids into a nice matrix
        stats(ii).centroid=reshape([props.Centroid]',...
                                   length(props(1).Centroid),stats(ii).num)';

        stats(ii).cellDiam=stats(1).cellDiam;
        stats(ii).resolution=stats(1).resolution;
   end
    

    textprogressbar(round( (ii/dim(3))*100))
end
textprogressbar(' done ')




%------------------------------------------------------------
% Identify  cell bodies in 2-D or 3-D
if ~TSeries
    [stats.vol stats.num]=bwlabeln(tmp);
    stats.vol=single(stats.vol);
    stats.props=regionprops(stats.vol);
    
    %Reshape the centroids into a nice matrix
    stats.centroid=reshape([stats.props.Centroid]',...
                           length(stats.props(1).Centroid),stats.num)';
    stats.props=rmfield(stats.props,'Centroid');
    
    if doPlot == 1;
        plotKCvolume(stats)
    end
end

for ii=1:length(stats)
    stats(ii).centroid=single(stats(ii).centroid);
end

return
%add distances
for ii=1:length(stats)
    stats(ii)=interCellDistances(stats(ii));
    stats(ii)=highlightCloseCentroids(stats(ii));
end


%Because this field rapidly ends up taking way too much space
if ~TSeries
    stats=rmfield(stats,'distances');
end

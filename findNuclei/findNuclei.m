function stats = findNuclei(data,grandMean,doPlot)
% Identify cells based on nuclear-localised fluorescence
%                                           
% function stats = findNuclei(data,grandMean)
%
% Purpose
% Identifies individual neurons in a time-series or in a Z-stack
% using template matching to a Gaussian of similar SD to a KC,
% tested with nls::DsRed nuclear marker as signal.
%
% Inputs
% data    - two-photon object containing Z-stack
% grandMean - if 1 then take the mean of all acquired volumes and
%           calculate centroids based on this alone. 
% doPlot  - optional, produces schematized plot of cell body positions in
%           3D space - false by default
%
% Outputs
% stats contains the following fields:
% vol      - 3D image matrix of cells indexed by cell ID
% props    - structure output of regionprops of length num containing 3D
%            area, centroid, and bounding box
% num      - total number of cells identified
% cellDiam - the filter diameter in microns
%
% Kyle Honegger - August, 2010
% Rob Campbell - 2010/2011


%This doesn't work for a t-series, which produces one struct per
%frame. We need to sort this!

if nargin < 2 | isempty(grandMean), grandMean = 1; end
if nargin < 3, doPlot = 0; end




if length(data)>1 & ~grandMean
  for dInd=1:length(data)
      fprintf('%d/%d ',dInd,length(data))
      stats(dInd)=findNuclei(data(dInd));
  end
  return
elseif length(data)>1 & grandMean 
    
    fname=strrep(data(1).info.XMLfile,'.xml','_Zstacks.mat');
    if exist(fname,'file')
        load(fname)
    else
        zStack=saveZdepths(data);
    end
    zStack=single(zStack);

    mu=squeeze(mean(zStack,3));    
    SD=squeeze(std(zStack,[],3));    


    f=find(mu<1.5);
    SD(f)=0;
    fano=SD./mu;
    

    clf
    ind=round(1:size(mu,3)/3:size(mu,3));
    L=length(ind);
    n=1;
    for ii=1:L
        subplot(3,L,n),n=n+1;
        imshow(mat2im(mu(:,:,ind(ii)),gray(100)))
        axis off equal
    end
    
    
    fano=convn(fano,ones([2,2,1])*0.25,'same'); 
    mu(fano>0.25)=0;
    mu(mu<2)=0;
    


    for ii=1:L
        subplot(3,L,n),n=n+1;
        imshow(mat2im(mu(:,:,ind(ii)),gray(100)))
        axis off equal
    end

    
    stats=findNuclei(data(1),mu,1); %Recursive call
    return
end



%Do we have Z-Stack or a T-Series?
if strmatch('TSeries ZSeries',data(1).info.type)
    TSeries=0;
elseif strmatch('TSeries',data(1).info.type)
    TSeries=1;
elseif strmatch('ZSeries',data(1).info.type)
    TSeries=2;
end



%--------------------------------------------------------------
% THRESHOLDS
cellDiam = 6;    %in um
threshold=0.15; %normxcorr threshold for finding peaks
ROIlevel = 0.09; %if not already set
rejectSmallAreas=3; %cells with areas smaller than this are removed

if isempty( strmatch('centroidProps',properties(data)) )
        addprop(data,'centroidProps');
end    
data.centroidProps.cellDiam=cellDiam;
data.centroidProps.threshold=threshold;
data.centroidProps.ROIlevel=ROIlevel;
data.centroidProps.rejectSmallAres=ROIlevel;


%--------------------------------------------------------------
%Get the resolution in x,y, and z
resolution = [data.info.micronsPerPixel_XAxis,...
              data.info.micronsPerPixel_YAxis,...
              abs(mean(diff(data.info.positionCurrent_ZAxis2)))];



%The output structure
stats=struct('cellDiam', cellDiam,...
             'resolution', resolution,...
             'centroid', [],...
             'distances', [],...
             'closeCentroids', [],...
             'tseries', TSeries,...
             'index', data.info.stimIndex,...
             'vol',[],'props',[],'num',[]);


%The template is 2-D
templateDiam = double(round(stats.cellDiam/resolution(1)));
template = fspecial('gaussian',templateDiam,templateDiam/2);
trimSize = floor(templateDiam/2);



%load data from disk just once. Average if it's a TZseries
if length(grandMean)>1
    imageStack=grandMean;
    chalk('Processing grand mean',1)
else
    chalk('Loading data',1)
    imageStack=squeeze(data.imageStack(:,:,:,1,:)); %channel 1
end

%if ~TSeries==1,imageStack=squeeze(mean(imageStack,3)); end





%------------------------------------------------------------
%Remove region outside the brain using an ROI. If an ROI already
%exists, use that. 
if ~isempty(data(1).ROI) 
    
    roi=data(1).ROI.roi;
    if length(size(roi))==2 & TSeries %colapse TSeries to one frame
        imageStack=mean(imageStack,3);
        imageStack=imageStack.*roi;
    elseif size(roi,3)==size(imageStack,3)
        imageStack=imageStack.*double(roi);
    else
        fprintf('Can''t apply ROI, skipping...')
    end 
    
elseif ~TSeries %then it's a TZseries or a ZSeries
    chalk('Applying ROI')
                
    %Calculate and apply the ROI
    ROI=ROI_TZseries(imageStack,ROIlevel);
    imageStack=squeeze(imageStack.*ROI.roi);
end
chalk('')



%------------------------------------------------------------
% Process image-stack on a slice by slice basis. First filter to
% enhance cell bodies and then threshold
verbose=0;

dim=size(imageStack);
tmp=nan(dim);

if ~TSeries
    textprogressbar('Finding nuclei ')
else
    chalk('Finding nuclei')    
end


trimxc=tmp;
for ii=1:size(imageStack,3)
    xc(:,:,ii) = normxcorr2(template,imageStack(:,:,ii));
    if verbose
        subplot(1,2,1)
        imagesc(imageStack(:,:,ii)); colormap gray

        subplot(1,2,2)
        imagesc(xc); colormap jet, colorbar
        pause
    end
    
    T=squeeze(xc(:,:,ii));
    trimxc=T(trimSize:end-trimSize-mod(cellDiam,2),...
             trimSize:end-trimSize-mod(cellDiam,2));
    %        trimxc=xc(trimSize:end-trimSize,...
    %         trimSize:end-trimSize);

    tmp(:,:,ii)=logical(im2bw(adapthisteq(trimxc),threshold));
    
    if ~TSeries & length(size(dim))>2,textprogressbar(round( (ii/dim(3))*100)),end
end

if doPlot

    n=length(get(gcf,'children'));
    L=n/2;
    ind=round(1:size(tmp,3)/3:size(tmp,3));
    n=n+1;
    for ii=1:L
        subplot(3,L,n),n=n+1;
        imagesc(tmp(:,:,ind(ii)))
        axis equal off
    end

end






%------------------------------------------------------------
% Identify  cell bodies in 2-D or 3-D
[stats.vol stats.num]=bwlabeln(tmp);
stats.vol=logical(stats.vol);
stats.props=regionprops(stats.vol);

f=find([stats.props.Area]<=rejectSmallAreas);
stats.props(f)=[];


%Reshape the centroids into a nice matrix
stats.centroid=reshape([stats.props.Centroid]',...
                       length(stats.props(1).Centroid),...
                       length(stats.props))';

stats.props=rmfield(stats.props,'Centroid');

STR=sprintf(' %d cells',size(stats.centroid,1));
if ~TSeries
    textprogressbar(STR)
else
    chalk([STR,'\n'])
end


if doPlot == 1;
    %    plotKCvolume(stats)
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

function stats = extractCentroidsFromEachFrame(data,doPlot)
%
% This code extracts the centroids from each time slice of a
% t-series or each volume of a TZseries. We can then try to use
% these centroids for estimating brain motion in order to calculate
% the motion-correction transformation. Identifies cells based on
% nuclear-localised fluorescence. This is mainly a direct copy of
% code already present in findNuclei. Eventually we will want just
% one copy of this code. 
%                                           
% function stats = extractCentroidsFromEachFrame(data,doPlot)
%
% Purpose
% Identifies individual neurons in a time-series or in a Z-stack
% using template matching to a Gaussian of similar SD to a KC,
% tested with nls::DsRed nuclear marker as signal.
%
% Inputs
% data    - two-photon object containing Z-stack
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


%This doesn't work for a t-series, which produces one struct per
%frame. We need to sort this!
if length(data)>1
  for dInd=1:length(data)
      fprintf('%d/%d ',dInd,length(data))
      stats(dInd,:)=extractCentroidsFromEachFrame(data(dInd));
  end
  return
end


if nargin < 2
    doPlot = 0;
end


%Do we have Z-Stack or a T-Series

if strmatch('TSeries ZSeries',data(1).info.type)
    TSeries=0;
elseif strmatch('TSeries',data(1).info.type)
    TSeries=1;
elseif strmatch('ZSeries',data(1).info.type)
    TSeries=0;
end



%--------------------------------------------------------------
% THRESHOLDS
cellDiam = 5;    %in um
threshold=0.5; %normxcorr threshold for finding peaks
rejectSmallAreas=5; %cells with areas smaller than this are removed


%--------------------------------------------------------------
%Get the resolution in x,y, and z
resolution = [data.info.micronsPerPixel_XAxis,...
              data.info.micronsPerPixel_YAxis,...
              abs(mean(diff(data.info.positionCurrent_ZAxis)))];



%The output structure
stats=struct('cellDiam', cellDiam,...
             'resolution', resolution,...
             'centroid', [],...
             'distances', [],...
             'closeCentroids', [],...
             'tseries', TSeries,...
             'vol',[],'props',[],'num',[]);


%The template is 2-D
templateDiam = round(stats.cellDiam/resolution(1));
template = fspecial('gaussian',templateDiam,templateDiam/2);
trimSize = floor(templateDiam/2);




%load data from disk just once. Do not average over time, because
%we care about each volume. 
chalk('Loading data',1)
imageStack=squeeze(data.imageStack(:,:,:,1,:)); %channel 1


%------------------------------------------------------------
% There is an ROI step here in findNuclei.m
% We aren't going to retain an ROI here, since if there is a lot of
% motion the ROI will be useless unless calculated for each
% frame. We will also try an ROI-based method for doing motion
% correction, but that will come later. 



%------------------------------------------------------------
% Find centroids
dim=size(imageStack);
tmp=single(zeros(dim));

chalk('')
textprogressbar('Finding nuclei ')

for ii=1:dim(3) %This is time for both a T- and a TZ- series

    if ~TSeries
        for jj=1:dim(4) %z-depth in the TZ-series volume
            xc=normxcorr2(template,squeeze(imageStack(:,:,ii,jj)));
            trimxc=xc(trimSize:end-trimSize-mod(cellDiam,2),...
                      trimSize:end-trimSize-mod(cellDiam,2));
            %trimxc=xc(trimSize:end-trimSize,...
            %          trimSize:end-trimSize);
            tmp(:,:,ii,jj) = logical(im2bw(trimxc, threshold)); 
        end

    elseif TSeries
        xc = normxcorr2(template,imageStack(:,:,ii));
        trimxc=xc(trimSize:end-trimSize, trimSize:end-trimSize);
        
        tmp(:,:,ii) = logical(im2bw(trimxc, threshold)); 

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
% Identify  cell bodies in 3-D
if ~TSeries
    for ii=1:size(tmp,3)
        [stats(ii).vol stats(ii).num]=...
            bwlabeln(squeeze(tmp(:,:,ii,:)));
        stats(ii).vol=logical(stats(ii).vol);
        stats(ii).props=regionprops(stats(ii).vol);
        
        f=find([stats(ii).props.Area]<=rejectSmallAreas);
        stats(ii).props(f)=[];

        %Reshape the centroids into a nice matrix
        stats(ii).centroid=reshape([stats(ii).props.Centroid]',...
                                   length(stats(ii).props(1).Centroid),...
                                   length(stats(ii).props))';
        stats(ii).props=rmfield(stats(ii).props,'Centroid');
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

function stats = volumeKCs(data,doPlot)
% Identify cells based on nuclear-localised fluorescence
%                                           
% function stats = volumeKCs(data,doPlot)
%
% Purpose
% Identifies individual neurons in a Z-stack using template matching to a
% Gaussian of similar SD to a KC, tested with nls::DsRed nuclear
% marker as signal.
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
% Kyle Honegger - August, 2010



if nargin < 2
    doPlot = 0;
end


%--------------------------------------------------------------
%Get the resolution in x,y, and z
%Should be square frames. If not, alert user that frames should be
%square for best results (or implement creation of an elliptical
%template).
% pixel resolution in x,y, and z
resolution = [data.info.micronsPerPixel_XAxis,...
              data.info.micronsPerPixel_YAxis,...
              abs(mean(diff(data.info.positionCurrent_ZAxis)))];

if resolution(1) ~= resolution(2)
    disp('NOTE: Image is not square.')
end


cellDiam = 4;    %in um

%The output structure
stats=struct('cellDiam', cellDiam, 'resolution', resolution,...
             'vol',[],'props',[],'num',[]);



templateDiam = round(stats.cellDiam/resolution(1));

template = fspecial('gaussian',templateDiam,templateDiam/2);
trimSize = floor(templateDiam/2);



threshold=0.5; %could implement GUI for interactive thresholding

chalk('Loading data',1)
imageStack=data.imageStack; %load data from disk just once
chalk('')

%------------------------------------------------------------
% Process image-stack on a slice by slice baisis. Firsr filter to
% enhance cell bodies and then threshold
textprogressbar('Processing image stack ')

dim=size(imageStack);
tmp=nan(dim);
for ii=1:dim(3)
    xc = normxcorr2(template,imageStack(:,:,ii));
    trimxc=xc(trimSize:end-trimSize-1,trimSize:end-trimSize-1);
    tmp(:,:,ii) = logical(im2bw(trimxc, threshold)); 
    textprogressbar(round( (ii/dim(3))*100))
end
textprogressbar(' done ')




%------------------------------------------------------------
% Identify  cell bodies in 3-D 
[stats.vol stats.num]=bwlabeln(tmp);
stats.vol=single(stats.vol);
stats.props=regionprops(stats.vol);


% In cases where a single cell has been assigned to two seperate
% volumes we will want to merge. This is probably best done in
% subsequently. We will decide on a single, standard, volume for
% all cells and place this at the centroid. In cases where we
% merge, we will simply replace the centroids with their mean and
% place the volume in that location. 


if doPlot == 1;
    plotKCvolume(stats.props)
end

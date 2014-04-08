function imageStack=scanimageTIFF2Stack(data)
% Convert ScanImage TIFF into an image stack
%
% function imageStack=scanimageTIFF2Stack(data)
%
% Example:
% function imageStack=scanimageTIFF2Stack(data)
%
%
% Rob Campbell - August 2012


if length(data)>1
    error('data should have length of 1')
end

if isunix, slash='/'; else, slash='\'; end

%We will make a 4-D matrix: x/y images with
%time in dimension 3 and PMT channel in dimension 4. 
%imFname=[data.info.rawDataDir,slash,data.info.Filename];
imFname=data.info.Filename;
[imageStack,imageInfo]=load3Dtiff(imFname);

bitDepth=14; %this is the maximum value in ScanImage
imageStack=imageStack/2^bitDepth; %to normalise image 

meta(1)=readScanImageMeta(imageInfo(1).ImageDescription);
nChan=meta(1).acq.numberOfChannelsSave;
nFramesActual=size(imageStack,3); %Number of frames recorded

for ii=1:nChan
    tmp(:,:,1:nFramesActual/nChan,ii)=imageStack(:,:,ii:nChan:size(imageStack,3));
end
imageStack=single(tmp); %Takes up half the space of an array of doubles

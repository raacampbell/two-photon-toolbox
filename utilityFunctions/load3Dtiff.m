function [imageStack,imageInfo]=load3Dtiff(FileName,frames)
% Load multi-image tiff from disk 
% 
%function [imageStack,imageInfo]=load3Dtiff(FileName,frames)  
%
% PURPOSE
% Load a 3D stack (e.g. those exported by ImageJ) as a 3-D matrix. 
% If you have multiple channels then you may need to separate these
% manually since ImageJ will interleave them. 
%
% INPUTS
% FileName - a string specifying the full path to the tif you wish
% to import.  
% frames - optional. By default the function loads all frames. If
% frames is present in loads only the frames defined by this
% vector. e.g. if frames is 1:10 then the first ten frames are loaded.
%
% OUTPUTS
% imageStack - a 3-D matrix of frames extracted from the file. 
% imageInfo - lots of information about the images [optional]
%
% NOTES
% We will output a matrix of singles since double precision
% isn't needed and takes up twice the space. You may, therefore,
% need to convert to double from time to time.
%
%
% Rob Campbell, March 2009

if nargin<2
    frames=[];
end

imageInfo=imfinfo(FileName);

%Number of columns in structure is equal to the number of frames (but
%sometimes it seems to be a row vector);
numFrames=length(imageInfo);


if nargin<2 %Load all frames
    imSize=[imageInfo(1).Height,imageInfo(1).Width,numFrames];
    imageStack=single(zeros(imSize));

    parfor frame=1:numFrames
        OriginalImage=single(imread(FileName,frame));
        imageStack(:,:,frame)=OriginalImage;
    end

else %load sub-set of frames

    f=find(frames>numFrames | frames<1);
    frames(f)=[];
    if length(frames)<1
        error('No frames selected');
    end
    
    imSize=[imageInfo(1).Height,imageInfo(1).Width,length(frames)];
    imageStack=single(zeros(imSize));

    for ii=1:length(frames)
        frame=frames(ii);
        OriginalImage=single(imread(FileName,frame));
        imageStack(:,:,frame-frames(1)+1)=OriginalImage;
    end
    
end


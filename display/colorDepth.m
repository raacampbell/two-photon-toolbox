function varargout=colorDepth(imageMatrix,cmap,bitDepth)
% Produce colour-coded depth plot of a z-stack
%
% function imageMatrix=colorDepth(imageMatrix,cmap,bitDepth)
%
% Purpose
% A clone of the colour-coded PrairieView depth view. Different
% depths are coded as different colours. When applied to a time
% series, can be used to highlight neural activation times as
% different colours. 
%
% Inputs
% * imageMatrix - a 3-D matrix containing an image-stack or
% z-stack. 
% * cmap -[optional] a colormap matrix. If not defined, a jet
% colour scheme is used. 
% * bitDepth - [optional] zero by default. If zero, imageMatrix
% contains numbers from zero to one only. If imageMatrix contains
% non-normalised raw data then we can use bitDepth to normalise by
% the bit depth. 
% 
% Output
% imageMatrix - [optional] returns the image matrix. 
%
% Example  
% e.g. colorDepth(data,hot(size(data,3)));
%      colorDepth(data);
%
% Also See: colorResponse
% Rob Campbell, 2009


error(nargchk(1,3,nargin));
  
if nargin<2 | isempty(cmap)
    cmap=jet(size(imageMatrix,3));
end

if nargin<3
  bitDepth=0;
end


  

imageMatrix=repmat(imageMatrix,[1,1,1,3]);
for i=1:size(imageMatrix,3)
  color=cmap(i,:);
  for j=1:3, imageMatrix(:,:,i,j)=imageMatrix(:,:,i,j)*color(j); end
end


%Max intensity projection
imageMatrix=max(imageMatrix,[],3);

imageMatrix=squeeze(imageMatrix);

%Need to convert to the right range to display the image
if bitDepth>0
  imageMatrix=imageMatrix/2^bitDepth; %2^N bits
end

imageMatrix=double(imageMatrix);


if nargout==1
  varargout{1}=imageMatrix;
end

%Plot
if max(imageMatrix(:))>1
  imageMatrix=imageMatrix/max(imageMatrix(:));
  disp('Warning: colorDepth is normalising out of range image')
end

imshow(imageMatrix)


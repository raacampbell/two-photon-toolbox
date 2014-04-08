function timeCourse=roiTimeCourse(imageStack,ROI)
% mean pixel intensity over time from a defined ROI
%
%  function timeCourse=roiTimeCourse(imageStack,ROI)
%
% Purpose
% Calculates mean pixel intensity over time in a defined ROI from
% an imageStack time series.
%
% Inputs
% * imageStack - a 3-D matrix (stack) of frames with time as the 3rd
%  dimension.
% * ROI - a 2-D mask of dimensions size(imageStack,1) by
%  size(imageStack,2). 
%
% Outputs
% * timeCourse - a vector of mean pixel intensities within the ROI
%              taken along the 3rd dimension of imageStack. 
%
% Rob Campbell, August 2009


if nargin<2
    ROI=ones(size(imageStack,1),size(imageStack,2));
end

if max(ROI(:))>1
    ROI(ROI>1)=1;
end

timeCourse=ones(1,size(imageStack,3));  
roiArea=sum(ROI(:));

%average down extra dimensions until we have only time
imageStack=averageDownIm(imageStack);

for ii = 1:size(imageStack,3)
  ROIOriginal=imageStack(:,:,ii).*ROI;
  timeCourse(ii) =  sum(ROIOriginal(:)) / roiArea;
end



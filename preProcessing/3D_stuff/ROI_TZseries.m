function ROI=ROI_TZseries(imageStack,level)
% function ROI_TZseries(imageStack,level)
%
% Produce a binary ROI from volume data.
% imageStack is [x,y,depth] and the mean of all time points
%
%

if nargin<2
    level=0.1;
end


roi=ones(size(imageStack));
for ii=1:size(roi,3)
    for jj=1:size(roi,4)
        
        roi(:,:,ii,jj) = logical(im2bw(imageStack(:,:,ii,jj),level));
    
        st=strel('disk',4); 
        roi(:,:,ii,jj)=imclose(roi(:,:,ii,jj),st);
        roi(:,:,ii,jj)=imerode(roi(:,:,ii,jj),st);
        
        st=strel('disk',3); 
        roi(:,:,ii,jj)=imdilate(roi(:,:,ii,jj),st);
    end
end




ROI.level=level;
ROI.roi=roi;
ROI.notes='auto-detected TZ ROI. DO NOT DELETE ME';
ROI.backgroundLevel=[];

function centroid=ROI2centroid(ROI)
% function centroid=ROI2centroid(ROI)
%
%
% Return centroid location of each cell in pixels. 
%
% Rob Campbell - February 2011


U=unique(ROI);
U(U==0)=[];


centroid=ones(length(U),3);
for ind=1:length(U)
    
    [ii,jj,kk]=ind2sub(size(ROI), find(ROI==U(ind)));
    centroid(ind,:)=[mean(jj),mean(ii),mean(kk)];

end

    
centroid=centroid(:,1:length(size(ROI)));

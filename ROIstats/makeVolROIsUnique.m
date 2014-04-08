function makeVolROIsUnique(data,roiIndex)
% function makeVolROIsUnique(data,roiIndex)
%
% Purpose
% If the recording contains multiple depths which are treated
% separately, then one may end up with non-unique ROI names. This
% function goes through all the depths and makes the ROI names
% unique. 
%
% Inputs
% data - twoPhoton object
% roiIndex - the index (numerical scalar) to work on. By default,
% this is 2. 
%
%
% Rob Campbell


if nargin<2 
    roiIndex=2;
end



if ~roiStability(data,roiIndex)
    error
end


roi=data(1).ROI(roiIndex).roi;

if size(roi,3)<2
    error('ROI is 2D')
end

verbose=0;

%Check if the ROIs are unique
if checkUnique(roi,verbose)
    fprintf('ROIs are already unique\n')    
    %    return
end



%First make ROIs within each slice go from 1 to n
for ii=1:size(roi,3)
    tmp=roi(:,:,ii);
    U=unique(tmp);
    U(U==0)=[];
    for jj=1:length(U)
        f=find(tmp==U(jj));
        tmp(f)=jj;
    end
    roi(:,:,ii)=tmp;    
end


%Otherwise fix 
m=max(unique(roi(:,:,1)));
for ii=2:size(roi,3)
    
    tmp=roi(:,:,ii);
    f=find(tmp>0);
    if length(f)==0, continue, end
    tmp(f)=tmp(f)+m;
    roi(:,:,ii)=tmp;

    m=max(tmp(:));

end


if ~checkUnique(roi,verbose)
    error('Failed to make ROIs unique for some reason')
end



%Now replace the the matrices
for ii=1:length(data)
    data(ii).ROI(roiIndex).roi=roi;
end






%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function isUnique=checkUnique(roi,verbose)

U=[];
for ii=1:size(roi,3)
    U=[U;unique(roi(:,:,ii))];
end



if verbose, disp(U), end
U(U==0)=[];

if length(U)==length(unique(U))
    isUnique=1;
else
    isUnique=0;
end

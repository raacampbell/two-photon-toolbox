function distanceCorrelation(data,ROIindex)
% Plot tuning correlation against distance in brain
%
%  function distanceCorrelation(data)
%
% Purpose
% Make a plot of tuning correlation against distance in the brain. 
%
% Inputs
% - data - twoPhoton data object
% - ROIindex - which ROI to use for the calulation. By default
% ROIindex is the string 'soma', but it can also be the index of
% the ROI    

%
% Rob Campbell - March 2010
  
if nargin<2 | isempty(ROIindex), ROIindex='soma'; end
if ischar(ROIindex)
    ROIindex=strmatch(ROIindex,{data(1).ROI.notes});
end

  
%Get the cell centers
  
masks=data(1).ROI(ROIindex).roi;
U=unique(masks(:));
U(U==0)=[];

%Get the x,y mean of each KC
cellPos=nan(length(U),2);
for ii=1:length(U)
  f=find(masks==U(ii));
  [x,y]=ind2sub(size(masks),f);
  cellPos(ii,1)=mean(y);
  cellPos(ii,2)=mean(x);
end


%Now generate a distance matrix
d=nan(length(U));
r=d;
kcMat=ROI_responseMatrix(data);
for ii=1:length(U)
  for jj=1:length(U)
    if jj>=ii, continue, end

    d(ii,jj)=sqrt(cellPos(ii,1)^2 + cellPos(jj,1)^2);
    c=corrcoef(kcMat(:,ii),kcMat(:,jj));
    r(ii,jj)=c(2);
  end
end


subplot(1,2,1), plot(d,r,'.k')
subplot(1,2,2), histCurve(r(:),30)


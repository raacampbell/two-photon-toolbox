function distanceCorrelation(data)
% Plot tuning correlation against distance in brain
%
%  function distanceCorrelation(data)
%
% Purpose
% Make a plot of tuning correlation against distance in the brain. 
%
% Inputs
% data - twoPhoton data object
%
%
% Rob Campbell - March 2010
  
  
  
%Get the cell centers
  
KCmasks=data(1).KCmasks;
U=unique(KCmasks(:));
U(U==0)=[];

%Ge x,y mean of each KC
cellPos=nan(length(U),2);
for ii=1:length(U)
  f=find(KCmasks==U(ii));
  [x,y]=ind2sub(size(KCmasks),f);
  cellPos(ii,1)=mean(y);
  cellPos(ii,2)=mean(x);
end


%Now generate a distance matrix
d=nan(length(U));
r=d;
kcMat=kcResponseMatrix(data);
for ii=1:length(U)
  for jj=1:length(U)
    if jj>=ii, continue, end

    d(ii,jj)=sqrt(cellPos(ii,1)^2 + cellPos(jj,1)^2);
    c=corrcoef(kcMat(:,ii),kcMat(:,jj));
    r(ii,jj)=c(2);
  end
end


subplot(1,2,1), plot(d,r,'ok')
subplot(1,2,2), hist(r(:),30)


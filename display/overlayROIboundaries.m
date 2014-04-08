function overlayROIboundaries(data,ROIindex)
% function overlayROIboundaries(data,ROIindex)
%
% Get the ROI boundary for each repeat and overlay all on the same
% graph. This is useful if different ROIs are selected across reps 
% and we want to see how stable they are. 
%
% Rob Campbell - Jan 2014, CSHL
  
if nargin<2
  ROIindex=1;
end

J=jet(length(data));

cla
hold on
for ii=1:length(data)
  bw=data(ii).ROI(ROIindex).roi;
  b=bwboundaries(bw);
  
  for jj=1:length(b)
    plot(b{jj}(:,2),b{jj}(:,1),'-','color',J(ii,:))
  end

end
hold off

axis equal
set(gca,'color','k','TickDir','Out',...
        'XTickLabel',[], 'YTickLabel',[])

axis ij

function plotROImap(data,stats)
% map and dF/F of each ROI. Useful for neuropil
%
% function plotROImap(data,stats)
%
% Purpose
% Makes pretty summary plot of the data produced by ROIstats.
% 
% Inputs  
% * data - one instance of the twoPhoton object
% * stats -  The ROI field to plot can be specified here. Either
%          as an index number (data.ROI(stats)) or as a name (see
%          the notes field in .ROI). By default stats is the
%          string "soma". 
%    
%
% Rob Campbell, September 2013


if nargin<2
    stats='soma';
end

if ischar(stats)
    stats=strmatch(stats,{data.ROI.notes});
end

%If stats is still empty then just set it to the first ROI
if isempty(stats)
    stats=1;
end

if ~isstruct(stats)
    notes=data.ROI(stats).notes;
    roi=data.ROI(stats).roi;
    stats=data.ROI(stats).stats;
else
    notes='';
end



overlayMean=0; %If 1 we overlay the mean into the colour plot



%First separate significant from non-significant
dff=stats.dff;
ind=1:size(dff,1);

sig=stats.sigRank;

dff(sig==0,:)=[];
ind(sig==0)=[];

%Sort by similarity
if size(dff,1)>1
  corrdist = pdist(dff, 'euclidean');
  corrlink = linkage(corrdist,'average');
  [H,b,perm] = dendrogram(corrlink);
  dff=dff(perm,:);ind=ind(perm);
end

  


fp=data.info.framePeriod;
X=(0:size(stats.dff,2)-1)*fp;





col=jet(length(ind));


%background image
clf
subplot(1,2,1)
im=data.info.muStack(:,:,end);
im=conv2(im,ones(2)/2^2,'same');
imagesc(im)
colormap gray
axis equal off


%add boundaries
hold on
for ii=1:length(ind)  
  tmp=roi;
  tmp(tmp~=ind(ii))=0;
  b=bwboundaries(tmp);
  if isempty(b)
    fprintf('ROI %d not found\n',ii)
  else    
    b=b{1};
    plot(b(:,2),b(:,1),'Color',col(ii,:))
  end
  
end
hold off


subplot(1,2,2)
hold on
for ii=1:length(ind)
  plot(X,dff(ii,:)+ii,'Color',col(ii,:),...
       'LineWidth',2)
end
hold off
xlabel('Time [s]')
xlim([0,max(X)])
set(gca,'YTick',1:length(ind),'YTickLabel',ind,...
        'Color',[1,1,1]*0.5)

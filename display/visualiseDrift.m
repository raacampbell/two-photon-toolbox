function varargout=visualiseDrift(data,stimName,im,reg)
% function [im,R]=visualiseDrift(data,stimName,im,reg)
%
% Purpose
% Plot correlation coefficient between all pairs of frames so we 
% can see where % is a stretch of stable repeats. 
%
%
% Inputs
% * data - twoPhoton object
% * stimName - the name of the stimulus field to use for dividing
%              up the data. 
% * stimName - optional, 'odour' by default.
% * im - if im is a 3-D image array then the correlation coefficients
% across frames (z) are calculated. im can also be a string,
% instructing the function which image data to extact. By default
% it's "mean" which causes it to use data.info.muStack, which is
% the average of the whole stack. This is stored to disk and so is
% faster. It can also be "baseline", which takes longer to build as
% the baseline frames need to be extracted from disk. So "mean" is
% default. im can also be a matrix where the 3rd dimension is equal
% to length(data).
% * reg -  which registration to show. by default it's the last
% registration. If raw data are commited to disk then this may not be
% an option (there will be only one depth)
%
% 
% Outputs
% * im - the raw data matrix extracted from the info.muStack arrays
% * R - the plotted cross-correlation matrix
% Rob Campbell 2012

if nargin<2 | isempty(stimName)
    stimName='odour';
end


if nargin<3 | isempty(im)
    im='mean';
end

if nargin<4
    reg=size(data(1).info.muStack,3);
end


if ~isstr(im) 
    imType='mean';
elseif isstr(im)
    imType=im;
end

if nargin<2 | isstr(im)
	im=extractImages(data,imType,reg);
end

im=flatenImage(im,2);




clf
c=corrcoef(im);
c=padarray(c,[1,1],nan,'post');
pcolor(double(c));
axis xy square
shading flat
colorbar 
colormap jet
set(gca,'TickDir','out')

%add stimulus blocks
S=getStimNames(data,stimName)
if isprop(data(1),'stim') && ~isempty(S)

    L=length(S.sInd);
    hold on
    
    for ii=L:L:length(data)
        plot([ii,ii]+1,ylim,'k-')
        plot(xlim,[ii,ii]+1,'k-')
    end

    hold off
    
    lab=0:L:length(data);
    set(gca,'XTick',lab+1,'XTickLabel',lab,...
            'YTick',lab+1,'YTickLabel',lab)
else
    fprintf('No stim field %s. Not adding odour blocks\n', stimName)
end


if nargout>0
    varargout{1}=im;
end
if nargout>1
    c(:,end)=[];
    c(end,:)=[];
    varargout{2}=c;
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function im=extractImages(data,imType,reg)

switch lower(imType)
  case 'baseline'
    im=data(1).baselineImage;
  case 'mean'
    im=data(1).info.muStack(:,:,reg);
end

im=repmat(im,[1,1,length(data)]);

for ii=2:length(data)
    
    switch lower(imType)
      case 'baseline'
        im(:,:,ii)=data(ii).baselineImage;
      case 'mean'
        im(:,:,ii)=data(ii).info.muStack(:,:,reg);
    end
end


function im=flatenImage(im,downSample)
downSample=2;
im(:,1:downSample:end,:)=[];
im(1:downSample:end,:,:)=[];
s=size(im);
im=reshape(im,[prod(s(1:2)),s(3)]);

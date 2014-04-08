function varargout=maskPlot(data,ROIindex,doPlot)
% Show activation of each cell in the mask using different colours.   
%
% function varargout=maskPlot(data,ROIindex,doPlot)
%
% Purpose
% Plot the outline of the main ROI and overlay the locations of the
% selected KCs. Fill those cells which responded
% signficantly. Colour-code the fills according to response
% magnitude of each cell. 
%
% Inputs
% * data - one or more (data are averaged) trials of the twoPhoton
% object which has been processed by kcDFF. 
% * ROIindex: which ROI to use for the calulation. By default
%   ROIindex is the string 'soma', but it can also be the index of
%   the ROI    
% * doPlot - 1 by default. 
%
% Outputs
% Optionally returns plot handles and image data. 
%
% Rob Campbell - 2010
  
  
if nargin<2, ROIindex='soma'; end
if nargin<3, doPlot=1; end
if ischar(ROIindex)
    ROIindex=strmatch(ROIindex,{data(1).ROI.notes});
end


sigR=[];
for ii=1:length(data)
    sigR=[sigR,data(ii).ROI(ROIindex).stats.sigResponses];
end
sigR=unique(sigR);

dff=zeros(size(data(1).ROI(ROIindex).stats.dff));
for ii=1:length(data)
    dff=dff+data(ii).ROI(ROIindex).stats.dff;
end
dff=dff./length(data);




%Select only the period during the response
startFrame=(2+data(1).stim.stimLatency)/data(1).info.framePeriod;
endFrame=((4+data(1).stim.stimDuration)/data(1).info.framePeriod)+startFrame;

startFrame=floor(startFrame);
endFrame=ceil(endFrame);




dff=mean(dff(:,startFrame:endFrame),2);


mask=data(1).ROI(ROIindex).roi;
tmp=mask;
for ii=1:length(dff)
    if sum(sigR==ii)
        mask(tmp==ii)=dff(ii);
    else
        mask(tmp==ii)=0;
    end
end


mask(mask==0)=nan;

if doPlot
    
    pcolor(mask)
    [B,L,N,A] = bwboundaries(tmp,'noholes');
    hold on
    pltP={'linewidth',0.5};
    for i=1:length(B)
        H.kc(i)=plot(B{i}(:,2),B{i}(:,1),'-k',pltP{:});
    end
    
    [B,L,N,A] = bwboundaries(data(1).ROI(1).roi,'noholes');
    hold on
    for i=1:length(B)
        H.bound(i)=plot(B{i}(:,2),B{i}(:,1),'k-','linewidth',2);
    end
    
    colormap jet
    hold off
    
    axis equal ij
    shading flat

    box on
    set(gca,'xtick',[],'ytick',[])
end


if nargout==1
    H.imdata=mask;
    varargout{1}=H;
end

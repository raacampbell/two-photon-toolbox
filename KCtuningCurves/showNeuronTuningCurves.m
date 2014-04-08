function kc=showNeuronTuningCurves(data,ROIindex,oneplot,doPlot)
% Find and plot all the "significant" tuning curves 
%
% function kc=showNeuronTuningCurves(data,oneplot,doPlot)
%
% Purpose
% Find all the "significant" tuning curves and plot them with
% asscociated error bars. 
%
% Inputs
% * data - 2 photon data object or it can be the kc struct outputed
%        by this function. In which case, plot this and don't sort
%        or do anything. 
% * ROIindex - which ROI to use for the calulation. By default
%   ROIindex is the string 'soma', but it can also be the index of
%   the ROI.
% * oneplot - [1 by default] 
%           1: each plot in it's own sub-plot. 
%           0: make a new plot for each significant response
%           if onplot is a vector of neuron indecies then plot each
%           neuron in the list on its own subplot. Does not search
%           for significant neurons in this instance. 
% * doPlot - 1 by default. if 0 then we only return the stuff that
%          would have been plotted.     
%
%
% Rob Campbell - Jan 2010

if isstruct(data), kc=data; end
if nargin<2, ROIindex='soma'; end
if nargin<3, oneplot=1; end
if nargin<4, doPlot=1; end

if ischar(ROIindex)
    ROIindex=strmatch(ROIindex,{data(1).ROI.notes});
end

if isvector(oneplot)
    plotInd=oneplot;
    oneplot=1;
end




if ~isstruct(data)
    
    %Get all KC tuning curves
    roi=plotROItuningCurves(data,'roi',ROIindex,'doplot',0); 
    
    %n=nNeurons2p(data);   %Find neurons with at least one
    %significant response
    n=neuronMeanVar(data,ROIindex,0);%Find neurons with significant responses to one odour

    if exist('plotInd','var')
        n.sigInd=plotInd;
    end
    
    for i=length(roi.neuronIndex):-1:1
        if sum(n.sigInd==roi.neuronIndex(i))==0 
            roi.plotData(:,i)  = [];
            roi.rawData(:,i,:) = [];
            roi.neuronIndex(i) = [];
            roi.sigResponses(:,i,:) = [];
        end    
    end
end

if ~doPlot, return, end



n=length(roi.neuronIndex);
s=numSubplots(n);

%We will highlight the parafin oil
oil=strmatch('paraffin',roi.odors);

clf

%Now find the neurons which responded significantly 
sigR=roi.rawData.*roi.sigResponses;


for i=1:n
    if oneplot
        subplot(s(1),s(2),i)
    else
        figure
    end
    
    hold on

    d=squeeze(roi.rawData(:,i,:))';
    tmp=squeeze(sigR(:,i,:));

    plot(d','-','color',[1,0.4,0.4])
    plot(tmp,'ro','markerfacecolor','r')


    shadedErrorBar([],d,{@nanmean,@SEM_calc},...
                   {'ob-','markerfacecolor',[0.3,0.3,1]},1);


    plot(oil,mean(d(:,oil)),'og','markersize',15,'linewidth',2)
    
    hold off
    box on
    fitAxesToData(0.05)
    xlim([0.9,size(d,2)+0.1])
    title(roi.neuronIndex(i))
end
    
    
if oneplot, makeAxesEqual, end

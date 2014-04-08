function out=neuronMeanVar(data,ROIindex,doPlot)
% mean and variance within stimulus for each cell
%
% function out=neuronMeanVar(data,ROIindex,doPlot)
%
% Purpose
% Calculate the mean and variance within stimulus for each
% neuron. Segregate neurons according to whether they were deemed
% significant or non-significant. 
%
% Inputs
% * data - the twoPhoton data structrue
% * ROIindex: which ROI to use for the calulation. By default
%   ROIindex is the string 'soma', but it can also be the index of
%   the ROI.
% * doPlot - optional, 1 by default
%
% Ouputs
% * out - a structure containing the data plotted.
% out.s is the number of significant neurons. These are the neurons that
% respond significantly at least half the time. [see code below]
% Note that the output of this function is more or less like
% plotKCtuningCurves output with some additional fields.  
%
% Rob Campbell - January 2009
%
% Also see: nNeurons2p, ROI_responseMatrix, plotROItuningCurves

if nargin<2, ROIindex='soma'; end   
if nargin<3, doPlot=0; end
if length(data)==1, doPlot=0; end

if ischar(ROIindex)
    ROIindex=strmatch(ROIindex,{data(1).ROI.notes});
end

if ~roiStability(data)
    disp('WARNING: ROIs are not consistent over trials')
end

p=plotROItuningCurves(data,'roi',ROIindex,'doplot',0);
p.std=nanstd(p.rawData,[],3);
p.var=nanvar(p.rawData,[],3);
if isfield(p,'sigResponses')
    p.nSig=nansum(p.sigResponses,3);
end



%What proportion are significant? Respond significantly at least
%thresh times. 
thresh=size(p.rawData,3)/2;


if doPlot & isfield(p,'sigResponses')

    ns=find(p.nSig(:)<thresh);    

    mu=p.plotData(:);
    s=p.var(:);
    plot(mu(ns),s(ns),'.k')
    

    f=find(p.nSig(:)>=thresh);    
    hold on
    plot(mu(f),s(f),'.r')
    hold off

    xlabel('mean')
    ylabel('variance')
    box on
    
    unityLine('b-');    

end



%The number and proportion of neurons with at least half of the
%responses to one odour significant. 
if isfield(p,'sigResponses')
p.n=size(p.nSig,2);
p.sigInd=max(p.nSig)>thresh; 
p.s=length(p.sigInd);
p.propSig=p.s/p.n;
end
p.thresh=thresh;

out=p;

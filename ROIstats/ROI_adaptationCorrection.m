function data=ROI_adaptationCorrection(data,ROI,doPlot)
% Corrects response adaptation using a linear model
%
% function [corrected,original]=ROI_adaptationCorrection(data,ROI,doPlot)
%
% Purpose
% Evoked reponses often adapt during the course of a presentation
% run. This adds substantial variance which isn't related to
% stimulus identity but to the fact that stimuli were presented
% closely in succession. For large, single, ROIs it makes some
% sense to correct for this as it may radically reduce the
% variance. This function does this and displays diagnostic plots. 
%
%
% Inputs
% data - the full data twoPhoton structure for one experiment
% ROI - the ROI to correct. If left blank we correct all ROIs
%       doPlot - 1 by default. If 1 show diagnostic plots. Can 
%       be a vector of ROI. 
%
%
% Ouputs 
% data - the orginal structure, with an extra field (correction) in
%        data.ROI.stats for the offsets we need to add to each
%        ROI. Note that this will probably work best for large
%        ROIs. Doing this on many cell bodies might results in
%        weirdness. 
%
%
% Rob Campbell - CSHL May 2013



if nargin<2
    ROI=1:length(data(1).ROI);
end
if nargin<3
    doPlot=0;
end



for ii=1:length(ROI)
    out=plotROItuningCurves(data,'roi',ROI(ii),'adaptCorrect',0,'doplot',0);
    c=addCorrection(out,0,doPlot);
    
    for jj=1:length(data)
        ind=c.ind(jj);
        data(ind).ROI(ROI(ii)).stats.correction=c.cor(jj);
    end
    
        
end




%Run correction for all ROIs within each odor
function out=addCorrection(R,robust,doPlot)
ind=R.oInd;

if robust
    method={'bisquare'};
else
    method={'ols'};
end


allCorrections=[];
for ii=1:length(ind) %iterate over odors
    data=R.rawData(:,ii,:);

    thisCorrection=[];
    for jj=1:size(data,2) %with one ROI this loop isn't obligatory
        y=data(:,jj);
        x=(1:length(y));
        
        [b,tmp]=robustfit(x,y,method{:});
        tmp.r=tmp.resid;
        tmp.beta=b;
        tmp.yhat = (x*b(2) + b(1))';
        
        tmp.y=y;
        tmp.corrected=y-tmp.yhat+mean(y);

        reg(jj)=tmp;
        correction(:,jj)=tmp.corrected-y;

        if doPlot
            plotModel(reg(jj))
            pause
        end
        
        
    end

    allCorrections=[allCorrections;correction];

    
end

ind=[ind{:}];
out.ind=ind(:);
out.cor=allCorrections;



function plotModel(reg)
subplot(1,2,1)
x=1:length(reg.r);
plot(x,reg.y,'ok','markerfacecolor',[0.5,0.5,1],'markersize',8)
hold on
plot(x,reg.yhat,'-b')


%plot(x,reg.corrected,'ko','markerfacecolor',ones(1,3)*0.5,'markersize',8)
hold off

subplot(1,2,2)
cla 
notBoxPlot([reg.y,reg.corrected],[],0.5,'orderedpatch')
set(gca,'XTickLabel',{'before','after'})

drawnow

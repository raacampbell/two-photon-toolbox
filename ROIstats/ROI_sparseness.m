function ROI_sparseness(data,ROIindex)
% sparseness plot
%
% function ROI_sparseness(data,ROIindex)
%
% Purpose
% Display KC sparsenes to summarise KC data from one
% recording. Make sure you have run addKC_stats(data)!
%
% Inputs
% data - twoPhoton data object
% ROIindex - which ROI to use for the calulation. By default
% ROIindex is the string 'soma', but it can also be the index of
% the ROI.
%
% Rob Campbell, August 2009 
% Updated: January 2009, January 2010
  

if nargin<2, ROIindex='soma'; end   
if ischar(ROIindex)
    ROIindex=strmatch(ROIindex,{data(1).ROI.notes});
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%------------------------------------------------------------
%Proportion of cells responding AT LEAST ONCE
odour=getOdourNames(data);
OUT=nNeurons2p(data,ROIindex);
activeCells=zeros(length(odour.oInd),OUT.n);

for i=1:length(odour.oInd)
    ind=odour.oInd{i};
    OUT=nNeurons2p(data(ind));
    activeCells(i,OUT.sigInd)=1;
end

% Plot by % KCs
ax(1)=subplot(2,2,1);
S=sum(activeCells,2)/size(activeCells,2)*100;
doBarPlot(S,0:10:50);
xlabel('% KCs responding'), ylabel('# Odours')
title('Significance by trial')

% Plot by % Odours
ax(2)=subplot(2,2,2);
S=sum(activeCells,1)/size(activeCells,1)*100;
doBarPlot(S,0:10:80)
xlabel('% Odours eliciting a response'), ylabel('# KCs')
title('Significance by trial')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%------------------------------------------------------------
%Proportion of cells responding at least half the time to one odour

OUT=neuronMeanVar(data,0);
activeCells=OUT.nSig>OUT.thresh;

% Plot by % KCs
ax(3)=subplot(2,2,3);
S=sum(activeCells,2)/size(activeCells,2)*100;
doBarPlot(S,0:10:50)
xlabel('% KCs responding'), ylabel('# Odours')
title('Significance by odour')

% Plot by % Odours
ax(4)=subplot(2,2,4);
S=sum(activeCells,1)/size(activeCells,1)*100;
doBarPlot(S,0:10:80)
xlabel('% Odours eliciting a response'), ylabel('# KCs')
title('Significance by odour')



makeAxesEqual(ax([1,3]))
makeAxesEqual(ax([2,4]))


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function doBarPlot(y,x)
[n,x]=hist(y,x);
bar(x,n,1);
delta=mean(diff(x));
fitAxesToData(0.05)
set(findobj(gca,'type','patch'),'facecolor',ones(1,3)*0.7)

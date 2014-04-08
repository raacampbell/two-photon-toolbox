function kc= mostLeastInformative(data,drop)
% function mostLeastInformative(data,drop)
%
% Plots tuning curves for the most and least informative neurons. 
% 
% drop - output of dropNeuronAnalysis




[pc,i]=sort(drop.pc);
n=4; %number of neurons from each category to be plotted. 


ind=[i(1:n),i((end-n+1):end)];
pc=pc([ 1:n,(end-n+1):end]);


kc=plotKCtuningCurves(data,[],0);

ind=mFind(kc.neuronIndex,ind);


kc.plotData=kc.plotData(:,ind);
kc.rawData=kc.rawData(:,ind,:);
kc.neuronIndex=kc.neuronIndex(ind);
kc.sigResponses=kc.sigResponses(:,ind,:);


showNeuronTuningCurves(kc);

c=get(gcf,'children');
pc=fliplr(pc);
for i=1:length(c) 
    set( get(c(i),'title'),'string',pc(i))
end

function out=neuronMeanVar(data,doPlot)
% mean and variance within stimulus for each cell
%
% function out=neuronMeanVar(data,doPlot)
%
% Purpose
% Calculate the mean and variance within stimulus for each
% neuron. Segregate neurons according to whether they were deemed
% significant or non-significant. 
%
% Inputs
% * data - the twoPhoton data structrue
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
% Also see: nNeurons2p, kcResponseMatrix, plotKCtuningCurves
    
if nargin<2, doPlot=1; end
if length(data)==1, doPlot=0; end

p=plotKCtuningCurves(data,[],0);
p.std=nanstd(p.rawData,[],3);
p.nSig=nansum(p.sigResponses,3);



mu=p.plotData(:);
s=p.std(:);
sig=p.nSig(:);

reps=size(p.rawData,3);


%What proportion are significant? Respond significantly at least
%thresh times. 
thresh=reps/2;

ns=find(sig<thresh);    
if doPlot, plot(mu(ns),s(ns),'.k'), end

f=find(sig>=thresh);    
if doPlot
    hold on
    %s=scatter(mu(f),s(f),10*(sig(f)+1),sig(f),'filled');
    plot(mu(f),s(f),'.r')

    hold off
    xlabel('mean')
    ylabel('\sigma')
    box on
    
    unityLine('b-');    

end



%The number and proportion of neurons with at least half of the
%responses to one odour significant. 
p.n=size(p.nSig,2);
p.sigInd=p.neuronIndex(max(p.nSig)>thresh); %because they're sorted!
p.s=length(p.sigInd);
p.propSig=p.s/p.n;

p.thresh=thresh;




out=p;

function neuronsWithSignificantLDs(data,nSig)
% function neuronsWithSignificantLDs(data,nSig)
%
% Purpose
% Let's see which are the significant tuning curves. 
% neurons have significant weightings for the LDA on the full data
% set. 
%
% Inputs
% data- twoPhoton data object 
% nSig - output of findSignificantWeightings
% 
% Rob Campbell, February 2009



out=plotKCtuningCurves(data,[],0);
error('THIS FUNCTION IS BROKEN SEE FILE')
%The following line doesn't work because ind may not be the
%original index (if plotKCtuningCurves is sorting, which it may now
%not be. Basically, check that this is right!
% RC 06/05/2011
ind=out.neuronIndex;


%plot the significant guys
p=4; %How many significant weightings needed
subplot(1,2,1)
f=ind(nSig>p);
imagesc(out.plotData(:,f));
colorbar
C=get(gca,'CLim');

subplot(1,2,2)
f=ind(nSig<=p);
imagesc(out.plotData(:,f));
colorbar
set(gca,'CLim',C)

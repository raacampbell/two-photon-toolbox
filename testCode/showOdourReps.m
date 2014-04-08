function showOdourReps(data,odours)
% function showOdourReps(data,odours)
%
% Purpose
% Quick and dirty function to compare different repeats of two
% odours in two side by side colour plots. 
%
% Inputs
% data - twoPhoton object with KC stats
% odours - an optional vector of indicating which odours from
%          getOdourNames to use. 
%
%
% Rob Campbell, August 2009
  
error(nargchk(1,2,nargin))


S=getOdourNames(data);
if nargin<2, odours=1:length(S.uOdours); end


full=kcResponseMatrix(data);
out=neuronMeanVar(data,0);


for i=1:length(odours)
    odourR{i}=full(S.oInd{odours(i)},:);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Overlay the direction of each LD onto the responses to each odour. 

clf

N=numSubplots(length(odours));

for i=1:length(odours)

    subplot(N(1),N(2),i)

    plotDat=odourR{i};
    imagesc(rot90(plotDat))
    title(S.uOdours{odours(i)})
    axis equal tight
    set(gca,'TickDir','out','linewidth',2)
    
    hold on
    for i=1:size(plotDat)
        plot([i,i]-0.5,ylim,'-k','linewidth',2)        
    end
    hold off

end

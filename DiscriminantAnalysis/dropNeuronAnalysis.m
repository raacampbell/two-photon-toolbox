function out=dropNeuronAnalysis(stats,makePlot)
% function dropNeuronAnalysis(stats,makePlot)
%
% This is run on the output of classifyKCs which has the 'drop'
% noise type. This assess the impact on classification accuracy of
% removing each KC in turn. 
% 
% Inputs
% stats - output of classifyKCs
% makePlot [optional] - by default it equals 1 and makes the plot. 
%
%
% Rob Campbell, October 2009
    
if nargin<2,makePlot=1;end

if ~strcmp(stats.noiseType,'drop')
    error('noise type must be of class "drop"')
end


%Get the percent correct following dropping of each unit in turn
for i=1:length(stats.noise)
    pc(i)=stats.noise(i).percentCorrect;
end
pc=pc-stats.xValidMu.percentCorrect;

    
[n,x]=hist(pc,unique(pc));
if makePlot
    bar(x,n)
    
    %Pretty labels with rounded numbers
    x=round(x*10)/10;
    set(gca,'XTick',x,'XTickLabel',x)

    ylabel('Change in clasification accuracy (%)')
    xlabel('number of cells')
    
    H=findobj(gca,'type','patch');
    set(H,'facecolor',[1,1,1]*0.5)
    box on
    
    y=max(abs(x))+2;
    %    ylim([-y,y])

end


out.accuracyChange=[x;n];%For output
out.pc=pc; %The percent change






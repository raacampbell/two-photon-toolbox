function odourCorrelationPlot(data)
% function odourCorrelationPlot(data)
%
% Purpose
% Plot the correlation coefficient in the KC population response
% between different stimulus presentations. Groups responses to the
% same stimuli so that they can be more easily compared to
% responses from different stimuli.
% 
% Inputs
% data - the twoPhoton data object. 
%
% Rob Campbell - February 2010

full=kcResponseMatrix(data);
S=getOdourNames(data);

ind=[S.oInd{:}];


imagesc(corrcoef(full(ind(:),:)'));
axis xy



n=0;
hold on
for i=1:length(S.oInd)
    x=length(S.oInd{i});
    x=x+n;    

    ticks(i)=mean([x-length(S.oInd{i}),x])+0.5;
    
    p(1)=plot([x,x]+0.5,ylim,'-');
    p(2)=plot(xlim,[x,x]+0.5,'-');
    set(p,'linewidth',2,'color','k')
    n=n+length(S.oInd{i});
    
end
hold off

set(gca,'XTick',ticks,'YTick',ticks,...
        'YTickLabel',S.uOdours,'XTickLabel',[],...
        'LineWidth',2,'TickDir','out')
axis equal tight



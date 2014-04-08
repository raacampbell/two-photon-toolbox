function weightingOnDFF(data,stats)
% function weightingOnDFF(data,stats)  
%
% Show each neuron's weighting as a function of dF/F
%
%
% Rob Campbell, September 2009

noiseType='shufflepresentations';
if ~strcmp(lower(stats.noiseType),noiseType)
    fprintf(['Set noiseType to "shufflePresentations" to add noise ' ...
             'field to this graph\n'])
end



kcDff=kcResponseMatrix(data);
ldAxes=[stats.xValidMu.LDspace.ldAxis]';

clf
subplot(1,2,1)
out=neuronMeanVar(data,1);
title('red are significant')

subplot(1,2,2)
hold on
mu=mean(kcDff,1);
if strcmp(lower(stats.noiseType),noiseType)
    for ii=1:length(stats.noise)
        tmp=[stats.noise(ii).LDspace.ldAxis]';
        plot(mu,abs(mean(tmp,1)),'.r');
    end
end

A=abs(mean(ldAxes,1));
plot(mu,A,'ok','markerfacecolor',[1,1,1]*0.5,'markersize',8)

%Highlight the significant neurons

f=out.sigInd;
plot(mu(f),A(f),'o','color',[0,0.4,0],...
     'markerfacecolor',[0.5,1,0.5],'markersize',8)


hold off
box on
xlabel('mean dF')
ylabel('LD weighting')
title('green are significant')

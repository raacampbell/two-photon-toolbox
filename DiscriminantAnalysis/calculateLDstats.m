function stats=calculateLDstats(stats)
% function stats=calculateLDstats(stats)
%
% Purpose
% Calculate descriptive statistics for the data projected on LD
% space. 
%
% Inputs
% stats - the output of classifyKCs/calculateLDdirections
%
% Outputs
% The stats structure with fields added to describe the
% data along the LDs. 
%
%
% Rob Campbell, August 2009
%
% See also: classifyKCs, odourClassConfMat, odourLDaxes

  

  
  
% classifyKCs does various discriminant analyses. We calculate
% summary stats for the projections of the data onto all these
% directions. 


  
%Work out LD-related statistics for each set of analyses
stats.discrimFull=doLDcalc(stats.discrimFull,1);
stats.xValidMu=doLDcalc(stats.xValidMu,1);
fprintf('Calculating LD stats for xValidated data')
for i=1:length(stats.xValid.discrim)
    fprintf('.')
    stats.xValid=doLDcalc(stats.xValid,i);
end
fprintf('\nCalculating LD stats for noise data')
for i=1:length(stats.noise)
    fprintf('.')
    tmp(i)=doLDcalc(stats.noise(i),1);
end
fprintf('\n')

stats.noise=tmp;




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data=doLDcalc(data,index)

N=size(data.discrim(1).coef,1); %number of different classes
S=length(data.trueClass); %numer of different stimuli

axN=1;



for i=1:N
  for j=1:N


    if i<=j, continue, end
    %The F statistic is a measure of separability since it is the
    %ratio of the variance between groups over the mean variance
    %within groups. 
    y=[data.LDspace(axN,index).ld(data.LDspace(axN,index).ind1);...
       data.LDspace(axN,index).ld(data.LDspace(axN,index).ind2)];

    group=[zeros(1,length(data.LDspace(axN,index).ind1)),...
           ones(1,length(data.LDspace(axN,index).ind2))];
    [p,anovaTab]=anova1(y,group,'off');
    data.LDspace(axN,index).F=anovaTab{2,end-1};
    data.LDspace(axN,index).betweenVar=anovaTab{2,4};
    data.LDspace(axN,index).withinVar=anovaTab{3,4};

    %Also calculate the area under the ROC curve
    trueGroups=[zeros(1,length(data.LDspace(axN,index).ind1)),...
                ones(1,length(data.LDspace(axN,index).ind2))*2];

    %the decision boundary
    data.LDspace(axN,index).group1=data.LDspace(axN,index).ld(data.LDspace(axN,index).ind1);
    data.LDspace(axN,index).group2=data.LDspace(axN,index).ld(data.LDspace(axN,index).ind2);
    bound=mean([mean(data.LDspace(axN,index).group1),...
                mean(data.LDspace(axN,index).group2)]);
    
    group1=data.LDspace(axN,index).group1;
    group2=data.LDspace(axN,index).group2;
    
    %points to the "left" are deemed to be group2 and to the
    %"right" are group1
    predictedGroups=[group1;group2];
    tmp=predictedGroups;
    predictedGroups(tmp>bound)=0;
    predictedGroups(tmp<bound)=1;

    [tp,fp]=myRoc(trueGroups,predictedGroups);
    data.LDspace(axN,index).rocArea=auroc(tp,fp);

    %And now work out the area of overlap between fitted Gaussians
    x=[2*min(data.LDspace(axN,index).ld):max(data.LDspace(axN,index).ld)*2];
    gaus1=normpdf(x,mean(group1),std(group1));
    gaus2=normpdf(x,mean(group2),std(group2));
    
    overlap=sum(gaus1)+sum(gaus2)-sum(abs(gaus1-gaus2));
    overlap=overlap/(sum(gaus1)+sum(gaus2));
    data.LDspace(axN,index).gausOverlap=overlap*100; %as a percentage
    
    
    
    
    axN=axN+1;    
  end
end



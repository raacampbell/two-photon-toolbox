function odourLDaxes1(stats)
% function odourLDaxes1(stats)
%
% Purpose
% Project neural responses onto *single* LD axes where each axis
% seperates two groups. We can represent data from different flies
% on the same axis. 
%
% Inputs
% stats - the output of classifyKCs. Furthermore, fields relevant
% to the present function function must be added by
% calculatLDprojections. 
%
%
% Rob Campbell, August 2009


clf

stats=stats.xValidMu; %not x-validated

LDspace=stats.LDspace;

N=size(stats.discrim(1).coef,1); %number of different classes
S=length(stats.trueClass); %numer of different stimuli


side=ceil(sqrt(length(LDspace)));
ind=1:S;
g1Col=[1,0,0];
g2Col=[0,0.7,0];

for i=1:length(LDspace)
    subplot(side,side,i)
    
    group1=LDspace(i).group1;
    group2=LDspace(i).group2;
    
    %Plot histogram of the odours not captured by this direction 
    tmpInd=ind;
    tmpInd([LDspace(i).ind1,LDspace(i).ind2])=[];
    [n,x]=hist(LDspace(i).ld(tmpInd));
    bar(x,n)
    h=findobj(gca,'type','patch');
    set(h,'facecolor','k','edgecolor','k')
    

    hold on
    
    %Plot histogram of the data corresponding to group 1
    [n,x]=hist(group1,round(length(LDspace(i).ind1)/2));
    bar(x,n)
    h=findobj(gca,'type','patch');
    set(h(end-1),'facecolor',g1Col,'edgecolor',g1Col)
   

    
    %Plot histogram of the data corresponding to group 2
    [n,x]=hist(group2,round(length(LDspace(i).ind2)/2));
    bar(x,n)
    h=findobj(gca,'type','patch');
    set(h(end-2),'facecolor',g2Col,'edgecolor',g2Col)

    

    
    %Overlay Gaussians describing groups 1 and 2
    X=xlim;  X=X(1):X(2);


    y=normpdf(X,mean(group1),std(group1));
    y=y*(max(n)/max(y))*1.5; 
    plot(X,y,'-','linewidth',2,'color',g1Col)


    y=normpdf(X,mean(group2),std(group2));
    y=y*(max(n)/max(y))*1.5; 
    plot(X,y,'-','linewidth',2,'color',g2Col)


    %The location of the line that bisects the two groups
    m=mean([mean(group1),mean(group2)]);
    plot([m,m],ylim,'b--','linewidth',2)
    plot([m,m],ylim,'w:','linewidth',2)
    hold off

    box on

    ylabel(LDspace(i).id1,'color',g1Col)
    xlabel(LDspace(i).id2,'color',g2Col)
    title(sprintf('F=%3.1f; ROC=%0.2f;%2.1f%%',...
                  LDspace(i).F, ...
                  LDspace(i).rocArea,...
                  LDspace(i).gausOverlap))
    
    
  end
end



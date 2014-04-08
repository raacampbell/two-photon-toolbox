function odourLDaxes2(stats,comparison)
% function odourLDaxes2(stats,comparison)
%
% Purpose
% Project neural responses onto *two* LD axes where each axis
% seperates two groups. We can represent data from different flies
% on the same axis. 
%
% Inputs
% stats - the output of classifyKCs. Furthermore, fields relevant
% to the present function function must be added by
% calculatLDprojections. 
% comparison - which stimulus presentation to use as the basis for
%              plotting the others. 
%
% Rob Campbell, August 2009


clf
stats=stats.discrimFull; %not x-validated
LDspace=stats.LDspace;

N=size(stats.discrim(1).coef,1); %number of different classes
S=length(stats.trueClass); %numer of different stimuli



ind=1:S;
g1Col=[1,0,0];
g2Col=[0,0.7,0];
g3Col=[0,0.0,1];
c=ceil(sqrt(length(LDspace)));
n=1;
%for i=1%:length(LDspace)



U=unique(stats.trueClass);
J=jet(length(U));
colors=[];
for i=1:length(stats.trueClass)
  colors=[colors; J(strmatch(stats.trueClass{i},U),:)];
end


for j=1:length(LDspace)
  
  subplot(c,c,n)
  if comparison==j, continue, end
  
  scatter(LDspace(comparison).ld,LDspace(j).ld,40,colors,'filled')
  box on
  set(gca,'color',ones(1,3)*0.5,...
          'XTick',[],'YTick',[])
  xlabel(sprintf('%s/%s',LDspace(comparison).id1,LDspace(comparison).id2))
  ylabel(sprintf('%s/%s',LDspace(j).id1,LDspace(j).id2))
  n=n+1;    
end

subplot(c,c,n)

for i=1:length(U)
  text(0.2,i*0.1,U{i},'color',J(i,:))
end

set(gca,'color',ones(1,3)*0.5,...
        'XTick',[],'YTick',[])
box on
  %end
return


    
    
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

   
   



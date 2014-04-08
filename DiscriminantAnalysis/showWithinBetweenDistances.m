function varargout=showWithinBetweenDistances(data)
% function ratio=showWithinBetweenDistances(data)
%
% Purpose
% Show the relationship between within-groups and between-groups
% variance for a discriminant analysis. 
%
% data - for example is stats.xValid
%
% Rob Campbell - November 2009

N=size(data.discrim(1).coef,1); %number of different classes
S=length(data.trueClass); %numer of different stimuli
index=1;
axN=1;

for i=1:N
  for j=1:N


    if i<=j, continue, end

   
    g1=data.LDspace(axN,index).ld(data.LDspace(axN,index).ind1);
    g2=data.LDspace(axN,index).ld(data.LDspace(axN,index).ind2);

    pool=[g1;g2];
    

    within(axN)=(var(g1)+var(g2));
    between(axN)=var(pool);
    
    axN=axN+1;    
  end
    
end

fsize=12;

plot(log10(within),log10(between),'ow','markerfacecolor','k',...
    'MarkerSize',4,'linewidth',0.2)
a=[xlim,ylim]; a=[min(a),max(a)];

hold on
plot3(a,a,[-1,-1],':','color',[1,1,1]*0.5,'linewidth',1);

hold off

xlim(a)
ylim(a)
axis square
set(gca,'fontsize',fsize)
xlabel('log(within groups variance)','fontsize',fsize)
ylabel('log(between groups variance)','fontsize',fsize)


if nargout==1
    varargout{1}=mean(log(between)./log(within));
end

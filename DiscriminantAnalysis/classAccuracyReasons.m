function stats=classAccuracyReasons(stats)
% function stats=classAccuracyReasons(stats)
%
% Why are some odours being classified better than others? 
%
% Inputs
% stats - the output of classifyKCs then processed by odourClassConfMat
%
%
% Rob Campbell, August 2009
%
% See also: classifyKCs

  
clf  


%Proportion of correct responses
correct=diag(stats.confMat);
total=sum(stats.confMat,1);

correctp=correct(:)./total(:);
stimuli=unique(stats.trueClass);


%how many significant responses where there for each odour?
sigResp=[];
for i=1:length(stimuli)
  s=strmatch(stimuli{i},stats.trueClass);

  tmp=[];
  for j=1:length(s)
    tmp=[tmp,stats.raw(s(j)).sigResponses];
  end
  

  sigResp(i)=length(unique(tmp));

end




if isfield(stats,'OSN'),subplot(2,2,1),end
plot(sigResp,correctp,'ok','markersize',15,'markerfacecolor',ones(1,3)*0.7)
for i=1:length(sigResp)
  text(sigResp(i)+0.05,correctp(i)+0.05,stimuli{i})
end


ylim([-0.5,1.5])
set(gca,'YTick',[0:0.2:1])
X=xlim;
xlim([X(1),X(2)*1.1])


grid on,box on

xlabel('n significant responses')
ylabel('proportion correct classifications')


if isfield(stats,'OSN')
  subplot(2,2,2)
  plot(sigResp,mean(stats.OSN,2),'ok','markersize',15,...
       'markerfacecolor',ones(1,3)*0.7)
  xlabel('number sig. KC responses')
  ylabel('mean OSN activation')


  for i=1:length(sigResp)
    text(sigResp(i)+0.05,mean(stats.OSN(i,:)),stimuli{i})
  end
  grid on,box on



  subplot(2,2,3)
  plot(mean(stats.OSN,2),correctp,'ok','markersize',15,...
       'markerfacecolor',ones(1,3)*0.7)
  xlabel('mean OSN activation')
  ylabel('prop. correct classifications')


  for i=1:length(sigResp)
    text(mean(stats.OSN(i,:)),correctp(i),stimuli{i})
  end

  ylim([0,1.1])
  grid on,box on


  subplot(2,2,4)
  plot(log(mean(stats.OSN,2)),correctp,'ok','markersize',15,...
       'markerfacecolor',ones(1,3)*0.7)
  xlabel('log_{10}(mean OSN activation)')
  ylabel('prop. correct classifications')


  for i=1:length(sigResp)
    text(log(mean(stats.OSN(i,:))),correctp(i),stimuli{i})
  end

  ylim([0,1.1])
  grid on,box on
end


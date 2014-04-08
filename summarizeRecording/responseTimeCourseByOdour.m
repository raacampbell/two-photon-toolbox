function responseTimeCourseByOdour(data)
% response time courses grouped by odour
%
%  function responseTimeCourseByOdour(data)
%
% Generates one figure per odour. Each figure contains time courses for
% each repeats of each odour. To be used with report-generator function. 
%
% Rob Campbell, October 2009
  
[odours,Uo,occ]=getOdourNames(data);

fsize=14;
fprintf('Calculating odour time courses ');
ROIindex=strmatch('soma',{data(1).ROI.notes});

for i=1:length(Uo)
  fprintf('.');
  f=occ{i};
  J=jet(length(f));
  figure
  hold on
  for j=1:length(f)
    fp=data(f(j)).info.framePeriod;
    %    mask=data(f(j)).ROI.roi    
    mask=data(f(j)).ROI(ROIindex).roi>1;
    tmp=roiTimeCourse(data(f(j)).dff,mask);    
    tmp=smooth(tmp,'lowess')-mean(tmp(data(f(j)).preFrames));
    x=[0:fp:length(tmp)*fp-fp];
    plot(x,tmp,'color',J(j,:),'linewidth',1.2)
  end

  hold off
  
  box on
  title(Uo{i},'fontsize',fsize)
  set(gca,'color',ones(1,3)*0.6,'fontsize',fsize)
  xlim([0,max(x)])
  
  
end



makeAxesEqual(1)



%now add the response box
figs=get(0,'children');
x=[data(1).stim.stimLatency,data(1).stim.stimLatency+ ...
   data(1).stim.stimDuration];
y=ylim;

for i=1:length(figs)
  figure(figs(i))
  p=patch([x(1),x(2),x(2),x(1)],[y(1),y(1),y(2),y(2)],1);
  set(p,'edgecolor','none','facecolor','b','facealpha',0.25);
end



fprintf('\n');

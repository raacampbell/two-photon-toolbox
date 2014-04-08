function varargout=responseMagByPresentation(data)
% Response magntitude of each trial
% 
% function responseMagByPresentation(data)
%
% Purpose 
%
% Called by generate recording report. Shows response magnitude on
% each trial and indicates odour identity of the trial. 
%
% Rob Campbell




rp=responsePeriodFrames(data(1));
stim=getOdourNames(data);

col=hsv(length(stim.uOdours)+2);

clf
hold on
for i=1:length(data)
    tmp=responseTimeCourse(data(i),[],0);
    mu(i)=mean(tmp.dff(rp(1):rp(2)));
end

plot(mu,'-k')
for i=1:length(data)
    ind=strmatch(data(i).stim.odour,stim.uOdours,'exact');%color index
    plot(i,mu(i),'ko','markerfacecolor',col(ind,:),...
         'markersize',12)
end


hold off

box on

xlabel('# trial')
ylabel('mean evoked response')


if nargout==1
varargout{1}=mu;
end

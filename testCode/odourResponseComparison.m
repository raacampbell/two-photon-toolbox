function [odours,pid]=odourResponseComparison(data,odours,pid)
% function odourResponseComparison(data)    
%
% The odour response isn't the same amplitude every time. So we
% want to see whether there is a relationship between the quantity
% of delivered odour and the dF/F. 
%
% 

[o,u,ind]=getOdourNames(data);
    
    
if nargin==1




odours=[];
pid=ones(length(data),length(data(1).stim.PID));
n=1;
for i=1:length(u)
    
    
    for j=1:length(ind{i})
        odours=[odours;...
                roiTimeCourse(data(ind{i}(j)).dff,data(ind{i}(j)).ROI.roi)];
        pid(n,:)=data(ind{i}(j)).stim.PID;
        n=n+1;
    end
    
end

end



for i=1:length(u)
    subplot(2,4,i)
    plot(odours(ind{i},:)')
    hold on
    plot(pid(ind{i},:)','--')
    hold off


    title(u{i})
end

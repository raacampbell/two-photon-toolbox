function evoked=meanTrace2Response(data,roi)
% function meanTrace2Response(data,roi)
%
%
% Just find the evoked repsonse over the whole ROI and return as
% vector. 
%
% The input variable "roi" determines which ROI to use. 
% see: "help responseTimeCourse" 

if nargin<2, roi=[]; end

for ii=1:length(data)
       
    rp=responsePeriodFrames(data(ii),3);
    resp=responseTimeCourse(data(ii),1,0);
    
    evoked(ii)=mean(resp.dff(rp(1):rp(2)));

end

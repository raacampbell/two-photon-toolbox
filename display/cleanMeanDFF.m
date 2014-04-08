function muInt=cleanMeanDFF(data,verbose)  
% Calculate a reduced-noise mean dF/F during the response 
%
% function muInt=cleanMeanDFF(data,verbose)  
%
% Purpose
% Calculate the mean dF/F during the response period. This function
% tries to clean this up as best as possible using smoothing and
% statistical criteria.  
%
% Inputs
% data is data(i) from the twoPhoton object
%
% Outputs
% muInt is a 2-d matrix containing the response image
%
%
% Rob Campbell - October 2009
  
if nargin<2
    verbose=0;
end


%Firstly, we have some dff values which are stupidly extreme, so we
%fix those on a frame by frame basis by a combination of pixel
%removal and averaging:
hi=10;lo=0; 

%Select only the period during the response
r=responsePeriodFrames(data);

startFrame=r(1);
endFrame=r(2);
if startFrame<0
  startFrame=1;
  disp('Forcing start frame to 1')
end

if verbose
    disp([startFrame,endFrame]*data.info.framePeriod)
end



%Note! assigning this way stops the workspace from changing
tmp.dff=double(data.dff);
tmp.dff=Kalman_Stack_Filter(tmp.dff,0.8);
tmp.dff=tmp.dff(:,:,startFrame:endFrame);

tmp.roi=data.ROI(1).roi;


%Apply a filter 
for i=1:size(tmp.dff,3)
    thisFrame=tmp.dff(:,:,i);

    f=find(thisFrame<lo);
    thisFrame(f)=0;

    f=find(thisFrame>hi);
    thisFrame(f)=0;

    thisFrame=imfilter(thisFrame,fspecial('gaussian',10,1.5));
    tmp.dff(:,:,i)= thisFrame;
end







%----------------------------------------------------------------------
%Now summarise with a max intensity projection or a mean dF/F
muInt=mean(tmp.dff,3);

%muInt=max(tmp.dff,[],3);

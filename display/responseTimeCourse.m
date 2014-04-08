function varargout=responseTimeCourse(data,roiIndex,doPlot)
% Plot response time course of an ROI
%
% function out=responseTimeCourse(data,roiIndex,doPlot)
%
% Purpose
% Plots the response time course (both dF/F and raw mean) over the
% whole ROI over time. Different ROIs can be specified. Note that
% the dF/F is calculated OVER THE WHOLE ROI, not pixelwise as in
% data.dff. This is less noisy. The time course is also
% smoothed. The red line along the x axis indicates the response
% period and the blue line indicates the baseline period. 
%
% Inputs
% * data - one element of the twoPhoton data structure
% * roiIndex - if it's a scalar then this corresponds to data.ROI(roiIndex)
%   It can also be a matrix of size: size(data.imageStack(:,:,1))
%   If roiIndex is missing or empty then it is 1 by
%   default. Note that all matrix elements >1 are simply
%   set to 1, so you can feed the select KC matrix into
%   this function if needed. 
% * doPlot - show the plots (optional, 1 by default; 0 supresses
%   plotting)
%
%
% Outputs
% * out - structure containing plotted data. 
%
%
% Rob Campbell, February 2010
%
% Also See: roiTimeCourse.m



%Check input arguments
error(nargchk(1,3,nargin));
if nargin<2, roiIndex=[]; end
if isempty(roiIndex), roiIndex=1; end
if nargin<3, doPlot=1; end



%Get the ROI
if isscalar(roiIndex)
    ROI=data.ROI(roiIndex).roi;
else
    ROI=roiIndex;
    ROI(ROI>1)=1; 
end

imageStack=data.imageStack;
S=size(imageStack);
if sum(S(1:2)-size(ROI))>0
    error('ROI and baseline image are not the same size')
else
    %Get only the ROI   
    baselineImage=data.baselineImage;
    baselineImage=baselineImage.*ROI;
end




%Now take the mean of each frame. 
muStack=roiTimeCourse(imageStack,ROI);
F=sum(baselineImage(:))/sum(ROI(:));

dff=(muStack-F)/F; %pixels outside ROI become inf
dff(dff==inf)=0;


%zero the baseline
dff=dff-mean(dff(data.preFrames));


%OUTPUT 
out.dff=dff;
out.raw=muStack;
out.imageStack=imageStack;

fp=data.info.framePeriod;
x=([1:length(muStack)]-1)*fp;
out.x=x;

%The start and end times of the stimulus
stim=responsePeriodFrames(data,0,0);
S=stim(1);
E=stim(2);
out.stimTimes=[S,E];




if doPlot
    filtWidth=3;
    
    y=smooth(out.dff,filtWidth);
    out.line=plot(x,y,'-k.');
    
    Y=[min(y)-range(y)*0.05,max(y)+range(y)*0.05];
    ylim(Y)
    
    
    %Response period
    L=line([x(S),x(E)],[Y(1),Y(1)]);
    set(L,'linewidth',3,'color','r')
    out.stim=L;

    %baseline period
    pf=data.preFrames;
    L=line([x(pf(1)),x(pf(end))],[Y(1),Y(1)]);
    set(L,'linewidth',3,'color','b')
    out.stim=L;

    xlabel('Time [s]')
    ylabel('Mean dF/F')
    title(sprintf('dF/F smoothed with %d point running average',...
                  filtWidth))
    xlim([0,max(x)])
    
    
end


%Only produce an output if it's requested 
if nargout==1, varargout{1}=out; end

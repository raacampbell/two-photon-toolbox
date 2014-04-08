function varargout=responsePeriodFrames(data,extraTime,offset,verbose)
% Calculate the frames which we will call our response period.
%
% function rp=responsePeriodFrames(data,extraTime,offset,verbose)
%
% Purpose
% Calculate the frames which we will call our response
% period. NOTE: this includes a fudge-factor to take into account
% the slow response time course. This ISN'T the stimulus times. 
%
% Inputs
% * data - one element of the twoPhoton data object    
% * extraTime - how many seconds to add to the response period
%             following the end of the odour offset
%             frame. [optional gathered from data.dffParams if possible]
% * offset - how many seconds to add ot the start of the response
%            period. Shifting it to later time points.  [optional
%            gathered from data.dffParams if possible]
% * verbose [0 by default] - shows the region of the response curve
%           deemed to be the response time.
%
% Outputs
% * rp - a two-element vector defining the first and last frame of
% the response period.
%
%
% Rob Campbell - October 2009

%Set up defaults
if isfield(data.dffParams,'respExtraTime')
    et=data.dffParams.respExtraTime;
else
   et=1;
end


if isfield(data.dffParams,'respOffset')
    ot=data.dffParams.respOffset;
else
    ot=0.5;
end


if nargin<2, extraTime=et; end    
if isempty(extraTime),extraTime=et;end

if nargin<3, offset=ot; end    
if isempty(offset),offset=ot;end

if nargin<4, verbose=0; end

s=data.stim.stimLatency+offset;
e=data.stim.stimDuration+s+extraTime+offset;

%In case there are multiple time points
e=e(s>0);
s=s(s>0);

%Convert to frames. If we acquired volumes then we need to round to
%the nearest volume. 
fp=data.info.framePeriod;
if strmatch(data.info.type,'TSeries ZSeries Element') & ~isempty(data.info.type)
    
    if isfield(data.info,'positionCurrent_ZAxis')
        nDepths=length(data.info.positionCurrent_ZAxis);
    elseif isfield(data.info,'positionCurrent_ZAxis2')
        nDepths=length(data.info.positionCurrent_ZAxis2);
    else
        error('No Z-Depths recorded')
    end
    
    volEndTimes = data.relativeFrameTimes(end,:);
    
    %We want to make sure that we don't put volumes ending before
    %stim onset into the response window
    volEndTimes(volEndTimes<s)=0;

    s=findNearest(volEndTimes,s);
    e=findNearest(volEndTimes,e);
    fp=nDepths*fp;

else
    s=ceil(s/fp);
    e=ceil(e/fp);
end

if e>length(data.relativeFrameTimes)
    e=length(data.relativeFrameTimes);
    disp('Warning: trial length seems short')
end

    

if nargout>0
    %again, to handle multiple time points
    varargout{1}=unique([s,e],'rows'); 
end

if nargout>1
    varargout{2}=unique([s,e],'rows')* data.info.framePeriod;
end


if verbose
    fprintf('Response frames are %d-%d (%1.2g-%1.2g s)\n',...
            s,e,s*fp,(1+e)*fp)
    %add 1 to e so that we display the END of the last frame. This
    %is important because when doing volumes the frame time is
    %long. 
end

   

    

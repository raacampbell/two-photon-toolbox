function pm=pixelResponseMatrix(data,extraTime)
% function pm=pixelResponseMatrix(data,extraTime)
%
%

% Like the KC response matrix function but works pixelwise. Kinda
% slow, therefore. 

if nargin<2, extraTime=[]; end

%Assume image parameters are the same for all frames
nStim=length(data);
nPixels=data(1).info.pixelsPerLine * data(1).info.linesPerFrame;
nFrames=length(data(1).info.positionCurrent_XAxis);


%We will use the same response window size for all stimulus
%responses. 
if length(extraTime)<2
    respP=responsePeriodFrames(data(1),extraTime);
else
    respP=extraTime;    
end


pm=ones(nPixels,nStim);
textprogressbar('making pixel matrix ')
for ii=1:length(data)
    textprogressbar(round((ii/length(data))*100))
    dff=data(ii).dff;
    dff=reshape(dff,nPixels,nFrames);
    pm(:,ii)=nanmean(dff(:,respP(1):respP(2)),2);
end

textprogressbar(' done')

pm=pm';

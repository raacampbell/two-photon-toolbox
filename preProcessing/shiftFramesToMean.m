function shiftFramesToMean(data,frames,ref)
% function shiftFramesToMean(data,frames,ref)
%
% Purpose
% Often the first two or three frames have a lower value than the
% rest because the pockels cell takes a second or so to reach a
% stable value. This function corrects for this by setting these
% frames to the mean of the reference frames. A bit of a hack, but
% it works. 
%
% We will implement this via the code already in place for the
% photo-bleach correction. 
%
%
% Example:
% shiftFramesToMean(data,1:3,4:20)
%
% NOTE: THIS SORT OF WORKS, BUT IT MAKES THE NOISE TOO LARGE. 
fprintf('\n')
for ii=1:length(data)
    fprintf('.')
    if ~data(ii).doPhotoBleachCorrection
        data(ii).doPhotoBleachCorrection=1;
    end
    
    out=responseTimeCourse(data(ii),1,0);
    
    mu=mean(out.raw(ref));
    
    data(ii).photoBleachFit(frames)=out.raw(frames)-mu;
    
end
fprintf('\n')

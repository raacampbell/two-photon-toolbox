function varargout=ROI_batch(data,sameBoundary)
% Determine the main ROI for each stimulus presentation
%
% function data=ROI_batch(data,sameBoundary)
%
% PURPOSE
% Automatically determine the region of interest (ROI) that 
% segregates brain from background. By default we do this for 
% the first response only and then copy this ROI *threshold* to
% all other responses. 
%  
% INPUTS
% * data--the twoPhoton object containing the movement-corrected
%   data. 
%  
% * sameBoundary [optional, 0 by defualt]. If == 1 it applies the ROI
% from the first recording to all the others. If == 0 the user
% specifies the level of the ROI and it's recalculated for each
% rep. 
%
%
% Rob Campbell, CSHL 2009
% MODIFIED: Jan 2013
verbose=0;


nargchk(1,2,nargin);
if nargin==1, sameBoundary=0; end

%Because we use this below and assume it's present. 
if ~isfield(data(1).info,'muStack')
  fprintf('info.muStack is missing. Adding it.\n')
  updateMuStack(data);
end

%If an baseline ROI has already been calculated (unlikely) then we
%should be cautious and zero the background and re-calculate the
%muStacks. If we don't do this, then they will contain the previous
%offset and we will get the wrong value. TBH, this is over-cautious
%as we don't generally bother to recalculate the muStacks after we
%do the background calculatation. The muStacks are just for
%qualitative purposes and speeding up code. 
if ~isempty(data(1).ROI)
  response=input(['Warning muStack offsets might be wrong. Update ', ...
                  '[y/n] '],'s');

  if strcmp('y',lower(response))
    for ii=1:length(data)
      if ~isempty(data(ii).ROI)
        data(ii).ROI.backgroundLevel=0;
      end
    end
    updateMuStack(data);
  end
  
end




%----------------------------------------------------------------------
% Determine the ROI. At this point, the idea is to select neural
% tissue from background. We will segment sub-regions at a later
% point as needed. 
%
% If length(data)>1 we can eventually take the ROI for the first entry
% in the structure and copy the same ROI over to the rest. However,
% right now we need to resolve movement problems so do ROI on each in
% turn. Instead we will use the level from the last ROI on the next one

set(gcf,'Name','')
n=1;
ROI=ROI_autodetectFancy(data(n)); 
data(n).ROI=ROI;

if sameBoundary==0
  for n=2:length(data)
    level=data(n-1).ROI.level;
    ROI=ROI_autodetectFancy(data(n),level);
    data(n).ROI=ROI;
  end
  clf
  overlayROIboundaries(data)
  
elseif sameBoundary==1
  disp(sprintf('Applying ROI #1 to all %d recordings',length(data)))
  for n=2:length(data)
    data(n).ROI=ROI;
  end
end


%Calculate and store background level
fprintf('Calculating background intensity')
for ii=1:length(data)
  ROI=data.ROI;
  bg=~ROI.roi;
  
  BackGroundPixels=bg.*data(ii).info.muStack(:,:,end); 
  muBackGround=sum(BackGroundPixels(:))/sum(bg(:));%mean background intensity

    data(ii).ROI.backgroundLevel=muBackGround;
    if verbose
      fprintf('\n%0.4g',muBackGround)
    else
      fprintf('.')
    end
    
end
fprintf('\n')

if nargout==1
  varargout{1}=data;
end

  

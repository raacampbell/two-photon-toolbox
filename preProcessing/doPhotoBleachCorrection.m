function data=doPhotoBleachCorrection(data,verbose)
% Conduct photo bleach correction on twoPhotonObject
%
% function data=doPhotoBleachCorrection(data,verbose)
%
% Purpose:
% Calculates the photo-bleach fit and stores it in the
% photoBleachFit property of the twoPhoton object. Will over-write
% whatever was there before!
%
% * * *
% Note that there is some argument for not doing the correction at
% all. Typically we image around each stimulus presentation for a
% total of about 20 seconds. Photo-bleaching isn't generally
% obvious over this time period at the laser power we're
% using. Since we calculate dF/F, the absolute level across
% stimulus presentations isn't relevant: it won't alter dF/F. The
% photo-bleach correction does introduce artefacts. In some (most?)
% cases it will add more artefacts then it removes. 
% * * *
%
% Inputs:
% data- the twoPhoton object.  
% verbose - zero by default
%
% Rob Campbell - August 2009
%
% December 2009: The double exponential that was here before wasn't
% very stable so instead I'm doing this with smoothing. It works a
% lot better in most cases. 
%
% February 2010: updated to linear spacing during response period
% and cut more of the time frame near the response peak. This
% improves the shape of the photo-bleach corrected response. The
% peak is larger and the decay is longer. 
%

if nargin<2; verbose=0; end

fprintf('Photo-bleach correction')
if verbose
    fprintf('\n');
end

for i=1:length(data)
  if verbose
          fprintf('%d/%d\n',i,length(data));
  else
      fprintf('.')
  end
  data(i).photoBleachFit(:)=0; %make sure this is empty so no
                               %correction is applied to the data  

  imageStack=data(i).imageStack;
  ROIave=roiTimeCourse(imageStack,data(i).ROI.roi);

  %If needed, set any early frames to the ROI mean
  if data(i).ignoreFrames>0
    ROIave(1:data(i).ignoreFrames)=mean(ROIave);
  end
  %ignore the response
  rp=responsePeriodFrames(data(1),5); %this period may need to be longer!

  %ROIave(rp(1):rp(2))=mean(ROIave); %Original code

  %New code with linear spacing. I think this makes more sense. Rob 22/02/10
  f=rp(1):rp(2); 
  mu1=mean(ROIave(1:rp(1)));
  mu2=mean(ROIave(rp(2):end));
  ROIave(f)=linspace(mu1,mu2,length(f));
  thisFit=smooth(ROIave,50);
  
  data(i).photoBleachFit=thisFit(1:length(ROIave));
  
end

if ~verbose, fprintf('\n'); end

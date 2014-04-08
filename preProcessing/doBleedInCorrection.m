function data=doBleedInCorrection(data,verbose)
% Conduct photo bleach correction on twoPhotonObject
%
% function data=doBleedInCorrection(data,verbose)
%
% Purpose:
% Calculates the bleed-in correction and stores it in the
% photoBleachFit property of the twoPhoton object. Will over-write
% whatever was there before!
%
%
% Inputs:
% data- the twoPhoton object.  
% verbose - zero by default. If 1 we print stuff to screen. If 2 it
% makes lots of graphs. 
%
% Rob Campbell - December 2010
%


if nargin<2; verbose=0; end

fprintf('Doing bleed-in correction')

if verbose
    fprintf('\n');
end




for ii=1:length(data)
    nTime=data(ii).stim.stimLatency-2.5; %correct this many seconds

  if verbose
          fprintf('%d/%d\n',ii,length(data));
  else
      fprintf('.')
  end


  data(ii).photoBleachFit(:)=0; %make sure this is empty so no
                               %correction is applied to the data  

  imageStack=data(ii).imageStack;
  ROIave=roiTimeCourse(imageStack,data(ii).ROI(1).roi);

  
  %If needed, set any early frames to the ROI mean
  if data(ii).ignoreFrames>0
    ROIave(1:data(ii).ignoreFrames)=mean(ROIave);
  end
  
  %Find the frame region in need of correcting. 
  t=ceil(nTime/data(1).info.framePeriod);

  %correct
  thisFit=smooth(ROIave,5)';
  %  bleedout=(1/6:(1/6):1) .*  thisFit(t-5:t)


  thisFit(t+1:end)=0;


  thisFit=thisFit(1:length(ROIave));

  %subtract the mean
  thisFit(1:t)=thisFit(1:t)-mean(thisFit(1:t));
  
  
  data(ii).photoBleachFit=thisFit;

  if verbose>1
      subplot(1,3,1), plot(thisFit), title('fit')
      tcourse=squeeze(mean(mean(imageStack)))';
      
      subplot(1,3,2), plot(tcourse), title('imstack')
      hold on
      plot(ROIave,'-r')
      hold off
      legend('Full','ROI')
      

      subplot(1,3,3)
      mu=mean(thisFit);
      corrected=ROIave-thisFit+mu;
      plot(corrected)
      hold on
      plot(ROIave,'-r')
      hold off
      legend({'corrected','original'})
      
      title('corrected')
  end
  
end

if ~verbose, fprintf('\n'); end

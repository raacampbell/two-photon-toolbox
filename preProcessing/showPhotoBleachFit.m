function showPhotoBleachFit(data)
% Plot time-series before and after photo-bleach correction
% 
% function showPhotoBleachFit(data)
%
% Purpose
% Make a nice plot showing the time-course of the mean intensity of
% the raw data and the photo-bleach fit we have applied to
% this. Show also the before and after fits. Note that the
% bleach-corrected data are actaully the residuals about the fit
% line and so are normalised to the fit. 
%
% Inputs
% data - the twoPhoton object
%
%
% Rob Campbell, August 2009

  

%Get the un-corrected and then the corrected data  
data.doPhotoBleachCorrection=0;
before=roiTimeCourse(data.imageStack,data.ROI(1).roi);
data.doPhotoBleachCorrection=1;
after=roiTimeCourse(data.imageStack,data.ROI(1).roi);

%The x axis and the fitted values for the photo-bleach fit. 
XData=(0:length(before)-1)*data.info.framePeriod;

%If the fit is zero then replace it with the mean
fittedValues=data.photoBleachFit;
if sum(fittedValues)==0
  fittedValues(:)=mean(before);
end




%Make nice plots
clf

subplot(1,2,1)
hold on

plot(XData,fittedValues,'b-','linewidth',2);
plot(XData,before,'.r-')

L=legend({'Fit','ROI mean'});set(L,'FontSize',8)

hold off
box on, grid on
title('Photobleach Fit')
xlabel('Time [s]')
ylabel('Frame Intensity')


subplot(1,2,2)
%The before fit will be normalised so that it has the same mean as
%the after fit. 
delta=mean(before)-mean(after);
plot(XData,before-delta,'r-','linewidth',3);%This is the old average.
hold on
plot(XData,after,'k-','linewidth',2);%This is after correcting for the photobleaching. 
hold off
L=legend({'before','after'});set(L,'FontSize',8)
box on, grid on
title('Photobleach correction')
xlabel('Time [s]')
ylabel('Relative Intensity In ROI')

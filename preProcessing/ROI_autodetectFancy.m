function ROI=ROI_autodetectFancy(data,defaultLevel)
% Use thresh_tool to perform a semi-automated detection of the main ROI
%
% function ROI=ROI_autodetectFancy(data,defaultLevel)
%
% PURPOSE
%  Attempts to automatically select the whole brain as the region
%  of interest (ROI) with the remaining area being the
%  background. 
%
% INPUTS
%  data - the twoPhoton object containing the image stack
%  defaultLevel - default level to use
%
% Rob Campbell, CSHL, 2009
%
% Also See:
% ROI_add  
 
error(nargchk(1,2,nargin));
  

%Call thresh_tool to do the fancy stuff
imageStack=data.imageStack;

imageStack=averageDownIm(imageStack,2);

if nargin>1
  [level,roi]=thresh_tool(imageStack,defaultLevel,1);
else
  [level,roi]=thresh_tool(imageStack);
end


% Structure for output
ROI.level=level;
ROI.roi=roi;
ROI.notes='auto-detected ROI. DO NOT DELETE ME';
ROI.backgroundLevel=[]; %This will be used to store the intensity
                        %level of the background so that we don't
                        %have to subtract it from the image stack
                        %and save this to disk. This takes ages and
                        %is dodgy. 


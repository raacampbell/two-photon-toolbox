function saveRawData(data,imageStack,compress)
% function saveRawData(data,imageStack,compress)
%
% Replace the rawData mat file for this instance of the 
% twoPhoton object "data" using the image matrix "imageStack" 
%
% "compress" is optional and 1 by default. If 0 then the data are stored 
% using Matlab's version 6 format. 
%
% Rob Campbell - August 2012

if nargin<3
	compress=1;
end

imageStack=single(imageStack);
fileStr=[data.info.rawDataDir,'/','rawData', num2str(data.info.stimIndex)]; 
eval(['rawData',num2str(data.info.stimIndex),'=imageStack;'])

if compress
	save(fileStr,['rawData',num2str(data.info.stimIndex)])
else
	save(fileStr,['rawData',num2str(data.info.stimIndex)],'-v6') 
end

function makeRawDataSingle(data)
% function makeRawDataSingle(data)
%
% Purpose
% Just in case the raw data were saved as doubles, we will load
% each in turn and re-save as single-precision. 
%
% Inputs
% data - twoPhoton object
%
%
% Rob Campbell - February 2010


for ii=1:length(data)
      
    fprintf('.')
    imageStack=single(data(ii).imageStack(:,:,:,:,:));
    eval([data(ii).info.rawDataFile,'=imageStack;'])
    fileStr=[data(ii).info.rawDataDir,'/',data(ii).info.rawDataFile];

    save(fileStr,data(ii).info.rawDataFile)

    clear('raw*')

end

fprintf('\n')

function normAllImages(data)
% function normAllImages(data)
%
% Normalise each image stack by its max value. 

fprintf('Normalising')

for S=1:length(data)
    fprintf('.')
    imageStack=data(S).imageStack;
    imageStack=single(imageStack/max(imageStack(:)));
    
    data(S).info.rawDataFile=sprintf('rawData%d',S);
    eval([data(S).info.rawDataFile,'=imageStack;'])
    fileStr=[data(S).info.rawDataDir,'/',data(S).info.rawDataFile];
    
    save(fileStr,data(S).info.rawDataFile)
    clear('raw*')
end

fprintf('\n')

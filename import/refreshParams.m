function refreshParams
%refreshes all parameter and dat data of files in current directory

d=dir('*.mat');

for ii=1:length(d)
    fname=d(ii).name;
    load(fname)
    
    p=dir([fname(1:end-4),'/params*']);
    load([fname(1:end-4),'/',p.name])
    
    updateDataDir(data);
    addStimParams(data,params);
    addDilution(data);
    addDatData(data);
    
    save(fname,'data')

end

    

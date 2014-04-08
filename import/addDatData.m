function data=addDatData(data)
% Add Trigger Sync analogue .dat data to twoPhoton object 
%
% function data=addDatData(data)
%
% Purpose
% Add DAT file data from Prairie's Trigger Synv to the twoPhoton
% object. At the moment this file only adds data from one channel
% (that associated with the PID device). It can fairly easily be
% modified to also import e-phys data.
%
% Inputs
% data - the twoPhoton data object.
%
% Outputs
% data - the twoPhoton data object with added DAT information.     
%
%
% Rob Campbell - December 2009
    
    
    
    
cwd=pwd;

dataDir=data(1).info.rawDataDir;

cd(dataDir)

datFiles=dir('*.dat');

if length(datFiles)~=length(data)
    disp(['addDatData: We may have a problem with these data. This function ' ...
           'isn''t finished yet. Check code'])
end




for i=1:length(data)
    data(i).stim.PID=readPVdat(datFiles(i).name);
end


cd(cwd)


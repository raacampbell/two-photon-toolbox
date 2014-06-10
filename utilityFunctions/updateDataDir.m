function varargout=updateDataDir(data,dataDir)
% Update path to data directory 
%
% function data=updateDataDir(data,dataDir)
%
% Purpose
% Called in fly root directory to update the data directory. Can
% also specify a directory manually. 
%
% Inputs
% data - twoPhoton data object
% dataDir [optional] - the root directory of the data. 
% e.g. if TSeries-05282009-1323-028 resides in /data/ then dataDir
% should be '/data/'
%
% If run with no input arguments, it simply updates all the twoPhoton
% objects in the current directory. Saves all to disk.
%  
% Outputs
% data - the updated data structure
%
% Example
% >> cd /data/
% >>ls    
% TSeries-05282009-1323-027   
% TSeries-05282009-1323-027.mat
% >> load TSeries-05282009-1323-027.mat
% >> data=updateDataDir(data)
%
%
% Or
% >>load /data/TSeries-05282009-1323-027.mat    
% >>data=updateDataDir(data,'/data/')
%
%
% Rob Campbell - October 2009
%
% KNOWN BUGS
% The regex currently doesn't work on Windows paths. 




if nargin==0
  d=dir('*.mat');
  for ii=1:length(d)
      
     F=whos('-file',d(ii).name);
     if length(F)>1 | ~strcmp(F.class,'twoPhoton')
        fprintf('%d/%d - skipping %s\n',ii,length(d),d(ii).name)
      continue
    end

    load(d(ii).name)
    fprintf('%d/%d - updating %s\n',ii,length(d),d(ii).name)
    data=updateDataDir(data);
    save(d(ii).name,'data')

  end
  return
end

  
if nargin<2, dataDir=pwd; end



%Strip trailing file separator (if present) and tag on the correct one. 
if any([strcmp(dataDir(end),'/'),strcmp(dataDir(end),'\')])
  dataDir(end)=[];
end
dataDir(end+1)=filesep;

     

for ii=1:length(data)
  if ~ispc
    data(ii).info.rawDataDir = regexprep(data(ii).info.rawDataDir,'/.*/',dataDir);
  else
    data(ii).info.rawDataDir = regexprep(data(ii).info.rawDataDir,['^[A-Z]/.*',filesep],dataDir);
  end

  %The following is likely legacy code as the new twoPhoton object has no field info.Filename
  if isfield(data(ii).info,'Filename')
      data(ii).info.Filename=...
       regexprep(data(ii).info.Filename,'/.*/',[data(ii).info.rawDataDir,'/']);
    end

end


if nargout==1
  varargout{1}=data;
end

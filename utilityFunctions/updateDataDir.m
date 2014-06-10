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
% Or, to update all files in the current directory us no arguments:
% >> cd /data/
% >>ls    
% TSeries-05282009-1323-027   
% TSeries-05282009-1323-027.mat
% TSeries-05282009-1523-028   
% TSeries-05282009-1523-028.mat
% >> updateDataDir
%
%
% Rob Campbell - October 2009




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



%Strip trailing file separator if present 
if any([strcmp(dataDir(end),'/'),strcmp(dataDir(end),'\')])
  dataDir(end)=[];
end

     

for ii=1:length(data)
  data(ii).info.rawDataDir=dataDir;
end


if nargout==1
  varargout{1}=data;
end

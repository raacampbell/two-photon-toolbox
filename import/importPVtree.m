function varargout=importPVtree(directory)
% Import data from multiple Prairie view data directories 
%
%  function importedFiles=importPVtree(directory)
%
% PURPOSE
%  Imports data from all the Prairie data sub-directories within a
%  directory. 
%
% INPUTS
%  directory is an optional string specifying the full path to the
%  data. e.g. '/home/work/imaging/Fly001/' This directory should
%  contain one or more directories each containing tif files and a
%  single .xml describing the imaging session. If no input is
%  specified then the current directory is used. 
%
% OUTPUTS
%  A list of imported files. This function saves data to mat files within
%  the specified directory. 
%
% WARNINGS
%  May not work on a non-unix filesystem  
%
% Rob Campbell, March 2009
  

if nargin==0
  directory=pwd;
end


d=dir(directory);
d=d([d.isdir]);

d(find(strcmp({d.name},'.')))=[];
d(find(strcmp({d.name},'..')))=[];

cur=pwd;
cd(directory)

n=1;
try
  
  for i=1:length(d)
    cd(d(i).name);  
    fnames=dir('*.xml');
    data=[];
    if length(fnames)>1
      fprintf('%d/%d %s - skipping: More than one XML file\n',...
              i,length(d),d(i).name)
    elseif length(fnames)<1
        fprintf('%d/%d %s - skipping: no XML files\n',...
                i,length(d),d(i).name)
    else
        fprintf('%d/%d - ',i,length(d))
        data=prairieXML_2_Matlab(fnames.name);
    end
    
    cd(directory)    
    if ~isempty(data)
        saveName=[d(i).name,'.mat'];
        save(saveName,'data')
        importedFiles(n)=dir(saveName);
        n=n+1;
    end
  end
  


catch
    cd(cur)
    rethrow(lasterror)  
end

  

cd(cur)

if nargout>0
    varargout{1}=importedFiles;
end

function importedFiles=importSItree(directory)
% Import data from multiple ScanImage data directories 
%
% function importedFiles=importSItree(directory)
%
% PURPOSE
%  Imports data from all ScanImage data sub-directories within a
%  directory. ScanImage saves each stimulus repeat in its own tiff
%  file. importScanImage will import just one tiff file. This
%  function treats all tiffs in the same directory as a single
%  session/experiment. So it imports them and pools them into the same
%  data structure. 
%
% INPUTS
%  directory is an optional string specifying the full path to the
%  data. e.g. '/home/work/imaging/Fly001/' This directory should
%  contain one or more sub-directories each containing at least one
%  ScanImage tif file. If no input is specified then a file
%  dialogue is presented. 
%
% OUTPUTS
%  A list of imported files. This function saves data to mat files within
%  the specified directory. 
%
% WARNINGS
%  May not work on a non-unix filesystem  
%
% Rob Campbell, May 2012
  

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

verbose=1;
try
  
  for ii=1:length(d)
    cd(d(ii).name);  
    fnames=dir('*.tif');

    if length(fnames)<1
        fprintf('%d/%d %s - skipping: no TIFF files\n',...
                ii,length(d),d(ii).name)
        cd(cur)
        continue
    else
        
        fprintf('%d/%d: %s',ii,length(d),d(ii).name)
        if verbose
            fprintf('\n')
            for jj=1:length(fnames)
                fprintf('Importing %s - ',fnames(jj).name)
                data(jj)=importScanImage(fnames(jj).name,jj);
                fprintf('SUCCESS\n')
            end                
        else
            for jj=1:length(fnames)
                data(jj)=importScanImage(fnames(jj).name,jj);
                fprintf('.')
            end             
            fprintf('\n')
        end

    end
    
    cd(directory)    
    if ~isempty(data)
        saveName=[d(ii).name,'.mat'];
        save(saveName,'data')
        importedFiles(n)=dir(saveName);
        n=n+1;
        clear data
    end
  end
  


catch
    cd(cur)
    rethrow(lasterror)  
end

  


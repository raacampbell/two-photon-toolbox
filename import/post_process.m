function post_process(d)
% Import and pre-process all PraireView data in current directory
%
% function post_process(d)
%
% Purpose
% Call from a root data directory to import all the data it
% contains. I.e. a root data directory is one which contains all
% the TSeries or ZSeries directories. This routine expects a
% parameter file (that produced by deliverOdours) in each TSeries
% directory. If the parameter file is missing then certain analysis
% operations are not performed. 
% 
% All *.mat 2-photon data objects in the current directory will be
% post-processed. Unless a dir structure with defined data is
% provided. 
%
% Rob Campbell - 2012
  
if nargin==0
    d=dir('*.mat');
end

  
cwd=pwd;
for ii=1:length(d)

  load(d(ii).name);  

  if ~strcmpi(class(data),'twophoton')
      fprintf('Skipping %s\n',d(ii).name)
      continue
  end
  
  
  disp(sprintf('****   %d/%d - Processing %s   ****',...
               ii,length(d),d(ii).name))
  

  if data(1).info.binningMode
      fprintf('Data were acquired using "summing" mode\n')
      normAllImages(data)
  end
  

  
  cd(data(1).info.rawDataDir)
  p=dir('params*.mat');
  if ~isempty(p) %The following only run if there is a params file
      if length(p)==1          
          load(p.name)
      elseif length(p)>1
          load(p(1).name)
          disp('Loading the first params file. There are others!')
      end
      
      data=addStimParamsSI(data,params);
      
      data=cleanBatch(data);
      data=alignOverReps(data);          
      data=ROI_batch(data);
      
      %The photo-bleach correction must be done last!
      %          data=doPhotoBleachCorrection(data);

  end
  
  cd(cwd)
  save(d(ii).name,'data')
  fprintf('Saving %s\n',d(ii).name)
  clear params data


end
  



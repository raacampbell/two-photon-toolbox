function peektiff(fname,framesToLoad)
%  function peektiff(fname,framesToLoad)
%
% Purpose
% Shows the mean of the first 5 frames (by default) from a tiff
% file. This is useful during recording, if we want to compare 
% what the incoming data look like to previously collected data. 
% e.g. is the brain in the same place?
%
% Inputs
% fname - can be any one of:
%  1. A string defining relative path to one file
%     peektiff('myFile.tif')
%  2. A cell array defining relative paths to one or more files. 
%     These plotted in the same figure window
%     peektiff({'myFile1.tif','myFile2.tif'})
%  3. A struct that is the output of the dir command and lists one
%     or more image files. These plotted in the same figure window:
%     peektiff(dir('*.tif'))
%
% framesToLoad [optional] - which frames to use for the
% average. Default: 1:5
%
%
% Rob Campbell - CSHL 2013
if nargin<2
  framesToLoad=1:5;
end


if iscell(fname) || isstruct(fname)
  n=length(fname);
  sp=numSubplots(n);
  for ii=1:n
    subplot(sp(1),sp(2),ii)
    if iscell(fname)
      peektiff(fname{ii},framesToLoad);
    elseif isstruct(fname)
      peektiff(fname(ii).name,framesToLoad);
    end
    
  end
  
  return
end

  
if exist(fname,'file')==0
  error('File %s not found',fname)
end


%Load and plot
im=load3Dtiff(fname,'frames',framesToLoad);
imagesc(mean(im,3))
axis equal off
colormap gray
  

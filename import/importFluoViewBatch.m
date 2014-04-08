function data=importFluoViewBatch
% Import all FluoView tiff files in the current directory
%
% function data=importFluoViewBatch
%
% Purpose 
% Import all FluoView tiff files in the current directory. Save
% results to disk. 
%
% NOTE: unfinished but should work

d=dir('*.tif');

for i=1:length(d)
    disp(sprintf('%d/%d %s',i,length(d),d(i).name))
    TMP(i)=importSue(d(i).name,i);    
end


data=TMP;
%saveFileName=regexprep(d(i).name,'\.tif','');
saveFileName='importedData';
disp(sprintf('Saving data to current directory: %s.mat ',saveFileName))
save(saveFileName,'data')
 

function tiffStacks2Dirs
% function tiffStacks2Dirs
%
% Go through tiff files in current directory and place each into its
% own directory, with each directory named after the file
% name. This function is of uncertain usefulness right now and may
% be deleted. 
%
% Rob Campbell 


F=dir('*.tif');

for ii=1:length(F)
    dirName=F(ii).name(1:length(F(ii).name)-4);
    if exist(dirName,'dir')==7
        fprintf('%s already exists\n',dirName)
    
    else
        mkdir(dirName)
    end
    
    cmd=sprintf('mv %s %s', F(ii).name, dirName);
    U=unix(cmd);
    if U ~= 0
        fprintf('PROBLEM WITH %s\n',cmd)
    end
    

    
end



function searchExperiments(directory)
% function searchExperiments(directory)
%
% Purpose
%
% Search through all experiments in a given directory. Mine their
% params files so that we know what was presented in each
% experiment. Present data as an HTML file which is saved in the
% defined root directory. 
%
% Input
% directory - [string] the directory name. 
%
%
% Rob Campbell - March 2011



if nargin==0
    directory='/bigDisk/data/RawData/2-Photon/Rob/';
end

if ~strcmp('/',directory(end))
    directory(end+1)='/';
end

    
[status,result] = ...
    unix(sprintf('find %s -name ''params*.mat''',directory));
fname=regexp(result,'.*?\.mat','match');



fid=fopen([directory,'odours.html'],'w');
fprintf(fid,'<html><body>\n');

for ii=1:length(fname)
    if ii>1
        fname{ii}(1)=[];
    end

    
    disp(fname{ii})
    load(fname{ii})
    
    %Write data for this file
    fprintf(fid,'<hr />\n<b>%s</b>\n',fname{ii});
    
    for p=1:length(params)
        try
            od=unique({params(p).odourNames(params(p).odours).odour});               
        catch
            fprintf(fid,'CAN''T EXTRACT ODOR NAMES\n');
        end
        
        fprintf(fid,'<ul>\n',fname{ii});
        for jj=1:length(od)
            fprintf(fid,'<li>%s</li>\n',od{jj});
        end
        fprintf(fid,'</ul>\n');
    end
    
        

end



fprintf(fid,'</html></body>\n');
fclose(fid);


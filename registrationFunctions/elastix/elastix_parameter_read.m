function params=elastix_parameter_read(fname)
% Read elastix parameter file
%
% function params=elastix_parameter_read(fname)
%
% Usage:
% params=elastix_input_parameter_read('myFname')
%
% Skips empty lines and treats lines starting with "//" as
% comments. 
%
%
% Rob Campbell - August 2012
%
% Also see: elastix_parameter_write, elastix_paramStruct2txt



fid=fopen(fname);
if fid<0 
    error('Can not open %s',fname)
end



%Keep reading until we find the first non-comment line
tline=fgetl(fid);
while isempty(tline) 
    tline=fgetl(fid);
    while regexp(tline,'^//')
        tline=fgetl(fid);
    end
end

while ischar(tline)

    %Skip comment lines and following empty lines. Extra break
    %statements are to handle comments at the end of the file
    while regexp(tline,'^//') 
        tline=fgetl(fid);
        while isempty(tline) 
            tline=fgetl(fid);
        end        
        if ~ischar(tline), break, end
    end
    if ~ischar(tline), break, end



    % - - - - - - - - - - - - - - - - - - - - - - - - -
    %Get the data
    %Extract parameter name
    tok=regexp(tline,'\((\w+)','tokens');
    param=tok{1}{1};

    if findstr(tline,'"') %Then it's a string value
        tok=regexp(tline,'"(.*)"','tokens');
        value=tok{1}{1};
    else %It's a numeric value
        tok=regexp(tline,'\w+ ([\d\. -]+)\)','tokens');
        value=str2num(tok{1}{1});
    end
    % - - - - - - - - - - - - - - - - - - - - - - - - -



    params.(param)=value; %Add to structure
    tline=fgetl(fid); %Read next line

    %Skip empty lines
    while isempty(tline), tline=fgetl(fid); end
end






fid=fclose(fid);
if fid<0 
    fprintf('Warning: Failed to close %s\n',fname)
end

function state=readScanImageMeta(meta,verbose)
% Reads scan image meta data from the tiff
%
% function state=readScanImageMeta(meta,verbose)
%
%
% Rob Campbell - December 2011


if nargin<2, verbose=0; end

meta=sprintf('%s\r',meta); %append charcter return because SCIM 
                           %doesn't always do it. 

%This finds all the structure names
vars=regexp(meta,'(state\..*?)=','tokens');
data=regexp(meta,'=(.*?)\r','tokens');


%error check
chk=0;
if chk
    for ii=1:length(data);
        fprintf('%s = %s\n',vars{ii}{1},data{ii}{1})
    end
end


if length(data) ~= length(vars)
    error(['number of variables (%d) doesn''t equal number of data entries (%d)'],...
          length(vars),length(data))
end




%Now we can transform these strings in a structure
for ii=1:length(vars)
    if verbose
        fprintf('***** %d *****\n',ii)
    end
    
    tmp=sprintf('%s=%s;',vars{ii}{1},data{ii}{1});
    if verbose, fprintf('%s\n',tmp), end
    
    eval(tmp);
    

end

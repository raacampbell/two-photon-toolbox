function elastix_paramStruct2txt(fname,params)
% Write elastix parameter structure to text file
%
% function elastix_paramStruct2txt(fname,params)
%
% Write parameter file to fname. Uses default values from this
% file. The output parameters are those produced by a
% registration (e.g. TransformParameters.0.txt). This function
% writes one of these files using a previously imported structure. 
%
%
% Rob Campbell - August 2012
%
% Also see: elastix_parameter_read, elastix_parameter_write



fid=fopen(fname,'w+');


R=fields(params);
for ii=1:length(R)
    param=R{ii};
    value=params.(R{ii});

    if isstr(value)
        fprintf(fid,'(%s "%s")\n',param,value);
    end
    
    if isnumeric(value)
        if mod(value(1),1)==0
            fprintf(fid,['(%s',repmat(' %d',1,length(value)), ')\n'],...
                    param,value);
        elseif mod(value(1),1)>0
            fprintf(fid,['(%s',repmat(' %2.6f',1,length(value)), ')\n'],...
                    param,value);
        end
    end
end

fclose(fid);



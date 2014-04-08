function varargout=data2libsvm(data,fname)
% convert twoPhoton data to libsvm format
%
% function info=data2libsvm(data,fname)
%
% Purpose
% Convert the mean evoked response of each KC to a text file
% suitable for use with libsvm. 
%
% Input
% * data - Either the twoPhoton object or a structure with the
% followings fields:
%   - data.kc = output of kcResponseMatrix
%   - data.S = getOdourNames(data);
%  If this is done, you will need to specify the file name. The
%  purpose of allowing the second input format is to give the user
%  flexibility in modifying the data to be
%  classified. e.g. removing neurons. 
% * fname - optional name for the svm file. By default, a file name
% based on the data structure is chosen. It will choose the suffix
% "svm". 
%
% Outputs
% * info - An optional structure listing the filename of the svm
% file, and the mapping of odour name to cluster number (libsvm
% wants groups numbered as strings)
%
%
% Rob Campbell - April 2010


if isstruct(data)
    kc=data.kc;
    S=data.S;
else
    kc=kcResponseMatrix(data);
    S=getOdourNames(data);
end


if ~isstruct(data) & nargin<2
    fname = strrep(data(1).info.XMLfile,'xml','svm');
else
    error('Please define filename')
end



fid=fopen(fname,'w');

for ii=1:size(kc,1)    
    fprintf(fid, '%0.6f ', strmatch(S.odours{ii},S.uOdours));
    for jj=1:size(kc,2)
        fprintf(fid, ' %d:%0.6f', jj, kc(ii,jj));
    end

    fprintf(fid,'\n');
end

fclose(fid);



if nargout==1
    info.fname=fname;
    info.classes=containers.Map(S.uOdours,1:length(S.uOdours));
    varargout{1}=info;
end

    

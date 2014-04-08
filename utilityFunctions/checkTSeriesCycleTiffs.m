function varargout=checkTSeriesCycleTiffs(dirName)
% function varargout=checkTSeriesCycleTiffs(dirName)
%
% Purpose
% Check that Prairie view has saved all of the raw data
% correcty. Prints to screen the number of tiff files in each
% T-Series cycle. Allows the user to check that all cycles have the
% correct number of tiffs. 
%
% If dirName is a data structure then it also checks the tiff names in
% the data directory and those in the structure to ensure that
% everything makes sense. 
%
%
% Rob Campbell


if nargin==0
    dirName=pwd;
end

if ~ischar(dirName)
    data=dirName;
    dirName=data(1).info.rawDataDir;
    compareData=1;
else
    compareData=0;
end


D=dir([dirName,'/*.tif']);
D([D.isdir])=[];

for ii=1:length(D)

    tok=regexp(D(ii).name,'_(Cycle\d+)_','tokens');
    Cycle{ii}=tok{1}{1};

end

cycleNames=unique(Cycle);
fprintf('The %d tif files contain %d cycle names.\n', ...
        length(D),length(cycleNames))


%Check how many frames were stored for each cycle name
for ii=1:length(cycleNames)
    fprintf('%d. %s contains %d frames\n',...
            ii, cycleNames{ii},...
            length(strmatch(cycleNames{ii},Cycle)))
end




fnames={};
if compareData
    for ii=1:length(data)
        fnames=[fnames; data(ii).info.fileName];

    end
end

fnames=fnames';
fnames=fnames(:);

if length(D) == length(fnames)
    disp('The number of imported TIFF files match those on the disk')
elseif length(D) > length(fnames)
    disp('The following TIFFs have not been imported')
    for ii=1:length(D)
        if isempty(strmatch(D(ii).name,fnames))
            disp(D(ii).name)
        end
        
    end
    
end






if nargout==1
    varargout{1}=cycleNames;
end

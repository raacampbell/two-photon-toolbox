function oldKCstructureToNew(data)
% function oldKCstructureToNew(data)
%
% Purpose
% The KC structure is being updated so that that all ROI data
% (including KC stats) is in one place: data.ROI
%
% This function converts existing, older, data structures to the
% new structure. 
%
% If called with no arguments it will recursively find all twoPhoton
% objects in the current directory and all parent directories and
% update the structures. 
%
% Rob Campbell 
%[unlikely we'll ever need this]
  
if nargin==1, data=updater(data); return, end




root=getDirContents;
updateData(root);

for ii=length(root):-1:1
    if ~root(ii).isdir, root(ii)=[]; continue, end
    cd(root(ii).name)

    fprintf('Entering %s\n',root(ii).name)
    tmp=getDirContents;
    updateData(tmp);

    cd('..')
    if length(root)==0, break, end
    root(ii)=[];        
end




%----------------------------------------------------------------------
function D=getDirContents
D=dir;
D(1:2)=[];
for ii=length(D):-1:1
    if ~D(ii).isdir & isempty(strfind(D(ii).name,'.mat'))
        D(ii)=[];
    elseif ~isempty(strfind(D(ii).name,'rawData')) |...
             ~isempty(strfind(D(ii).name,'params')) 
        D(ii)=[];
    end    
    
end


%----------------------------------------------------------------------
function root=updateData(root)
for ii=length(root):-1:1
    if isempty(strfind(root(ii).name,'.mat')), continue, end
    
    D=load(root(ii).name);

    if isfield(D,'data') & strmatch(class(D.data),'twoPhoton')
        if isempty(strmatch('KCmasks',fieldnames(D.data(1))))
            continue
        end
        data=D.data;
      
        data=updater(data);
        
        save(root(ii).name,'data')
    end %if isfield(D,'data') & strmatch(D.data,'twoPhoton')
       
end %for ii=1:length(root)



%----------------------------------------------------------------------
function data=updater(data)

for ii=1:length(data)
    if ~isfield(data(ii).ROI(1),'notes')
        data(ii).ROI(1).notes='';
    end
    if ~isfield(data(ii).ROI(1),'backgroundLevel')
        data(ii).ROI(1).backgroundLevel='';
    end
    if ~isfield(data(ii).ROI(1),'stats')
        data(ii).ROI(1).stats=[];
    end


    ROI.level=nan;
    ROI.roi=data(ii).KCmasks;
    ROI.notes='soma';
    ROI.backgroundLevel=nan;
    ROI.stats=data(ii).KCstats;

    ROI.stats.dff=ROI.stats.kcDFF;
    rmfield(ROI.stats,'kcDFF');
    
    data(ii).ROI(end+1)=ROI;

    
    rmprops(data(ii),'KCstats','KCmasks')
    
end


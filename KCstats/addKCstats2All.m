function addKCstats2All
% function addKCstats2All
%
% Recursively find all twoPhoton objects in the current directory
% and all parent directories and update the KC stats if required. 
%
%
% Rob Campbell - 2010



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
      
        updateDataDir(data);
        
        if isempty(strmatch('KCstats',fieldnames(D.data(1))))
            fprintf(' Processing %s: ',root(ii).name)
            data=addKC_stats(data);
            save(root(ii).name,'data')
            continue
        end
        if size(data(1).KCstats.kcDFF,1)~= ...
                length(unique(data(1).KCmasks(:)))-1
            data=addKC_stats(data);
            fprintf(' Processing %s ',root(ii).name)
            data=addKC_stats(data);
            save(root(ii).name,'data')
            continue
        end
        root(ii)=[];
    end %if isfield(D,'data') & strmatch(D.data,'twoPhoton')
       
end %for ii=1:length(root)


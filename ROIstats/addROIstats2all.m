function addROIstats2all
% function addROIstats2all
%
% Recursively find all twoPhoton objects in the current directory
% and all parent directories and update the KC stats if required. 
%
%
% Rob Campbell - December 2010



root=getDirContents;
updateData(root);

for ii=length(root):-1:1
    if ~root(ii).isdir, root(ii)=[]; continue, end
    cd(root(ii).name)

    fprintf('Entering %s\n',root(ii).name)
    tmp=getDirContents;
    updateData(tmp);

    cd('..')
    if isempty(root), break, end
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
       
        if isempty(strmatch('soma',{D.data(1).ROI.notes}))
            continue
        end
        data=D.data;
      
        updateDataDir(data);
        
        if ~isempty(strmatch('soma',{data(1).ROI.notes}))
            f=strmatch('soma',{data(1).ROI.notes});
            if isempty(data(1).ROI(f).stats) | ...
                    size(data(1).ROI(f).stats.dff,1)~= ...
                    length(unique(data(1).ROI(f).roi(:)))-1
                
                
                fprintf(' Processing %s: ',root(ii).name)
                data=addROIstats(data);
                save(root(ii).name,'data')
                continue
            end
        end
        root(ii)=[];
    end %if isfield(D,'data') & strmatch(D.data,'twoPhoton')
       
end %for ii=1:length(root)


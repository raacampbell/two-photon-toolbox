function data=addConcs(data)
% function addConcs(data)
% 
% To make our life easier, we ought to add seperate odour conc
% fields into the stim structure. Right now, things are too
% disorganised. 
%
% Rob Campbell 
% [not clear as to use of this function]
  
  
for ii=1:length(data)

    stim=data(ii).stim;

    data(ii).stim.odourConcs=[];

    tok=[];
    odourConcs=[];

    if ~isempty(strfind(stim.odour,'['))
        
        expr='(\w+)\[(\d+?\.?\d+?)\]';
        tok=regexp(stim.odour,expr,'tokens');
        for T=1:length(tok)
                odourConcs.(lower(tok{T}{1}))=str2double(tok{T}{2});
            %Favour the concs field if this already exists
            if isfield(data(ii).stim,'concs')
                odourConcs.concs(T)=data(ii).stim.concs(T);
            else
                odourConcs.concs(T)=str2double(tok{T}{2});
            end
            
        end
        
    else
        expr='(\d+)(\w+)';
        tok=regexp(stim.odour,expr,'tokens');
        for T=1:length(tok)
            odourConcs.(lower(tok{T}{2}))=str2double(tok{T}{1});

            %Favour the concs field if this already exists
            if isfield(data(ii).stim,'concs')
                odourConcs.concs(T)=data(ii).stim.concs(T);
            else
                odourConcs.concs(T)=str2double(tok{T}{1});
            end

        end
    end

    if ~isempty(tok)
        data(ii).stim.odourConcs=odourConcs;
    end
    

            
end


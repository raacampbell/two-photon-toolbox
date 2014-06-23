function data=addStimParams(data,params)
% Add stimulus parameters to data structure
%
% function data=addStimParams(data,params)
%
% Purpose
% Add stimulus parameters to the twoPhoton object. This function is
% very specific to the odor delivery system used in the Turner
% Lab. This adds a field called "stim" to the twoPhoton
% object. The field "stim" is a structure that contains all the
% relevant information for our experiments: e.g. the odor name, the
% onset time, and the stimulus duration. For different experiments,
% you will need to write an equivilent function to this and add
% your own information. The only critical thing is that you will
% need to include the fields stim.stimLatency and
% stim.stimDuration, as subsequent analysis functions employ these to
% figure out the response window.     
%
% Inputs
% data - the twoPhoton object [optional, if no arguments add params
%        to all twoPhoton objects in the current path]
% params - a parameter structure of the sort used by Rob's deliver
%          odours routine. [optional, if empty search for the
%          params and load]
%
% Outputs
% data - the twoPhoton object with a field called "stimuli"
%        containing the stimulus paramsers. 
%
%
%
% Important:
% This function loads a particular data structure produce by our
% stimulus delivery system and adds these data to the twoPhoton
% object in the data.stim field. These are important meta-data
% because they contain information such as the stimulus latency,
% identity, and duration. It doesn't matter what your particular
% stimuli are or how you store the data regarding what was
% presented on each trial. What does matter is that you import this
% information so as to produce the fields expected by the twoPhoton
% toolbox. You will need to have a structure called within each
% trial of the data structure. Here is an example from an
% experiment where odors were used as stimuli:
%    
% >> data(1).stim
%
% ans = 
%
%     stimLatency: 8
%           odour: '3-octanol'
%             isi: 25
%      odourNames: [1x1 struct]
%       timestamp: 7.3418e+05
%    stimDuration: 1
%
% 
% The critical fields, which you will need to reproduce, are
% stimLatency and stimDuration. Those are used to determine the
% response period by other functions. 
%
% Rob Campbell 


if nargin==0
    d=dir('*.mat');
    for ii=1:length(d)
        F=whos('-file',d(ii).name);
        if length(F)>1 | ~strcmp(F.class,'twoPhoton')
            fprintf('%d/%d - skipping %s\n',ii,length(d),d(ii).name)
            continue
        end
        
        fprintf('%d/%d - adding stim params to %s\n',ii,length(d),d(ii).name)
        load(d(ii).name)
        addStimParams(data);
        save(d(ii).name,'data')

    end
    return
end

    
if nargin==1
    DIR=data(1).info.rawDataDir;
    FILES=dir([data(1).info.rawDataDir,'/params*']);

    if length(FILES)~=1
        fprintf('Found %d parameter files. Skipping.\n',length(FILES))
        return
    end

    load([DIR,'/',FILES.name])
    addStimParams(data,params);
    return
end


if strcmp(data(1).info.type,'scanimage')
    error('These are scanimage data. Please use addStimParamsSI')
end
    
%Modify the frame period if we have volumes. 
if ~strcmp('TSeries Timed Element',data(1).info.type) & ~strcmp('scanimage',data(1).info.type)
    disp('Correcting frame period for volume data')
    for ii=1:length(data)
            data(ii).info.framePeriod=...
                    data(ii).info.framePeriod* ...
                size(data(ii).info.positionCurrent_XAxis,1);
    end
end


    
%This is for legacy support and will be removed at some point
if length(params)==1 && length(params.stimLatency)==1 
    
    names={params.odourNames(params.odours).odour};
    disp('Old style parameter file')
    
    for ii=1:length(data)
        
        data(ii).stim.stimLatency=params.stimLatency;            
        data(ii).stim.stimDuration=params.duration;
        data(ii).stim.odour=names{ii};
        
        if isfield(params,'data')
            data(ii).stim.PID=params.data{ii};
            data(ii).stim.sr=params.sr;
        end
    end
else  
    
    %This is the code that will probably be used for all new
    %data (at least from summer 2010 onwards)
    N=0;
    for P=1:length(params)
        [data,N]=largeOlfactom(data,params(P),N);            
    end 
end
  

return

%May re-work this code if needed to write a better name string for
%Alicat Olfactom data
for i=1:length(data)        
    odours=data(i).stim.odour(data(i).stim.stimLatency>1);%presented
                                                          %odours
    
    onset=data(i).stim.stimLatency(data(i).stim.stimLatency>1);
    offset=data(i).stim.stimDuration(data(i).stim.stimLatency>1);
    concs=data(i).stim.concs(data(i).stim.stimLatency>1);
    tmp=[];
    for j=1:length(odours)
        tmp=[tmp,sprintf('%s t=%0.2g,%0.2g[%0.2g]; ',...
                         odours{j},onset(j),offset(j), ...
                         concs(j))];
    end
    tmp(end-1:end)=[];
    data(i).stim.odour=tmp;
end

  

function [data,ind]=largeOlfactom(data,theseParams,n)
    
    L=length(data);
    F=fields(theseParams);

    for ii=1:length(theseParams.isi)
        ind=ii+n;
        if ind>L, break, end
        data(ind).stim=[];
        
        for jj=1:length(F)
            if strcmp(F{jj},'data'),continue,end
            if strcmp(F{jj},'odourList'),continue,end
            

            if strcmp(F{jj},'odours') & isnumeric(theseParams.odours)
                O=theseParams.(F{jj})(ii);
                data(ind).stim.odour= ...
                    theseParams.odourNames(O).odour;
            elseif strcmp(F{jj},'odours')
                data(ind).stim.odour=theseParams.odours{ii};
            elseif strcmp(F{jj},'odourNames')
                on=sort(unique(theseParams.odours));
                data(ind).stim.odourNames=theseParams.odourNames(on);

            elseif length(theseParams.(F{jj}))>=L
                dat=theseParams.(F{jj});
                if numel(dat)==length(dat) %in case params data are stored as one row
                    dat=dat(ii);
                else
                    dat=dat(ii,:);
                end                
                data(ind).stim.(F{jj})=dat;
            end
        end
        
        
        
        if isfield(theseParams,'data')
            if length(theseParams.data)>=ind
                data(ind).stim.PID=theseParams.data{ii};
                data(ind).stim.sr=theseParams.sr;
            else
                data(ind).stim.PID=[];
                data(ind).stim.sr=[];
            end
            
        end
        
        if isfield(data(ind).stim,'duration')
            data(ind).stim.stimDuration=data(ind).stim.duration;
            data(ind).stim=rmfield(data(ind).stim,'duration');
        end
        
            
    end
        
    


function data=addStimParamsVol(data,params)
% Add stimulus parameters to a volume data structure
%
% function data=addStimParamsVol(data,params)
%
% Purpose
% Add stimulus parameters to the twoPhoton object. 
%
% Inputs
% data - the twoPhoton object
% params - a parameter structure of the sort used by Rob's deliver
%          odours routine.
%
% Outputs
% data - the twoPhoton object with a field called "stimuli"
%        containing the stimulus paramsers. 
%
% Rob Campbell 

    
    disp('THIS FUNCTION HOPEFULLY WON''T BE NEEDED SOON')
    
N=0;
for P=1:length(params)
    [data,N]=largeOlfactom(data,params(P),N);            
end
  

%Update the stim pre-frames to cope with our data
%HARD CODE 3 BASELINE VOLUMES!
for ii=1:length(data)
    data(ii).info.framePeriod=data(ii).relativeFrameTimes(end);
    data(ii).dffParams.baseLineTime=...
        3*data(ii).relativeFrameTimes(end);
end



  



function [data,ind]=largeOlfactom(data,theseParams,n)
    
    L=length(data);
    F=fields(theseParams);
    for ii=1:length(theseParams.odours)
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
        
    


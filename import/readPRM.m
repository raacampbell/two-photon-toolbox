function prm=readPRM(fname)
% Import Trigger Sync PRM file
%   
% function prm=readPRM(fname)
%
% Purpose
% Import data from a Prairie View .prm file.
%
% Inputs
% fname - the file name of the .prm to import
%
% Outputs
% prm - a structure containing the data in the prm file.
%
% 
% Rob Campbell - December 2009
    

    
    
fid=fopen(fname); 
fgetl(fid); %Discard the first line

prm=struct;

%Read the first few lines
for i=1:11, prm=readVal1(fgetl(fid),prm); end
fgetl(fid);  

%Now we read in the DAC lines but we'll skip some of the crap which
%we're probably not going to need. YOU WILL NEED TO UPDATE THE
%CODE IF YOU WANT TO USE THESE EPOCH THINGIES. 
while 1
    tline=fgetl(fid);
    if isempty(strfind(tline,'DAC')), break, end    
    if strfind(tline,'Epoch'), continue, end
    if strfind(tline,'Color'), continue, end

    [prm,i]=readDAC(tline,prm); 
    prm.DAC(end).channelID=i-1;
end


%Now add the remaining channel info which is located further down
%the file.
numChannels=length(prm.DAC);
while 1
    tline=fgetl(fid);
    if tline<0, break, end

    %Skip the following 
    if strfind(tline,'Color'),            continue, end
    if strfind(tline,'Continuous Pulse'), continue, end
    if strfind(tline,'Channel Min-Max'),  continue, end
    if strfind(tline,'Sensitivity'),      continue, end
    if strfind(tline,'Misce'),            continue, end
    if strfind(tline,'Camera'),           continue, end
    if strfind(tline,'Marked '),          continue, end

    
    %Look for section heading
    if regexp(tline,'\[(.*)\]')
        tok=regexp(tline,'\[(.*)\]','tokens');
        headingName=strrep(tok{1}{1},' ','');
        
        for i=1:numChannels
            prm=readChanInfo(fgetl(fid),prm,headingName);
        end        
    end
    
end


fclose(fid);



%Only keep the ones that have useful outputs:
prm.DAC(find(~[prm.DAC.OutputSignal]))=[];



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data=readVal1(tline,data)
    tok=regexp(tline,'(.*)=(.*)','tokens');
    
    vName=tok{1}{1};
    value=str2double(tok{1}{2});
    vName=regexprep(vName,'[ /]','');
    vName=regexprep(vName,'uisition','');
    
    data.(vName)=value;
  
  

function [data,i]=readDAC(tline,data)
    tok=regexp(tline,'DAC(\d+) (.*)=(.*)','tokens');
    i=str2double(tok{1}{1})+1;
    vName=tok{1}{2};
    vName=regexprep(vName,'[ -]','');

    value=tok{1}{3};
    if strcmp(value,'FALSE')
        value=0;
    elseif strcmp(value,'TRUE')
        value=1;
    end        

    if ~isnumeric(value)
        if isempty(strmatch(vName,{'DACLabel','CustomWaveformFile'}))
            value=str2double(value);
        end


    end
    
    if ischar(value)
        value=regexprep(value,'"','');    
    end
    
    data.DAC(i).(vName)=value;
  
  
function data=readChanInfo(tline,data,headingName)
    tok=regexp(tline,'Ch (\d+).*=(.*)','tokens');
    i=str2double(tok{1}{1})+1;
    value=tok{1}{2};

    if ~isempty(strfind(headingName,'GainChannel')) %don't convert to number here
        value=str2double(value);
    else        
        value=regexprep(value,'"','');
    end

    if strcmp(value,'FALSE')
        value=0;
    elseif strcmp(value,'TRUE')
        value=1;
    end        

    
    data.DAC(i).(headingName)=value;

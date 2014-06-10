function data=prairieXML_2_Matlab(FileName,extractInfoOnly)
% Import PrairieView XML and image-stacks to Matlab
%    
% function data=prairieXML_2_Matlab(FileName,extractInfoOnly)
%
% PURPOSE
%  Imports the data in a PraireView XML file (tested with versions
%  3 and 4) and associated image files. Creates a data structure
%  with the data. Tested with 1 and 2 channel data. Works with both
%  T-Series and Z-Series. 
%  
% INPUTS
%  FileName [optional] - a string specifying the name of the XML
%  file to import. The raw-data tiff files and the XML file should
%  be in the current directory. If run no arguments are given, the
%  function tries to find an XML file in the current directory. 
%  extractInfoOnly [optional] - if 1 we only extract information
%  and not import images. 0 by default. 
%
% OUTPUTS  
%  data - this function returns an object of class twoPhoton that
%  contains the meta data present in the XML file. The image stacks
%  are saved in the current directory as mat files. Each mat file
%  contains data from one image stack as a 3-D matrix (if we have
%  only one channel and depth). These are names rawDataX.mat, where
%  'X' represents the index of the recording. The twoPhoton
%  structure transparently accesses the rawData files.
%    
% NOTES
% Confocal and 2-photon image stacks will be indexed images (typically
% 12 or 16 bit). Many functions in the MathWorks Image Processing
% toolbox expect the image to be a matrix of doubles with pixel
% intensities between 0 and 1. This function will therefore normalise
% the image so imageStack it is no longer indexed. We divide by the
% bit depth of the image. ** However ** we will output a matrix of
% singles since double precision isn't needed and takes up twice the
% space. You therefore need to convert to double from time to time.
%
%
% Rob Campbell, March 2009
%
% Also See
% generateDFFobject.m, twoPImportBatch.m


%% To Do: remove sequence structure and do it all with info structure. 
    
if nargin<1 | isempty(FileName)
  d=dir('*.xml');
  if length(d)==1
    FileName=d.name;
  else
    fprintf('There are %d XML files in current directory: skipping\n',length(d))
    data=[];
    return    
  end
end

if nargin<2
    extractInfoOnly=0;
end

  

fid=fopen(FileName); %Open the XML file  
if fid<0
    error('Can''t find %s',FileName)
end

tline=fgets(fid); %Discard the first line

if ~ischar(tline)
    error('XML file appears to be empty')
end



%Get "header" information in line 2
tline = fgets(fid);
tok=regexp(tline,'PVScan version="(.*)" date="(.*)" notes="(.*)"','tokens');
info.XMLfile=FileName;
info.PVversion=tok{1}{1};
info.date=tok{1}{2};
info.notes=tok{1}{3};




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Step One: Get information from the rest of the XML file
fprintf('%s:  ',FileName)
chalk('extracting information',1);

while ischar(tline)

  %Each sequence signifies one repeat. Get information about this
  if ~isempty(strfind(tline, '<Sequence '))               
    expression='<Sequence type="(.*)" cycle="(\d+)"';
    tok=regexp(tline,expression,'tokens');
    cycleIndex=str2double(tok{1}{2});

   if cycleIndex==0 & strcmp('Single', tok{1}{1})        
        cycleIndex=1;
    end
    sequence(cycleIndex).type=tok{1}{1};
  end

  %Get information about frame
  if ~isempty(strfind(tline, '<Frame')) 
    expression='<Frame relativeTime="(.*)" absoluteTime="(.*)" index="(\d+)" label="(.*)"';
    tok=regexp(tline,expression,'tokens');
    index=str2double(tok{1}{3});
    sequence(cycleIndex).relativeFrameTimes(index)=str2double(tok{1}{1});
    sequence(cycleIndex).absoluteTime(index)=str2double(tok{1}{2});
  end

  %If it was single image then we will loop through this collecting all the
  %images.

  while ~isempty(strfind(tline, '<File '))
      if ~isempty(strfind(tline, '<File '))
          %Older versions of PV did not have a channel name
          %field. We won't bother collecting it here, unless
          %there's a real need. 
          expression='<File channel="(\d)".*filename="(.*)"';
          tok=regexp(tline,expression,'tokens');
          ch=str2double(tok{1}{1});
          fn=tok{1}{2};
          sequence(cycleIndex).channel(ch).frames(index).filename=fn;
          tline=fgets(fid);
      else
          continue
      end

  end

  %-----------------------------------------------------------------
  %Most parameters stored for each frame will not change between
  %frames. We will therefore save all of these just once from the
  %first frame alone. 

  %We now read in the information for each sequence (cycle)
  %fgets(fid)
  if ~isempty(strfind(tline,'<PVStateShard>'))

    %Objective lens done separately since this is the only
    %parameter that is a string.
    tline=fgets(fid);
    tok=regexp(tline,'<Key key="objectiveLens".*value="(.*)"','tokens');
    info(cycleIndex).objectiveLens=tok{1}{1};

    %Remaining keys have numeric values so keep reading until there
    %are no more. If it's a position key, we store these for all
    %frames. 
    tline=fgets(fid);


    while strfind(tline,'key="')
        %store the x/y/z positions for each frame        
        while ~isempty(strfind(tline, 'positionCurrent_')) 
            tok=regexp(tline,'Key key="(.*)" p.*value="(.*)"', 'tokens');
            var=tok{1}{1};
            val=str2num(tok{1}{2});
            info(cycleIndex).(var)(index,:)=val;
            tline=fgets(fid);        
        end        
        
        %Only run this for the first frame of each sequence. This
        %really speeds up the import. 
        if index==1
            var=regexp(tline,'Key key="(.*)" p', 'tokens');
            var=var{1}{1};
            info=readKey(tline,var,info,cycleIndex);
        end
        tline=fgets(fid);

        
    end
      
    if isfield(info(cycleIndex),'systemType')
        
        if info(cycleIndex).systemType==2, 
            info(cycleIndex).scanMode='AOD';
        elseif info(cycleIndex).systemType==3
            info(cycleIndex).scanMode='Galvo';
        else
            info(cycleIndex).scanMode='unknown';
        end
        
    end
    

  end

  tline=fgets(fid); %Go to the next line  
end

fclose(fid); %close access to the data file


%Add information present only in first structure to all the rest. 
for ii=2:length(info)
    info(ii).XMLfile=info(1).XMLfile;
    info(ii).PVversion=info(1).PVversion;
    info(ii).date=info(1).date;
    info(ii).notes=info(1).notes;
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Step Two: Check for sequences or channels with no frames and remove
%If there is an empty (unfinished) sequence at the end then remove
%it first. 
if length(sequence) ~= length(info)
    if isempty(sequence(end).channel)
        sequence(end)=[];
    end    
end

n=length(sequence);
skipped=0; %just a reference for the messages displayed to the user
for ii=n:-1:1
    if isempty(sequence(ii).relativeFrameTimes)
        sequence(ii)=[];
        info(ii)=[];

        if ~skipped
            fprintf('\n%s:  Removing empty sequence: ',FileName)
        end
        fprintf('%d, ',ii)
        skipped=1;
    else
        for jj=length(sequence(ii).channel):-1:1
            if isempty(sequence(ii).channel(jj).frames)
                sequence(ii).channel(jj)=[];
            end
        end
    end
    
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Step Three: Create data structure using the info and sequence
%%%             structures. 
LS=length(sequence);
if skipped
    fprintf('\b\b  \n%s:  ',FileName)
end

    
chalk(sprintf('creating data structure [%s]',repmat('.',1,LS)),skipped)
fprintf(repmat('\b',1,1+LS))


for S=1:LS

  data(S).info=info(S);
  data(S).info.type=sequence(S).type;
  data(S).relativeFrameTimes=sequence(S).relativeFrameTimes;  
  data(S).absoluteTime=sequence(S).absoluteTime;  
  data(S).info.stimIndex=S;
  data(S).info.rawDataDir=pwd;
  fprintf('*')  


  %Now we loop through the frame names and add these to the structure
  for ch=1:length(sequence(S).channel)
      for ii=1:length(sequence(S).channel(ch).frames)
          data(S).info.fileName{ch,ii}=...
              sequence(S).channel(ch).frames(ii).filename;
      end
  end
  
  if extractInfoOnly, continue, end
  imageStack=prairieTIFFs2Stack(data(S));

  data(S).info.rawDataFile=sprintf('rawData%d',S);
  eval([data(S).info.rawDataFile,'=imageStack;'])
  fileStr=[data(S).info.rawDataDir,filesep,data(S).info.rawDataFile];
  save(fileStr,data(S).info.rawDataFile,'-v6') %Save uncompressed. It's faster. Later we'll compress
  clear('raw*')


  
end %S=1:length(sequence)

fprintf(']') %needed to be neat so chalk will work as expected
chalk('Done!\n')

%Correct the number of microns per pixel if we're using PV
%version <4.3.2.12 [RAAC 13/9/2013]
thisVer=str2num(strrep(data(1).info.PVversion,'.',''));
if thisVer<43212
  opticalZoom=data(1).info.opticalZoom;
  x=data(1).info.micronsPerPixel_XAxis;
  y=data(1).info.micronsPerPixel_YAxis;
  for ii=1:length(data)
    data(ii).info.micronsPerPixel_XAxis=x/opticalZoom;
    data(ii).info.micronsPerPixel_YAxis=y/opticalZoom;    
  end
  
end


  
  
%Convert structure to data object
data=generateDFFobject(data);  



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Strips the value from a numeric "Key" tag in the XML document
function [info,value]=readKey(tline,key,info,ind)
  expression=['key="', key, '".*value="(.*)"']; %much faster than sprintf
  tok=regexp(tline,expression,'tokens');


  value=str2num(tok{1}{1});
  if isempty(value), return, end

  if ~isnan(value)
      key=strrep(key,' ',''); %Just in case there's a space
      info(ind).(key)=single(value);
  end
  


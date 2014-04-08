function tmp=formatZTseriesHack(data,channels,volsPerT)
% function data=formatZTseriesHack(data,channels,volsPerT)
%
% data - twoPhoton object
% channels - in which channels we have data (e.g. 1 or 1:2) [2 by default]
% volsPerT - how many volumes per stimulus. If empty, it attempts
%            to extract this value from the .cfg file
%
% Rob Campbell - August 2010


verbose=1;


if nargin<2
    channels=1;
end

if verbose
    if length(channels)==1
        fprintf('Working with %d channel\n',length(channels))
    else
        fprintf('Working with %d channels\n',length(channels))
    end
    
end


if nargin<3
   volsPerT=[];
   eval(['cfgName=dir(''',data(1).info.rawDataDir,'/*.cfg'');'])
   fid=fopen([data(1).info.rawDataDir,'/',cfgName.name]);
   tline = fgetl(fid);
   while ischar(tline)
     if strfind(tline,'repetitions=')
       tok=regexp(tline,'repetitions="([0-9]+)','tokens');
       volsPerT=str2num(tok{1}{1});
       break
     end     
     tline = fgetl(fid);
   end
   
   if isempty(volsPerT)
     error('volsPerT is empty. Can''t find it in .cfg file');
   end
   
   fclose(fid);
end




%Now build TZ series
x=1:length(data);
slicesPerVol=length(data(1).relativeFrameTimes);
x=reshape(x,volsPerT,length(data)/volsPerT)';
tmp=data(x(:,1));


%The number of depths will be the same in all recordings. 
nDepths=length(data(1).absoluteTime);
nVolumes=size(x,2);

for ii=1:size(x,1)    
    ind=x(ii,:);
    fprintf('%d/%d ',ii,size(x,1))
    tmp(ii).info.stimIndex=ii;    

    Z=makeZstack(data(ind),channels);
    tmp(ii).info.rawDataFile=sprintf('rawData%d',ii);
    eval([tmp(ii).info.rawDataFile,'=Z;'])

    
    
    %Now copy over other information 
    for jj=1:nVolumes

        tmp(ii).absoluteTime(1:nDepths,jj)=...
            data(x(ii,jj)).absoluteTime;
        
        tmp(ii).relativeFrameTimes(1:nDepths,jj)=...
            data(x(ii,jj)).relativeFrameTimes;
        
        tmp(ii).info.positionCurrent_XAxis(1:nDepths,jj)=...
            data(x(ii,jj)).info.positionCurrent_XAxis;
        tmp(ii).info.positionCurrent_YAxis(1:nDepths,jj)=...
            data(x(ii,jj)).info.positionCurrent_YAxis;

        if isfield(data(x(ii,jj)).info,'positionCurrent_ZAxis1')
          tmp(ii).info.positionCurrent_ZAxis1(1:nDepths,jj)=...
              data(x(ii,jj)).info.positionCurrent_ZAxis1;
          tmp(ii).info.positionCurrent_ZAxis2(1:nDepths,jj)=...
              data(x(ii,jj)).info.positionCurrent_ZAxis2;
        end
        if isfield(data(x(ii,jj)).info,'positionCurrent_ZAxis')
          tmp(ii).info.positionCurrent_ZAxis1(1:nDepths,jj)=...
              data(x(ii,jj)).info.positionCurrent_ZAxis(:,1);
          tmp(ii).info.positionCurrent_ZAxis2(1:nDepths,jj)=...
              data(x(ii,jj)).info.positionCurrent_ZAxis(:,2);
        end
        

    end
 
    %Replace .mat image files on disk
    fileStr=[tmp(ii).info.rawDataDir,'/',tmp(ii).info.rawDataFile];
    save(fileStr,tmp(ii).info.rawDataFile)
    eval(['clear ',tmp(ii).info.rawDataFile])
end

%Delete the redundant images to save disk space
for ii=length(tmp)+1:length(data)
    delete(sprintf('%s/rawData%d.mat',data(1).info.rawDataDir,ii))
end




function out=splitTZ_series(data,volsPerT)
% function splitTZ_series(data)
%
% Purpose 
%
% Convert a TZ series where V volumes are repeated R times each over I
% iterations into a structure composed of V rows (i.e. one for each
% depth) and I columns. Each T-Series, therefore will contain R
% frames. 
%
%
%
% Inputs
% data - twoPhoton object
% volsPerT - number of volumes in one iteration



x=1:length(data);
slicesPerVol=length(data(1).relativeFrameTimes);
x=reshape(x,volsPerT,length(data)/volsPerT)';


tmp=data(x(:,1)); %I columns (see help, above)
tmp=repmat(tmp,slicesPerVol,1); %V rows (see help, above)
size(tmp)
return
stimIndex=1;


for ii = 1:size(tmp,2)
    fprintf('%d/%d ',ii,size(x,1))

    ind=x(ii,:);
    %Z has size: x,y,volsPerT,channels,depths
    Z=makeZstack(data(ind),channels);

    for jj=1:slicesPerVol
        tSeries=squeeze(Z(:,:,:,jj));
        tmp(ii,jj).info.stimIndex=stimIndex;

    
    %ASSUME THERE IS ONE CHANNEL ONLY. SO NOW:
    %Z has size: x,y,volsPerT,depths
    Z=squeeze(Z)

        stimIndex=stimIndex+1;
    end
    
    
    
    
    tmp(ii).info.rawDataFile=sprintf('rawData%d',ii);
    eval([tmp(ii).info.rawDataFile,'=Z;'])


    
end


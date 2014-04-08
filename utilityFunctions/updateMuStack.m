function updateMuStack(data)
% function updateMuStack(data)
%
% Loop through the data structure, loading each stack in turn,
% averaging it and placing the result into
% data.info.muStack. Removes the response frames prior to
% averaging. muStack has 3 dimensions. The third corresponding to
% the registraions. First slice of 3rd dim is unregistered. Then we
% move through the different registations. data.process.registration


verbose=1;



skips=[data(1).process.registration{1}.skip];
for ii=1:length(data)
    %store skips

    if verbose
        fprintf('%d/%d\n',ii,length(data))
    end
    
    rs=data(ii).process.regSeries;
    rp=responsePeriodFrames(data(ii));

    reg=data(ii).process.registration{rs};
    
    regParams(data(ii),'skip',1:length(reg))

    muStack=ones(data(ii).info.linesPerFrame,...
                 data(ii).info.pixelsPerLine,...
                 length(reg)+1);
    
    
    im=data(ii).imageStack;
    nonResp=[1:rp(1)-2,rp(2)+2:size(im,3)];
    muStack(:,:,1)=mean(im(:,:,nonResp),3);
    for jj=1:length(reg)
        if ~skips(jj)
            regParams(data(ii),'unskip',jj)
            im=preProcess(im,data(ii));
            regParams(data(ii),'skip',jj)
        end
        
        muStack(:,:,jj+1)=mean(im(:,:,nonResp),3);
        
    end
    regParams(data(ii),'unskip',1:length(reg))
    data(ii).info.muStack=single(muStack);
    
    
end

%go back to original skips
for ii=1:length(skips)
    if skips(ii)
        regParams(data,'skip',ii)
    end
end

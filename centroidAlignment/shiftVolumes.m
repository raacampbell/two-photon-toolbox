function im=shiftVolumes(im,shifts)
%
% Shift the RFP channel in im by the x,y,z shifts described by
% the rows of shifts. Returns the image matrices as a 4-d array



for ii=1:size(im,3)
    
    tmp=imtranslate(squeeze(im(:,:,ii,:)), shifts(ii,:));
    for jj=1:size(tmp,4)
        im(:,:,ii,jj)=tmp(:,:,jj);
    end
    
    
end

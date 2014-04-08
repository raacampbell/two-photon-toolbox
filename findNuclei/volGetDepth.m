function im=volGetDepth(data,depth,chan)
%
% Purpose
% pulls out one depth of one channel from all volumes
%
% 

im=mean(data(1).imageStack(:,:,:,chan,:),3);
im=squeeze(im(:,:,:,:,depth));

im=repmat(im,[1,1,length(data)]);


for ii=2:length(data)
    fprintf('.')
    tmp=mean(data(ii).imageStack(:,:,:,chan,:),3);
    tmp=squeeze(tmp(:,:,:,:,depth));
    im(:,:,ii)=tmp;
end

fprintf('\n')

function imageStack=averageDownIm(imageStack,dim)
% function imageStack=averageDownIm(imageStack,dim)
%
% Average down an image stack until only dim dimensions are left. By
% default, dim=3. Starts at highest non-singleton
% dimension. Singleton dimensions are removed first. 
%
% Inputs
% imageStack - a high-D image stack containing channel and TZ
% dimensions
% dim - scalar the number of dimensions
%
% Rob Campbell


if nargin<2
    dim=3;
end

imageStack=squeeze(imageStack);

while length(size(imageStack))>dim
    
    L=length(size(imageStack)); 
    imageStack=squeeze(mean(imageStack,L));
    
    
    if dim==1 && numel(imageStack)==length(imageStack)
        break
    end
    
end

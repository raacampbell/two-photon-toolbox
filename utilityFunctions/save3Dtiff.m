function save3Dtiff(imageStack,fname)
% Save 3-D grayscale matrix 'imageStack' as 3-D tiff 'fname'.
%  
% function save3Dtiff(imageStack,fname)
%
% Purpose
% Save 3-D grayscale matrix 'imageStack' as 3-D tiff 'fname'.
%
% Note
% Writes 16 bit tiffs. If your data are floats between zero and 1
% then it will convert to uint16 before saving. 
%  
% Rob Campbell, September 2009

if round(range(imageStack))<=1
    imageStack=imageStack*2^16;
end
if ~strcmp(class(imageStack),'uint16')
    imageStack=uint16(imageStack);
end


options={'compression','none'};
imwrite(imageStack(:,:,1),fname,'tiff','writemode','overwrite',options{:})  
for ii=2:size(imageStack,3)
  imwrite(imageStack(:,:,ii),fname,'tiff','writemode','append',options{:})
end

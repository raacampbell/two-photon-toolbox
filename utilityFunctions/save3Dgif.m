function save3Dgif(imageStack,fname)
% Save 3-D grayscale matrix 'imageStack' as 3-D (animated) gif 'fname'.
%  
% function save3Dgif(imageStack,fname)
%
% Purpose
% Save 3-D grayscale matrix 'imageStack' as 3-D gif 'fname'.
%
%  
% Rob Campbell, September 2009

if round(range(imageStack))<=1
    imageStack=imageStack*2^8;
end
if ~strcmp(class(imageStack),'uint8')
    imageStack=uint8(imageStack);
end


%options={'compression','none'};
options={'DelayTime',0.5};
imwrite(imageStack(:,:,1),fname,'gif','writemode','overwrite',options{:},...
    'LoopCount',inf);
for ii=2:size(imageStack,3)
  imwrite(imageStack(:,:,ii),fname,'gif','writemode','append',options{:})
end

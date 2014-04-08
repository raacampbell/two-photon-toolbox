function im=translateSlices(im,offSetPixel,phase)

% function im=translateSlices(im,offSetPixel,phase)%
%
% im is the 3-D image matrix. We shift each of the frames in the
% 3rd dimension by the row and column values specified in
% offSetPixel. 
%
% Code from alignOverReps, which in turn came from the dftshift
% routine. 
%
% Rob Campbell - August 2010

nr=size(im,1);
nc=size(im,2);
Nr = ifftshift([-fix(nr/2):ceil(nr/2)-1]);
Nc = ifftshift([-fix(nc/2):ceil(nc/2)-1]);    
[Nc,Nr] = meshgrid(Nc,Nr);

row_shift=offSetPixel(1)*1.2;
col_shift=offSetPixel(2)*1.2;

for ii=1:size(im,3)
    tmpFFT=fft2(im(:,:,ii));
    reg=tmpFFT.*exp(i*2*pi*(-row_shift*Nr/nr-col_shift*Nc/nc));
    reg=reg.*exp(-i*phase); 
    im(:,:,ii)=abs(ifft2(reg));
end


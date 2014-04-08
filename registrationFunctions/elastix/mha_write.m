function mha_write(im,fname)
% Writes MHA and RAW files for an image. 
%
% function mha_write(im,fname)
%
% im is a double or single precision floating point image
% stack. voxels are bounded between 0 and 1. Does not have to span
% the whole range. This function saves the image as a double and
% converts to 16 bit.
%
% see:
% http://www.itk.org/pipermail/insight-users/2007-November/024337.html


%Probably data are from zero to 1. Check that and if so convert to 16
%bit. If there's a rounding error that's causing it to be a little
%more than 1, we'll spot it here.
m=max(im(:));
M=max(round(im(:)));

if M==1 & m>1
    fprintf('write elastix: image was not properly rounded. max: %1.7f\n',M)
    im=im/m;
end

if m<=1
    im=im*2^16;
end

fid=fopen([fname,'.raw'],'w+');
cnt=fwrite(fid,im,'double');
fclose(fid);



fid=fopen([fname,'.mhd'],'w+');
fprintf(fid,'NDims = %d\n', length(size(im)));
fprintf(fid,['DimSize = ',repmat('%d ',1, length(size(im))), '\n'], size(im));
fprintf(fid,'ElementSize = 1 1 1\n');
fprintf(fid,'ElementSpacing = 1 1 1\n');
fprintf(fid,'ElementType = MET_DOUBLE\n');
fprintf(fid,'ElementByteOrderMSB = False\n');
fprintf(fid,'ElementDataFile = %s.raw\n',fname);
fclose(fid);

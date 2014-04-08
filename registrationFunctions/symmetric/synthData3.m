function [ img1,img2,xout,yout,zout ] = synthData3( howmany, imgsize, r, varargin )
%SYNTHDATA3 Produce test data for registration code
%     [IMG1,IMG2,XOUT,YOUT,ZOUT] = SYNTHDATA3( HOWMANY,IMGSIZE,R,SHAPE ) returns a square image img1
%     with size imgsize x imgsize and stack of deformed images img2 with size
%     imgsize x imgsize x howmany. IMG2 is produced by local
%     polynomial deformations originating from the center of the image. The
%     produced images can be either a circle (default) or a square. R controls
%     the radius of the circle or half the side length of the square.
%     XOUT and YOUT are the deformed meshgrids used to produce IMG2; they can be
%     compared to the output of a registration.

%Create images
[x,y,z] = meshgrid(1:imgsize,1:imgsize,1:imgsize);

[xf,yf,zf] = meshgrid(-imgsize/2:(imgsize/2 - 1),-imgsize/2:(imgsize/2 - 1),-imgsize/2:(imgsize/2 - 1));
rad = xf.^2 + yf.^2 + zf.^2;

img1 = zeros(imgsize,imgsize,imgsize);
img2 = zeros(imgsize,imgsize,imgsize,howmany);

if (nargin < 4 || strcmpi(shape,'cube'))
    img1(imgsize/2-r:imgsize/2+r,imgsize/2-r:imgsize/2+r,imgsize/2-r:imgsize/2+r) = 1;
else
    img1(rad <= r) = 1;
end

%Add low pass filtered noise
noise = randn(imgsize,imgsize,imgsize);
noiseft = fftshift(fftn(noise));
disc = zeros(imgsize,imgsize,imgsize);
disc(rad <= 4 * log2(imgsize)) = 1;
disc = smooth3(disc,'gaussian');
noiseft = noiseft .* disc;
noise = real(ifftn(ifftshift(noiseft)));
img1 = img1 .* noise;

%Normalize
img1 = img1/max(img1(:));

%Make sure that background is clearly different from image
img1(img1 == 0) = -2;

for i = 1:howmany
    
%Generate coefficients
coefsx = -.06 + .12 * rand(9,1);
coefsy = -.06 + .12 * rand(9,1);
coefsz = -.06 + .12 * rand(9,1);

centersx = -3 + 6 * rand(9,1);
centersy = -3 + 6 * rand(9,1);
centersz = -3 + 6 * rand(9,1);

defx = zeros(imgsize,imgsize,imgsize);
defy = zeros(imgsize,imgsize,imgsize);
defz = zeros(imgsize,imgsize,imgsize);

x2 = x;
y2 = y;
z2 = z;

%Use coefficients to find deformations
for k = 1:2
    defx = defx + coefsx(3*k - 2) * (xf - centersx(3*k - 2)).^(3-k) + coefsx(3*k - 1) * (yf - centersx(3*k - 1)).^(3-k) + coefsx(3*k) * (zf - centersx(3*k)).^(3-k);
    defy = defy + coefsy(3*k - 2) * (xf - centersy(3*k - 2)).^(3-k) + coefsy(3*k - 1) * (yf - centersy(3*k - 1)).^(3-k) + coefsy(3*k) * (zf - centersy(3*k)).^(3-k);
    defz = defz + coefsz(3*k - 2) * (xf - centersz(3*k - 2)).^(3-k) + coefsz(3*k - 1) * (yf - centersz(3*k - 1)).^(3-k) + coefsz(3*k) * (zf - centersz(3*k)).^(3-k);
end

defx = defx + coefsx(7) * xf.*yf + coefsx(8) * xf.*zf + coefsx(9) * yf.*zf;
defy = defy + coefsy(7) * xf.*yf + coefsy(8) * xf.*zf + coefsy(9) * yf.*zf;
defz = defz + coefsz(7) * xf.*yf + coefsz(8) * xf.*zf + coefsz(9) * yf.*zf;

while 1
    
    %Apply local deformation. If deformation is too great, reduce and try
    %again.
    x2 = x + defx .* exp(-rad/(r/4).^3);
    y2 = y + defy .* exp(-rad/(r/4).^3);
    z2 = z + defz .* exp(-rad/(r/4).^3);
    
    x2 = min(max(1,x2),imgsize);
    y2 = min(max(1,y2),imgsize);
    z2 = min(max(1,z2),imgsize);
    
    if (min(x2(:)) >= 1 && max(x2(:)) <= imgsize && min(y2(:)) >= 1 && max(y2(:)) <= imgsize && min(z2(:)) >= 1 && max(z2(:)) <= imgsize)
        xout(:,:,:,i) = x2;
        yout(:,:,:,i) = y2;
        zout(:,:,:,i) = z2;
        break;
    else
        defx = .7 * defx;
        defy = .7 * defy;
        defz = .7 * defz;
    end
end

img2(:,:,:,i) = interp3(img1,x2,y2,z2,'cubic');


end


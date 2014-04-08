function [ img1,img2,xout,yout ] = synthData2( howmany, imgsize, r, varargin )
%SYNTHDATA2 Produce test data for registration code
%     [IMG1,IMG2,XOUT,YOU] SYNTHDATA2( HOWMANY,IMGSIZE,R,VARARGIN ) returns a square image img1
%     with size IMGSIZE x IMGSIZE and stack of deformed images IMG2 with size
%     IMGSIZE x IMGSIZE x HOWMANY. IMG2 is produced by local
%     polynomial deformations originating from the center of the image. The
%     produced images can be either a circle (default) or a square. G controls
%     the radius of the circle or half the side length of the square.
%     XOUT and YOUT are the deformed meshgrids used to produce IMG2; they can be
%     compared to the output of a registration.

if (nargin < 4)
    shape = 'circle';
else
    shape = varargin{1};
end

%Draw images
[x,y] = meshgrid(1:imgsize,1:imgsize);

[xf,yf] = meshgrid(-imgsize/2:(imgsize/2 - 1), -imgsize/2:(imgsize/2 -1));

img1 = zeros(imgsize,imgsize);
img2 = zeros(imgsize,imgsize,howmany);

rad = xf.^2 + yf.^2;

if (strcmpi(shape,'circle'))
    img1(rad <= r^2) = 1;
else
    img1(imgsize/2 - r:imgsize/2 + r, imgsize/2 - r:imgsize/2 + r) = 1;
end



%Generating low-pass filtered noise
noise = randn(imgsize,imgsize);
noiseft = fftshift(fft2(noise));
disc = zeros(imgsize,imgsize);
disc(rad <= 4 * log2(imgsize)) = 1;
f = fspecial('gaussian',3);
disc = filter2(f,disc);
noiseft = disc .* noiseft;
noise = real(ifft2(ifftshift(noiseft)));
img1 = filter2(f,img1);
img1 = noise .* img1;


%Differentiating background
img1 = img1/max(img1(:));
img1(img1==0) = -2;

for i = 1:howmany

coefsx = -.06 + .12 * rand(5,1);
coefsy = -.06 + .12 * rand(5,1);

centersx = -10 + 20 * rand(6,1);
centersy = -10 + 20 * rand(6,1);

defx = zeros(imgsize,imgsize);
defy = zeros(imgsize,imgsize);

x2 = x;
y2 = y;

for k = 1:2
    defx = defx + coefsx(2*k-1) * (xf - centersx(2*k-1)).^(3-k) + coefsx(2*k) * (yf - centersx(2*k)).^(3-k);
    defy = defy + coefsy(2*k-1) * (xf - centersy(2*k-1)).^(3-k) + coefsy(2*k) * (yf - centersy(2*k)).^(3-k);
end

defx = defx + coefsx(5) * xf .* yf;
defy = defy + coefsy(5) * xf .* yf;

while 1
    x2(20:end-20,20:end-20) = x(20:end-20,20:end-20) + defx(20:end-20,20:end-20) .* exp(-(rad(20:end-20,20:end-20))/(r/2.5)^2);
    y2(20:end-20,20:end-20) = y(20:end-20,20:end-20) + defy(20:end-20,20:end-20) .* exp(-(rad(20:end-20,20:end-20))/(r/2.5)^2);
    
    if (min(x2(:)) >= 1 && max(x2(:)) <= imgsize && min(y2(:)) >= 1 && max(y2(:)) <= imgsize)
        xout(:,:,i) = x2;
        yout(:,:,i) = y2;
        break;
    else
        defx = .7 * defx;
        defy = .7 * defy;
    end
end

img2(:,:,i) = interp2(img1,x2,y2);


end

function img_out=filter_image(img,sigma)
h=fspecial('gaussian',13,sigma);
img_out=conv2(img,h,'same');


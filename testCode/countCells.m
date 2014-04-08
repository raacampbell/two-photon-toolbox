% script that attempts (badly to count number of KCs)

hy = fspecial('sobel');
hx = hy';
Iy = imfilter(double(I), hy, 'replicate');
Ix = imfilter(double(I), hx, 'replicate');
gradmag = sqrt(Ix.^2 + Iy.^2);



%This over-segments
L = watershed(gradmag);
Lrgb = label2rgb(L);
imagesc(Lrgb)




se = strel('disk', 1);
Io = imopen(I, se);

se=strel('disk',1);
Io = imopen(I, se);imagesc(Io)
Ioc = imclose(Io, se);

Id = imdilate(I, se);imagesc(Id)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%This looks interesting
Ie = imerode(I, se); imagesc(Ie)

%then ran the image through the LEMS1im thingy that equalises
%brightness. Took the result and did:
se=strel('disk',2)
d(d>900)=0; %d is the corrected image with the 
imagesc(imclose(edge(d,'canny',0.05),se))

im=imread('correctedPh.tif'); %pass it through the color picker tool in ps7
bw=im2bw(im,0.55);


%In fact, that works about as well as running it on Ie

L = watershed(Ie);
Lrgb = label2rgb(L);
imagesc(Lrgb)



hy = fspecial('sobel');
hx = hy';
Iy = imfilter(double(Ie), hy, 'replicate');
Ix = imfilter(double(Ie), hx, 'replicate');
gradmag = sqrt(Ix.^2 + Iy.^2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Iobr = imreconstruct(Ie, I);






%This process gets us back to where we were before. Much like the other
%open and close things above. 
Iobrd = imdilate(Iobr, se);
Iobrcbr = imreconstruct(imcomplement(Iobrd), imcomplement(Iobr));
Iobrcbr = imcomplement(Iobrcbr);

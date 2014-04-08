function varargout=example

%Load the data
load lena
lena=double(lena);
lena=lena/max(lena(:));


%Plot original data
clf
subplot(2,2,1)
imshow(lena)
title('Original')



tform = maketform('affine',[2 0 0; .5 1 0; 0 0 1]);
                           


lenaTrans=imrotate(lena,30,'bicubic');
lenaTrans(lenaTrans<0)=0;
lenaTrans=lenaTrans/max(lenaTrans(:));

subplot(2,2,2)
imshow(lenaTrans)
title('Transformed')
drawnow



p(1).Transform='EulerTransform';
p(1).NumberOfSpatialSamples=2450;
p(1).MaximumNumberOfIterations=2000;
p(1).SP_a=4000;

%p(2).Transform='BSplineTransform';
tic
%[reg,out]=apply_elastix(lenaRot,lena,p);

[reg,out]=apply_demon(lenaTrans,lena);
toc
subplot(2,2,3),
imshow(reg)
title('CORRECTED')
%odd, it works like crap for many of these rotations but the demon 
%registration reg is really is good. Sigh...



if nargout>0
    varargout{1}=reg;
end
if nargout>1
    varargout{2}=out
end

function [f_c,f_r,img2_o_f] = register2(img1,img2,rho,lambda,maxIter,varargin)

%% [F_C,F_R,IMG2_O_F] = REGISTER2(IMG1,IMG2,RHO,LAMBDA,MAXITER,OPTIONS) 
% performs a non-rigid registration on IMG1, returning two functions, F_C and F_R,
% that transform IMG2 into IMG1, as well as IMG2 composed with these functions.
% 
% IMG1 and IMG2 can be binary or grayscale images read from a file or
% matlab variable. If read from a file with three layers such as jpeg,
% the intensity of the image will be calculated as the average of the
% three layers. RHO is the stepsize at each iteration, LAMBDA regulates
% the laplacian smoothing term, and MAXITER is the number of iterations
% performed.
%
% To save the original, interpolated, and difference images, append
% 'Images' to the input arguments. To save a .mat file containing the
% output variables as well as the original images, append 'Mat'.
%                                                                
% Example: register2(brain1,brain2,0.5,0.1,1000,'Images');
%
% See also register2Symmetric, register3, register3Symmetric

%If inputs are images, read them
if (ischar(img1))
    img1 = double(imread(img1));
    if (size(img1) == 3)
        img1 = (img1(:,:,1) + img1(:,:,2) + img1(:,:,3))/3;
    end
end

if (ischar(img2))
    img2 = double(imread(img2));
    if (size(img1) == 3)
        img2 = (img2(:,:,1) + img2(:,:,2) + img2(:,:,3))/3;
    end
end

%Determine whether we should save images and/or .mat
save_mat = 0;
save_images = 0;

if (nargin > 5)
    if (strcmpi(varargin{1},'Mat'));
        save_mat = 1;
    elseif (strcmpi(varargin{1},'Images'));
        save_images = 1;
    end
    
    if (nargin > 6)
        
        if (strcmpi(varargin{2},'Mat'));
            save_mat = 1;
        elseif (strcmpi(varargin{2},'Images'));
            save_images = 1;
        end
    end
end
    
if (save_images)
    imwrite(mat2gray(img1), 'out/img1.png', 'png');
    imwrite(mat2gray(img2), 'out/img2.png', 'png');
    imwrite(mat2gray(img1-img2), 'out/diff_orig.png', 'png');
end

imgSize = size(img1);
rows = imgSize(1);
cols = imgSize(2);

%Initialize the registration function
[f_c,f_r]=meshgrid(1:cols,1:rows);

[dr_img2_orig,dc_img2_orig] = grad_img(img2);


%Calculate grid size. Blocks are fixed at 32x32.
grid = [ceil(cols/32), ceil(rows/32)];
   
%Initialize kernels
interp = parallel.gpu.CUDAKernel('register2.ptx','register2.cu', 'interp');
interp.GridSize = grid;
interp.ThreadBlockSize = [32,32];

extf = parallel.gpu.CUDAKernel('register2.ptx', 'register2.cu', 'extf');
extf.GridSize = grid;
extf.ThreadBlockSize = [32,32];

intf = parallel.gpu.CUDAKernel('register2.ptx', 'register2.cu', 'intf');
intf.GridSize = grid;
intf.ThreadBlockSize = [32,32];

add = parallel.gpu.CUDAKernel('register2.ptx', 'register2.cu', 'add');
add.GridSize = grid;
add.ThreadBlockSize = [32,32];

d_f = parallel.gpu.CUDAKernel('register2.ptx', 'register2.cu', 'd_f');
d_f.GridSize = grid;
d_f.ThreadBlockSize = [32,32];

%Initialize variables on the GPU

dr_img2 = gpuArray(dr_img2_orig);
dc_img2 = gpuArray(dc_img2_orig);

img2_o_f = gpuArray(img2);


f_c = gpuArray(f_c);
f_r = gpuArray(f_r);

img1 = gpuArray(img1);
img2 = gpuArray(img2);

extf_r = parallel.gpu.GPUArray.zeros(size(f_c));
extf_c = parallel.gpu.GPUArray.zeros(size(f_c));

intf_r = parallel.gpu.GPUArray.zeros(size(f_c));
intf_c = parallel.gpu.GPUArray.zeros(size(f_c));

d_f_r = parallel.gpu.GPUArray.zeros(size(f_c));
d_f_c = parallel.gpu.GPUArray.zeros(size(f_c));


for k=1:maxIter,
    
    %Interpolate image2 and gradient
    img2_o_f = feval(interp, img2_o_f, f_c, f_r, img2, rows, cols);
    
    dr_img2 = feval(interp, dr_img2, f_c, f_r, dr_img2_orig, rows, cols);
    dc_img2 = feval(interp, dc_img2, f_c, f_r, dc_img2_orig, rows, cols);

    %External energies
    extf_r = feval(extf, extf_r, img1, img2_o_f, dr_img2, rows, cols); 
    extf_c = feval(extf, extf_c, img1, img2_o_f, dc_img2, rows, cols);
    
    %Internal energies
    intf_r = feval(intf, intf_r, f_r, rows, cols);
    intf_c = feval(intf, intf_c, f_c, rows, cols);
    
    %Update f_c and f_r
    d_f_r = feval(d_f, d_f_r, intf_r, extf_r, rho, lambda, rows, cols);
    d_f_r = min(max(d_f_r,-3),3);
    f_r = feval(add, f_r, f_r, d_f_r, rows, cols);
    
    f_r = max(min(f_r, rows),1);
    
    d_f_c = feval(d_f, d_f_c, intf_c, extf_c, rho, lambda, rows, cols);
    d_f_c = min(max(d_f_c,-3),3);
    f_c = feval(add, f_c, f_c, d_f_c, rows, cols);
    
    f_c = max(min(f_c, cols),1);
    
end

img1 = gather(img1);
img2_o_f = gather(img2_o_f);

if (save_images)
    imwrite(mat2gray(img2_o_f), 'out/interpolated2.png', 'png');
    imwrite(mat2gray(img1 - img2_o_f), 'out/diff.png', 'png');
end

if (save_mat)
    img2 = gather(img2);
    f_c = gather(f_c);
    f_r = gather(f_r);
    save('out/register2.mat','f_c','f_r','img1','img2_o_f','img2');
end


function [dr_img,dc_img]=grad_img(img)
dr_img=zeros(size(img));
dc_img=zeros(size(img));

dr_img(2:end-1,2:end-1)=img(3:end,2:end-1)-img(1:end-2,2:end-1);
dc_img(2:end-1,2:end-1)=img(2:end-1,3:end)-img(2:end-1,1:end-2);
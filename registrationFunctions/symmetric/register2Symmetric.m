function [g_c,g_r,f_c,f_r,img1_o_g,img2_o_f] = register2Symmetric(img1,img2, rho, lambda, lambda2, maxIter, varargin)

%% [G_C,G_R,F_C,F_R,IMG1_O_G,IMG2_O_F] = REGISTER2SYMMETRIC(IMG1,IMG2,
% RHO, LAMBDA, LAMBDA2, MAXITER, OPTIONS) performs a non-rigid
% registration on IMG1 and IMG2, transforming each of them into an image
% between the two. The transformation functions G_C, G_R, F_C, and F_R are
% returned, as well as the transformed images. 
%
% IMG1 and IMG2 can be binary or grayscale images read from a file or
% matlab variable. If read from a file with three layers such as jpeg,
% the intensity of the image will be calculated as the average of the
% three layers. RHO is the stepsize at each iteration, LAMBDA regulates
% the laplacian smoothing term, LAMBDA2 regulates the barrier function
% and MAXITER is the number of iterations performed
% 
% To save the original, interpolated, and difference images, append
% 'Images' to the input arguments. To save a .mat file containing the
% output variables as well as the original images, append 'Mat'.
%                                                                
% Example: register2(brain1,brain2,0.5,0.3,0.3,1000,'Images','Mat');
%
% See also register2, register3, register3Symmetric

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

save_images = 0;
save_mat = 0;

if (nargin > 6)
    if (strcmpi(varargin{1},'Mat'));
        save_mat = 1;
    elseif (strcmpi(varargin{1},'Images'));
        save_images = 1;
    end
    
    if (nargin > 7)
        
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

%Save initial stepsize
rho_init = rho;

%Initialize the mesh grids
[f_c,f_r]=meshgrid(1:cols,1:rows);
g_c = f_c;
g_r = f_r;

%Calculate grid size. Blocks are fixed at 32x32.
grid = [ceil(cols/32), ceil(rows/32)];

%Load CUDA Kernels
interp = parallel.gpu.CUDAKernel('register2Symmetric.ptx','register2Symmetric.cu','interp');
interp.GridSize = grid;
interp.ThreadBlockSize = [32,32];

jacPartialsAndBarrier = parallel.gpu.CUDAKernel('register2Symmetric.ptx', 'register2Symmetric.cu', 'jacPartialsAndBarrier');
jacPartialsAndBarrier.GridSize = grid;
jacPartialsAndBarrier.ThreadBlockSize = [32,32];

jacobian = parallel.gpu.CUDAKernel('register2Symmetric.ptx', 'register2Symmetric.cu', 'jacobian');
jacobian.GridSize = grid;
jacobian.ThreadBlockSize = [32,32];

extf = parallel.gpu.CUDAKernel('register2Symmetric.ptx', 'register2Symmetric.cu', 'extf');
extf.GridSize = grid;
extf.ThreadBlockSize = [32,32];

intf = parallel.gpu.CUDAKernel('register2Symmetric.ptx', 'register2Symmetric.cu', 'intf');
intf.GridSize = grid;
intf.ThreadBlockSize = [32,32];

add = parallel.gpu.CUDAKernel('register2Symmetric.ptx', 'register2Symmetric.cu', 'add');
add.GridSize = grid;
add.ThreadBlockSize = [32,32];

d_f = parallel.gpu.CUDAKernel('register2Symmetric.ptx', 'register2Symmetric.cu', 'd_f');
d_f.GridSize = grid;
d_f.ThreadBlockSize = [32,32];



%Initialize variables on GPU
[dr_img2_orig,dc_img2_orig]=grad_img(img2);
[dr_img1_orig,dc_img1_orig]=grad_img(img1);

dr_img2 = gpuArray(dr_img2_orig);
dc_img2 = gpuArray(dc_img2_orig);
dr_img1 = gpuArray(dr_img2_orig);
dc_img1 = gpuArray(dc_img2_orig);

img2_o_f = gpuArray(img2);
img1_o_g = gpuArray(img1);
jacf = parallel.gpu.GPUArray.ones(size(f_c));
jacg = parallel.gpu.GPUArray.ones(size(f_c));
jacf_temp = jacf;
jacg_temp = jacg;


f_c = gpuArray(f_c);
f_r = gpuArray(f_r);
f_c_temp = f_c;
f_r_temp = f_r;

img1 = gpuArray(img1);
img2 = gpuArray(img2);

extf_r = parallel.gpu.GPUArray.zeros(size(f_c));
extf_c = parallel.gpu.GPUArray.zeros(size(f_c));

intf_r = parallel.gpu.GPUArray.zeros(size(f_c));
intf_c = parallel.gpu.GPUArray.zeros(size(f_c));

d_f_r = parallel.gpu.GPUArray.zeros(size(f_c));
d_f_c = parallel.gpu.GPUArray.zeros(size(f_c));

fi_m_1x = parallel.gpu.GPUArray.ones(size(f_c));
fi_p_1x = parallel.gpu.GPUArray.ones(size(f_c));
fj_m_1x = parallel.gpu.GPUArray.ones(size(f_c));
fj_p_1x = parallel.gpu.GPUArray.ones(size(f_c));

fi_m_1y = parallel.gpu.GPUArray.ones(size(f_c));
fi_p_1y = parallel.gpu.GPUArray.ones(size(f_c));
fj_m_1y = parallel.gpu.GPUArray.ones(size(f_c));
fj_p_1y = parallel.gpu.GPUArray.ones(size(f_c));

barrier_f_c = parallel.gpu.GPUArray.zeros(size(f_c));

barrier_f_r = parallel.gpu.GPUArray.zeros(size(f_c));

g_c = gpuArray(g_c);
g_r = gpuArray(g_r);
g_c_temp = g_c;
g_r_temp = g_r;

extg_r = parallel.gpu.GPUArray.zeros(size(f_c));
extg_c = parallel.gpu.GPUArray.zeros(size(f_c));

intg_r = parallel.gpu.GPUArray.zeros(size(f_c));
intg_c = parallel.gpu.GPUArray.zeros(size(f_c));

d_g_r = parallel.gpu.GPUArray.zeros(size(f_c));
d_g_c = parallel.gpu.GPUArray.zeros(size(f_c));

gi_m_1x = parallel.gpu.GPUArray.ones(size(f_c));
gi_p_1x = parallel.gpu.GPUArray.ones(size(f_c));
gj_m_1x = parallel.gpu.GPUArray.ones(size(f_c));
gj_p_1x = parallel.gpu.GPUArray.ones(size(f_c));

gi_m_1y = parallel.gpu.GPUArray.ones(size(f_c));
gi_p_1y = parallel.gpu.GPUArray.ones(size(f_c));
gj_m_1y = parallel.gpu.GPUArray.ones(size(f_c));
gj_p_1y = parallel.gpu.GPUArray.ones(size(f_c));

barrier_g_c = parallel.gpu.GPUArray.zeros(size(f_c));

barrier_g_r = parallel.gpu.GPUArray.zeros(size(f_c));


for k=1:maxIter,
    %Reset the stepsize every few hundred iterations
    if (mod(k,250) == 0)
        rho = rho_init;
    end
    
    %Interpolate images and gradients
    img1_o_g = feval(interp, img1_o_g, g_c, g_r, img1, rows, cols);
    dr_img1 = feval(interp, dr_img1, g_c, g_r, dr_img1_orig, rows, cols);
    dc_img1 = feval(interp, dc_img1, g_c, g_r, dc_img1_orig, rows, cols);
    
    img2_o_f = feval(interp, img2_o_f, f_c, f_r, img2, rows, cols);
    dr_img2 = feval(interp, dr_img2, f_c, f_r, dr_img2_orig, rows, cols);
    dc_img2 = feval(interp, dc_img2, f_c, f_r, dc_img2_orig, rows, cols);

    %External energies
    extf_r = feval(extf, extf_r, img1_o_g, img2_o_f, dr_img2, rows, cols);
    extf_c = feval(extf, extf_c, img1_o_g, img2_o_f, dc_img2, rows, cols);
    
    extg_r = -feval(extf, extg_r, img1_o_g, img2_o_f, dr_img1, rows, cols);
    extg_c = -feval(extf, extg_c, img1_o_g, img2_o_f, dc_img1, rows, cols);
    
    
    
    %Calculate the barrier function and partials of the jacobian
    [fi_m_1x, fi_p_1x, fj_m_1x, fj_p_1x, barrier_f_c] = feval(jacPartialsAndBarrier, fi_m_1x, fi_p_1x, fj_m_1x, fj_p_1x, barrier_f_c, jacf, f_r, img1_o_g, img2_o_f, rows, cols, 1);
    [gi_m_1x, gi_p_1x, gj_m_1x, gj_p_1x, barrier_g_c] = feval(jacPartialsAndBarrier, gi_m_1x, gi_p_1x, gj_m_1x, gj_p_1x, barrier_g_c, jacg, g_r, img1_o_g, img2_o_f, rows, cols, 1); 
    

    
    
    [fi_m_1y, fi_p_1y, fj_m_1y, fj_p_1y, barrier_f_r] = feval(jacPartialsAndBarrier, fi_m_1y, fi_p_1y, fj_m_1y, fj_p_1y, barrier_f_r, jacf, f_c, img1_o_g, img2_o_f, rows, cols, -1);
    [gi_m_1y, gi_p_1y, gj_m_1y, gj_p_1y, barrier_g_r] = feval(jacPartialsAndBarrier, gi_m_1y, gi_p_1y, gj_m_1y, gj_p_1y, barrier_g_r, jacg, g_c, img1_o_g, img2_o_f, rows, cols, -1);

    
   
    
    
    
    
    
    
    
    while (1)
        
        %Internal energies
        intf_c = feval(intf, intf_c, f_c, rows, cols);
        intf_r = feval(intf, intf_r, f_r, rows, cols);
        
        %Update f_c and f_r
        d_f_c = feval(d_f, d_f_c, jacf, jacg, fi_m_1x, fj_m_1x, fi_p_1x, fj_p_1x, barrier_f_c, intf_c, extf_c, rho, lambda, lambda2, rows, cols);
        d_f_c = min(max(d_f_c,-3),3); %limit single iteration jump
        f_c_temp = feval(add, f_c_temp, f_c, d_f_c, rows, cols);
        
        f_c_temp = max(min(f_c_temp,cols),1); %can't map over the edge
        
        d_f_r = feval(d_f, d_f_r, jacf, jacg, fi_m_1y, fj_m_1y, fi_p_1y, fj_p_1y, barrier_f_r, intf_r, extf_r, rho, lambda, lambda2, rows, cols);
        d_f_r = min(max(d_f_r,-3),3);
        f_r_temp = feval(add, f_r_temp, d_f_r, f_r, rows, cols);
        
        f_r_temp = max(min(f_r_temp,rows),1);
        
        jacf_temp = feval(jacobian, jacf_temp, f_c_temp, f_r_temp, rows, cols);
        
        
        %Internal energies
        intg_c = feval(intf, intg_c, g_c, rows, cols);
        intg_r = feval(intf, intg_r, g_r, rows, cols);
        
        %Update g_c and g_r
        d_g_c = feval(d_f, d_g_c, jacf, jacg, gi_m_1x, gj_m_1x, gi_p_1x, gj_p_1x, barrier_g_c, intg_c, extg_c, rho, lambda, lambda2, rows, cols);
        d_g_c = min(max(d_g_c,-3),3);
        g_c_temp = feval(add, g_c_temp, g_c, d_g_c, rows, cols);
        
        g_c_temp=max(min(g_c_temp,cols),1);
        
        d_g_r = feval(d_f, d_g_r, jacf, jacg, gi_m_1y, gj_m_1y, gi_p_1y, gj_p_1y, barrier_g_r, intg_r, extg_r, rho, lambda, lambda2, rows, cols);
        d_g_r = min(max(d_g_r,-3),3);
        g_r_temp = feval(add, g_r_temp, g_r, d_g_r, rows, cols);
        
        g_r_temp = max(min(g_r_temp,rows),1);
        
        jacg_temp = feval(jacobian, jacg_temp, g_c_temp, g_r_temp, rows, cols);

        minjacf = min(jacf_temp(:));
        minjacg = min(jacg_temp(:));
        
        
        %If Jacobian is non-negative, proceed. Else, reduce stepsize.
        if (minjacf >= 0 && minjacg >= 0)
            f_c = f_c_temp;
            f_r = f_r_temp;
            g_r = g_r_temp;
            g_c = g_c_temp;
            jacf = jacf_temp;
            jacg = jacg_temp;
            break;
        else
            rho = rho * .5;
        end
    end
end



img2_o_f = gather(img2_o_f);
img1_o_g = gather(img1_o_g);


if (save_images)
    imwrite(mat2gray(img2_o_f), 'out/interpolated2.png', 'png');
    imwrite(mat2gray(img1_o_g), 'out/interpolated1.png', 'png');
    imwrite(mat2gray(img1_o_g - img2_o_f), 'out/diff.png', 'png');
end

if (save_mat)
    f_c = gather(f_c);
    f_r = gather(f_r);
    
    g_c = gather(g_c);
    g_r = gather(g_r);
    
    img2 = gather(img2);
    img1 = gather(img1);
    save('out/register2Symmetric.mat','f_c','f_r','g_c','g_r','img1_o_g','img2_o_f','img1','img2');
end


function [dr_img,dc_img]=grad_img(img)
dr_img=zeros(size(img));
dc_img=zeros(size(img));

dr_img(2:end-1,2:end-1)=img(3:end,2:end-1)-img(1:end-2,2:end-1);
dc_img(2:end-1,2:end-1)=img(2:end-1,3:end)-img(2:end-1,1:end-2);


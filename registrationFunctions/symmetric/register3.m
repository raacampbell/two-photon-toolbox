function [f_c,f_r,f_b,img2_o_f] = register3(img1,img2,rho,lambda,maxIter,varargin)
%% [F_C,F_R,F_B,IMG2_O_F] = REGISTER3(IMG1,IMG2,RHO,LAMBDA,MAXITER,OPTIONS) 
% performs a non-rigid registration on IMG1, returning two functions, F_C, F_R, and F_B,
% that transform IMG2 into IMG1, as well as IMG2 composed with these functions.
% 
% IMG1 and IMG2 can be binary or grayscale images read from a file or
% matlab variable. If read from a file with three layers such as jpeg,
% the intensity of the image will be calculated as the average of the
% three layers. RHO is the stepsize at each iteration, LAMBDA regulates
% the laplacian smoothing term, and MAXITER is the number of iterations
% performed.
%
% To save a .mat file containing the
% output variables as well as the original images, append 'Mat'.
%                                                                
% Example: register2(brain1,brain2,0.5,0.1,1000,'Mat');
%
% See also register2Symmetric, register2, register3Symmetric

%See if we should save .mat
save_mat = 0;

if (nargin > 6)
    if (strcmpi(varargin{1},'Mat'));
        save_mat = 1;
    end
end

imgSize = size(img1);
rows = imgSize(1);
cols = imgSize(2);
beams = imgSize(3);


%Initialize the registration function
[f_c,f_r,f_b] = meshgrid(1:cols,1:rows,1:beams);

[dr_img2_orig,dc_img2_orig,db_img2_orig]=grad_img(img2);

%calculate block and grid sizes
block = [8,8,8];
while (mod(rows,block(2)) ~= 0)
    block(2) = block(2)/2;
    block(3) = block(3) * 2;
end
grid = [ceil(cols/block(1)), ceil(rows/block(2)) * ceil(beams/block(3))];

%initialize kernels%
interp = parallel.gpu.CUDAKernel('register3.ptx', 'register3.cu', 'interp3');
interp.ThreadBlockSize = block;
interp.GridSize = grid;

extf = parallel.gpu.CUDAKernel('register3.ptx', 'register3.cu', 'extf');
extf.ThreadBlockSize = block;
extf.GridSize = grid;

intf = parallel.gpu.CUDAKernel('register3.ptx', 'register3.cu', 'intf');
intf.ThreadBlockSize = block;
intf.GridSize = grid;

d_f = parallel.gpu.CUDAKernel('register3.ptx', 'register3.cu', 'd_f');
d_f.ThreadBlockSize = block;
d_f.GridSize = grid;

%initialize variables on the gpu
img2_o_f = parallel.gpu.GPUArray.zeros(rows, cols, beams);

f_c = gpuArray(f_c);
dc_img2 = parallel.gpu.GPUArray.zeros(rows, cols, beams);

d_f_c = parallel.gpu.GPUArray.zeros(rows, cols, beams);

extf_c = parallel.gpu.GPUArray.zeros(rows, cols, beams);
intf_c = parallel.gpu.GPUArray.zeros(rows, cols, beams);

f_r = gpuArray(f_r);
dr_img2 = parallel.gpu.GPUArray.zeros(rows, cols, beams);

d_f_r = parallel.gpu.GPUArray.zeros(rows, cols, beams);

extf_r = parallel.gpu.GPUArray.zeros(rows, cols, beams);
intf_r = parallel.gpu.GPUArray.zeros(rows, cols, beams);

f_b = gpuArray(f_b);
db_img2 = parallel.gpu.GPUArray.zeros(rows, cols, beams);

d_f_b = parallel.gpu.GPUArray.zeros(rows, cols, beams);

extf_b = parallel.gpu.GPUArray.zeros(rows, cols, beams);
intf_b = parallel.gpu.GPUArray.zeros(rows, cols, beams);

dc_img2_orig = gpuArray(dc_img2_orig);
dr_img2_orig = gpuArray(dr_img2_orig);
db_img2_orig = gpuArray(db_img2_orig);



for k=1:maxIter,
    
    %Interpolate image2 and gradient
    img2_o_f = feval(interp, img2_o_f, f_c, f_r, f_b, img2, rows, cols, beams);
    dr_img2 = feval(interp, dr_img2, f_c, f_r, f_b, dr_img2_orig, rows, cols, beams);
    dc_img2 = feval(interp, dc_img2, f_c, f_r, f_b, dc_img2_orig, rows, cols, beams);
    db_img2 = feval(interp, db_img2, f_c, f_r, f_b, db_img2_orig, rows, cols, beams);

    %External energies
    extf_r = feval(extf, extf_r, img1, img2_o_f, dr_img2, rows, cols, beams); 
    extf_c = feval(extf, extf_c, img1, img2_o_f, dc_img2, rows, cols, beams);
    extf_b = feval(extf, extf_b, img1, img2_o_f, db_img2, rows, cols, beams);
    
    
    %Internal energies
    intf_c = feval(intf, intf_c, f_c, rows, cols, beams);
    intf_r = feval(intf, intf_r, f_r, rows, cols, beams);   
    intf_b = feval(intf, intf_b, f_b, rows, cols, beams);
    
    d_f_c = feval(d_f, d_f_c, extf_c, intf_c, rho, lambda, rows, cols, beams);
    d_f_c = min(max(d_f_c,-3),3);
    f_c = f_c+d_f_c;
    
    f_c = max(min(f_c,cols),1);


    d_f_r = feval(d_f, d_f_r, extf_r, intf_r, rho, lambda, rows, cols, beams);
    d_f_r = min(max(d_f_r,-3),3);
    f_r = f_r+d_f_r;
    
    f_r = max(min(f_r,rows),1);
    
    d_f_b = feval(d_f, d_f_b, extf_b, intf_b, rho, lambda, rows, cols, beams);
    d_f_b = min(max(d_f_b,-3),3);
    f_b = f_b+d_f_b;
    
    f_b = max(min(f_b,beams),1);

end

if (save_mat)
    img1 = gather(img1);
    img2 = gather(img2);
    
    img2_o_f = gather(img2_o_f);
    
    f_c = gather(f_c);
    f_r = gather(f_r);
    f_b = gather(f_b);
    
    save('out/out.mat','img2_o_f','f_c','f_r','f_b','img1','img2');
end


function [dr_img,dc_img,db_img]=grad_img(img)
dr_img=zeros(size(img));
dc_img=zeros(size(img));
db_img=zeros(size(img));

dr_img(2:end-1,2:end-1,2:end-1)=img(3:end,2:end-1,2:end-1)-img(1:end-2,2:end-1,2:end-1);
dc_img(2:end-1,2:end-1,2:end-1)=img(2:end-1,3:end,2:end-1)-img(2:end-1,1:end-2,2:end-1);
db_img(2:end-1,2:end-1,2:end-1)=img(2:end-1,2:end-1,3:end)-img(2:end-1,2:end-1,1:end-2);


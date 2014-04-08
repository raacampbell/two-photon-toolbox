#include <cuda.h>

__global__ void interp3(double *imgout, 
	double *f_c, 
	double *f_r, 
	double *f_b,
	double *imgin, 
	int rows, 
	int cols, 
	int beams)
{
	int i = blockIdx.x * blockDim.x + threadIdx.x;
	int j = blockIdx.y % (rows/blockDim.y) * blockDim.y + threadIdx.y;
	int k = blockIdx.y / (rows/blockDim.y) * blockDim.z + threadIdx.z;

	if (i >= cols - 1 || j >= rows - 1 || k >= beams - 1)
		return;

	double i_o_f = f_c[i*rows + j + k*rows*cols] - 1;
	double j_o_f = f_r[i*rows + j + k*rows*cols] - 1;
	double k_o_f = f_b[i*rows + j + k*rows*cols] - 1;

	//first along i//
	int j_d = (int) j_o_f;
	int k_d = (int) k_o_f;
	double w_d = floor(i_o_f + 1) - i_o_f;
	double w_u = 1.0f - w_d;

	double R00 = w_d * imgin[((int) i_o_f) * rows + j_d + k_d*rows*cols] + w_u * imgin[((int) (i_o_f + 1))*rows + j_d + k_d*rows*cols];
	double R10 = w_d * imgin[((int) i_o_f) * rows + (j_d + 1) + k_d*rows*cols] + w_u * imgin[((int) (i_o_f + 1))*rows + (j_d + 1) + k_d*rows*cols];
	double R01 = w_d * imgin[((int) i_o_f) * rows + j_d + (k_d + 1)*rows*cols] + w_u * imgin[((int) (i_o_f + 1))*rows + j_d + (k_d + 1)*rows*cols];
	double R11 = w_d * imgin[((int) i_o_f) * rows + (j_d + 1) + (k_d + 1)*rows*cols] + w_u * imgin[((int) (i_o_f + 1))*rows + (j_d + 1) + (k_d + 1)*rows*cols];

	//now along j//
	w_d = floor(j_o_f + 1) - j_o_f;
	w_u = 1.0f - w_d;

	double R0 = w_d * R00 + w_u * R10;
	double R1 = w_d * R01 + w_u * R11;

	//finally along k//
	w_d = floor(k_o_f + 1) - k_o_f;
	w_u = 1.0f - w_d;

	imgout[i*rows + j + k*cols*rows] = w_d * R0 + w_u * R1;

}	

__global__ void extf (
	double *out,
	double *img1,
	double *img2,
	double *grad,
	int rows,
	int cols,
	int beams)
{
	int i = blockIdx.x * blockDim.x + threadIdx.x;
	int j = blockIdx.y % (rows/blockDim.y) * blockDim.y + threadIdx.y;
	int k = blockIdx.y / (rows/blockDim.y) * blockDim.z + threadIdx.z;

	if (i >= cols || j >= rows || k >= beams)
		return;

	out[i*rows + j + k*rows*cols] = (img1[i*rows + j + k*rows*cols]
		- img2[i*rows + j + k*rows*cols])
		* grad[i*rows + j + k*rows*cols];

}

__global__ void intf(
	double *out,
	double *f,
	int rows,
	int cols,
	int beams)
{
	int i = blockIdx.x * blockDim.x + threadIdx.x;
	int j = blockIdx.y % (rows/blockDim.y) * blockDim.y + threadIdx.y;
	int k = blockIdx.y / (rows/blockDim.y) * blockDim.z + threadIdx.z;

	if (i >= cols - 1 || j >= rows - 1 || k >= beams - 1 || i < 1 || j < 1 || k < 1)
		return;

	out[i*rows + j + k*rows*cols] = -6 * f[i*rows + j + k*rows*cols] +
		f[(i-1)*rows + j + k*rows*cols] + f[(i+1)*rows + j + k*rows*cols] +
		f[i*rows + (j-1) + k*rows*cols] + f[i*rows + (j+1) + k*rows*cols] +
		f[i*rows + j + (k-1)*rows*cols] + f[i*rows + j + (k+1)*rows*cols];
}

__global__ void d_f(
	double *out,
	double *extf,
	double *intf,
	double rho,
	double lambda,
	int rows,
	int cols,
	int beams)
{
	int i = blockIdx.x * blockDim.x + threadIdx.x;
	int j = blockIdx.y % (rows/blockDim.y) * blockDim.y + threadIdx.y;
	int k = blockIdx.y / (rows/blockDim.y) * blockDim.z + threadIdx.z;

	if (i >= cols || j >= rows || k >= beams)
		return;

	out[i*rows + j + k*rows*cols] = rho * 
		(extf[i*rows + j + k*rows*cols] + lambda*intf[i*rows + j + k*rows*cols]);
}
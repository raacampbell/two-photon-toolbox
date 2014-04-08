#include <cuda.h>

__global__ void interp2(double *imgout, double *fCol, double *fRow, double *imgin, int rows, int cols)
{
	int i = blockIdx.x * blockDim.x + threadIdx.x;
	int j = blockIdx.y * blockDim.y + threadIdx.y;

	if (i >= rows || j >= cols)
		return;

	double i_o_f = fCol[i * cols + j];
	double j_o_f = fRow[i * cols + j];

	i_o_f = fmax(1.0, fmin(i_o_f, (double) cols));
	j_o_f = fmax(1.0, fmin(j_o_f, (double) rows));

	//we will interpolate x direction first, giving R1 and R2//
	double R1 = (floor(i_o_f + 1) - i_o_f) * imgin[(int) floor(i_o_f - 1) * cols + (int) floor(j_o_f - 1)] + (i_o_f - floor(i_o_f)) * imgin[(int) ceil(i_o_f - 1) * cols + (int) floor(j_o_f - 1)];
	double R2 = (floor(i_o_f + 1) - i_o_f) * imgin[(int) floor(i_o_f - 1) * cols + (int) ceil(j_o_f - 1)] + (i_o_f - floor(i_o_f)) * imgin[(int) ceil(i_o_f - 1) * cols + (int) ceil(j_o_f - 1)];

	//now finish//
	imgout[i * cols + j] = (floor(j_o_f + 1) - j_o_f) * R1 + (j_o_f - floor(j_o_f)) * R2;
}

__global__ void extf( double *out, double *img1, double *img2, double *grad, int rows, int columns )
{
	int i = blockIdx.x * blockDim.x + threadIdx.x;
	int j = blockIdx.y * blockDim.y + threadIdx.y;

	// if (i >= columns || j >= rows)
	// 	return;
	
	out[i + j * columns] = 2 * (img1[i + j * columns] - img2[i + j * columns]) * grad[i + j * columns];
	
}

__global__ void intf(
	double *out,
	double *f,
	int rows,
	int columns)
{
	int i = blockIdx.x * blockDim.x + threadIdx.x;
	int j = blockIdx.y * blockDim.y + threadIdx.y;

	if (i < 1 || j < 1 || i  >= (columns - 1) || j >= (rows - 1))
		return;

	out[i * rows + j] = -4 * f[i * rows + j] + f[(i - 1) * rows + j] + f[(i + 1) * rows +j] + f[i * rows + (j - 1)] + f[i * rows + (j+ 1)];
}

__global__ void add(
	double *out,
	double *in1,
	double *in2,
	int rows,
	int columns)
{
	int i = blockIdx.x * blockDim.x + threadIdx.x;
	int j = blockIdx.y * blockDim.y + threadIdx.y;

	if (i < 2 || j < 2 || i  >= (columns - 2) || j >= (rows - 2))
		return;

	out[i * rows + j] = in1[i * rows + j] + in2[i * rows + j];
}


__global__ void d_f(
	double *out,
	double *intf,
	double *extf,
	double rho,
	double lambda,
	int rows,
	int columns)
{
	int i = blockIdx.x * blockDim.x + threadIdx.x;
	int j = blockIdx.y * blockDim.y + threadIdx.y;

	if (i < 1 || j < 1 || i  >= (columns - 1) || j >= (rows - 1))
		return;

	out[i * rows + j] = rho * (extf[i * rows + j] + lambda * intf[i * rows + j]);
}
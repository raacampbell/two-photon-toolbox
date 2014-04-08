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

	if (i >= columns || j >= rows)
		return;
	
	out[i + j * columns] = 2 * (img1[i + j * columns] - img2[i + j * columns]) * grad[i + j * columns];
	
}

__global__ void jacPartialsAndBarrier(
	double *i_m_1,
	double *i_p_1,
	double *j_m_1,
	double *j_p_1,
	double *barrier,
	double *jac,
	double *f,
	double *img1,
	double *img2,
	int rows,
	int columns,
	int flip) //-1 for F_y, 1 for F_x// 
{
	int i = blockIdx.x * blockDim.x + threadIdx.x;//to be consistent with matlab indexing//
	int j = blockIdx.y * blockDim.y + threadIdx.y;

	if (i < 1 || j < 1 || i  >= (columns - 1) || j >= (rows - 1))
		return;

	i_m_1[i * rows + j] = flip * .25 * (f[(i - 1) * rows + (j + 1)] - f[(i - 1) * rows + (j - 1)]);
	i_p_1[i * rows + j] = flip * .25 * (f[(i + 1) * rows + (j - 1)] - f[(i + 1) * rows + (j + 1)]);
	j_m_1[i * rows + j] = flip * .25 * (f[(i - 1) * rows + (j - 1)] - f[(i + 1) * rows + (j - 1)]);
	j_p_1[i * rows + j] = flip * .25 * (f[(i + 1) * rows + (j + 1)] - f[(i - 1) * rows + (j + 1)]);

	//barrier//
	barrier[i * rows + j] = -1 * (
		i_m_1[i * rows + j] * (log(jac[(i - 1) * rows + j]) - 1) / pow(jac[(i - 1) * rows + j], 2) +
		i_p_1[i * rows + j] * (log(jac[(i + 1) * rows + j]) - 1) / pow(jac[(i + 1) * rows + j], 2) +
		j_m_1[i * rows + j] * (log(jac[i * rows + (j - 1)]) - 1) / pow(jac[i * rows + (j - 1)], 2) +
		j_p_1[i * rows + j] * (log(jac[i * rows + (j + 1)]) - 1) / pow(jac[i * rows + (j + 1)], 2));

	//multiply the partials by the image difference//
	i_m_1[i * rows + j] *= pow(img1[(i - 1) * rows + j] - img2[(i - 1) * rows + j], 2);
	i_p_1[i * rows + j] *= pow(img1[(i + 1) * rows + j] - img2[(i + 1) * rows + j], 2);
	j_m_1[i * rows + j] *= pow(img1[i * rows + (j - 1)] - img2[i * rows + (j - 1)], 2);
	j_p_1[i * rows + j] *= pow(img1[i * rows + (j + 1)] - img2[i * rows + (j + 1)], 2);
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

__global__ void jacobian(
	double *out,
	double *f_c,
	double *f_r,
	int rows,
	int columns)
{
	int i = blockIdx.x * blockDim.x + threadIdx.x;
	int j = blockIdx.y * blockDim.y + threadIdx.y;

	if (i < 1 || j < 1 || i  >= (columns - 1) || j >= (rows - 1))
		return;

	out[i * rows + j] = .25 *
		((f_c[(i + 1) * rows + j] - f_c[(i - 1) * rows + j]) * (f_r[i * rows + (j + 1)] - f_r[i * rows + (j - 1)]) -
		(f_c[i * rows + (j + 1)] - f_c[i * rows + (j - 1)]) * (f_r[(i + 1) * rows + j] - f_r[(i - 1) * rows + j])); 
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
	double *jacf,
	double *jacg,
	double *i_m_1,
	double *j_m_1,
	double *i_p_1,
	double *j_p_1,
	double *barrier,
	double *intf,
	double *extf,
	double rho,
	double lambda,
	double lambda2,
	int rows,
	int columns)
{
	int i = blockIdx.x * blockDim.x + threadIdx.x;
	int j = blockIdx.y * blockDim.y + threadIdx.y;

	// if (i < 1 || j < 1 || i  >= (columns - 1) || j >= (rows - 1))
	// 	return;

	out[i * rows + j] = rho * (extf[i * rows + j] * (jacf[i * rows + j] + jacg[i * rows + j]) +
		i_m_1[i * rows + j] + i_p_1[i * rows + j] + j_m_1[i * rows + j] + j_p_1[i * rows + j] +
		lambda * intf[i * rows + j] + lambda2 * barrier[i * rows + j]);
}
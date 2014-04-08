function varargout=elastix_parameter_write(fname,varargin)
% Create params=elastix parameter file with default options
%
% function elastix_parameter_write(fname,varargin)
%
% Usage:
% elastix_parameter_write('myFname')
% Write parameter file to fname. Uses default values from this
% file. Affine transform done by default
%
%
% Default values can be over-ridden in one of two ways:
%
% 1.    
% elastix_parameter_write('myFname','param1,value1,...)
% Write parameter file to fname. Override defaults with
% user-defined parameter/value pairs. See this file and elastix
% documentation for valid inputs. 
%
% 2. 
% elastix_parameter_write('myFname',paramStructure)
% where "paramStructure" is in the format:
% >> params
% params =    
%       AutomaticScalesEstimation: 'true'
%       AutomaticTransformInitialization: 'true'
%       BSplineInterpolationOrder: 1
%       DefaultPixelValue: 0
%       .... 
%
% This structure can be produced by reading in a parameter file
% with elastix_parameter_read. Not all parameters need to be
% defined in the parameter structure. Values defined in the
% structure over-ride the defaults defined in this function. 
%    
% Rob Campbell - August 2012
%
% Also see: elastix_parameter_read, elastix_paramStruct2txt
%
%
% NOTE: Some parameters are commented out and not all may be
% present. You may need to modify this file to suit your
% needs. Read the elastix website (http://elastix.isi.uu.nl/) to
% get the most out of the registration options available: the
% elastix toolbox is very capable. 
    

    
%First determine if a parameter structure has been provided and if
%so, discard any extra parameter/value pairs and convert the
%structure to parameter value pairs that can be handled by this
%function. 
if nargin==2 
    if isstruct(varargin{1})
        varargin=struct2varargin(varargin{1});
    else
        error('Expecting a parameter structure as the second input')
    end
end    


IN=inputParser;
IN.CaseSensitive=true;

addRequired(IN,'fname')

%----------------------------------------------------------------------
% **** ImageTypes ****
% The dimensions of the fixed and moving image
% NB: This has to be specified by the user. The dimension of
% the images is currently NOT read from the images.
% Also note that some other settings may have to specified
% for each dimension separately.
addOptional(IN,'FixedImageDimension',2, @isnumeric)
addOptional(IN,'MovingImageDimension', 2, @isnumeric)

% The internal pixel type, used for internal computations
% Generally this should be left as "float."
% NB: this is not the type of the input images! The pixel 
% type of the input images is automatically read from the 
% images themselves.
% This setting can be changed to "short" to save some memory
% in case of very large 3D images.
addOptional(IN,'FixedInternalImagePixelType','float', @isstr)
addOptional(IN,'MovingInternalImagePixelType','float', @isstr)



% Specify whether you want to take into account the so-called
% direction cosines of the images. Recommended: true.
% In some cases, the direction cosines of the image are corrupt,
% due to image format conversions for example. In that case, you 
% may want to set this option to "false".
addOptional(IN,'UseDirectionCosines', 'true', @isstr)



%----------------------------------------------------------------------
% **** Main Components ****
% The following components should usually be left as they are:
addOptional(IN,'Registration', 'MultiResolutionRegistration', @isstr)
addOptional(IN,'Interpolator', 'BSplineInterpolator', @isstr)
addOptional(IN,'ResampleInterpolator', 'FinalBSplineInterpolator', @isstr)
addOptional(IN,'Resampler', 'DefaultResampler', @isstr)

% These may be changed to Fixed/MovingSmoothingImagePyramid.
% See the manual.
addOptional(IN,'FixedImagePyramid', 'FixedRecursiveImagePyramid', @isstr)
addOptional(IN,'MovingImagePyramid', 'MovingRecursiveImagePyramid', @isstr)

% The following components are most important:
% The optimizer AdaptiveStochasticGradientDescent (ASGD) works
% well in general. The Transform and Metric are important
% and need to be chosen careful for each application. See manual.
addOptional(IN,'Optimizer', 'StandardGradientDescent', @isstr)
%StandardGradientDescent is another option


%Euler: rigid, Affine: Affine, BSpline: non-rigid
validTrans = {'EulerTransform','AffineTransform','BSplineTransform','BSplineStackTransform'};
checkTrans = @(x) any(validatestring(x,validTrans));
addOptional(IN,'Transform', 'BSplineTransform', checkTrans)

addOptional(IN,'Metric', 'AdvancedMattesMutualInformation', @isstr)



%----------------------------------------------------------------------
% **** Transformation [bspline] ****
% Scales the affine matrix elements compared to the translations, to make
% sure they are in the same range. In general, it's best to  
% use automatic scales estimation:
addOptional(IN,'AutomaticScalesEstimation', 'true', @isstr)
%addOptional(IN,'Scales', 1000, @isnumeric)

% Automatically guess an initial translation by aligning the
% geometric centers of the fixed and moving.
addOptional(IN,'AutomaticTransformInitialization', 'true', @isstr)

% Whether transforms are combined by composition or by addition.
% In generally, Compose is the best option in most cases.
% It does not influence the results very much.
addOptional(IN,'HowToCombineTransforms', 'Compose', @isstr)

%Center by default
%addOptional(IN,'CenterOfRotation', [256,256], @isnumeric) 

%----------------------------------------------------------------------
% **** Transformation [bspline] ****
% The control point spacing of the bspline transformation in 
% the finest resolution level. Can be specified for each 
% dimension differently. Unit: mm.
% The lower this value, the more flexible the deformation.
% Low values may improve the accuracy, but may also cause
% unrealistic deformations. This is a very important setting!
% We recommend tuning it for every specific application. It is
% difficult to come up with a good 'default' value.
%addOptional(IN,'FinalGridSpacingInPhysicalUnits', 16, @isnumeric)

%Alternatively, the grid spacing can be specified in voxel units.
%To do that, uncomment the following line and comment/remove
%the FinalGridSpacingInPhysicalUnits definition.
addOptional(IN,'FinalGridSpacingInVoxels',16)


%----------------------------------------------------------------------
% **** Similarity Measure ****
% Number of grey level bins in each resolution level,
% for the mutual information. 16 or 32 usually works fine.
% You could also employ a hierarchical strategy:
%(NumberOfHistogramBins 16 32 64)
addOptional(IN,'NumberOfHistogramBins', 32, @isnumeric)

% If you use a mask, this option is important. 
% If the mask serves as region of interest, set it to false.
% If the mask indicates which pixels are valid, then set it to true.
% If you do not use a mask, the option doesn't matter.
addOptional(IN,'ErodeMask', 'true', @isstr)



%----------------------------------------------------------------------
% **** Multi-Resolution ****
% The number of resolutions. 1 Is only enough if the expected
% deformations are small. 3 or 4 mostly works fine. For large
% images and large deformations, 5 or 6 may even be useful.
addOptional(IN,'NumberOfResolutions', 5, @isnumeric)


% The downsampling/blurring factors for the image pyramids.
% By default, the images are downsampled by a factor of 2
% compared to the next resolution.
% So, in 2D, with 4 resolutions, the following schedule is used:
addOptional(IN,'ImagePyramidSchedule',[8 8  4 4  2 2  1 1],@isnumeric)
% And in 3D:
%(ImagePyramidSchedule 8 8 8  4 4 4  2 2 2  1 1 1 )
% You can specify any schedule, for example:
%(ImagePyramidSchedule 4 4  4 3  2 1  1 1 )
% Make sure that the number of elements equals the number
% of resolutions times the image dimension.



%----------------------------------------------------------------------
% **** Optimizer ****
% Maximum number of iterations in each resolution level:
% 200-500 works usually fine for affine and non-rigid registration.
% For more robustness, you may increase this to 1000-2000. The
% more, the better, but the longer computation time. This is an
% important parameter!
%addOptional(IN,'MaximumNumberOfIterations', [300 300 600], @isnumeric)
addOptional(IN,'MaximumNumberOfIterations', 400, @isnumeric)

% The step size of the optimizer, in mm. By default the voxel size is used.
% which usually works well. In case of unusual high-resolution images
% (eg histology) it is necessary to increase this value a bit, to the size
% of the "smallest visible structure" in the image:
%addOptional(IN,'MaximumStepLength', 50.0, @isnumeric)


%----------------------------------------------------------------------
% **** Image Sampling ****
% Number of spatial samples used to compute the mutual
% information (and its derivative) in each iteration.
% With an AdaptiveStochasticGradientDescent optimizer,
% in combination with the two options below, around 2000
% samples may already suffice.
addOptional(IN,'NumberOfSpatialSamples', 1048, @isnumeric)

% Refresh these spatial samples in every iteration, and select
% them randomly. See the manual for information on other sampling
% strategies.
addOptional(IN,'NewSamplesEveryIteration', 'true', @isstr)
addOptional(IN,'ImageSampler', 'Random', @isstr)



%----------------------------------------------------------------------
% **** Interpolation and Resampling ****
% Order of B-Spline interpolation used during registration/optimisation.
% It may improve accuracy if you set this to 3. Never use 0.
% An order of 1 gives linear interpolation. This is in most 
% applications a good choice.
addOptional(IN,'BSplineInterpolationOrder', 1, @isnumeric)

% Order of B-Spline interpolation used for applying the final
% deformation.
% 3 gives good accuracy; recommended in most cases.
% 1 gives worse accuracy (linear interpolation)
% 0 gives worst accuracy, but is appropriate for binary images
% (masks, segmentations); equivalent to nearest neighbor interpolation.
addOptional(IN,'FinalBSplineInterpolationOrder', 3, @isnumeric)

%Default pixel value for pixels that come from outside the picture:
addOptional(IN,'DefaultPixelValue', 0, @isnumeric)


% Choose whether to generate the deformed moving image.
% You can save some time by setting this to false, if you are
% only interested in the final (nonrigidly) deformed moving image
% for example.
addOptional(IN,'WriteResultImage', 'true')

% The pixel type and format of the resulting deformed moving image
addOptional(IN,'ResultImagePixelType', 'double')
addOptional(IN,'ResultImageFormat', 'mhd')



%----------------------------------------------------------------------
% **** Optimiser Parameters ****

%SP: Param_a in each resolution level. a_k = a/(A+k+1)^alpha
addOptional(IN,'SP_a', 500.1, @isnumeric)

%SP: Param_alpha in each resolution level. a_k = a/(A+k+1)^alpha
addOptional(IN,'SP_alpha', 0.602, @isnumeric)

%SP: Param_A in each resolution level. a_k = a/(A+k+1)^alpha
addOptional(IN,'SP_A', 50.0, @isnumeric)



%----------------------------------------------------------------------
% **** Misc. ****
addOptional(IN,'WriteTransformParametersEachIteration', 'false', @isstr)
addOptional(IN,'WriteTransformParametersEachResolution', 'false', @isstr)
addOptional(IN,'ShowExactMetricValue', 'false', @isstr)

addOptional(IN,'FixedKernelBSplineOrder', 1, @isnumeric)
addOptional(IN,'MovingKernelBSplineOrder', 3, @isnumeric)





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Parse the default inputs and write to a file
parse(IN,fname,varargin{:});

params=IN.Results;
params=rmfield(params,'fname');
elastix_paramStruct2txt(fname,params)


if nargout>0
    varargout{1}=params;
end

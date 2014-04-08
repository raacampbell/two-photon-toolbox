% Pre-process imported data
%
% Files
%   alignOverReps           - Conduct translation correction across trials
%   cleanBatch              - Wrapper for applying cleanImageStack across trials
%   cleanImageStack         - Conduct translation correction and 2-D filtering for each trial
%   correctRotation         - Apply rotation correction to image-stack
%   correctTranslation      - Apply 2-translation correction to image-stack
%   demonRegMovie           - non-linear affine transform on an image-stack
%   demonRegSession         - non-linear affine transform across trials
%   dftregistration         - Subpixel image registration by crosscorrelation 
%   doPhotoBleachCorrection - Conduct photo bleach correction on twoPhotonObject
%   generateDFFobject       - Convert imported data structure into the twoPhoton data object
%   ROI_add                 - Append a new ROI to the ROI structure of the twoPhoton object
%   ROI_autodetectFancy     - Use thresh_tool to perform a semi-automated detection of the main ROI
%   ROI_batch               - Determine the main ROI for each stimulus presentation
%   showPhotoBleachFit      - Plot time-series before and after photo-bleach correction
%   thresh_tool             - Interactively select intensity level for image thresholding.
%   twoPhoton               - classdef twoPhoton

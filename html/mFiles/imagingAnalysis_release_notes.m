%% 2-Photon Imaging Toolbox Release Notes
% This toolbox was written at CSHL to analyse 2-photon neuronal
% functional imaging data from drosophila. It handles data import, pre-processing,
% common statistical analyses, and data display. Data import
% assumes a Prairie Technologies imaging system, but this is easily
% modified. 
%
% The 2-Photon Imaging Analysis Toolbox requires the Image
% Processing Toolbox(TM), the Statistics Toolbox(TM), and the Curve
% Fitting Toolbox(TM). 
% 
%
%% 19-June-2013
% Finished a re-write of the HTML docs. They are now *mostly* up to
% date, but a lot of stuff can still only be found by trawling
% through the directory tree. Various bugs fixed, especially in the
% registration functions. Registration functions now work in
% parallel automatically if the user has connected multiple
% workers. 
%
%% 30-August-2012
% A large number of changes have been made to the toolbox. Data
% import is now faster and more flexible. There are many more
% options for image registration. Details:
%
% 1. Importing, handled by twoPImportBatch, is now very configurable and
% substantially more automated. 
%
% 2. There are multiple new image registration algorithms
% available. These can be run in parallel on hardware that supports
% this. 
% 
% 3. By default the image registration routines do not over-write the
% rawData.mat files. Instead, they store the coefficients and data are
% transformed at load time. This increases loading time but allows the
% user to experiment with different motion correction strategies. The
% new regParams allows the user to switch between different stored
% transforms, erase transforms, skip transforms, and commit the current
% transforms to disk (replacing raw data with transformed to speed up
% loading times), and revert to original (untransformed) data. 
%
% 4. rawData.mat files are stored uncompressed (doubles used disk space
% but massively decreases saving times) until the last save during
% the import process. This improves import speed. 
%
% 5. 2-D image filtering during data import is no longer done by default
% and has been moved to a seperate function. There is no good
% reason for smoothing data by default. 
%
%
%% 02-July-2010
% * New documentation written and integrated into MATLAB Help Browser.
%
%% 18-March-2010
% * Change file name of importPrairieViewData to prairieXML_2_Matlab
% * The ROI_batch function no longer subtracts the background from the
%  image stack and then saves this new version. Instead, it adds a new
%  field called 'backgroundLevel' to the ROI structure (see
%  ROI_autodetectFancy). The twoPhoton object then subtracts this
%  offset EVERY TIME THE IMAGE STACK IS LOADED! This makes it possible
%  to modify this number at any time. 
%
%% 01-March-2010
% 
% * Motion correction now done in the 
% <http://www.mathworks.com/matlabcentral/fileexchange/18401 spatial frequency domain>. The is faster
% and more accurate.
% * The motion correction code in cleanImageStack now adds the mean
% image to data.info.muStack. This makes the selectKCs and alignOverReps
% functions work much faster whilst only modestly increasing the file
% size of the twoPhoton object.
% 
%% 01-February-2010
% 
% * Add optional multiple comparisons correction (FDR) in kcDFF
% *doPhotoBleachCorrection now linearly spaces points between baseline
%  and post-stimulus frames for a less distorting fit. 
%
%% 28-October-2009
% 
% Update the way KCdff calculates significance (it no longer does a
% dodgy parametric test). There is also a new directory of functions for
% summarizing data. 
%
%% 17-August-2009
% 
%
% * twoPhoton object modified in the following ways:
%  a. imageStack is now a method which loads an array stored on
%  disk. This makes it WAY faster to load the structure. By default it
%  stores the image stacks with the raw data. The location of the raw
%  data is hard-coded into the array. This may be a problem but at the
%  moment I don't have a better solution right now.
%  b. the dff method no longer does weird noise correction. Now it
%  simply smooths the baseline (F). Previous noise correction was
%  bollocks because it was horribly ad hoc and was chucking out
%  potentially useful data. 
%  c. fields in data.sequence have been put elsewhere and tiff file
%     names have been removed because I can't see why you'd ever need
%     them. 
%
% * cleanImageStack (and other functions which alter the raw image
%  stack) now replace the raw data matrix on disk. 
%
% * photo-bleach correction no longer applies the correction to the image
%  stack. Instead it stores the correction fit and allows you to apply it
%  on the fly via the imageStack method. How awesome is that? You can
%  therefore toggle it by altering the boolean
%  data.doPhotoBleachCorrection or change it by providing any fit you
%  like to data.photoBleachFit
%
% * The ROI field now only contains the ROI mask and the thresholding
%  level at which that mas was created. The background is no longer
%  there because it's simply ~roi, and the area is just
%  sum(roi(:)). The mean intensity is no longer there because we will
%  calculate the photo-bleached data on the fly. You can get the mean
%  intensity of any image stack by doing roiTimeCourse(imageStack,ROI)
%
% The series of analysis steps is now:
%
% importPrairieViewData('fileName.xml') %Or you can do the batch
% data=generateDFFobject(data);
%
% Will soon make a new params file format which will work better then
% this one. This step will still be used, however. 
% data=addStimParams(data,params); 
%
% data=cleanBatch(data);
% data=alignOverReps(data);
% data=ROI_batch(data);
% data=doPhotoBleachCorrection(data);
% that's it!
%
% You can also run twoPImportBatch.m to go through those steps
% automatically. 
%
% To see the photo-bleach fit do:
% showPhotoBleachFit(data(1))
%
% Then say you want to do a KC analysis:
% selectKCs(data)
% addKC_stats(data)
% odourDendrogram(data)
%
%% 10-June-2009
% Fix many bugs in motion correction code. 
%
%% 30-April-2009
%
% The data structure is now an object so we can calculate dF/F on
% the fly (no pun intended) using a method call. See
% generateDFFobject.m for details. You will need a fairly recent
% version of Matlab to deal with these objects (I think versions >2008a are OK).



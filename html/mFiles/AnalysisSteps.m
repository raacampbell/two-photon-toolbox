%% Analysis Steps
%
% This page provides a summary of the work-flow and capabilities of
% the Toolbox. Implementation details and examples can be found in the
% <imagingAnalysis_user_guide.html User Guide>.
%
%% Importing
%
% Imaging acquisition programs typically store data as multi-frame
% tiffs (e.g. Olympus FluoView and ScanImage) or single-frame tiffs (e.g. Prairie
% View). In the latter case there is one tiff file per
% frame. Acquisition parameters may either be stored in the tiff
% file's meta-data or as a separate file; Prairie, for instance,
% store their meta-data in an XML file. 
%
% This Toolbox is organised around the notion that each experiment is
% divided up into trials. For each trial a series of frames are
% recorded. The goal of the import process is to read these frames and
% convert them into a matrix, with one matrix per trial. In single
% matrix, each 2-D slice is one frame and the 3rd dimension
% corresponds to time. One such 3-D matrix will henceforth be referred
% to as an "image-stack." Many functions in the 2-Photon Toolbox work
% on such image-stacks. [Note that the Toolbox also allows other
% dimensions (PMT channel and z-depth) to be stored in the raw-data
% matrix as well. Therefore, data are stored on disk as a 5-D matrix,
% in order to incorporate these extra dimensions. However, these
% higher dimensions are only returned if they are present and the user
% specifically requests them. More on this later.]  Meta-data, such as
% laser power, frame times, dwell time, and laser wavelength, are also
% imported. The image-stacks are saved to disk and the meta-data are
% inserted into a MATLAB object of class |twoPhoton|, that is defined by
% this Toolbox.
%
% The data are stored in an object of class |twoPhoton|. This is
% important. The purpose of the |twoPhoton| object is to dynamically
% load raw data from disk and pre-process it as needed. Doing things
% this way means that when we load a data object from disk, we don't
% need to load all the raw data at the same time. Instead, we load
% only meta-data and derived statistics (such as dF/F over time for
% each cell or ROI). This allows data to be stored in a fairly raw
% form and modified post-hoc, which maximises flexibility with a
% (usually) very minor time penalty for loading and pre-processing.
%
% Image-stacks are loaded transparently to the user. Following loading
% the image stack is pre-processed according to parameters stored in
% the |twoPhoton| object. For example photo-bleach correction and
% subtraction of background intensity are done transparently when the
% data are loaded. In early stages of processing, even the
% motion-correction can be applied at load-time. This makes it
% possible to change these parameters at any time without having to
% re-import the raw data. Typically the user will want to find the
% optimal motion correction and apply this to the saved raw data,
% since performing a correction on the fly is slow. 
%
% The importing your stimulus parameters is something that you will
% have to take care of. There are examples supplied to show you how we
% do it for our data, but your data will be different and you will have
% to take care of this step yourself. There are functions for
% importing Prairie triggerSync files, but we have not tested these
% extensively. 
%
% If your imaging system is not supported, it should be
% straightforward to write your own import code by modifying that used
% for importing Prairie, ScanImage, or FluoView data. You should aim
% to produce a structure which is as similar as possible to those in
% the examples directory. For details see
% <imagingAnalysis_importing.html Importing>: some fields in |.info| are
% used to perform calculations and load data. Following importing of
% the raw data files, stimulus parameters are added. The stimulus
% parameters are stored as a MATLAB structure during data acquisition.
%
%
%% Pre-Processing
% Having been imported, data must be pre-processed to minimise
% motion and photo-bleaching artifacts and separate brain from
% background. Multiple ROIs can be added later (<ROI_add.html |ROI_add|>). 
% The ROIs allow the user to independently analyse signals from
% different cells or neuropil regions. 
% 
% Motion correction is an important feature of this Toolbox. A lot of
% our data are gathered from the Drosophila Mushroom Body. This brain
% region is composed of many small superficial neurons, the somata of
% which are packed closely like popcorn. The somatic field moves
% substantially over time. This is a problem because our analysis
% routines do not automatically identify cell bodies and so the same
% cell must be in the same location over the whole recording session.
% In some experiments there is only simple translation, whereas in
% others there can be non-linear distortions. We therefore include
% functions to cope with both these scenarios. Obviously nothing can
% be done for cases where there has been significant Z-drift, but in
% our hands careful use of non-linear registration has improved our
% yield.
%
% The motion correction procedure is discussed in detail in the
% <imagingAnalysis_user_guide.html User Guide>. Briefly, each
% individual trial is first corrected so that all frames align with
% the mean of the first 10 or so frames. Then, since most analyses
% will be dependent on the same bit of brain appearing in the same
% place across trials, we then conduct a translation correction across
% trials. This latter correction depends particularly on user
% interaction to ensure that the correction has been performed
% optimally. 
%
% In our recording scenario we typically have both fluorescent neural
% tissue and non-florescent background in each frame. Using a
% semi-automated approach we now separate brain from background. The
% mask distinguishing the two is stored as a Region Of Interest
% (ROI). More ROIs can be added later, but this first ROI is used for
% various calculations and so shouldn't be deleted from the data
% object. Note that background subtraction is done by subtracting the
% mean pixel intensity outside of the brain's ROI. This corrects for
% both shot noise and auto-flourescence. If you wanted to correct only
% for shot-noise you would need to record a small number of frames
% with the shutter closed on each trial. This hasn't been implemented
% yet but see <imagingAnalysis_release_notes.html Release Notes> for
% 18th March 2010.
%
% The response time courses are corrected for photo-bleaching if
% desired. We have found that little photo-bleaching is evident in
% short trials and so there is little need to conduct the correction
% in these cases (remember that we're working with dF/F, which is
% calculated from the mean of the first few frames of the trial). 
%
% Pre-processing is now complete and the data are stored. This series
% of analysis steps is largely automated by a single function,
% although some user-interaction is required. The user may now go on
% to select regions of interest or manually identify neurons upon
% which further analyses are conducted.
%
%% Neuronal Analyses
% The Toolbox includes functions for selecting small circular ROIs
% corresponding to neuronal cell bodies. The ROI information is
% stored in the data structure and can be used to calculate
% response time courses, assess response significance, and plot the
% resulting data. If the user's data make automatic identification
% of cells a reasonable proposition, then it would be easy to have
% this conducted by a user-written function that writes the
% appropriate data into the 2-Photon data structure. Details are
% supplied in the <imagingAnalysis_user_guide.html User Guide> and
% Function Reference section on this guide. 
%
%% Displaying Data
% Various generic functions for visualising raw data are included; for
% example an image of the <overlayDFFandBaseline.html mean evoked
% response>, <responseTimeCourse.html plot of dF/F time
% course>, and a movie of a trial (<playMovie.html
% |playMovie|>). Included separately are functions used for
% pre-processing the data in order to produce the plots. This makes it
% easier for the user to produce their own graphics.


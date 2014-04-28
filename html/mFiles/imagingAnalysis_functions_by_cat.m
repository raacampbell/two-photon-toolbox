%% Functions by Category
% 2-Photon Imaging Analaysis Toolbox
% June-2013
%
% Requires the Image Processing Toolbox(TM) and Statistics Toolbox(TM).
%
%% Import
% * <addDatData.html |addDatData|> - Add Trigger Sync analogue .dat data to twoPhoton object 
% * <addStimParams.html |addStimParams|>       - Add stimulus parameters to data structure
% * <generateDFFobject.html |generateDFFobject|>       - Convert imported data structure into the twoPhoton data object
% * <importFluoView.html |importFluoView|>        -  Import a tiff generated by FluoView
% * <importFluoViewBatch.html |importFluoViewBatch|>        -  Import all FluoView tiff files in the current directory
% * <importPVtree.html |importPVtree|>        - Import data from multiple Prairie view data directories 
% * <prairieXML_2_Matlab.html |prairieXML_2_Matlab|> - Import PrairieView XML and image-stacks to MATLAB
% * <readPRM.html |readPRM|> - Import Trigger Sync PRM file
% * <readPVdat.html |readPVdat|> - Import Prairie view .dat file
% * <twoPImportBatch.html |twoPImportBatch|>     - Import and pre-process all PraireView data in current directory
% * <importScanImage.html |importScanImage|>     - Import a tiff generated by ScanImage
% * <importSItree.html |importSItree|>     - Import data from multiple ScanImage directories
%
%% Pre-Processing
% * <filterImageStack.html |filterImageStack|>              - Smooth frames to make the look prettier
% * <doPhotoBleachCorrection.html |doPhotoBleachCorrection|> - Conduct photo-bleach correction on twoPhotonObject
%
%% Motion Correction
%
% * <alignStack.html |alignStack|> -   Apply 2-D translation correction to  animage-stack
% * <alignRepeats.html |alignRepeats|> -   Conduct translation correction across trials
% * <apply_ffttrans.html |apply_ffttrans|> - Apply fft-based translation correction
% * <apply_demon.html |apply_demon|> - Apply non-linear, liquid, demon registration 
% * <apply_elastix.html |apply_elastix|> - Apply elastix registrations
% * <apply_gkerr.html |apply_gkerr|> - Apply Greenberg & Kerr 2-photon correction 
% * <apply_symmetric.html |apply_symmetric|> - Apply GPU-based non-rigid correction
% * <regParams.html |regParams|> - add, remove and modify the registration parameters
% * <visualiseDrift.html |visualiseDrift|> - Assess the degree of motion across repeats with cross-correlation
% * <visualiseDriftMovie.html |visualiseDriftMovie|> - Assess the degree of motion across repeats with a movie
%
%
%% ROIs 
% * <ROI_add.html |ROI_add|>                 - Append a new ROI to the ROI structure of the twoPhoton object
% * <ROI_autodetectFancy.html |ROI_autodetectFancy|>     - Use thresh_tool to perform a semi-automated detection of the main ROI
% * <ROI_batch.html |ROI_batch|> - Determine the main ROI for each stimulus presentation
% * <selectROIs.html |selectROIs|>              - Select neuronal cell bodies with a GUI
% * <nNeurons2p.html |nNeurons2p|>      - Summarise number of responding neurons, etc
% * <showPhotoBleachFit.html |showPhotoBleachFit|>      - Plot time-series before and after photo-bleach correction
%
%
%% Basic Neuronal Statistics & Plotting
% * <odour3Dplot.html |odour3Dplot|>            - 3-D PC plot of each stimulus
% * <odourDendrogram.html |odourDendrogram|>        - dendrogram showing response relatedness
% * <whichROIsAreSignificant.html |whichROIsAreSignificant|> - Show how many times each ROI responded significantly
% * <plotROIstats.html |plotROIstats|>      - Plot neuronal response traces ordered by signifiance
%
%% Data Display
% * <cleanMeanDFF.html |cleanMeanDFF|>          - Calculate a reduced-noise mean dF/F during the response 
% * <colorDepth.html |colorDepth|>            - Produced colour-coded depth plot of a z-stack
% * <colorResponse.html |colorResponse|>         - colour-coded maximum intensity projection
% * <imageStackCorr.html |imageStackCorr|>        - plots correlation between 1st and later frames from one trial
% * <Kalman_Stack_Filter.html |Kalman_Stack_Filter|>   - Apply a Kalman filter to the time dimension of an image stack
% * <kcMaskPlot.html |kcMaskPlot|>            - Show activation of each cell in the mask using different colours.   
% * <overlayDFFandBaseline.html |overlayDFFandBaseline|> - overlay of significant dF/F onto baseline image and plot
% * <overlayDFFs.html |overlayDFFs|>           - Overlay significant dF/F pixels from two recordings and plot
% * <playMovie.html |playMovie|>             - Play a movie of an imageStack
% * <responseTimeCourse.html |responseTimeCourse|>    - Plot response time course of an ROI
% * <roiTimeCourse.html |roiTimeCourse|>         - mean pixel intensity over time from a defined ROI
% * <showSelectedKCs.html |showSelectedKCs|>       - Overlay selected KCs onto a mean image of the stack
%
%% Summarize Recording Session
% * <generateRecordingReport.html |generateRecordingReport|>     - Make an HTML report of one experiment
% * <responseMagByPresentation.html |responseMagByPresentation|>   - Response magntitude of each trial
% * <responseTimeCourseByOdour.html |responseTimeCourseByOdour|>   - response time courses grouped by odour
%
%% Utility Functions
% * <data2libsvm.html |data2libsvm|>          - convert twoPhoton data to libsvm format
% * <getOdourNames.html |getOdourNames|>        - Summarise stimuli used in one experiment
% * <imagingAnalysisimagingAnalysis_load3Dtiff.html |load3Dtiff|>           - Load multi-image tiff from disk 
% * <imagingAnalysis_mat2im.html |mat2im|>               - mat2im - convert to rgb image
% * <imagingAnalysis_meanFromTif.html |meanFromTif|>          - Calculate mean of a multi-image tiff 
% * <nNeurons2p.html |nNeurons2p|>           - Return neural summary statistics 
% * <patch2blender.html |patch2blender|>        - Convert image stack to blender format
% * <responsePeriodFrames.html |responsePeriodFrames|> - Determine which frames fall into the response period
% * <imagingAnalysis_save3Dtiff.html |save3Dtiff|>           - Save 3-D grayscale matrix 'imageStack' as 3-D tiff 'fname'
% * <imagingAnalysis_tiffFrames.html |tiffFrames|>           - Iteratively find the number of slices in a tiff
% * <updateDataDir.html |updateDataDir|>        - Update path to data directory 
% * <zExplorer.html |zExplorer|>            - Scroll through a z-stack with a slider
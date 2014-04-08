
** 2-Photon Imaging Analysis Toolbox **

Rob Campbell - Cold Spring Harbor
campbell@cshl.edu 
Last updated: 19/06/2013

Contents
1. Installation
2. Disclaimer & Licence
3. Directory Contents



1. Installation
 - DropBox directory 
   The ImagingCode directory contains various sub-directories. Add
   these and their sub-directories to your MATLAB path. In particular,
   make sure you add ImagingAnalysis to you path. This directory
   contains a file called info.xml which MATLAB uses to construct the
   2-Photon Toolbox help pages in the MATLAB Documentation Window. 
 - tar archive
   Unpack the contents of the archive into an empty directory. Add
   this directory and all sub-directories to your MATLAB path. In
   particular, make sure the file called info.xml is in the
   Toolbox's root directory. MATLAB needs this file to construct the
   2-Photon Toolbox help pages, which you can access via the "doc"
   command from the MATLAB command line. 

Once Installation is complete you can go to the MATLAB documention
viewer to see help and examples on using the toolbox. Note that the
examples directory is not the web right now due to space
constraints. If you want it, please e-mail me. 


2. Disclaimer and licence
This code is distributed under the Creative Commons licence under
these rules: http://creativecommons.org/licenses/by-sa/3.0 
In addition there are the following restrictions:
1. Every effort has been made to ensure that all analyses are
reasonable, correct, and bug free. If you have reason to think this is
not the case, *you must contact me*.
2. The fact that this code is not available on the web is
deliberate. *Do not pass it on to third parties without permission.*




3. Directory Contents

Import - Functions for importing raw data. prairieXML_2_Matlab.m
will import all image stacks and XML meta-data from a Prairie
system. There are also functions for importing Prairie triggerSync
files (readPRM, readPVdat). Note that load3Dtiff in the
utilityFunctions directory will import the large tiffs produced by
some other imaging systems. Functions exist in the image processing
toolbox to extract meta-data from these tiffs. If writing your own
import routines, you may need to use this meta-data to add some of the
key information into the .info structure of the data object. 

pre-Processing - Having been imported, data must be pre-processed to
minimise motion and photo-bleaching artifacts and separate brain from
background. Multiple ROIs can be added later (ROI_add). Note that
background subtraction is currently being done by subtracting the mean
pixel intensity outside of the brain's ROI. This is reasonable but
does assume that there is no fluorescence source outside of the ROI. A
more robust way of doing background subtraction would be to record a
small number of frames with the shutter closed on each trial. This
hasn't been implemented yet but see Change History for 18th March 2010
(below). Translation correction is achieved in the spatial frequency
domain using code from the File Exchange (dftregistration.m which is
called by correctTranslation and alignOverReps). An affine correction
can also be done (demonRegMovie), but this very slow.

Display - Various generic functions for visualising raw data; for
example an image of the mean evoked response (overlayDFFandBaseline.m),
plot of dF/F over time (responseTimeCourse.m), and a movie of a trial
(playMovie). Also in this directory are some functions used for
pre-processing prior to visualisation;  e.g. roiTimeCourse, which
extracts the response time series, and Kalman_Stack_Filter, which
applies a predictive Kalman filter to the image stack. 

ROItats - Functions to select cells, calculate time courses,
assessment of response significance, associated plotting routines. 

summarizeRecording - Routines for making an HTML file summary of the
data from one imaging session. These are likely to need modifying
depending on your requirements. 

utilityFunctions - Various functions which perform fairly generic
tasks.

testCode - functions that are experimental, unfinished, or just
silly. 

Other directories:
The directories maths, plotting, stats, and misc contain code
previously written for other purposes but useful (and used) for the
imaging analysis. 



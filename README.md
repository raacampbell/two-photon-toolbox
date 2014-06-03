
*** 2-Photon Imaging Analysis Toolbox ***

Rob Campbell - Cold Spring Harbor - git@raacampbell.com


Read this file and the HTML help before e-mailing with questions. 



**Installation**


- Download or clone repository from Bitbucket https://bitbucket.org/turnerlab/two-photon-toolbox

- Open MATLAB. Launch the path tool (pathtool from the command line). 

- Add the two photon toolbox directory *with* sub-directories to your MATLAB path. You will now need to REMOVE certain directories.

-Take out all directories starting with ".git"
- Take out the html sub-directory. If you don't do this, you will run into LOTS of problems. 
- Remove the examples sub-directory. It doesn't have to be in your path. 
- Do NOT remove the root directory or the HTML help won't work. 

- If you did the above correctly, the two photon toolbox should appear in MATLAB's documentation browser. On newer versions of MATLAB it is accessed via the "Supplemental Software" link. 

- Next you will need to install some miscellaneous MATLAB functions. Dowload or clone this: https://bitbucket.org/turnerlab/misc-matlab Not all of these files are needed to run the 2-p toolbox, but there are various useful functions here. 

- Add directory *with* sub-directories to your MATLAB path. 

- Remove everything starting with ".git"

- Save the path. If this is the first time you've added stuff to your MATLAB path, then exit and restart MATLAB; check the toolbox directories are still there. If not: Google and repeat until fixed. 

- If you want to use the elastix image registration functions then you will have to download elastix (http://elastix.isi.uu.nl/download.php) and add the binaries to your *system path* NOT your MATLAB path. Unix users should know what that means. Windows users who don't know will have to http://lmgtfy.com/?q=windows+add+system+path

- The installation is now complete: read the HTML docs in MATLAB to get started. 





**Directory Contents**

* Import
Functions for importing raw data. prairieXML_2_Matlab.m
will import all image stacks and XML meta-data from a Prairie
system. There are also functions for importing Prairie triggerSync
files (readPRM, readPVdat). Note that load3Dtiff in the
utilityFunctions directory will import the large tiffs produced by
some other imaging systems. Functions exist in the image processing
toolbox to extract meta-data from these tiffs. If writing your own
import routines, you may need to use this meta-data to add some of the
key information into the .info structure of the data object. 

* pre-Processing 
Having been imported, data must be pre-processed to
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

* Display
Various generic functions for visualising raw data; for
example an image of the mean evoked response (overlayDFFandBaseline.m),
plot of dF/F over time (responseTimeCourse.m), and a movie of a trial
(playMovie). Also in this directory are some functions used for
pre-processing prior to visualisation;  e.g. roiTimeCourse, which
extracts the response time series, and Kalman_Stack_Filter, which
applies a predictive Kalman filter to the image stack. 

* ROItats
Functions to select cells, calculate time courses,
assessment of response significance, associated plotting routines. 

* summarizeRecording
Routines for making an HTML file summary of the data from one imaging 
session. These are likely to need modifying depending on your requirements. 

* utilityFunctions
Various functions which perform fairly generic tasks.

* testCode
functions that are experimental, unfinished, or just silly. 

* Other directories:
The directories maths, plotting, stats, and misc contain code
previously written for other purposes but useful (and used) for the
imaging analysis. 




**Recommended system config**

You will need the following toolboxes:
- Image Processing
- Statistics
- Curve Fitting
- Parallel Computing [OPTIONAL]

Likely any version of MATLAB after about 2011 will work. More recent is better: they run faster. If doing a lot of the more complicated image registrations (more demanding than FFT translation) then you will need a fairly beefy computer with at least four cores. The RAM requirement is high, however, since raw data is loaded dynamically. However, this does mean that a fast hard disk will improve the speed of data import. 




**Disclaimer and license**

This code is distributed under the Creative Commons licence under these rules: http://creativecommons.org/licenses/by-sa/3.0 

In addition there are the following restrictions:

* Every effort has been made to ensure that all analyses are reasonable, correct, and bug free. If you find mistakes **you must contact me**. I can't fix things if I don't know about them. 

* The fact that this code is not available on the web is deliberate. *Do not pass it on to third parties without permission.* If a third party would like this Toolbox, please ask them to contact me. 




*Last updated: 03/06/2014*


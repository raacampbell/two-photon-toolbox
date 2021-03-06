# 2-Photon Imaging Analysis Toolbox

Rob Campbell - Cold Spring Harbor

Read this file before you start. Read this file and the HTML help before e-mailing with questions. 

## NOTE [20/04/2015]
This toolbox is no longer in active development. It works well enough for relatively small data sizes where the amount of RAM taken up by each trial multiplied by the number of cores will fit comfortably into RAM. If you have very long trials, this toolbox will not work well. In this case, I point you to [Dylan Muir's toolboxes](http://dylan-muir.com/projects/focusstack_stimserver/) and Dylan's [tiffstack tool](http://www.mathworks.com/matlabcentral/fileexchange/32025-read-tiff-stacks-into-matlab-fast--with-lazy-loading). Some components of this toolbox may be developed into stand-alone tools in the future. Any such tools will appear on [my github page](https://github.com/raacampbell).



## Installation


- Download or clone the repository.

- Open MATLAB. Launch the path tool (`pathtool` from the command line). 

- Add the two photon toolbox directory *with* sub-directories to your MATLAB path. You will now need to REMOVE certain directories.

- Take out all directories starting with `.git`

- Take out the `html` sub-directory. If you don't do this, you will run into *LOTS* of problems. 

- Remove the `examples` sub-directory. It doesn't have to be in your path. 

- Do *NOT* remove the root directory or the HTML help won't work. 

- The two photon toolbox should now appear in MATLAB's documentation browser. On newer versions of MATLAB it is accessed via the "Supplemental Software" link. 

- If you want to use the Elastix image registration functions then you will have to [download elastix](http://elastix.isi.uu.nl/download.php) and add the binaries to your *system path* NOT your MATLAB path. If you don't know what that means: [Google it](http://lmgtfy.com/?q=windows+add+system+path)

- The installation is now complete: read the HTML docs in MATLAB to get started. 

- If you find you are missing functions, please contact me. 


## Using the "examples" archive
The toolbox comes with an archive containing an example data set which you can analyse. 
Unpack this into *a different directory* if you wish to explore these examples. 
If you don't do this, your analyses of the example data will be wiped when you update the repository. 
Please note that the `.mat` data file in the example directory might be out of date. 
Extra parameters are added to the data object from time to time and if the code base expects these but the data file does not contain them, then there could well be a problem. 
Don't, therefore, get hung up on errors related to the saved example data object. 


## Directory Contents

* **Import** -- 
Functions for importing raw data. `prairieXML_2_Matlab.m`
will import all image stacks and XML meta-data from a Prairie
system. There are also functions for importing Prairie triggerSync
files (`readPRM`, `readPVdat`). Note that `load3Dtiff` in the
utilityFunctions directory will import the large tiffs produced by
some other imaging systems. Functions exist in the image processing
toolbox to extract meta-data from these tiffs. If writing your own
import routines, you may need to use this meta-data to add some of the
key information into the .info structure of the data object. 

* **pre-Processing** --
Having been imported, data must be pre-processed to
minimise motion and photo-bleaching artifacts and separate brain from
background. Multiple ROIs can be added later (`ROI_add`). Note that
background subtraction is currently being done by subtracting the mean
pixel intensity outside of the brain's ROI. This is reasonable but
does assume that there is no fluorescence source outside of the ROI. A
more robust way of doing background subtraction would be to record a
small number of frames with the shutter closed on each trial. This
hasn't been implemented yet but see Change History for 18th March 2010
(below). Translation correction is achieved in the spatial frequency
domain using code from the File Exchange (`dftregistration.m` which is
called by `correctTranslation` and `alignOverReps`). An affine correction
can also be done (`demonRegMovie`), but this very slow.

* **Display** --
Various generic functions for visualising raw data; for
example an image of the mean evoked response (`overlayDFFandBaseline.m`),
plot of dF/F over time (`responseTimeCourse.m`), and a movie of a trial
(`playMovie`). Also in this directory are some functions used for
pre-processing prior to visualisation;  e.g. `roiTimeCourse`, which
extracts the response time series, and `Kalman_Stack_Filter`, which
applies a predictive Kalman filter to the image stack. 

* **ROItats** --
Functions to select cells, calculate time courses,
assessment of response significance, associated plotting routines. 

* **summarizeRecording** --
Routines for making an HTML file summary of the data from one imaging 
session. These are likely to need modifying depending on your requirements. 

* **utilityFunctions** --
Various functions which perform fairly generic tasks.

* **testCode** --
functions that are experimental, unfinished, or just silly. 

* **Other directories** --
The directories maths, plotting, stats, and misc contain code
previously written for other purposes but useful (and used) for the
imaging analysis. 




## Recommended system config

You will need the following toolboxes:

* Image Processing

* Statistics

* Curve Fitting

* Parallel Computing [OPTIONAL]

Likely any version of MATLAB after about 2011 will work. 
More recent is better: they run faster. 
If doing a lot of the more complicated image registrations (more demanding than FFT translation) then you will need a fairly beefy computer with at least four cores. 
The RAM requirement should not be too high, however, since raw data are loaded dynamically as needed. 
This means that fast disk access (SSD or RAID) will improve the speed of data import/pre-processing. 




## Disclaimer and license
This code is distributed under the Creative Commons licence under these rules: http://creativecommons.org/licenses/by-sa/3.0 

Please note:
* Every effort has been made to ensure that all analyses are reasonable, correct, and bug free. If you find mistakes **you must contact me**. I can't fix things if I don't know about them. 

## Warning
The codebase is fairly large and there are a great many functions. Whilst the HTML help is relatively up to date, it's not 100% current. You *will* find stuff in the HTML docs, usually minor synatix issues, that is not current. If you run into errors when trying out examples from the HTML help, you should look at the help for the function in question. It might be that the input arguments have changed. As a related point, it's worth spending some time browsing the functions by directory and seeing what they do. There's a lot of stuff included here and there's no point re-inventing the wheel. 

## Citation
If you publish with this, please cite Campbell et al. J Neurosci. 2013 Jun 19;33(25):10568-81. doi: 10.1523/JNEUROSCI.0682-12.2013. "*Imaging a population code for odor identity in the Drosophila mushroom body.*"

*Last updated: 09/11/2015*

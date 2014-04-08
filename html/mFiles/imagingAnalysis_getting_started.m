%% 2-Photon Imaging Analysis Toolbox: Getting Started
%
%
% The 2-Photon Toolbox is a collection of functions for analysing
% functional imaging data. The focus is on analysis of signals from
% individual neurons, but the routines will work equally well on
% neuropil regions. We have not included code for automatically
% identifying cell bodies, as we have found thus far that such
% functions work poorly in our brain area of interest (the mushroom
% body), where the cell bodies are small and tightly packed
% together. Automatic cell body has been shown to work in areas
% such as cerebral cortex. On option is CellSort by Eran Mukamel on
% the FEX. 
%
% This software was developed at the Turner Lab, CSHL, by Rob
% Campbell. If you have used it in your work, please cite us:
% Honegger, et al. 2011, PMID: 21849538 and/or Campbell, et al. 2013
%
% For more details on our work, please see: http://turnerlab.cshl.edu
%
%
%% Introduction
% These routines will import and analyse 2-photon data derived from
% various imaging platforms. Most functions for importing and creating
% the data structure assume a Prairie system. These can easily be
% modified for other systems and examples of such code is included for
% ScanImage and Fluoview. 
%
% Functions are grouped into logically named sub-directories according
% to their purpose. It is worth trawling through the folders to see
% what's in there: all functions have extensive help but not all
% are described in the HTML help docs due to time contstraints. 
%
% This toolbox is constantly being updated with bug fixes, performance
% improvements, and new features. If you need to modify code, you
% are encouraged to write a wrapper around existing functions and
% store your wrappers in a separate location. This way you'll
% benefit from future releases automatically without having to
% continually port your code. Where possible, we take care that new
% features don't break old code.
%
%
%% Acknowledgments
% Some code in this toolbox has been sourced from the
% <http://www.mathworks.com/matlabcentral/fileexchange/ File
% Exchange> and some code has been contributed by
% co-workers. Acknowledgments are included in the relevant
% function files. 
%
%% Disclaimer and Licence
% This code is distributed under the
% <http://creativecommons.org/licenses/by-sa/3.0 Creative Commons
% licence>. You are free to share and adapt this work so long as
% you acknowledge us. Every effort has been made to ensure that all
% analyses are reasonable, correct, and bug free. *If you find errors
% you must contact me: rob@raacampbell.com This is a strict
% condition of use.*
%



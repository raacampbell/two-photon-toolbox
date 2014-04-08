%% readPVdat
% Import Prairie view .dat file
%
% |function data=readPVdat(fname)|
%
%% Purpose
% Extract data from a trigger-sync .dat file. Which, I think, is a
% LabView format. For details see the revision history of
% PraireView.  
%
%% Notes
%
% The format for the binary file that is used within TriggerSync
% for saving experiment data is as follows:
%
% * i. The file begins with 616 bytes of header (starting with
% DTLG), which appears to be irrelevant for the purposes of
% extracting data.
%
% * ii.	The next byte (first important value) at a hex address of
% 268 is the number of channels/sets of data stored as a 4 byte
% long.
%
% * iii. The value after that at address 26C is the number of data
% points in the sample stored as a 4 byte long.
% iv.	The rest of the file starting at address 270 is a listing
% of all of the data values in the following order;
%
% |Channel 1:Value 1, Channel 1:Value 2 . . . Channel 1:Value N|
%
% |Channel 2:Value 1, Channel 2:Value 2 . . . Channel 2:Value N|
%
% |Channel M:Value 1, Channel M:Value 2 . . . Channel M:Value N|
%
% * v.	Each of these values is stored in a 32 bit IEEE single
% precision floating point format.
%
% * vi.	All values are stored as big endian.



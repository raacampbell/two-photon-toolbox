function data=readPVdat(fname)
%% readPVdat
% Import Prairie view .dat file
%
% |function data=readPVdat(fname)|
%
% Pull out data from a trigger-sync .dat file. Which, I think, is a
% LabView format. For details see the revision history of
% PraireView.  
%
%
% The format for the binary file that is used within TriggerSync
% for saving experiment data is as follows:
%
% i.	The file begins with 616 bytes of header (starting with
% DTLG), which appears to be irrelevant for the purposes of
% extracting data.
%
% ii.	The next byte (first important value) at a hex address of
% 268 is the number of channels/sets of data stored as a 4 byte
% long.
% iii.	The value after that at address 26C is the number of data
% points in the sample stored as a 4 byte long.
% iv.	The rest of the file starting at address 270 is a listing
% of all of the data values in the following order;
%  1.	Channel 1:Value 1, Channel 1:Value 2 . . . Channel 1:Value N
%  2.	Channel 2:Value 1, Channel 2:Value 2 . . . Channel 2:Value N
%  3.	Channel M:Value 1, Channel M:Value 2 . . . Channel M:Value N
% v.	Each of these values is stored in a 32 bit IEEE single
% precision floating point format.
% vi.	All values are stored as big endian.
f=fopen(fname);


%There is 616 bytes of header. Mostly of unknown content. I'm not
%sure whether the sample rate is in there. 

char(fread(f,4,'char')); %The characters 'DTLG'
fread(f,612,'char'); %The rest of the header is totally unknown


numChannels=fread(f,1,'long','ieee-be');
numDataPoints=fread(f,1,'long','ieee-be');

data=fread(f,numDataPoints*numChannels,'single','ieee-be'); 
fclose(f);



%Reshape to produce an n-by-m matrix of n time points and m channels. 
data=reshape(data(:),numDataPoints,numChannels);



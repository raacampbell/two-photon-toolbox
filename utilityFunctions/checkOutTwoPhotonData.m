function data=checkOutTwoPhotonData(fname,tmpDataDir)
% check data out of a server
%
% function data=checkOutTwoPhotonData(fname,tmpDataDir)
%
% Purpose
% Copies a saved twoPhoton data object and rawData files from remote shared
% folder onto a temporary folder on the local machine. Sets up the
% rawDataDir variable for the local machine. e.g. this is useful when
% accessing the server via sshfs or VPN on a slow conncection which
% precludes working with the data directly on the server. 
% 
% Inputs  
% fname - a string specifying the filename and relative path of the .mat
%         twoPhoton file. 
% tmpDataDir [optional] - path to temporary data directory 
%   
% Outputs
% data - once the process is complete, the function loads and returns the
%        local copy of the object.
%
%   
% Notes: uses forward slashes so won't work on Windows without
%        modification. Function not used much and may not work. 
%
% Rob Campbell - October 2009


%Default temporary data directory  
if nargin<2
  [s,m]=unix('echo $HOME'); m(end)=[]; %Get the full path
  tmpDataDir=[m,'/temporaryImagingData/'];
end

if ~exist(tmpDataDir,'dir'), mkdir(tmpDataDir), end

if ~exist(fname,'file'), error('Can''t find %s',fname), end


tokens=regexp(fname,'(.*/)?(.*\.mat)','tokens');
path2File=tokens{1}{1};
matFile=tokens{1}{2};
if isempty(path2File), path2File='./'; end


%Get the 2-photon file
if exist([tmpDataDir,matFile],'file'), error('File %s already exists',matFile), end
fprintf('Copying %s\n',matFile)
if ~copyfile(fname,tmpDataDir); error('Unable to copy %s to %s',fname,tmpDataDir), end

%Get the raw data .mat files
localDataDir=[tmpDataDir,regexprep(matFile,'\.mat',''),'/'];
remoteDataDir=[path2File,regexprep(matFile,'\.mat',''),'/'];
if exist(localDataDir,'dir'), error('Directory %s already exists',localDataDir), end
mkdir(localDataDir)


%This is slow with sshfs. Using scp would probably be quicker
disp('Searching for raw data files on remote server')
d=dir([remoteDataDir,'*.mat']);



fprintf('Copying %d raw data files (%d Mb) ',length(d),round(sum([d.bytes])/1024^2))
for i=1:length(d)
  fprintf('.')  
   if ~copyfile([remoteDataDir,d(i).name],localDataDir); error('Unable to copy %s to %s',fname,tmpDataDir), end
end
fprintf('\n')


%Load local copy and change raw data path
load([tmpDataDir,matFile],'data');
data=updateDataDir(data,tmpDataDir);


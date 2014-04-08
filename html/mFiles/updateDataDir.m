%% updateDataDir
% Update path to data directory 
%
% |function data=updateDataDir(data,dataDir)|
%
%% Purpose
% Called in data root directory to update the data directory. Can
% also specify a directory manually. 
%
%% Inputs
% * |data| - twoPhoton data object
% * |dataDir| [optional] - the root directory of the data. 
% e.g. if |TSeries-05282009-1323-028| resides in ./data/ then dataDir
% should be './data/'
%
%% Outputs
% * |data| - the updated data structure
%
%% Example
%  >> cd /data/
% >>ls    
% TSeries-05282009-1323-027   
% TSeries-05282009-1323-027.mat
% >> load TSeries-05282009-1323-027.mat
% >> data=updateDataDir(data)
%
%  Or
% >>load /data/TSeries-05282009-1323-027.mat    
% >>data=updateDataDir(data,'/data/')

function stats=cellSize(data)

% Calculate summary statistics of cell size values
%
% function out=cellSize(data)
%
%
% Inputs
% * data - twoPhoton data object
%
% Outputs
% * stats - cell size statistics in a structure. 
%
% Rob Campbell - August 2010



m=data(1).KCmasks(:);
m(m==0)=[];

v=unique(m);


stats.n=ones(size(v));
for ii=1:length(v)

    stats.n(ii)=length(find(m==v(ii)));
    
end


stats.mu=mean(stats.n);
stats.sd=std(stats.n);
stats.range=[min(stats.n),max(stats.n)];

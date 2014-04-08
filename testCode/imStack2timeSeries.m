function im=imStack2timeSeries(im)
% function im=imStack2timeSeries(im)
%
% Turn a 3D image stack into 1-D vector. The order of the data points in the
% order in which they were acquired. 

s=size(im);
im=reshape(permute(im,[2,1,3]),[1,prod(s),1]);

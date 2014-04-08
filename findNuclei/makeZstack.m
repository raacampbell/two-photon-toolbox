function Z=makeZstack(data,channel)
% function Z=makeZstack(data,channel)
%
% Convert a series of Z-stacks from a sequence of data structures
% in a TZseries to a single 5-d matrix whose dimensions are:
% [x,y,time,channel,z]
%
% Rob Campbell - August 2010

%NOTE: This function is being used by formatTZseriesHack, but may
%not be useful elsewhere. Maybe saveZdepths is more handy.



if nargin<2, channel=1; end

fprintf('Building z-stack');
ii=1;


im=data(ii).imageStack(:,:,:,:,:);
initialDims=length(size(im));

im=squeeze(im(:,:,:,channel,:));

S=size(im);

Z=single(ones([length(data),S]));

Z(ii,:,:,:,:)=(im);

for ii=2:length(data)
    fprintf('.');
    Z(ii,:,:,:,:)=data(ii).imageStack(:,:,:,channel,:);
end
Z=shiftdim(Z,1);



%if the number of dimensions was 4, then the data haven't yet been
%converted into the 5-D  [x,y,time,channel,z] format. We therefore
%need to permute the matrix for the subsequent code to work. 

if initialDims==3
    Z=permute(Z,[1,2,4,5,3]);
end
if initialDims==4
    Z=permute(Z,[1,2,5,4,3]);
end



fprintf('\n');

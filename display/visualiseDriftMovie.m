function varargout=visualiseDriftMovie(data,reg)
% function varargout=visualiseDriftMovie(data,reg)
%
%
% Purpose: Display drift over time as movie. 
%
% reg is which registration to show. by default it's the last
% registration. If raw data are commited to disk then this may not be
% an option (there will be only one depth)

if nargin<2
    reg=size(data(1).info.muStack,3);
end


im=data(1).info.muStack(:,:,reg);

im=repmat(im,[1,1,length(data)]);

for ii=2:length(data)
    im(:,:,ii)=data(ii).info.muStack(:,:,reg);
end




if nargout>0
    playMovie(im,0.01,0)
    varargout{1}=im;
else
    playMovie(im)
end

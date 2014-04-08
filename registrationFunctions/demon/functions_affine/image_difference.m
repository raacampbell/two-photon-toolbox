function [t,I]=image_difference(V,U,type)
% This function gives a registration error and error image I between the two
% images or volumes.
% 
% [t,I]=image_difference(I1,I2,type,Mask)
%
% inputs,
%   I1: Input image 1
%   I2: Input image 2
%   type: Type of similarity / error measure
%
% if type,
% 'sd' : squared differences
% 'mi' : normalized mutual information
%
%  Example,
%    I1=im2double(imread('lenag1.png')); 
%    I2=im2double(imread('lenag2.png'));
%    [t,I] = image_difference(I1,I2,'sd');
%    disp(t);
%    imshow(I,[])
%
% This function is written by D.Kroon University of Twente (February 2009)

if(isempty(V)), t=2; I=2; return; end
switch(type)
    case 'sd'
        [I,t]=registration_error_squared_differences(V,U);
    case 'mi'
        [I,t]=registration_error_mutual_info(V,U);
    otherwise
        error('Unknown error type')
end    
if(isnan(t)), warning('imagedifference:NaN','NaN in error image'); t=2; I=2; end

function [I,t]=registration_error_squared_differences(V,U)
I=(V-U).^2;
t=sum(I(:))/numel(V);

function [I,t]=registration_error_mutual_info(V,U)
% This function t=registration_error_mutual_info(V,U) gives a registration error
% value based on mutual information (H(A) + H(B)) / H(A,B)

% Make a joint image histogram and single image histograms
bins=round(numel(V)^(1/ndims(V)));

range=getrangefromclass(V);
if(isa(V,'double'))
    [hist12, hist1, hist2]=mutual_histogram_double(double(V),double(U),double(range(1)),double(range(2)),double(bins));
else
    [hist12, hist1, hist2]=mutual_histogram_single(single(V),single(U),single(range(1)),single(range(2)),single(bins));
end

% Calculate probabilities
p1=hist1./numel(V);
p2=hist2./numel(V);
p12=hist12./numel(V);

p1log=p1 .* log(p1+eps);
p2log=p2 .* log(p2+eps);
p12log=p12.* log(p12+eps);

% Calculate amount of Information
HA = -sum(p1log);
HB = -sum(p2log);
HAB = -sum(p12log(:));

% Studholme, Normalized mutual information
t=2-(HA+HB)/HAB;
I=[];


function imageStack=reloadImStack(data)
% function imageStack=reloadImStack(data)
%
% A wrapper function to re-import raw data from file names. 
% We're using a wrapper to cope with the fact that users may
% have used different analysis progams. 
%




if length(data)>1
    error('data should have length of 1')
end


if strmatch(data(1).info.type,'scanimage')
    imageStack=scanimageTIFF2Stack(data);
else
    imageStack=prairieTIFFs2Stack(data);
end

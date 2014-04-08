function [obj,data]=generateDFFobject(data)
% Convert imported data structure into the twoPhoton data object
%
% function obj=generateDFFobject(data)
% 
% Purpose
% Merges the imported 2 photon data structure with an object
% containing methods for calculating dF/F. Can also be used to update
% the object in case the class file has changed.
%
% 
% Rob Campbell, April 2009




if isstruct(data)
  try
    data=rmfield(data,{'dffParams'});
  catch  
  end
else %Convert from 
  warning off
  for i=1:length(data)
    tmp(i)=struct(data(i));
  end
  warning on
  clear data
  data=tmp;
end




fi=fields(data);
f=strmatch('dffParams',fi);
fi(f)=[];
for j=1:length(data)
  obj(j)=twoPhoton;  
  for i=1:length(fi)
    addprop(obj(j),fi{i});
    obj(j).(fi{i}) = data(j).(fi{i});
  end  
  obj(j).photoBleachFit=zeros(size(obj(j).relativeFrameTimes));
end



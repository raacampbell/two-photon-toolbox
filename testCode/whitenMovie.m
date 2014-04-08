function imageStack=whitenMovie(imageStack)
% function imageStack=whitenMovie(imageStack)  
%
% Purpose whiten (sphere) each pixel timecourse in imageStack
%
%
% Rob Campbell, October 2009

  
  
if length(size(imageStack))==3
  S=size(imageStack);
  vectordata=reshape(imageStack, S(1)*S(2), S(3));
  reshapeData=1;
else
  vectordata=imageStack;
  
  if diff(size(vectordata))>0
    disp('transposing input')
    vectordata=vectordata';
  end
  
  reshapeData=0;
end



vectordata=sphereData(vectordata); %sphere

if reshapeData
  imageStack=reshape(vectordata,S);
else
  imageStack=vectordata;
end

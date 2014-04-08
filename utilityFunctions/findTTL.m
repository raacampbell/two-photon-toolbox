function [times,signs]=findTTL(t,s)
% function time=findTTL(t,s)  
%
% Return the times (in seconds) at which TTL pulses were sent, given t
% (the voltage values recorded through an AI) and s (the number of
% recorded samples per second). 
%
% Inputs
% t - vector. AI signal  
% s - number of samples per second. 1E4 if not supplied. 
%
% Outputs
% times - vectors. times in seconds of the pulses (both onsets and offsets)
% signs - vector same length as times. +1 indicates onset of the
%         pulse and -1 indicates offset. 
%
%
%
% Rob Campbell - JFRC Feb 2012
  
verbose=0;

if verbose, clf, end

  
if nargin<2, s=1E4; end

sr=1/s;

x=0:sr:(length(t)*sr)-sr;

t=round(t);
thresh=4.5;
t(t<thresh)=0; %A bit horrible, but deal with instances where we've
               %caught the TTL pulse as it's rising/falling. 

if verbose
  subplot(1,2,1)
  plot(x,t,'-k.')
end

d=diff(t);
if verbose
  subplot(1,2,2)
  plot(x(1:end-1),d,'-k.')
end


d=d/max(d);
d(isnan(d))=0;

f=find(d~=0);

% outputs
times=x(f);
signs=d(f);


  

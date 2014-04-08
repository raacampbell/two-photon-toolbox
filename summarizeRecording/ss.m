function out=ss(in,n)
%  function out=ss(in,n)
%
% plot style sheet. in is a string specifying a style for each plot  
  
  
  
switch lower(in)
 case 'bar'
  out={'edgecolor','k','facecolor',[1,1,1]*0.5};
 case 'lineorder'
  set(gcf,'defaultcolororder',jet(n))
 case 'etc'
end

  
 
 

function n=numberOfNeuronsInSingleSections



D=batchData;
D=D(:);


for ii=1:length(D)
   
    load(D(ii).data);
    
    n(ii)=size(data(1).ROI(2).stats.dff,1);

        
    
end

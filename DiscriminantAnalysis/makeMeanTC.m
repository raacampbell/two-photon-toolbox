function out=makeMeanTC(TC)
% function out=makeMeanTC(TC)
%
% Input is cell array of tuning curves from makeTuningCurve run in
% a loop. Output is the mean of these. 


for ii=1:length(TC)
    tmp(:,:,ii)=TC{ii};
end


for ii=1:size(tmp,1)


    for jj=1:size(tmp,2)
        out(ii,jj).concs=tmp(ii,jj,1).concs;        
        pc=[];
        for n=1:size(tmp,3)
            pc=[pc;tmp(ii,jj,n).pc];
        end
        out(ii,jj).pc=mean(pc,1);
    end

end




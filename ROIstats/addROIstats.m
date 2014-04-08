function data=addROIstats(data)
% populate twoPhoton object with ROI stats
%
% function data=addROIstats(data,parallel)
%
% Purpose
% Loops through the twoPhoton object, data, and adds a statistics
% field to any relevant structures in data.ROI. This can be used,
% for instance, to the responses of each KC. This requires one to
% have already run selectKCs. Automatically works in parallel if
% multiple cores are attached.
%
% Inputs
% data - the twoPhoton object which contains an appropriate ROI
% filed in data.ROI. i.e. we should have run selectKCs. 
%
% Outputs
% Do: data=addROI_stats(data);
%
%
% Rob Campbell, August 2009
  

warning off

if numCores==0

    fprintf('Calculating ROI stats ')
    for ii=1:length(data)
        fprintf('.')
        
        for jj=1:length(data(ii).ROI)
            data(ii).ROI(jj).stats=ROIstats(data(ii),jj);
        end
    end
    fprintf('\n')    

elseif numCores>0

    fprintf('Adding ROIs using %d cores\n',numCores)
    parfor ii=1:length(data)
        for jj=1:length(data(ii).ROI)
            data(ii).ROI(jj).stats=ROIstats(data(ii),jj);
        end
    end

end

warning on



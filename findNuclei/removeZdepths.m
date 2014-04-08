function removeZdepths(data,depths)
% function removeZdepths(data,depths)
%
% There are some instances where z-depths need to be removed. This
% function does this. It removes the planes in the vector "depths"
% and over-writes the rawData matlab matrices. 
%
%
% Rob Campbell


fprintf('Trimming image stacks')
for ii=1:length(data)

    imageStack=data(ii).imageStack(:,:,:,:,:);
    imageStack(:,:,:,:,depths)=[];
    

    if ~isempty(data(ii).ROI) 
        
        for jj=1:length(data(ii).ROI)
            if isfield(data(ii).ROI,'roi') 
                data(ii).ROI(jj).roi(:,:,depths)=[];
            end
        end
        
    end
    
    
    fileStr=[data(ii).info.rawDataDir,'/','rawData', num2str(data(ii).info.stimIndex)]; 
    eval(['rawData',num2str(data(ii).info.stimIndex),'=imageStack;'])
    save(fileStr,['rawData',num2str(data(ii).info.stimIndex)])
    clear('raw*')  

    fprintf('.')

end

    
fprintf('\n')

try
    addROIstats(data)  
catch
    disp('Can''t add ROI stats')
end

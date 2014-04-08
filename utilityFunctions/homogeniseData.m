function homogeniseData
% function homogeniseData
%
% Load all the data in a set of sub-directories defined here. Make
% sure it's all be analysed the same way:
% 1. Same baseline time.
% 2. Same response period. [the is set by, say, neuronMeanVar]
% 3. Remove photo-bleach fit and de-trend the baseline. 



local='/bigDisk/data/RawData/2-Photon/Rob/';
bh='/shares/bh/data/RawData/2-Photon/Rob/';



dirs={'090801_smallOdourSet1',...
      '091001_smallOdourSet2',...
      'ImagingPaper1',...
      'oct_mch',...
      '2DBlends'};




for ii=1:length(dirs)
    dir=[local,dirs{ii}];
    files=rdir([dir,'/**/TSer*.mat']);
    
    for jj=1:length(files)    
        clear data %make sure there're no cockups between files
        %Get the root directory for the file
        root=regexprep(files(jj).name,'TSeries.*mat','');
        fprintf('Loading %s\n',files(jj).name)
        load(files(jj).name);

        updateDataDir(data,root);

        
        if isempty(data(1).ROI), continue, end


        if ~isempty(strmatch('KCstats',properties(data(1))))
            oldKCstructureToNew(data);
        end

        data=doBleedInCorrection(data);

        %Remove the KCdff field if it's there
        for n=1:length(data)
            for r=1:length(data(n).ROI)
                data(n).dffParams.baseLineTime=3;
                
                if ~isfield(data(1).ROI(r),'stats'),continue,end
                if isempty(data(n).ROI(r).stats), continue, end
                try
                    data(n).ROI(r).stats=...
                        rmfield(data(n).ROI(r).stats,'kcDFF');
                catch
                end
                
                    

            end
            
        end

        %Save locally and on BH
        disp('saving...')
        save(files(jj).name,'data')
        save(strrep(files(jj).name,'/bigDisk','/shares/bh'),'data')

        
    end
    
        
end

classdef twoPhoton<dynamicprops
    
    % classdef twoPhoton
    %
    % Purpose:
    % This class definition is applied to a data structure of Praire View
    % data. Its purpose is to load data dynamicallt and work out
    % dF/F and related parameters on the fly using method
    % calls.
    %    
    % Inherits from dynamicprops so that we can add data to the class at later
    % points.
    %
    % The key method is twoPhoton.imageStack which loads data from the
    % disk. Also useful is twoPhoton.dff, which is the dF/F *WITH
    % THE THRESHOLD MASK APPLIED*. The following are legal calls of the method:
    % twoPhoton.dff
    % twoPhoton.dff(1:10,1:10,1)
    % for i=1:60,imagesc(mean(twoPhoton.dff(:,:,i),3)),drawnow,end 
    %
    % also see generateDFFobject
    %
    % Rob Campbell, April 2009-2012, CSHL
    %
    % RC 06/2012 - alter pre-frames so it can be a vector defining
    % start end frames of the baseline period. This means that
    % baseLineTime will be allowed to be a vecor of length 2 or a scalar
    %
    % RC 13/09/2013 - add obj.dffParams.baselineOffsetFrames for
    %                 allowing the first few frames to be skipped. 
    properties
        ignoreFrames
        dffParams
        process
        ROI
        photoBleachFit
        doPhotoBleachCorrection
        stim
    end
    
    
    methods
        %%% Constructor %%%
        function obj = twoPhoton
            obj.dffParams.hsize=12;
            obj.dffParams.filtstd=5;            
            obj.dffParams.baseLineTime=3; %weird artefacts may occur if this is too small (e.g. <3)
            obj.dffParams.baselineOffsetFrames=0; %Set to >0 in order to shift
                                  %the baseline forward in time by
                                  %this many frames (i.e. ignore
                                  %beginning of baseline
            obj.dffParams.cleanSTD=0; %if 1 requires
                                      %conseq. significant bins. But will
                                      %only be calculated if we ask for >5
                                      %frames at once.
            obj.dffParams.respOffset=0.5; %The offset parameter
                                          %used by response period frames
            obj.dffParams.respExtraTime=3; %The extratime parameter
                                           %used by response period frames
            obj.process=struct;
            obj.doPhotoBleachCorrection=0;    
        end
        
        
      
    
        %At least this number of frames should be in the baseline.
        function out=preFrames(obj)
            b=obj.dffParams.baseLineTime;

            if strcmpi('TSeries ZSeries Element',obj.info.type)
              out=ceil(b/(obj.info.framePeriod*...
                        size(obj.info.positionCurrent_XAxis,1)));
            else
              out=floor(b/obj.info.framePeriod);
            end
            
              
            if length(out)==1
                out=[1,out];
            end
            out=out(1):out(2);
            out=out+obj.dffParams.baselineOffsetFrames;
        end
        
        function out=baselineImage(obj)            
            out=obj.imageStack(:,:,obj.preFrames);
            out=mean(out,3);           
        end

        
        
        %Loads raw data from file
        function out=imageStack(obj,y,x,z,a,b)
            if isunix, slash='/'; else, slash='\'; end
            fileStr=[obj.info.rawDataDir,slash,obj.info.rawDataFile];
            load(fileStr,obj.info.rawDataFile)
            eval(['out=',obj.info.rawDataFile,';']);
            
            if nargin<2, y=1:size(out,1);end
            if nargin<3, x=1:size(out,2);end            
            if nargin<4, z=1:size(out,3);end            
            if nargin<5 & size(out,4)>1 %By default take the GFP channel
                a=2;
            elseif nargin<5 & size(out,4)==1
                a=1;
            end
            if nargin<6 & size(out,5)>1 %By default return all z if it's a TZseries
                b=1:size(out,5);
            elseif nargin<6 & size(out,5)==1
                b=1;
            end
            
            out=out(y,x,z,a,b);

           %THIS IS A POTENTIAL BUG! 
           % EACH TIME THE IMAGE STACK IS SAVED THIS CONSTANT IS SUBTRACTED!
           % AUG 2012 RAAC: not a problem given how we run the
           % code, but this is a worry. 
           %Subtract the background from everything if possible. 
           %Otherwise we assume that saved images have already had
           %this done
            if ~isempty(strmatch('ROI',properties(obj)))
                if ~isempty(obj.ROI) & isfield(obj.ROI(1),'backgroundLevel') & ~isempty(obj.ROI(1).backgroundLevel)
                    bg=obj.ROI(1).backgroundLevel;

                    out=out-bg;
                    out(out<0)=0;%Make negative values zero
                end
            end
            

            %Now apply the photo-bleach correction.
            if obj.doPhotoBleachCorrection
                bleachFit=obj.photoBleachFit(z);
                mu=mean(bleachFit);
                for i=1:length(bleachFit)
                    out(:,:,i)=out(:,:,i)-bleachFit(i)+mu;
                end      
            end
            
            out=preProcess(out,obj);
 
        end
        
        
        function out=dff(obj,y,x,z)              
            baselineImage=obj.baselineImage.*obj.ROI(1).roi;
            if nargin<2, y=1:size(baselineImage,1);end
            if nargin<3, x=1:size(baselineImage,2);end            
            baselineImage=baselineImage(y,x);
            
            imageStack=obj.imageStack;
            if nargin<4, z=1:size(imageStack,3);end           
            
            imageStack=imageStack(y,x,z);

            F=repmat(baselineImage,[1,1,length(z)]);
            ind=F<obj.ROI(1).level;
            F(ind)=1;
            imageStack(ind)=1;
            DeltaF=imageStack-F;

            DeltaFOverF=DeltaF./F;
            out=DeltaFOverF;
            
            out(out==inf)=0;
        end
      
        
    end %methods
    
end


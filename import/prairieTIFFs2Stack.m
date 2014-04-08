function imageStack=prairieTIFFs2Stack(data)
% Convert a list of PraireView TIFF file names into an image stack
%
% function imageStack=prairieTIFFs2Stack(data)
%
%
%
% Rob Campbell - August 2012
%                 April 2013

if length(data)>1
    error('data should have length of 1')
end

%pre-size raw data matrix: a 4-D matrix of x/y images with
%time in dimension 3 and PMT channel in dimension 4. 
imSize=[data.info.linesPerFrame,...           
           data.info.pixelsPerLine,...
           length(data.relativeFrameTimes),...
           size(data.info.fileName,1)];
imageStack=single(ones(imSize));


%Now we loop through the frame names and create the image stack(s).   
for ch=1:imSize(4)
    for ii=1:imSize(3)
        if isunix, slash='/'; else, slash='\'; end
        imFname=[data.info.rawDataDir,slash,data.info.fileName{ch,ii};];
        try
            imageStack(:,:,ii,ch)=single(imread(imFname));
        catch
            fprintf('** Can''t read tiff for channel %d frame %d\n',ch,ii) 
            continue
        end    
    end
end
  


%The image bit depth is stored in the xml file. It probably has a
%value of 12. Extrating the image bit-depth from the tiff isn't
%useful since it reports it as 16 bit. However, if in the dwell time
%controls you have the Averaging/Summing control set to 'Summing',
%the pixel then the intensity values can easily exceed 4095 (the
%range of 12-bit data).If this happens, binningMode will equal 1


  if isfield(data.info,'bitDepth') & data.info.binningMode==0 
      bitDepth=data.info.bitDepth;
  elseif ~isfield(data.info,'bitDepth') & data.info.binningMode==0 
      bitDepth=12; %Guess
  elseif data.info.binningMode==1
      bitDepth=0; %We'll not normalise the image if data were acquired in summing mode.       
  else
      error('Can''t set bit-depth in %s',mfilename)
  end

%normalise by maximum possible value 
imageStack=single(imageStack/2^bitDepth);

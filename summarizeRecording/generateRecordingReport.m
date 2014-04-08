function generateRecordingReport(data,sect,append)
% Make an HTML report of one experiment
% 
% function generateRecordingReport(data,sect,append)
%
% Purpose
% Extracts key features from an imported twoPhoton object (at the moment we
% assume KC stats have been calculated) and presents them as an HTML (and
% in the future perhaps a LaTeX-derived PDF. 
%
% Inputs
% data - the twoPhoton object  
% sect - which sections of the report to make. see start of
% function. 
% ** append - if 1 it replaces the sections specified in
% sections. Quick hack to make the longer parts this run faster and
% not over-write each time. Do it better soon. if <0 then delete dir**
%
% Notes
% For HTML, the appropriate plots will be saved as SVG (scalable vector
% graphics) because this is awesome. Possibly this will not work in Internet
% Explorer and requires the plot2svg package on Matlab Central to be in
% your path.
%
% Routine will require modification to work on Windows machines. Requires
% data.info fields only present from a PraireView import.
%
% Rob Campbell, October 2009
  

if nargin<3, append=0; end

sections={'baselines','Basline Images';...
          'overlays','dF/F Overlays';...
          'stability','Response Stability';...
          'tcourse','Response Time Courses of all KCS';...
          'kcdff','KC dF/F';...
          'dendrogram','Odour Dendrogram'};

if nargin<2 
  sect=1:size(sections,1);
end
sections=sections(sect,:);





c = onCleanup(@()myCleanUp); %Quit gracefully
CWD=pwd;
%----------------------------------------------------------------------
%Key parameters
imFormat='-djpeg100'; %default image type and compression for non-svg images


%----------------------------------------------------------------------
%make or over-write directory with report
recordingName=data(1).info.XMLfile;

dirName=regexprep(recordingName,'\.xml','_html_report');
if exist(dirName,'dir') && append==-1
  disp(sprintf('** deleting existing %s ',dirName))
  delete([dirName,'/*']); 
  rmdir(dirName); 
end

if ~exist(dirName,'dir')
  m=mkdir(dirName);
  if ~m, error('Failed to make directory %s',dirName), end   
end
cd(dirName)


fprintf('----------------------------------------\n * Placing report in:\n %s\n',pwd)



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% determine the number of reps for each odour 
[odours,U,occ]=getOdourNames(data); 



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Open the file and write header information
fid=fopen('index.html','w');
info=data(1).info;
reportString(fid,'header',info.XMLfile);


%Now we write the somewhat messy Javascript used for the movies. 
%There will be a better way using the DOM, but I don't know what it is.
labels='A':'Z';
fprintf(fid,'\n<script type="text/javascript">\n');
fprintf(fid,'var ');
for i=1:length(U)
  fprintf(fid,'%s=0',lower(labels(i)));
  if i~=length(U)
    fprintf(fid,',');
  else
    fprintf(fid,'\n');
  end
end

for i=1:length(U)
  fprintf(fid,'var %s=[',labels(i));
  tmpStr=sprintf('%d,',occ{i});
  tmpStr(end:end+3)='];\n';
  fprintf(fid,tmpStr);
end

fprintf(fid,'\nfunction changepic() {\n');
for i=1:length(U)
  N=length(occ{i});
  fprintf(fid,['%s++; if (%s>%d) {%s=0}\ndocument.getElementById(''overlay%s'').style.backgroundImage',...
               '= "url("+"overlay"+%s[%s]+".jpg)";\n'],...
          lower(labels(i)),lower(labels(i)),N-1,lower(labels(i)),...
          labels(i),labels(i),lower(labels(i)));
end


fprintf(fid,'setTimeout("changepic()",250);\n}\n</script>\n');
fprintf(fid,'</head>\n\n<body onload="changepic()">\n<a name="top"></a>\n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Show the aqcuisition parameters
reportString(fid,'box1start','600');

fprintf(fid,['<ul>\n',...
             '<li><b>recording time</b>: %s</li>\n',...
             '<li><b>2-photon &#955;</b>: %d nm; <b>Chan2 gain</b>: %d</li>\n',...
             '<li><b>Optical Zoom</b>: %0.3g; <b>Dwell Time</b>: %0.3g &#956;s; <b>fps</b>: %0.3g</li>\n',...
            '</ul>\n'],...
        info.date,...
        info.laserWavelength_0,round(info.pmtGain_1),...
        info.opticalZoom,info.dwellTime,1/info.framePeriod...
        );

reportString(fid,'boxend');



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Add some links to allow us to jump straight to points of interest
%this can also be used to toggle whether or not different sections are 
% made 

fprintf(fid,'<table><tr><td width=400px><ul>\n');
for i=1:size(sections,1)
  fprintf(fid,'<li><a href="#%s">%s</a></li>\n',sections{i,:});
end
fprintf(fid,'</ul>\n</td>\n<td>\n');

%Show which KCs have been selected

showSelectedKCs(data,[],1)
set(gca,'position',[0.01,0.01,0.99,0.99]);
thisFile='hiliteKCs.jpg';
print(imFormat,'-r60',thisFile);
im=imfinfo(thisFile);
reportString(fid,'jpgdiv',...
             {thisFile,num2str(im.Width),num2str(im.Height),''});
fprintf(fid,'</td></tr></table>\n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Recording baselines
% ONE
if strmatch('baselines',sections(:,1))
  fprintf(fid,'<a name="baselines"></a>\n');
  fprintf(fid,'\n<hr /> <p><b>Recording Baselines</b> (<a href="#top">top</a>)</p>\n');
  fprintf('Writing baseline images ')
  
  for i=1:length(data)
    fprintf('.')
    thisFile=sprintf('baseline%d.jpg',i);   

    if append<=0
      clf
      axes('position',[0.01,0.01,0.99,0.99])
      imagesc(data(i).baselineImage)
      colormap gray
      box on
      axis off equal
      
      print(imFormat,'-r30',thisFile)
    end
    im=imfinfo(thisFile);
    label=sprintf('#%d %s',i,data(i).stim.odour);
    reportString(fid,'jpgdiv',...
                 {thisFile,num2str(im.Width),num2str(im.Height),label});

  end
  fprintf('\n');
  fprintf(fid,'\n<div style="clear:left;"></div>\n');
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% overlay dF/F onto baseline
% TWO
if strmatch('overlays',sections(:,1))
  fprintf(fid,'<a name="overlays"></a>\n');
  fprintf(fid,['\n<hr /> <p><b>Overlays</b> (<a href="#top">top</a>' ...
               ')</p>\n']);
  
  thisFile=sprintf('overlay%d.jpg',i);

  if append<=0
    fprintf('Calculating dF/F overlays ')
    for i=1:length(data)
      fprintf('.')
      muInt{i}=cleanMeanDFF(data(i));
      mval(i)=max(muInt{i}(:));
    end
    fprintf('\n')
    
    maxVal=max(mval(:));
    fprintf('Writing dF/F overlays ')
    for i=1:length(data)
      fprintf('.')
      clf, overlayDFFandBaseline(data(i),maxVal,[],muInt{i});
      set(gcf,'name',['data ', num2str(i)])
      thisFile=sprintf('overlay%d.jpg',i);
      print(imFormat,'-r50',thisFile);
      label=sprintf('#%d %s',i,data(i).stim.odour);
    end
    fprintf('\n')
  end
  

  %Write the image place holders
  im=imfinfo(thisFile);
  for i=1:length(U)
    label=sprintf('overlay%s',labels(i));
    reportString(fid,'jpgdiv',...
                 {thisFile,num2str(im.Width),num2str(im.Height),U{i},label});
  end
  
  fprintf(fid,'\n<div style="clear:left;"></div>\n');
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% How stable are the responses over time?
% THREE
if strmatch('stability',sections(:,1))
  clf
  colormap jet
  set(gcf,'paperposition',[0 0 6,5])
  fprintf(fid,'<a name="stability"></a>\n');
  fprintf(fid,'\n<hr /> <p><b>Response Stability</b> (<a href="#top">top</a>)</p>\n');
  
  makeSVG=significantCellsByRecording(data);
  thisFile='sigKCsByReps';
  if makeSVG %only make the SVG if we have line graphs
    thisFile=[thisFile,'.svg'];
    plot2svg(thisFile,gcf)
    reportString(fid,'svg',{thisFile,'300','450'});
  else
    printJPG([thisFile,'.jpg'],'jpgdiv','')
  end
  
  whichROIsAreSignificant(data)
  printJPG('kcTuning.jpg','jpgdiv','')
  

  %How do responses change over the duration of the whole session?
  responseMagByPresentation(data)
  set(gcf,'paperposition',[0,0,9,3])
  thisFile='responseMagPresent.jpg';
  printJPG(thisFile,'jpgdiv','')
  close
  
  %now add two versions of the 3-D plot
  O=getOdourNames(data);
  if length(O.uOdours)>1
      clf
      set(gcf,'paperposition',[0,0,6,5])
      odour3Dplot(data);
      set(gcf, 'InvertHardCopy', 'off');
      printJPG('3d-plot_1.jpg','jpgdiv','')
      
      set(gca,'View',[120,30]);
      printJPG('3d-plot_2.jpg','jpgdiv','')
      
      close
  end
  

  fprintf(fid,'\n<div style="clear:left;"></div>\n');
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% How do the time-courses change over time?
if strmatch('tcourse',sections(:,1))
  fprintf(fid,'<a name="tcourse"></a>\n');
  
  fprintf(fid,'\n<hr /> <p><b>Odour Time Courses</b> (<a href="#top">top</a>)</p>\n');
  
  close all


  if append<=0 
    responseTimeCourseByOdour(data)
    fprintf('Writing odour time courses ')
    figs=get(0,'children');
    %sort alphabetically and highlight control
    for i=1:length(figs)
      figure(figs(i))
      titString=get(get(gca,'title'),'string');
      tit{i}=titString;
      if findstr(titString,'paraffin')
        set(get(gca,'title'),'color','r')
      end    
    end
    [tit,x]=sort(tit);
    figs=figs(x);
    
    for i=1:length(figs)
      fprintf('.')
      thisFile=sprintf('timeCourse%d.svg',i);
      plot2svg(thisFile,figs(i))
    end

  end
  
  d=dir('timeCourse*');
  for i=1:length(d)
    thisFile=d(i).name;
    reportString(fid,'svg',{thisFile,'400','400'});
  end
  fprintf('\n');
  close all
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% KC dF/F over time
if strmatch('kcdff',sections(:,1))
  fprintf(fid,'<a name="kcdff"></a>\n');
  
  fprintf(fid,'\n<hr /> <p><b>KC dF/F</b> (<a href="#top">top</a>) </p>\n');

  if append<=0
    fprintf('Writing KC dF/F over time ')
    for i=1:length(data)
      fprintf('.');
      plotKCdFF(data(i)),
      set(gcf,'renderer','painters','InvertHardCopy', 'off');
%      thisFile=sprintf('kcdff%d.svg',i); plot2svg(thisFile,gcf)
      thisFile=sprintf('kcdff%d.jpg',i); print(imFormat,'-r100',thisFile)
      
    end
    fprintf('\n');
    close all
  end
  
  %The SVG looks nice but it's sooo slow
  %add a selection box
  fprintf(fid,'<p>\n<select id="kcSwapper" onChange="swapImage()">\n');
  for i=1:length(data)
    fprintf(fid,'  <option value="kcdff%d.jpg">Recording %d: %s </option>\n',...
            i,i,data(i).stim.odour);
  end 
  fprintf(fid,'</select>\n</p>\n');
  %insert one figure
  %fprintf(fid,'<object id="kcdff" type="image/svg+xml" data="kcdff1.svg" width="1000" height="600"></object>\n');
  fprintf(fid,'<object id="kcdff" type="image/jpg" data="kcdff1.jpg" width="801px" height="600px "></object>\n');
end





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Dendrogram
if strmatch('dendrogram',sections(:,1))

  
  fprintf(fid,'\n<hr /> <p><b>Odour Dendrogram & Classifier</b> (<a href="#top">top</a>)</p>\n');

  odourDendrogram(data,0.55)
  set(gcf,'paperposition',[0 0 12,8])
  printJPG('odourDendrogram.jpg','jpgdiv','')
  close
  %Run the classifier and report the results
  OUT=classifyKCs(data);
  odourClassConfMat(OUT.xValidMu);
  set(gcf,'paperposition',[0 0 6,5])
  printJPG('confMat.jpg','jpgdiv','')
  fprintf(fid,'<a name="dendrogram"></a>\n');


  
  
end





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Finish up
reportString(fid,'footer');

close all
fprintf('Done!\n----------------------------------------\n')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function printJPG(thisFile,stringType,label)
  print(imFormat,'-r100',thisFile)
  im=imfinfo(thisFile);
  reportString(fid,stringType,...
               {thisFile,num2str(im.Width),num2str(im.Height),label});
end

function myCleanUp
  if exist('fid','var')
    fclose(fid);
  end
  cd(CWD)
end
  

end
 

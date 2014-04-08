function varargout = selectROIs(data,ROI,depth)
% Select neuronal cell bodies with a GUI
%
% function varargout = selectKCs(varargin)
%
% selectKCs allows the user to select cells in the image by
% interactively clicking on them. 
%
% The zoom may not work, but if it does then the red cross button on
% the toolbar allows you to go out of the zoom or pan modes and back
% into the clicking mode. 
% 
% INPUTS
% data - the twoPhoton data structure we will work o
% ROI - a optional string defining the type of ROI being
% selected. By default this is 'soma'. If this ROI type already
% exists in data.ROI then it will be replaced by the newly clicked
% ROI data. If it does not exist then it will be appended and
% labeled with the supplied name (ROI). 
% depth - if the recording has multiple depths then work only on
% the depth defined by this scalar. depth equal 1 by default.
%    
%   
% USAGE:
% data = selectKCs(data);
% Where data is the output from generateDFFobject. 
%
% OUTPUT: 
% If data has length 1 then the function returns the array but adds
% the field KCmasks, which contains the clicked data. This can
% serve as an input to KCdFF.m to calculate dF/F for individual
% cells. 
% If data has length>1 then cell clicking is performed on an image
% which is the mean over all stimulus presentations (cells that
% move will look blurry). Following each click the background
% animates to show whether or not the clicked area is stable over
% time. This one set of KC locations is then applied to all
% stimulus presentations. 
%
% Eyal Gruntman April 2009

% NOTE:
% The function is a modification of the iconEditor example, and as such has
% irrelevant relics in it. 

  
% Create all UI objects 
hMainFigure     =   figure(...
                    'Units','characters',...
                    'MenuBar','none',...
                    'Toolbar','figure',...
                    'Position',[71.8 34.7 106 36.15],...
                    'WindowButtonDownFcn', @hMainFigureWindowButtonDownFcn);
tbh             =   findall(hMainFigure,'Type','uitoolbar');
tth             =   uipushtool(tbh,'CData', cat(3,(eye(20)+fliplr(eye(20)))*.5,zeros(20,20,2)),... % push button to cancel the zoom mode
                    'Separator','on',...
                    'HandleVisibility','Callback',...
                    'ClickedCallback', @htthClickedCallback);
hImgEditPanel  =    uipanel(...
                    'Parent',hMainFigure,...
                    'Units','characters',...
                    'Clipping','on',...
                    'Position',[1.8 4.3 68.2 27.77]);
hImgEditAxes   =   axes(...
                    'Parent',hImgEditPanel,...
                    'Units','characters',...
                    'Position',[2 1.15 64 24.6],...
                    'color','none');               
hImgEditAxes2   =   axes(...
                    'Parent',hImgEditPanel,...
                    'Units','characters',...
                    'Position',[2 1.15 64 24.6],...             
                    'color','none');               
hImgMsg        =   uicontrol(...
                    'Parent',hMainFigure,...
                    'Units','characters',...
                    'HorizontalAlignment','left',...
                    'Position',[3.8 32.9 16.2 1.46],...
                    'String','Messages: ',...
                    'BackgroundColor','w',...
                    'Style','text');
hImgMsgDisp   =   uicontrol(...  %displays the messages 
                    'Parent',hMainFigure,...
                    'Units','characters',...
                    'HorizontalAlignment','left',...
                    'Position',[19.8 32.9 40 1.62],...
                    'String','add new cell',...
                    'BackgroundColor','w',...
                    'Style','text');
hmanipPanel   =   uipanel(...
                    'Parent',hMainFigure,...
                    'Units','characters',...
                    'Title','Parameters',...
                    'Clipping','on',...
                    'Position',[71.8 10.38 32.2 20]);
hmanipControl =   uicontrol(...
                    'Parent',hmanipPanel,...
                    'Units','characters',...
                    'Visible','off',...
                    'Position',[2 3.77 16.2 5.46],...
                    'String','');
hCellDiamTi      =   uicontrol(...
                    'Parent', hmanipPanel,...
                    'Units', 'normalized',...
                    'Style', 'text',...
                    'Position', [.1 .85 .8 .1],...
                    'String', 'Enter Cell Diameter:');                
hCellDiameter   =   uicontrol(...
                    'Parent', hmanipPanel,...
                    'Units', 'normalized',...
                    'Style', 'edit',...
                    'Position', [.1 .75 .8 .1],...
                    'String', '7',...
                    'BackgroundColor', 'w',...
                    'Callback', @hCellDiameterCallback);
hCellCountTit   =   uicontrol(...
                    'Parent', hmanipPanel,...
                    'Units', 'normalized',...
                    'Style', 'text',...
                    'Position', [.1 .55 .8 .1],...
                    'String', 'Number of Cells marked:'); 
hCellCount      =   uicontrol(...
                    'Parent', hmanipPanel,...
                    'Units', 'normalized',...
                    'Style', 'text',...
                    'Position', [.1 .45 .8 .1],...
                    'String', '0');                 
hSectionLine    =   uipanel(...
                    'Parent',hMainFigure,...
                    'Units','characters',...
                    'HighlightColor',[0 0 0],...
                    'BorderType','line',...
                    'Title','',...
                    'Clipping','on',...
                    'Position',[2 3.62 102.4 0.077]);
hDoneButton     =   uicontrol(...
                    'Parent',hMainFigure,...
                    'Units','characters',...
                    'Position',[65.8 0.62 17.8 2.38],...
                    'String','Done',...
                    'Callback',@hDoneButtonCallback);
hUndoButton   =   uicontrol(...
                    'Parent',hMainFigure,...
                    'Units','characters',...
                    'Position',[85.8 0.62 17.8 2.38],...
                    'String','Undo',...
                    'Callback',@hUndoButtonCallback);



% -----------------------
% ONE
% Pull out data and behave appropriately depending on whether we
% have a single element or many elements in the array. If many we
% will plot the average image and allow the user to make selections
% based on this. The user will also be able to animate it. 

if nargin<2 || isempty(ROI)
    ROI='soma';
end

if nargin<3
    depth=1;
end

    
ROIindex=strmatch(ROI,{data(1).ROI.notes});
if isempty(ROIindex)
    ROIindex=length(data(1).ROI)+1;
end

%We assume that ROI fields are present in the same order in all
%response structures. Go through and ensure that each has this ROI
%information
for ii=1:length(data)
    data(ii).ROI(ROIindex).notes=ROI;
end





disp('setting up image array')
if length(data)==1 %unlikely to ever be the case
  frames=[];
  inputim = double(mean(data.imageStack,3));
elseif length(data)>1
  frames=zeros([data(1).info.linesPerFrame,...
                data(1).info.pixelsPerLine,...
                length(data)]);
  tmp=frames;
  if isfield(data(1).info,'muStack')
    for i=1:length(data)
      frames(:,:,i)=data(i).info.muStack(:,:,end,1,depth);
    end
  else
    for i=1:length(data)
      frames(:,:,i)=averageDownIm(data(i).imageStack,2);
    end
  end
  
  inputim=mean(frames,3);
  clear tmp
end

%define variables
imdim = size(inputim);
theta = -pi:0.1:pi ;
mOutputArgs = {};

if ~isempty(data(1).ROI(ROIindex).roi) & ...  
        size(data(1).ROI(ROIindex).roi,3)>=depth
    
    roimasks=data(1).ROI(ROIindex).roi(:,:,depth);
    u=unique(roimasks(:));
    u=u(end);
    set(hCellCount,'string',num2str(u))
else
    roimasks = zeros(imdim);
end


[convim cMap] = gray2ind(inputim, 2^12+2); % to make KC ROIs coloured
convim = double(convim); % needed so that direct mapping for both green and red will work

doingPlay=0; %bool to specify whether the movie is currently being played


% -----------------------
% TWO
% Set presenting the image
axes(hImgEditAxes2)
pcolor(inputim),shading flat, axis equal tight off
set(gca,'CLim',[min(frames(:)),max(frames(:))])
colormap gray
imObj=get(gca,'children');
axis ij

axes(hImgEditAxes)
pcolor(zeros(size(inputim))*nan)
shading flat, axis equal tight off
set(gca,'color','none')
axis ij

prepareLayout(hMainFigure);                            


uiwait(hMainFigure); %Make the GUI blocking


% Return the edited icon CData 
for i=1:length(data)
    data(i).ROI(ROIindex).roi(:,:,depth)=roimasks;
end
varargout{1}=data;
varargout{2}=frames;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Below are nested sub-functions of the main function. By nesting,
% these functions have the same scope as the enclosing
% function. Rather handy!

%---------------------------------------------
    function hMainFigureWindowButtonDownFcn(hObject, eventdata, handles)
        % Callback called when mouse is pressed on the figure. Used to change
        % the color of the specific icon data point under the mouse to that of
        % the currently selected color of the colorPalette
            if (ancestor(gco,'axes') == hImgEditAxes)
                localEditImg
            end
    end


%---------------------------------------------
    function hCellDiameterCallback(hObject, eventdata, handles)
        user_entry = str2double(get(hObject,'string'));
        if isnan(user_entry)
            errordlg('You must enter a numeric value','Bad Input','modal')
         return
        end
    end


%---------------------------------------------
    function hDoneButtonCallback(hObject, eventdata, handles)
        uiresume;
        delete(hMainFigure);
    end


%---------------------------------------------
    function hUndoButtonCallback(hObject, eventdata, handles)
        if sum(roimasks(:)) == 0
            set(hImgMsgDisp, 'string', 'No cells to delete', 'FontSize', 14, 'FontWeight', 'Bold');
        else
            
            num = str2num(get(hCellCount, 'string'));
            roimasks(find(roimasks == num)) = 0;
            set(hImgMsgDisp, 'string', 'Cell Deleted');
            num = str2num(get(hCellCount, 'string'));
            set(hCellCount, 'string', num2str(num-1));
            updateim(0);
        end
        
    end


%---------------------------------------------
    function htthClickedCallback(hObject, eventdata, handles)
        zoom off
        pan off
    end


%---------------------------------------------
    function localEditImg
        pt = get(hImgEditAxes,'currentpoint');
        rad = str2num(get(hCellDiameter, 'string'))/2;
        getdisk(pt,rad);
        
    end


%---------------------------------------------
    function getdisk(point, radius)
        Xcrds = fix (point(1,1) + radius * cos(theta) );
        Ycrds = fix (point(1,2) + radius * sin(theta) );
        currmask = roipoly(inputim, Xcrds, Ycrds);
        verifiedcurrmask = checkoverlap(currmask);
        if verifiedcurrmask == currmask
            set(hImgMsgDisp, 'string', 'Cell Added'); 
        else
            set(hImgMsgDisp, 'string', 'Cell Added -  overlapping pixels', 'FontSize', 14, 'FontWeight', 'Bold');
        end
        
        num = str2double(get(hCellCount, 'string'));
        roimasks(find(verifiedcurrmask)) = num+1;
        set(hCellCount, 'string', num2str(num+1));
        updateim

    end

%---------------------------------------------
function updateim(playMov)
  if nargin==0;playMov=1;end
if isempty(frames), playMov=0; end

        ylimit = get(hImgEditAxes, 'YLim');
        xlimit = get(hImgEditAxes, 'XLim');
        
        if sum(roimasks(:)) == 0 % in order to delete the first cell
          disp('ALL ROIs REMOVED')
%            imshow(convim, cMap);
%            set(hImgEditAxes, 'Ylim', ylimit, 'Xlim', xlimit);
        else
          
          %Add the locations of the points to the image
          lastmask = zeros(imdim);
          prevmasks = zeros(imdim);
          num = str2double(get(hCellCount, 'string'));
          lastmask(roimasks == num) = 1;
          prevmasks(roimasks > 0 & roimasks < num) = 1;
          tempim = convim; tempmap = cMap; 
          tempmap(end+1,:) = [0,1,0];
          tempmap(end+1,:) = [1,0,0];
          tempim(logical(lastmask)) = size(tempmap,1);
          tempim(logical(prevmasks)) = size(tempmap,1)-1;
          
          axes(hImgEditAxes)
          tempim(tempim<=length(cMap))=nan;
          tempim(1,1)=1;
          axes(hImgEditAxes)
          chil=get(gca,'children');
          chil=chil(strmatch('surface',get(chil,'type')));
          set(chil,'CData',tempim,'FaceAlpha',0.35)
          colormap(tempmap)          
          set(hImgEditAxes, 'Ylim', ylimit, 'Xlim', xlimit);

          if playMov & ~doingPlay
          for i=1:size(frames,3)
            set(imObj,'CData',frames(:,:,i))
            drawnow
            pause(0.001)
            doingPlay=1;
          end
          doingPlay=0;
          set(imObj,'CData',inputim)
          end
          
        end
    end

%---------------------------------------------
% this function verfies that there are no overlapping pixels between the
% exsiting masks and the last one
    function vermask = checkoverlap(mask)
        if str2double(get(hCellCount, 'string')) == 0
            vermask = mask;
        else
         
         allinds = find(roimasks);
         lastinds = find(mask);
         diff = setdiff(lastinds, allinds);
         vermask = zeros(imdim);
         vermask(diff) = 1;
        end        
    end


end %End of main function 


%------------------------------------------------------------------
% Below are other functions which have their own scope. 

function prepareLayout(topContainer)
% This is a utility function that takes care of issues related to
% look&feel and running across multiple platforms. You can reuse
% this function in other GUIs or modify it to fit your needs.
    allObjects = findall(topContainer);
    warning off  %Temporary presentation fix
    try
        titles=get(allObjects(isprop(allObjects,'TitleHandle')), 'TitleHandle');
        allObjects(ismember(allObjects,[titles{:}])) = [];
    catch
    end
    warning on


    % Make GUI objects available to callbacks so that they cannot
    % be changes accidentally by other MATLAB commands
    set(allObjects(isprop(allObjects,'HandleVisibility')), 'HandleVisibility', 'Callback');

    % Make the GUI run properly across multiple platforms by using
    % the proper units
    if strcmpi(get(topContainer, 'Resize'),'on')
        set(allObjects(isprop(allObjects,'Units')),'Units','Normalized');
    else
        set(allObjects(isprop(allObjects,'Units')),'Units','Characters');
    end

end

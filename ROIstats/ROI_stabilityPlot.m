function ROI_stabilityPlot(data,ROIindex)
% function ROI_stabilityPlot(data,ROIindex)
%
% Purpose
% Assess whether the ROI (or ROIs) has drifted over the course of 
% a session. This function is likely most useful for single, large,
% ROIs. Makes a little sub-plot for each response and overlays the 
% ROI. 
%
% Inputs
% data - twoPhoton data structure
% ROIindex - the indecies to plot. Can be a vector
%
%
% Rob Campbell - CSHL June 2013


if nargin<2
    ROIindex=[];
end


if ischar(ROIindex)
    ROIindex=strmatch(ROIindex,{data(1).ROI.notes});
end
    
if isempty(ROIindex)
    if length(data(1).ROI)>0
        ROIindex=1;
    else
        fprintf('Can''t find any ROIs. Exiting')
        if nargout>0
            varargout{1}=[];
        end
        return
    end
    
end

n=numSubplots(length(data));


if length(ROIindex)==1
    col=[0,1,0];
else
    col=lines(length(ROIindex));
end


clf

pltP={'-','linewidth',0.5};



for ii=1:length(data)
    subplot(n(1),n(2),ii)
    imagesc(data(ii).info.muStack(:,:,end))

    hold on    

    %Overlay the resired ROIs
    for r=1:length(ROIindex)
        mask=data(ii).ROI(ROIindex(r)).roi;
        [B,L,N,A] = bwboundaries(mask,'noholes');
        for b=1:length(B)
            H.kc(b)=plot(B{b}(:,2),B{b}(:,1),pltP{:},...
                         'color',col(r,:));
        end
    end
    
    

    %Add red text at the top of right of the sub-plot indicating
    %the repeat number
    X=xlim;
    Y=ylim;
    text(X(2)*0.95, Y(2)-diff(Y)*0.9,num2str(ii),...
         'HorizontalAlignment','Right',...
         'color','r','FontWeight','Bold')
    
    axis equal off
    hold off
    
    drawnow
    

end

    
spaceplots
    
end



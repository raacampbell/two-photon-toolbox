%% generateRecordingReport
% Make an HTML report of one experiment
% 
% |function generateRecordingReport(data,sect,append)|
%
%% Purpose
% Extracts key features from an imported twoPhoton object (at the moment we
% assume KC stats have been calculated) and presents them as an
% HTML.
%
%% Inputs
% * |data| - the |twoPhoton| object  
% * |sect| - which sections of the report to make. see start of
% function. 
% * |append| - if 1 it replaces the sections specified in
% sections. Quick hack to make the longer parts this run faster and
% not over-write each time. Do it better soon. if <0 then delete
% dir. 
%
%% Notes
% For HTML, the appropriate plots will be saved as SVG (scalable vector
% graphics) because this is awesome. Possibly this will not work in Internet
% Explorer and requires the plot2svg package on Matlab Central to be in
% your path.
%
% This routine is a bit rough and somewhat confusing. Users would
% probably want to make their own version which makes the summary
% plots they desire. Also, this code may  will require modification
% to work on Windows machines.

% ------------------------------------------------------------------------
% Copyright (C) 2015 University of Southern California, SAIL, U.S.
% Author: Maarten Van Segbroeck
% Mail: maarten@sipi.usc.edu
% Date: 2015-20-1
% ------------------------------------------------------------------------

function show_syllable_distance(handles) 

datasetNames=dir(fullfile(handles.datasetdir,'*.mat'));
if isempty(datasetNames)
    errordlg('Please create a dataset first.','No dataset created');
    return;
end

guihandle=handles.output;
datasetdir=handles.datasetdir;

% figure
set(guihandle, 'HandleVisibility', 'off');
close all;
set(guihandle, 'HandleVisibility', 'on');
screenSize=get(0,'ScreenSize');
defaultFigPos=get(0,'DefaultFigurePosition');
figure('Position',[defaultFigPos(1) 0.90*screenSize(4)-defaultFigPos(4) defaultFigPos(3) defaultFigPos(4)]);
syl_dist_tot=[];
g1=[];
syllable_distance_plot_margin=5;
load('util/cmap.mat');
colormap(cmap2);
barcolors=cmap2([1:floor(size(cmap2,1)/length(datasetNames)):size(cmap2,1)-1],:);
barcolors=flipud(barcolors);
datasetnames=cell(1,length(datasetNames));

for datasetID = 1:length(datasetNames)
    
    dataset_filename = fullfile(datasetdir,datasetNames(datasetID).name);
    [~, datasetnames{datasetID}]=fileparts(dataset_filename);
    datasetnames{datasetID}=strtrim(regexprep(datasetnames{datasetID},'[_([{}()=''.(),;:%{%}!@])]',' '));    

    if isempty(whos('-file',dataset_filename,'dataset_stats'))
        fprintf('Data set stats does not exist. Recreate data set.\n');        
    else
        load(dataset_filename,'dataset_stats','fs');
    end
    
    % accumulating stats
    syllable_dist=dataset_stats.syllable_distance;
    syl_dist_tot=[syl_dist_tot syllable_dist];    
    g1=[g1 datasetID*ones(size(syllable_dist))];
    
end

h=boxplot(syl_dist_tot,g1,'widths',.25,'whisker',0.95,'orientation', 'horizontal'); hold on;
lower_whisker_obj=findobj(gca,'Tag','Lower Whisker');
lower_whisker=min(cell2mat({lower_whisker_obj.XData}));
upper_whisker_obj=findobj(gca,'Tag','Upper Whisker');
upper_whisker=max(cell2mat({upper_whisker_obj.XData}));
xlim1=max(lower_whisker-syllable_distance_plot_margin,0);
xlim2=upper_whisker+syllable_distance_plot_margin;
h = findobj(gca,'Tag','Box');
for j=1:length(h)
   patch(get(h(j),'XData'),get(h(j),'YData'),barcolors(j,:));
end
for j=1:length(h)
   medianval=median(syl_dist_tot(g1==j));
   plot( [medianval medianval], [j-0.25 j+.25],'k','LineWidth',2);
end
hold off
set(gca, 'Box', 'off', 'TickDir','out')
grid on;
xlabel('Time (milliseconds)', 'FontSize',handles.FontSize1);
xlim([xlim1 xlim2]);
set(gca,'ytick',[1:length(datasetNames)]);
set(gca,'yticklabel',datasetnames);
set(gca, 'FontSize',handles.FontSize2);
title('Inter-syllable distance','FontSize',handles.FontSize1, 'FontWeight','bold');
axvals=axis; text(axvals(2)/2,axvals(4)/2,{'MUPET version 1.0', '(unreleased)'},'Color',[0.9 0.9 0.9],'FontSize',handles.FontSize1+10,'HorizontalAlignment','center','Rotation',45);
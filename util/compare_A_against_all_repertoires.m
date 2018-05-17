% ------------------------------------------------------------------------
% Copyright (C) 2015 University of Southern California, SAIL, U.S.
% Author: Maarten Van Segbroeck
% Mail: maarten@sipi.usc.edu
% Date: 2015-20-1
% ------------------------------------------------------------------------

function compare_A_against_all_repertoires(handles,repertoireNames,repertoireA) 

guihandle=handles.output;
repertoiredir=handles.repertoiredir;

csvdir=fullfile(handles.repertoiredir,'CSV');
if ~exist(csvdir)
  mkdir(csvdir)
end

% csv header
csv_header=sprintf('%s,%s,%s,%s,%s,%s\n', ...
    'dataset', ...
    'similarity score (top 5%)', ...
    'similarity score (Q1)', ... 
    'similarity score (median)', ...
    'similarity score (Q3)', ...
    'similarity score (top 95%)');

csvfile=fullfile(csvdir,sprintf('%s_vs_all_repertoire_comparison.csv',strrep(repertoireA,'.mat','')));
fid = fopen(csvfile,'wt');
fwrite(fid, csv_header);

% figure
set(guihandle, 'HandleVisibility', 'off');
close all;
set(guihandle, 'HandleVisibility', 'on');
screenSize=get(0,'ScreenSize');
defaultFigPos=get(0,'DefaultFigurePosition');
basesunits=cell(length(repertoireNames),1);
basesactivations=cell(length(repertoireNames),1);
basesnames=cell(length(repertoireNames),1);
for repertoireID = 1:length(repertoireNames)
    
    repertoire_filename = fullfile(repertoiredir,repertoireNames{repertoireID});    
    [~, repertoirename]=fileparts(repertoire_filename);

    if ~exist(repertoire_filename)
        fprintf('Repertoire of data set does not exist. Build the repertoire.\n');
    else
        load(repertoire_filename,'bases','activations','NbUnits','NbChannels','NbPatternFrames');
    end
    basesunits{repertoireID}=bases;
    basesactivations{repertoireID}=activations;
    basesnames{repertoireID}=strrep(repertoirename,'_',' ');
    
end

ndx_A=find(strcmp(repertoireNames,repertoireA));
ndx_comparing=find(~strcmp(repertoireNames,repertoireA));
filename_A=basesnames(ndx_A);
filenames_comparingrepertoire=basesnames(ndx_comparing);
sim_scores=[];
sim_scores_highact=[]; 
diag_scores=[];
for repertoireID = 1:length(ndx_comparing)
    [mssim, mssim_diag , similarity_score_mean, similarity_score_highactivity, diag_score ] = ...
        repertoire_comparison(basesunits{ndx_A}, basesactivations{ndx_A}, basesunits{ndx_comparing(repertoireID)}, basesactivations{ndx_comparing(repertoireID)} );
    sim_scores = [sim_scores; similarity_score_mean];
    sim_scores_highact = [sim_scores_highact; similarity_score_highactivity];
    diag_scores = [diag_scores; diag_score'];
end

% figure
figure('Position',[defaultFigPos(1) 0.90*screenSize(4)-defaultFigPos(4) defaultFigPos(3)*(1+fix(length(ndx_comparing)/16)) defaultFigPos(4)]);
minY=0.65;
maxY=1.0;
rec_width=.2;
load('util/cmap.mat');
colormap(cmap2);
barcolors=cmap2([1:floor(size(cmap2,1)/size(sim_scores_highact,1)):size(cmap2,1)],:);
for barID=1:size(sim_scores_highact,1)
   bwqs = sim_scores_highact(barID, 4);
   bwq = sim_scores_highact(barID, 2) - sim_scores_highact(barID, 4);
   bwmin = sim_scores_highact(barID, 5);
   minY = min(minY,bwmin-0.025);
   bwmax = sim_scores_highact(barID, 1);
   bwcnt = sim_scores_highact(barID, 3);
   rectangle('Position',[barID-rec_width/2 bwqs rec_width bwq],'FaceColor',barcolors(barID,:)); hold on;
   plot([barID], [bwmin], '+', 'MarkerEdgeColor','k', 'MarkerFaceColor','k'); 
   plot([barID], [bwmax], '*', 'MarkerEdgeColor','k', 'MarkerFaceColor','w'); 
   plot([barID-rec_width barID+rec_width], [bwcnt bwcnt], 'k', 'LineWidth', 2); 
   % print comparison information
   dataset_info=sprintf('%s,%.2f,%.2f,%.2f,%.2f,%.2f\n', ...
     strrep(filenames_comparingrepertoire{barID},' ','_'), ...
     sim_scores_highact(barID, 1), ...
     sim_scores_highact(barID, 2), ...
     sim_scores_highact(barID, 3), ...
     sim_scores_highact(barID, 4), ...
     sim_scores_highact(barID, 5));
   fwrite(fid, dataset_info);
end
grid on
set(gca, 'Box', 'off', 'TickDir','out')
ylim([minY maxY]);
axis('square');
set(gca,'xtick',[1:length(filenames_comparingrepertoire)]);
set(gca,'XTickLabel',filenames_comparingrepertoire);
set(gca,'ytick',[0:0.1:maxY]);
set(gca,'yTickLabel',[0:0.1:maxY]);
ylabel('Similarity score (%)', 'FontSize',handles.FontSize1);
title(filename_A,'FontSize',handles.FontSize1, 'FontWeight','bold');
set(gca, 'FontSize',handles.FontSize2);
hold off
axvals=axis; text(axvals(1)+(axvals(2)-axvals(1))/2,axvals(3)+(axvals(4)-axvals(3))/2,{'MUPET version 1.0', '(unreleased)'},'Color',[0.9 0.9 0.9],'FontSize',handles.FontSize1+10,'HorizontalAlignment','center','Rotation',45);


% ------------------------------------------------------------------------
% Copyright (C) 2015 University of Southern California, SAIL, U.S.
% Author: Maarten Van Segbroeck
% Mail: maarten@sipi.usc.edu
% Date: 2015-20-1
% ------------------------------------------------------------------------

function compare_A_against_B(handles,repertoireNames) 

guihandle=handles.output;
repertoiredir=handles.repertoiredir;

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

[mssim, mssim_diag , similarity_score_mean, sim_scores_highact, diag_score ] = ...
    repertoire_comparison(basesunits{1}, basesactivations{1}, basesunits{2}, basesactivations{2} );

% figure
figure('Position',[defaultFigPos(1) 0.90*screenSize(4)-defaultFigPos(4) defaultFigPos(3)*2 defaultFigPos(4)]);
load('util/cmap.mat');
colormap(cmap2);
barcolors=cmap2([1:floor(size(cmap2,1)/size(sim_scores_highact,1)):size(cmap2,1)],:);
subplot 121;
mssim_diag_show=mssim_diag{6};
imagesc(mssim_diag_show,[.0 1]);
colormap(cmap2);
axis('square');
set(gca,'XTick',[0:NbUnits/5:NbUnits]) % frequency
set(gca,'XTickLabel',[0:NbUnits/5:NbUnits]) % frequency
set(gca,'YTick',[0:NbUnits/5:NbUnits]) % frequency
set(gca,'YTickLabel',[0:NbUnits/5:NbUnits]) % frequency
ylabel(sprintf('Repertoire %s', basesnames{1}),'FontSize',handles.FontSize1,'FontWeight','bold');
xlabel(sprintf('Repertoire %s', basesnames{2}),'FontSize',handles.FontSize1,'FontWeight','bold');
set(gca, 'FontSize',handles.FontSize2);
hcb=colorbar;
set(get(hcb,'Title'),'String','Pearson''s correlation','FontSize',handles.FontSize2);
axvals=axis; text(axvals(1)+(axvals(2)-axvals(1))/2,axvals(3)+(axvals(4)-axvals(3))/2,{'MUPET version 1.0', '(unreleased)'},'Color',[0.5 0.5 0.5],'FontSize',handles.FontSize1+10,'HorizontalAlignment','center','Rotation',45);


subplot 122;
minY=0.65;
maxY=1.0;
rec_width=.2;
bwqs = sim_scores_highact(4);
bwq = sim_scores_highact(2) - sim_scores_highact(4);
bwmin = sim_scores_highact(5);
bwmax = sim_scores_highact(1);
bwcnt = sim_scores_highact(3);
rectangle('Position',[1-rec_width/2 bwqs rec_width bwq],'FaceColor',barcolors(1,:)); hold on;
set(gca,'xtick',1);
plot([1], [bwmin], '+', 'MarkerEdgeColor','k', 'MarkerFaceColor','k'); 
plot([1], [bwmax], '*', 'MarkerEdgeColor','k', 'MarkerFaceColor','w'); 
plot([1-rec_width 1+rec_width], [bwcnt bwcnt], 'k', 'LineWidth', 2); 
xlim([1-20*rec_width 1+20*rec_width]);
ylim([min(minY,bwmin) maxY]);
grid on
set(gca, 'Box', 'off', 'TickDir','out');
set(gca,'ytick',[minY:0.05:maxY]);
yticklbl=arrayfun(@num2str, [minY:0.05:maxY], 'UniformOutput', false);
set(gca,'yTickLabel',yticklbl);
ylabel('Similarity score (%)', 'FontSize',handles.FontSize1);
title(sprintf('%s repertoire',strtrim(regexprep(basesnames{1},'[_([{}()=''.(),;:%{%}!@])]',' '))),'FontSize',handles.FontSize1, 'FontWeight','bold');
set(gca, 'FontSize',handles.FontSize2);
set(gca,'XTickLabel',strtrim(regexprep(basesnames{2},'[_([{}()=''.(),;:%{%}!@])]',' ')),'FontSize',handles.FontSize1);
%set(gca, 'Color', 'none');
hold off
axvals=axis; text(axvals(1)+(axvals(2)-axvals(1))/2,axvals(3)+(axvals(4)-axvals(3))/2,{'MUPET version 1.0', '(unreleased)'},'Color',[0.9 0.9 0.9],'FontSize',handles.FontSize1+10,'HorizontalAlignment','center','Rotation',45);


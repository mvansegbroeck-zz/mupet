% ------------------------------------------------------------------------
% Copyright (C) 2015 University of Southern California, SAIL, U.S.
% Author: Maarten Van Segbroeck
% Mail: maarten@sipi.usc.edu
% Date: 2015-20-1
% ------------------------------------------------------------------------

function compare_A_against_all_repertoires_match(handles,repertoireNames,repertoireA) 

guihandle=handles.output;
repertoiredir=handles.repertoiredir;

% figure
set(guihandle, 'HandleVisibility', 'off');
close all;
set(guihandle, 'HandleVisibility', 'on');
screenSize=get(0,'ScreenSize');
defaultFigPos=get(0,'DefaultFigurePosition');

cnt=0;

for repertoireID = 1:length(repertoireNames)
    
    if strcmp(repertoireA,repertoireNames{repertoireID})
       continue;
    end
    cnt=cnt+1;
    
    repertoirePairNames={repertoireA,repertoireNames{repertoireID}};
    basesunits=cell(length(repertoirePairNames),1);
    basesactivations=cell(length(repertoirePairNames),1);
    basesnames=cell(length(repertoirePairNames),1);
    for repertoirePairID = 1:length(repertoirePairNames)

        repertoire_filename = fullfile(repertoiredir,repertoirePairNames{repertoirePairID});    
        [~, repertoirename]=fileparts(repertoire_filename);

        if ~exist(repertoire_filename)
            fprintf('Repertoire of data set does not exist. Build the repertoire.\n');
        else
            load(repertoire_filename,'bases','activations','NbUnits','NbChannels','NbPatternFrames');
        end
        basesunits{repertoirePairID}=bases;
        basesactivations{repertoirePairID}=activations;
        basesnames{repertoirePairID}=strrep(repertoirename,'_',' ');

    end

    [mssim, mssim_diag , similarity_score_mean, sim_scores_highact, diag_score, ndx_permutation ] = ...
        repertoire_comparison(basesunits{1}, basesactivations{1}, basesunits{2}, basesactivations{2} );

    % figure
    figure('Position',[defaultFigPos(1)+(cnt-1) 0.90*screenSize(4)-defaultFigPos(4)-(cnt-1) defaultFigPos(3)*3 defaultFigPos(4)*1]);

    subplot(1,3,2:3);
    linebases=basesunits{1};
    [number_of_calls]=hist(basesactivations{1}',NbUnits);
    % permutate
    linebases=linebases(ndx_permutation);
    number_of_calls=number_of_calls(ndx_permutation);
    
    NbRows=5;
    NbCols=floor(NbUnits/NbRows);
    linebases_mat=zeros(NbChannels*NbRows,(NbPatternFrames+1)*NbCols);
    for kk=1:NbRows
    for ll=1:NbCols
      base_unit_normalized = linebases{(NbRows-kk)*NbCols+ll}./max(max(linebases{(NbRows-kk)*NbCols+ll}));
      linebases_mat((kk-1)*NbChannels+1:kk*NbChannels,(ll-1)*(NbPatternFrames+1)+1:ll*(NbPatternFrames+1))=base_unit_normalized;
    end
    end
    hsubplot(2)=imagesc(linebases_mat,[0 0.85]); axis xy; hold on;
    for kk=1:NbCols-1
    plot([(NbPatternFrames+1)*kk+1,(NbPatternFrames+1)*kk+1],[1 NbRows*NbChannels],'Color',[0.2 0.2 0.2],'LineWidth',1);
    end
    for kk=1:NbRows-1
    plot([1 size(linebases_mat,2)],[kk*NbChannels+1 kk*NbChannels+1 ],'Color',[0.2 0.2 0.2],'LineWidth',1);
    end
    cnt=0;
    offset1=6;
    offset2=28;
    for kk=NbRows-1:-1:0
      for jj=0:NbCols-1
          cnt=cnt+1;
          text(offset1+jj*(NbPatternFrames+1),(kk+1)*NbChannels-10,num2str(cnt),'Color','k','FontSize',handles.FontSize2,'fontweight','bold');
          text((jj+1)*(NbPatternFrames+1)-offset2,(kk+1)*NbChannels-10,sprintf('%i',number_of_calls(cnt)),'Color','b','FontSize',handles.FontSize2,'fontweight','normal');
      end
    end
    set(gcf, 'Color', 'w');
    set(gca,'XTick',[]);
    set(gca,'YTick',[]);
    ylabel('Gammatone channels','FontSize',handles.FontSize1);
    colormap pink; colormap(flipud(colormap));

    title(sprintf('Syllable repertoire: %s',strtrim(regexprep(basesnames{1},'[_([{}()=''.(),;:%{%}!@])]',' '))),'FontSize',handles.FontSize1,'fontweight','bold');
    set(gca, 'looseinset', get(gca, 'tightinset'));
    hold off;

    xlabel('Frames','FontSize',handles.FontSize1);
    set(gca, 'FontSize',handles.FontSize2);
    freezeColors;
    
    subplot(1,3,1);
    load('util/cmap.mat');
    colormap(cmap2);
    cmap_sim=cmap2;
    barcolors=cmap2([1:floor(size(cmap2,1)/size(sim_scores_highact,1)):size(cmap2,1)],:);
    mssim_diag_show=mssim_diag{6};
    hsubplot(1)=imagesc(mssim_diag_show,[.0 1]);
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
    
end

% compare_repertoires_activity
function compare_repertoires_activity(handles,repertoireNames,repertoireA)

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

    % csv header detailed
    csv_header_detailed=sprintf('%s','dataset');
    for percID=1:100
        csv_header_detailed=sprintf('%s',csv_header_detailed,sprintf('%s',sprintf(',%i%% PCTL',percID)));
    end
    csv_header_detailed=sprintf('%s\n',csv_header_detailed);
    csvfile_detailed=fullfile(csvdir,sprintf('%s_vs_all_repertoire_comparison_detailed.csv',strrep(repertoireA,'.mat','')));
    fid_detailed = fopen(csvfile_detailed,'wt');
    fwrite(fid_detailed, csv_header_detailed);

    % figure
    set(guihandle, 'HandleVisibility', 'off');
    %close all;
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
    sim_scores_highact_detailed=[];
    diag_scores=[];
    for repertoireID = 1:length(ndx_comparing)
        [mssim, mssim_diag , similarity_score_mean, similarity_score_highactivity, diag_score, ~, ~, similarity_score_highactivity_detailed ] = ...
            repertoire_comparison(basesunits{ndx_A}, basesactivations{ndx_A}, basesunits{ndx_comparing(repertoireID)}, basesactivations{ndx_comparing(repertoireID)} );
        sim_scores = [sim_scores; similarity_score_mean];
        sim_scores_highact = [sim_scores_highact; similarity_score_highactivity];
        sim_scores_highact_detailed = [sim_scores_highact_detailed; similarity_score_highactivity_detailed];
        diag_scores = [diag_scores; diag_score'];
    end

    % figure
    figure('Position',[defaultFigPos(1) 0.90*screenSize(4)-defaultFigPos(4) defaultFigPos(3)*(1+fix(length(ndx_comparing)/16)) defaultFigPos(4)]);
    minY=0.65;
    maxY=1.0;
    rec_width=.2;
    colormap_mupet=load_colormap;
    colormap(colormap_mupet);
    barcolors=colormap_mupet([1:floor(size(colormap_mupet,1)/size(sim_scores_highact,1)):size(colormap_mupet,1)],:);
    barcolors=0.5*ones(size(barcolors));
    bwqs=cell(1,size(sim_scores_highact,1));
    bwq=cell(1,size(sim_scores_highact,1));
    bwmin=cell(1,size(sim_scores_highact,1));
    bwmax=cell(1,size(sim_scores_highact,1));
    bwcnt=cell(1,size(sim_scores_highact,1));
    for barID=1:size(sim_scores_highact,1)
       bwqs{barID} = min(sim_scores_highact(barID, 4),sim_scores_highact(barID, 2));
       bwq{barID} = abs(sim_scores_highact(barID, 2) - sim_scores_highact(barID, 4));
       bwmin{barID} = sim_scores_highact(barID, 5);
       minY = min(minY,bwmin{barID}-0.025);
       bwmax{barID} = sim_scores_highact(barID, 1);
       bwcnt{barID} = sim_scores_highact(barID, 3);
       % print comparison information
       dataset_info=sprintf('%s,%.2f,%.2f,%.2f,%.2f,%.2f\n', ...
         strrep(filenames_comparingrepertoire{barID},' ','_'), ...
         sim_scores_highact(barID, 1), ...
         sim_scores_highact(barID, 2), ...
         sim_scores_highact(barID, 3), ...
         sim_scores_highact(barID, 4), ...
         sim_scores_highact(barID, 5));
       fwrite(fid, dataset_info);

       % print detailed comparison information
       dataset_info_detailed=sprintf('%s',strrep(filenames_comparingrepertoire{barID},' ','_'));
       fwrite(fid_detailed, dataset_info_detailed);
       for percID=1:100
           dataset_info_detailed=sprintf(',%.2f',sim_scores_highact_detailed(barID, percID));
           fwrite(fid_detailed, dataset_info_detailed);
       end
       fwrite(fid_detailed, sprintf('\n',''));

    end

    [~,ndx_sort]=sort(cell2mat(bwcnt),'descend');
    filenames_comparingrepertoire=filenames_comparingrepertoire(ndx_sort);
    for ndx=1:size(sim_scores_highact,1)
        barID = ndx_sort(ndx);
        rectangle('Position',[ndx-rec_width/2 bwqs{barID} rec_width bwq{barID}],'FaceColor',barcolors(barID,:)); hold on;
        plot([ndx], [bwmin{barID}], '+', 'MarkerEdgeColor','k', 'MarkerFaceColor','k');
        plot([ndx], [bwmax{barID}], '*', 'MarkerEdgeColor','k', 'MarkerFaceColor','w');
        plot([ndx-rec_width ndx+rec_width], [bwcnt{barID} bwcnt{barID}], 'k', 'LineWidth', 2);
    end
    grid on
    set(gca, 'Box', 'off', 'TickDir','out')
    ylim([minY maxY]);
    xlim([0.5 size(sim_scores_highact,1)+.5]);
%     axis('square');
    set(gca,'xtick',[1:length(filenames_comparingrepertoire)]);
    set(gca,'XTickLabel',filenames_comparingrepertoire);
    set(gca,'ytick',[0:0.1:maxY]);
    set(gca,'yTickLabel',[0:0.1:maxY]);
    ylabel('Similarity score (%)', 'FontSize',handles.FontSize1);
    title(filename_A,'FontSize',handles.FontSize1, 'FontWeight','bold');
    set(gca, 'FontSize',handles.FontSize2);
    hold off
    % text(axvals(1)+(axvals(2)-axvals(1))/2,axvals(3)+(axvals(4)-axvals(3))/2,{'MUPET version 1.0', '(unreleased)'},'Color',[0.9 0.9 0.9],'FontSize',handles.FontSize1+10,'HorizontalAlignment','center','Rotation',45);

end

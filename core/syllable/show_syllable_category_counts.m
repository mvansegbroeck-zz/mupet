% show_syllable_category_counts
function show_syllable_category_counts(handles,repertoireNames,NbCategories)

    guihandle=handles.output;

    csvdir=fullfile(handles.repertoiredir,'CSV');
    if ~exist(csvdir)
      mkdir(csvdir)
    end

    % csv header
    csv_header=sprintf('%s,%s,%s,%s,%s\n', ...
        'repertoire unit (RU) cluster', ...
        'number of RUs', ...
        'RU-to-centroid correlation (mean)', ...
        'RU-to-centroid correlation (std)', ...
        'total number of syllables');

    %figure
    set(guihandle, 'HandleVisibility', 'off');
    close all;
    set(guihandle, 'HandleVisibility', 'on');
    screenSize=get(0,'ScreenSize');
    defaultFigPos=get(0,'DefaultFigurePosition');
    basesunits=[];
    basesactivations=cell(length(repertoireNames),1);
    basesmap=cell(length(repertoireNames),1);

    for repertoireID = 1:length(repertoireNames)

        repertoire_filename = fullfile(handles.repertoiredir,repertoireNames{repertoireID});

        if ~exist(repertoire_filename)
            fprintf('Repertoire of data set does not exist. Build the repertoire.\n');
        else
            load(repertoire_filename,'bases','activations','NbUnits','NbChannels','NbPatternFrames');
        end
        basesmap{repertoireID}=[length(basesunits)+1:length(basesunits)+length(bases)];
        basesunits=[basesunits; bases];
        basesactivations{repertoireID}=activations;

    end

    %
    figure('Position',[defaultFigPos(1) 0.90*screenSize(4)-defaultFigPos(4) defaultFigPos(3)*(1+fix(NbCategories/40)) defaultFigPos(4)]);
    V=zeros(NbChannels*(NbPatternFrames+1), length(basesunits));
    for k=1:length(basesunits)
      V(:,k)=reshape(basesunits{k}, NbChannels*(NbPatternFrames+1), 1);
    end

    % meta clustering
    [W,J]=kmedoids(V, NbCategories);

    syllable_category_correlation=zeros(length(repertoireNames),2,NbCategories);
    nb_of_repertoire_units=zeros(NbCategories,length(repertoireNames));
    for repertoireID = 1:length(repertoireNames)

        d_repertoire=V(:,basesmap{repertoireID});
        J_repertoire=J(basesmap{repertoireID});
        for categoryID=1:NbCategories
            s = J_repertoire==categoryID;
            nb_of_repertoire_units(categoryID,repertoireID) = sum(s);
            if nb_of_repertoire_units(categoryID,repertoireID) == 0
                syllable_category_correlation(repertoireID,1,categoryID) = 0;
                syllable_category_correlation(repertoireID,2,categoryID) = 0;
            else
                measure_corr = corr(d_repertoire(:,s),W(:,categoryID));
                syllable_category_correlation(repertoireID,1,categoryID) = mean(measure_corr);
                syllable_category_correlation(repertoireID,2,categoryID) = std(measure_corr);
            end
        end
    end

    % prepare outputs
    linebases=cell(NbCategories,1);
    for kk=1:NbCategories
        linebases{kk} = reshape(W(1:NbChannels*(NbPatternFrames+1),kk),NbChannels,(NbPatternFrames+1));
    end

    NbRows=5;
    NbCols=floor(NbCategories/NbRows);
    linebases_mat=zeros(NbChannels*NbRows,(NbPatternFrames+1)*NbCols);
    for kk=1:NbRows
      for ll=1:NbCols
        base_unit_normalized = linebases{(NbRows-kk)*NbCols+ll}./max(max(linebases{(NbRows-kk)*NbCols+ll}));
        linebases_mat((kk-1)*NbChannels+1:kk*NbChannels,(ll-1)*(NbPatternFrames+1)+1:ll*(NbPatternFrames+1))=base_unit_normalized;
      end
    end
    imagesc(linebases_mat,[0 0.85]); axis xy; hold on;
    for kk=1:NbCols-1
      plot([(NbPatternFrames+1)*kk+1,(NbPatternFrames+1)*kk+1],[1 NbRows*NbChannels],'Color',[0.2 0.2 0.2],'LineWidth',1);
    end
    for kk=1:NbRows-1
      plot([1 size(linebases_mat,2)],[kk*NbChannels+1 kk*NbChannels+1 ],'Color',[0.2 0.2 0.2],'LineWidth',1);
    end
    cnt=0;
    for kk=NbRows-1:-1:0
        for jj=0:NbCols-1
            cnt=cnt+1;
            text(floor(0.05*NbPatternFrames)+jj*(NbPatternFrames+1),(kk+1)*NbChannels-10,num2str(cnt),'Color','k','FontSize',handles.FontSize2,'fontweight','normal');
        end
    end
    set(gcf, 'Color', 'w');
    set(gca,'XTick',[]);
    set(gca,'YTick',[]);
    % ylabel('Gammatone channels','FontSize',handles.FontSize1);
    colormap pink; colormap(flipud(colormap));
    title(sprintf('Meta USV syllable repertoire'),'FontSize',handles.FontSize1,'fontweight','bold');
    hold off;
    set(gca, 'looseinset', get(gca, 'tightinset'));

    % figure
    xtickunits=2;
    colormap_mupet=load_colormap;
    activation_pie=zeros(NbCategories,length(repertoireNames));
    nb_of_calls_pie=zeros(NbCategories,length(repertoireNames));
    for repertoireID = 1:length(repertoireNames)

        lineactivity=basesactivations{repertoireID};
        Jline=J((repertoireID-1)*NbUnits+1:repertoireID*NbUnits);
        lineactivity_mapped=Jline(lineactivity);
        for k=1:NbCategories
          activation_pie(k,repertoireID)=sum(lineactivity_mapped==k);
        end
        nb_of_calls_pie(:,repertoireID)=activation_pie(:,repertoireID);
        activation_pie(:,repertoireID)=100*activation_pie(:,repertoireID)./sum(activation_pie(:,repertoireID));
    end

    for repertoireID = 1:length(repertoireNames)

        figure('Position',[defaultFigPos(1)+(repertoireID)*25 0.90*screenSize(4)-defaultFigPos(4)-(repertoireID)*25 defaultFigPos(3) defaultFigPos(4)]);

        % pie diagram
        h=bar(nb_of_calls_pie(:,repertoireID)',1,'grouped');
        bar_child=get(h,'Children');
        colormap(colormap_mupet);
        %set(bar_child,'CData',max(log(activation_pie(:,repertoireID)'),0));
        set(bar_child,'CData',max(log(min(activation_pie(:,repertoireID),25)'),0));
        set(gca,'XTick',[0:xtickunits:NbCategories]);
        xlim([.5 NbCategories+.5]);
        %ylim([0 40]);
        set(gca,'XGrid','off','YGrid','on','XMinorGrid','off');
        set(gca, 'Box', 'off', 'TickDir','out')
        repertoireName=strtrim(regexprep(strrep(repertoireNames{repertoireID},'.mat',''),'[_([{}()=''.(),;:%{%}!@])]',' '));
        title(sprintf('%s',strrep(repertoireName,'_',' ')),'FontSize',handles.FontSize1,'fontweight','bold');
        set(gca, 'FontSize',handles.FontSize2);
        set(gca, 'looseinset', get(gca, 'tightinset'));
    %     ylabel('Activity counts (%%)','FontSize',handles.FontSize1);
        ylabel('Number of syllables','FontSize',handles.FontSize1);
        xlabel('Repertoire units (RUs)','FontSize',handles.FontSize1);
        axis('square')

        % CSV
        csvfile=fullfile(csvdir, sprintf('%s_RU_cluster_counts_of_%i.csv',strrep(repertoireNames{repertoireID},'.mat',''),NbCategories));
        fid = fopen(csvfile,'wt');
        fwrite(fid, csv_header);
        for categoryID = 1:NbCategories
            % print category information
            syl_cat_cor_mn = syllable_category_correlation(repertoireID,1,categoryID);
            syl_cat_cor_st = syllable_category_correlation(repertoireID,2,categoryID);
            if syl_cat_cor_mn == 0 && syl_cat_cor_st == 0
                syl_cat_cor_mn_str = '-';
                syl_cat_cor_st_str = '-';
            elseif syl_cat_cor_st == 0;
                if abs(syl_cat_cor_mn - 1 ) < 1e-10 % not exactly 1
                    syl_cat_cor_mn_str = sprintf('%.0f',syl_cat_cor_mn);
                else
                    syl_cat_cor_mn_str = sprintf('%.4f',syl_cat_cor_mn);
                end
                syl_cat_cor_st_str = sprintf('%i',syl_cat_cor_st);
            else
                syl_cat_cor_mn_str = sprintf('%.4f',syl_cat_cor_mn);
                syl_cat_cor_st_str = sprintf('%.4f',syl_cat_cor_st);
            end

            category_info=sprintf('%i,%i,%s,%s,%i\n', ...
                categoryID, ...
                nb_of_repertoire_units(categoryID,repertoireID), ...
                syl_cat_cor_mn_str, ...
                syl_cat_cor_st_str, ...
                nb_of_calls_pie(categoryID,repertoireID));
            fwrite(fid, category_info);
        end
        fclose(fid);
    end
end
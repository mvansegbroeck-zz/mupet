% show_syllable_counts
function show_syllable_counts(handles)

    datasetNames=dir(fullfile(handles.datasetdir,'*.mat'));
    strrep(datasetNames(end).name,':','/');
    if isempty(datasetNames)
        errordlg('Please create a dataset first.','No dataset created');
        return;
    end

    guihandle=handles.output;
    datasetdir=handles.datasetdir;

    % figure
    set(guihandle, 'HandleVisibility', 'off');
    %close all;
    set(guihandle, 'HandleVisibility', 'on');
    screenSize=get(0,'ScreenSize');
    defaultFigPos=get(0,'DefaultFigurePosition');
    figure('Position',[defaultFigPos(1) 0.90*screenSize(4)-defaultFigPos(4) defaultFigPos(3) defaultFigPos(4)]);
    syl_count_tot=[];
    syllable_count_plot_margin=1;
    g1=[];
    colormap_mupet=load_colormap;
    colormap(colormap_mupet);
    barcolors=colormap_mupet([1:floor(size(colormap_mupet,1)/length(datasetNames)):size(colormap_mupet,1)-1],:);
    barcolors=flipud(barcolors);
    barcolors=0.5*ones(size(barcolors));
    datasetnames=cell(1,length(datasetNames));
    syl_count=cell(1,length(datasetNames));
    syl_count_mean=cell(1,length(datasetNames));

    for datasetID = 1:length(datasetNames)

        dataset_filename = fullfile(datasetdir,datasetNames(datasetID).name);
        [~, datasetnames{datasetID}]=fileparts(dataset_filename);
        datasetnames{datasetID}=strtrim(regexprep(datasetnames{datasetID},'[_([{}()=''.(),;%{%}!@])]',' '));
        datasetnames{datasetID}=strtrim(regexprep(datasetnames{datasetID},':','/'));

        if isempty(whos('-file',dataset_filename,'dataset_stats'))
            fprintf('Data set stats does not exist. Recreate data set.\n');
        else
            load(dataset_filename,'dataset_stats','fs');
        end

        % accumulating stats
        syl_count{datasetID}=dataset_stats.syllable_count_per_second(dataset_stats.syllable_count_per_second>0);
        syl_count_mean{datasetID}=median(syl_count{datasetID});

    end

    % sorting
    [~,ndx_sort]=sort(cell2mat(syl_count_mean),'ascend');
    datasetnames=datasetnames(ndx_sort);
    barcolors=barcolors(flipud(ndx_sort),:);

    for ndx = 1:length(datasetNames)
        datasetID=ndx_sort(ndx);
        syl_count_tot=[syl_count_tot; syl_count{datasetID}];
        g1=[g1; ndx*ones(size(syl_count{datasetID}))];
    end

    % set(gcf,'Position', [50 250 3*175 1.25*175])
    h=boxplot(syl_count_tot,g1,'widths',.25,'whisker',.5,'orientation', 'horizontal'); hold on;
    set(h(7,:),'Visible','off')
    lower_whisker_obj=findobj(gca,'Tag','Lower Whisker');
    lower_whisker=min(min(cell2mat(get(lower_whisker_obj,'XData'))));
    upper_whisker_obj=findobj(gca,'Tag','Upper Whisker');
    upper_whisker=max(max(cell2mat(get(upper_whisker_obj,'XData'))));
    xlim1=max(lower_whisker-syllable_count_plot_margin,0);
    xlim2=upper_whisker+syllable_count_plot_margin;
    h = findobj(gca,'Tag','Box');
    for j=1:length(h)
       patch(get(h(j),'XData'),get(h(j),'YData'),barcolors(j,:));
    end
    for j=1:length(h)
       medianval=median(syl_count_tot(g1==j));
       plot( [medianval medianval], [j-0.25 j+.25],'k','LineWidth',2);
    end
    hold off
    set(gca, 'Box', 'off', 'TickDir','out')
    grid on;
    xlabel('Syllables / second', 'FontSize',handles.FontSize1);
    xlim([xlim1 xlim2]);
    set(gca,'ytick',[1:length(lines)]);
    set(gca,'yticklabel',datasetnames);
    set(gca, 'FontSize',handles.FontSize2);
    title('Syllable counts per second','FontSize',handles.FontSize1, 'FontWeight','bold');
    axvals=axis;
    % text(axvals(2)/2,axvals(4)/2,{'MUPET version 1.0', '(unreleased)'},'Color',[0.9 0.9 0.9],'FontSize',handles.FontSize1+10,'HorizontalAlignment','center','Rotation',45);

end
% show_vocalization_time
function show_vocalization_time(handles)

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
    close all;
    set(guihandle, 'HandleVisibility', 'on');
    screenSize=get(0,'ScreenSize');
    defaultFigPos=get(0,'DefaultFigurePosition');
    figure('Position',[defaultFigPos(1) 0.90*screenSize(4)-defaultFigPos(4) defaultFigPos(3) defaultFigPos(4)]);
    syllable_activity_threshold=0.005;
    muYtot=[];
    colormap_mupet=load_colormap;
    colormap(colormap_mupet);
    barcolors=colormap_mupet([1:floor(size(colormap_mupet,1)/length(datasetNames)):size(colormap_mupet,1)-1],:);
    barcolors=0.5*ones(size(barcolors));
    datasetnames=cell(1,length(datasetNames));

    %fprintf('\n');
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

        % figure
        syl_activity=dataset_stats.syllable_activity;
        syl_activity(syl_activity<syllable_activity_threshold)=[];
        muY=mean(syl_activity);
        varY=std(syl_activity);
        h=bar(datasetID, muY,0.5); hold on;
        errorbar(datasetID, muY, -varY, varY,'black')
        set(h, 'FaceColor',barcolors(datasetID,:),'LineWidth',1);
        muYtot=[muYtot; muY];
        %fprintf('%s %.2f%% \n', datasetnames{datasetID}, muY*100);

    end

    hold off
    grid on
    box off
    perc_max=1.25*max(muYtot);
    xlim([0.5 length(datasetnames)+.5]);
    set(gca,'XTick',[1:length(datasetnames)]) % frequency
    set(gca,'XTickLabel',datasetnames,'FontName','Helvetica','FontSize',handles.FontSize1);
    ylim([0 perc_max]);
    set(gca,'YTick',[0:perc_max/5:perc_max]) % frequency
    set(gca,'YTickLabel',fix([0:perc_max/5:perc_max]*1000)/10,'FontName','Helvetica','FontSize',handles.FontSize1) % frequency
    ylabel('Vocalization time (in %)','FontSize',handles.FontSize1);
    set(gca, 'FontSize',handles.FontSize2);
    axvals=axis;
    % text(axvals(2)/2,axvals(4)/2,{'MUPET version 1.0', '(unreleased)'},'Color',[0.9 0.9 0.9],'FontSize',handles.FontSize1+10,'HorizontalAlignment','center','Rotation',45);

end

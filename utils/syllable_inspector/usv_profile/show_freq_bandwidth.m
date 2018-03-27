% show_freq_bandwidth
function show_freq_bandwidth(handles)

    datasetNames=dir(fullfile(handles.datasetdir,'*.mat'));
    if isempty(datasetNames)
        errordlg('Please create a dataset first.','No dataset created');
        return;
    end

    guihandle=handles.output;
    datasetdir=handles.datasetdir;

    % FFT
    if ~exist('Nfft', 'var')
       Nfft=512;
    end

    % figure
    set(guihandle, 'HandleVisibility', 'off');
    close all;
    set(guihandle, 'HandleVisibility', 'on');
    screenSize=get(0,'ScreenSize');
    defaultFigPos=get(0,'DefaultFigurePosition');
    figure('Position',[defaultFigPos(1) 0.90*screenSize(4)-defaultFigPos(4) defaultFigPos(3) defaultFigPos(4)]);
    fstart=25000;
    fskip=25000;
    perc_quant=0.7;
    colormap_mupet=load_colormap;
    colormap(colormap_mupet);
    barcolors=colormap_mupet([1:floor(size(colormap_mupet,1)/length(datasetNames)):size(colormap_mupet,1)-1],:);
    barcolors=0.5*ones(size(barcolors));

    datasetnames=cell(1,length(datasetNames));
    datasetNames=flipud(datasetNames);

    bwmin=cell(length(datasetNames),1);
    bwmax=cell(length(datasetNames),1);
    muf=cell(length(datasetNames),1);
    bwqs=cell(length(datasetNames),1);
    bwq=cell(length(datasetNames),1);

    for datasetID = 1:length(datasetNames)

        dataset_filename = fullfile(datasetdir,datasetNames(datasetID).name);
        [~, datasetnames{datasetID}]=fileparts(dataset_filename);
        datasetnames{datasetID}=strtrim(regexprep(datasetnames{datasetID},'[_([{}()=''.(),;%{%}!@])]',' '));
        datasetnames{datasetID}=strtrim(regexprep(datasetnames{datasetID},':','/'));

        if isempty(whos('-file',dataset_filename,'psdn'))
            fprintf('PSD stats of data set does not exist. Recreate the data set.\n');
        else
            load(dataset_filename,'psdn','fs');
        end

        psdsum=sum(psdn);
        psdline=psdn./psdsum;
        [sigma,mu]=gaussfit(1:length(psdline), psdline, handles);
        psdcum=cumsum(psdn);
        bw=find(psdn./psdsum>.025*max(psdn./psdsum));
        bwmin{datasetID}=bw(1)*(fs/2)/Nfft;
        bwmax{datasetID}=bw(end)*(fs/2)/Nfft;
        psd_interval=perc_quant*psdcum(end);
        [~,maxk]=min(abs(psdcum-(psdcum(end)-psd_interval)));
        intervals=zeros(1,maxk);
        for k=1:maxk
        [~,tmp1]=min(abs(psdcum-(psdcum(k)+psd_interval)));
        intervals(k)=tmp1-k;
        end
        muf{datasetID} = mu/Nfft*fs/2;
        sigmaf = sigma/Nfft*fs/2;
        bwqs{datasetID}=muf{datasetID}-sigmaf;
        bwq{datasetID}=sigmaf*2;
    end
    rec_width=.3;
    % sorting
    [~,ndx_sort]=sort(cell2mat(muf),'descend');
    datasetnames=datasetnames(ndx_sort);
    barcolors=barcolors(ndx_sort,:);

    for ndx = 1:length(datasetNames)
        datasetID=ndx_sort(ndx);
        % figure
        axis([0 fs/2 .25 length(datasetNames)+.75])
        barID=length(datasetNames)-ndx+1;
        plot( [bwmin{datasetID} bwmax{datasetID}],[barID barID], 'k--');
        rectangle('Position',[bwqs{datasetID} barID-rec_width/2 bwq{datasetID} rec_width],'FaceColor',barcolors(barID,:)); hold on;
        plot([muf{datasetID} muf{datasetID}], [barID-rec_width barID+rec_width], 'k-', 'LineWidth', 2);

    end

    hold off
    grid on
    box off
    set(gca,'YTick',[1:length(datasetnames)]) % frequency
    set(gca,'YTickLabel',fliplr(datasetnames),'FontName','Helvetica','FontSize',handles.FontSize1);
    fmax=fs/2;
    set(gca,'XTick',[fstart:fskip:fmax]) % frequency
    set(gca,'XTickLabel',fix([fstart:fskip:fmax]/1000),'FontName','Helvetica','FontSize',handles.FontSize1) % frequency
    xlim([fstart/2 fmax]);
    xlabel('frequency (kHz)','FontSize',handles.FontSize3);
    title('Frequency bandwidth','FontSize',handles.FontSize1,'fontweight','bold');
    set(gca, 'FontSize',handles.FontSize2);
    % text(axvals(2)/2,axvals(4)/2,{'MUPET version 1.0', '(unreleased)'},'Color',[0.9 0.9 0.9],'FontSize',handles.FontSize1+10,'HorizontalAlignment','center','Rotation',45);

end
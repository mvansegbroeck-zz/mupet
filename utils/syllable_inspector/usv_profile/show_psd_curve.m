% show_psd_curve
function show_psd_curve(handles)

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
    fskip=25000;
    fstart=25000;
    barcolors={[1 102/256 102/256], [1 153/256 153/256], [0.5 0.5 0.5], [102/256 153/256 1] ,[153/256 204/256 1]};
    ylabelstring='PSD (normalized, 1e-2)';
    textoffset=0.2;

    for datasetID = 1:length(datasetNames)

        dataset_filename = fullfile(datasetdir,datasetNames(datasetID).name);
        [~, datasetname]=fileparts(dataset_filename);

        if isempty(whos('-file',dataset_filename,'psdn'))
            fprintf('PSD stats of data set does not exist. Recreate the data set.\n');
        else
            load(dataset_filename,'psdn','fs');
        end

        % FFT
        fmax=fs/2;
        nfftmax=fix(fmax*Nfft/(fs/2));
        nfftstart=fix(fstart*Nfft/(fs/2));
        nfftskip=fix(fskip*Nfft/(fs/2));

        % Gaussian fit line
        psdsum=sum(psdn);
        psdline=psdn./psdsum;
        [sigma,mu]=gaussfit(1:length(psdline), psdline, handles);
        gaussfitline=1/(sqrt(2*pi)*sigma)*exp( -([1:length(psdline)] - mu).^2 / (2*sigma^2));

        % plot figure
        figure('Position',[defaultFigPos(1)+(datasetID-1)*25 0.90*screenSize(4)-defaultFigPos(4)-(datasetID-1)*25 defaultFigPos(3) defaultFigPos(4)]);
        plot(100*gaussfitline,'LineWidth',2,'Color',barcolors{4});
        hold on;
        plot(100*psdline,'LineWidth',2,'Color','k'); axis tight;
        ylim([0 1.5]);
        xlim([0 Nfft]);
        set(gca,'XTick',[nfftstart:nfftskip:nfftmax]) % frequency
        set(gca,'XTickLabel',fix([fstart:fskip:fmax]/1000),'FontName','Helvetica','FontSize',handles.FontSize1) % frequency
        set(gca,'YTick',[0:0.5:2.5]) % frequency
        xlabel('frequency (kHz)','FontSize',handles.FontSize1);
        ylabel(ylabelstring,'FontSize',handles.FontSize1);
        axis('square');
        set(gcf, 'Color', 'w');
        title(sprintf('Data set: %s',strtrim(regexprep(datasetname,'[_([{}()=''.(),;%{%}!@])]',' '))),'FontSize',handles.FontSize1,'fontweight','bold');
        set(gca, 'FontSize',handles.FontSize2);
        box off; set(gca,'Color','none');
        muf = mu/Nfft*fs/2;
        sigmaf = sigma/Nfft*fs/2;
        text(2*160,1.3,sprintf('mean = %.1f kHz', muf/1e3),'Color','k','FontSize',handles.FontSize1,'fontweight','normal');
        text(2*160,1.3-2/3*textoffset,sprintf('STD = %.1f kHz', sigmaf/1e3),'Color','k','FontSize',handles.FontSize1,'fontweight','normal');
        line([muf*Nfft/(fs/2) muf*Nfft/(fs/2)],[0 100],'Color','r','LineStyle','--','LineWidth',1);
        axvals=axis;
        %text(axvals(2)/2,axvals(4)/2,{'MUPET version 1.0', '(unreleased)'},'Color',[0.9 0.9 0.9],'FontSize',handles.FontSize1+10,'HorizontalAlignment','center','Rotation',45);

    end

end
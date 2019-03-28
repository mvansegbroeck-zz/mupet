% export_csv_dataset_stats
function export_csv_dataset_stats(handles)

    datasetNames=dir(fullfile(handles.datasetdir,'*.mat'));
    if isempty(datasetNames)
        errordlg('Please create a dataset first.','No dataset created');
        return;
    end

    guihandle=handles.output;
    datasetdir=handles.datasetdir;

    csvdir=fullfile(datasetdir,'CSV');
    if ~exist(csvdir)
      mkdir(csvdir)
    end

    % FFT
    if ~exist('Nfft', 'var')
       Nfft=512;
    end
    
    fs = handles.config{7};

    % figure
    set(guihandle, 'HandleVisibility', 'off');
    % close all;
    set(guihandle, 'HandleVisibility', 'on');
    perc_quant=0.7;
    syllable_activity_threshold=0.005;
    barcolors={[1 102/256 102/256], [1 153/256 153/256], [0.5 0.5 0.5], [102/256 153/256 1] ,[153/256 204/256 1]};
    datasetnames=cell(1,length(datasetNames));

    % limit
    max_syl_dist_tot=200;
    max_syl_dur_tot=110;
    max_syl_count_tot=11;

    % csv header
    csv_header=sprintf('%s,%s (kHz),%s (kHz),%s (kHz),%s (counts),%s (counts),%s (counts),%s (msec),%s (msec),%s (msec),%s (msec),%s (msec),%s (msec),%s (counts),%s (sec),%s (sec)\n', ...
        'data set', ...
        'PSD mean', ...
        'PSD std', ...
        'frequency bandwidth', ...
        'syllables/second mean', ...
        'syllables/second median', ...
        'syllables/second std', ...
        'inter-syllable interval mean', ...
        'inter-syllable interval median', ...
        'inter-syllable interval std', ...
        'syllable duration mean', ...
        'syllable duration median', ...
        'syllable duration std', ...
        'total number of syllables', ...
        'total syllable activity', ...
        'total recording time');

    csvfile=fullfile(csvdir,sprintf('datasets_USV_profile_stats.csv'));
    fid = fopen(csvfile,'wt');
    fwrite(fid, csv_header);

    csv_header_psdn=sprintf('%s (kHz),%s\n', ...
        'frequency', ...
        'PSD (normalized)');

    for datasetID = 1:length(datasetNames)

        dataset_filename = fullfile(datasetdir,datasetNames(datasetID).name);
        [~, datasetnames{datasetID}]=fileparts(dataset_filename);

        if isempty(whos('-file',dataset_filename,'psdn'))
            fprintf('PSD stats of data set does not exist. Recreate the data set.\n');
        else
            load(dataset_filename,'psdn','fs');
        end
        if isempty(whos('-file',dataset_filename,'dataset_stats'))
            fprintf('Data set stats does not exist. Recreate data set.\n');
        else
            load(dataset_filename,'dataset_stats','fs');
        end

        % PSD stats
        psdsum=sum(psdn);
        psdline=psdn./psdsum;
        [sigma,mu]=gaussfit(1:length(psdline), psdline, handles);
        psdcum=cumsum(psdn);
        bw=find(psdn./psdsum>.025*max(psdn./psdsum));
        psd_interval=perc_quant*psdcum(end);
        [~,maxk]=min(abs(psdcum-(psdcum(end)-psd_interval)));
        intervals=zeros(1,maxk);
        for k=1:maxk
        [~,tmp1]=min(abs(psdcum-(psdcum(k)+psd_interval)));
        intervals(k)=tmp1-k;
        end
        muf = mu/Nfft*fs/2;
        sigmaf = sigma/Nfft*fs/2;
        bwq=sigmaf*2;

        % vocalization time
        syl_activity=dataset_stats.syllable_activity;
        syl_activity(syl_activity<syllable_activity_threshold)=[];
        muY=mean(syl_activity);
        stdY=std(syl_activity);

        % syllable stats
        dataset_stats.syllable_count_per_second(dataset_stats.syllable_count_per_second>max_syl_count_tot)=[];
        syl_count_mean=mean(dataset_stats.syllable_count_per_second(dataset_stats.syllable_count_per_second>0));
        syl_count_median=median(dataset_stats.syllable_count_per_second(dataset_stats.syllable_count_per_second>0));
        syl_count_std=std(dataset_stats.syllable_count_per_second(dataset_stats.syllable_count_per_second>0));
        dataset_stats.syllable_distance(dataset_stats.syllable_distance>max_syl_dist_tot)=[];
        syllable_dist_mean=mean(dataset_stats.syllable_distance);
        syllable_dist_median=median(dataset_stats.syllable_distance);
        syllable_dist_std=std(dataset_stats.syllable_distance);
        dataset_stats.syllable_dur(dataset_stats.syllable_dur>max_syl_dur_tot)=[];
        syllable_dur_mean=mean(dataset_stats.syllable_dur);
        syllable_dur_median=median(dataset_stats.syllable_dur);
        syllable_dur_std=std(dataset_stats.syllable_dur);

        fprintf('\nStatistics of dataset "%s"\n',datasetnames{datasetID});
        fprintf('  PSD curve:   %.2f kHz (mean), %.2f kHz (std)\n',(muf/1e3),(sigmaf/1e3));
        fprintf('  frequency bandwidth:   %.2f kHz\n',(bwq/1e3));
        fprintf('  syllables/second:   %.2f (mean),  %.2f (median), %.2f (std)\n',syl_count_mean,syl_count_median,syl_count_std);
        fprintf('  inter-syllable interval:   %.2f ms (mean), %.2f ms (median), %.2f ms (std)\n',syllable_dist_mean,syllable_dist_median,syllable_dist_std);
        fprintf('  syllable duration:   %.2f ms (mean), %.2f ms (median), %.2f ms (std)\n',syllable_dur_mean,syllable_dur_median,syllable_dur_std);
        fprintf('  total number of syllables:   %i\n',dataset_stats.nb_of_syllables);
        fprintf('  total syllable activity:   %.2f\n',dataset_stats.syllable_time);
        fprintf('  total recording time:   %.2f\n',dataset_stats.recording_time);

        dataset_info=sprintf('%s,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%i,%.2f,%.2f\n', ...
        datasetnames{datasetID}, ...
        (muf/1e3), ...
        (sigmaf/1e3), ...
        (bwq/1e3), ...
        syl_count_mean, ...
        syl_count_median, ...
        syl_count_std, ...
        syllable_dist_mean, ...
        syllable_dist_median, ...
        syllable_dist_std, ...
        syllable_dur_mean, ...
        syllable_dur_median, ...
        syllable_dur_std, ...
        dataset_stats.nb_of_syllables, ...
        dataset_stats.syllable_time, ...
        dataset_stats.recording_time);
        fwrite(fid, dataset_info);

        % export PSD values
        csvfile_psdn=fullfile(csvdir,sprintf('psd_stats_dataset_%s.csv', datasetnames{datasetID}));
        fid_psd = fopen(csvfile_psdn,'wt');
        fwrite(fid_psd, csv_header_psdn);
        nfft_max = size(psdn,1);
        khz=1;
        nfft_skip=1000*khz*nfft_max/(fs/2);
        % ensuring NFFT bins larger than requested frequency steps from 0
        % to fs/2
        while nfft_skip < 0
            khz=khz+1;
            nfft_skip=1000*khz*nfft_max/(fs/2);
        end
        for nfft_bin=nfft_skip:nfft_skip:nfft_max
            fwrite(fid_psd,sprintf('%.1f, %.6f\n',fix(nfft_bin/nfft_skip)*khz,psdn(fix(nfft_bin))));
        end
        fclose(fid_psd);
        
    end

    fclose(fid);
    msgbox(sprintf('***       All data sets stats exported to CSV files       ***\n See folder %s/CSV',handles.datasetdir),'MUPET info');

end

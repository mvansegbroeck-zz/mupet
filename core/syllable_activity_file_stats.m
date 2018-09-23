% syllable_activity_file_stats
function [syllable_data, syllable_stats, filestats, fs] = syllable_activity_file_stats(handles, audiofile, TotNbFrames, syllable_data, syllable_use, Nfft)

    if ~exist('Nfft', 'var')
        Nfft=512;
    end

    load_data=false;
    if ~exist('syllable_data', 'var')
        load_data=true;
    end

    if ~exist('syllable_use', 'var')
        syllable_use=[];
    end

    GTfloor=1e-1;
    %fs=250000;
    fs=handles.config{7};
    frame_shift=floor(handles.frame_shift_ms*fs);

    % load values from config file
    noise_reduction_sigma=handles.config{1};
    min_syllable_duration=handles.config{2};
    max_syllable_duration=handles.config{3};
    min_syllable_total_energy=handles.config{4};
    min_syllable_peak_amplitude=handles.config{5};
    filterbank_type=handles.config{11};
    number_filterbank_filters=handles.config{10};
    minimum_usv_frequency=handles.config{8};
    maximum_usv_frequency=handles.config{9};

    if filterbank_type == 0
        gtbands = gammatone_matrix_sigmoid(Nfft*2, fs, number_filterbank_filters);
    else
        gtbands = gammatone_matrix_linear(Nfft*2, fs, number_filterbank_filters, minimum_usv_frequency, maximum_usv_frequency);
    end
    gt2fftbands=cell(size(gtbands,1),1);
    for k=1:size(gtbands,1)
        gt2fftbands{k}=find(gtbands(k,:)>0.15);
        % prevent overlapping bands
        if k>1
            [~,fftbands_ndx_remove]=intersect(gt2fftbands{k},gt2fftbands{k-1});
            gt2fftbands{k}(fftbands_ndx_remove)=[];
        end
    end

    % load syllable data
    [~,filename]=fileparts(audiofile);
    if load_data
        gtdir=fullfile(handles.audiodir);
        GT_file=fullfile(gtdir, sprintf('%s.mat', filename));
        if exist(GT_file,'file'),
            load(GT_file,'syllable_data','syllable_stats','filestats');
            if isempty(syllable_data)
                fprintf('File %s not processed.\n', filename);
                return;
            end
            syllable_use=cell2mat(syllable_stats(1,:));
        else
            fprintf('File %s not processed.\n', filename);
            return
        end
    else
        if isempty(syllable_use)
            syllable_use=ones(1,length(syllable_data));
        end
    end
    fprintf('Updating stats of file %s.\n', filename);

    % start processing - ignore unused/refined syllables
    syllable_data=syllable_data(:,syllable_use==1);

    % compute time stamp information
    syllable_onset=cell2mat(syllable_data(5,:));
    syllable_offset=cell2mat(syllable_data(6,:));
    
    nb_of_syllables=size(syllable_data,2);
    syllable_stats=cell(14,nb_of_syllables);
    ndx_remove=zeros(1,nb_of_syllables);

    for k=1:nb_of_syllables

       syllable_stats{7,k}=0; % duration
       syllable_stats{13,k}=0; % duration
       syllable_stats{11,k}=min_syllable_total_energy; % mean energy
       syllable_stats{12,k}=min_syllable_peak_amplitude; % peak energy
       syllable_threshold=log(max(exp(syllable_data{2,k}),GTfloor));
       syllable_threshold=(syllable_threshold-syllable_data{9,k})>noise_reduction_sigma*syllable_data{8,k};

       syllable_threshold_timestamps=find(sum(syllable_threshold));
       if ~isempty(syllable_threshold_timestamps)

           syllable_stats{1,k}=1; % syllable use

           [~,gtmax]=max(syllable_threshold(:,syllable_threshold_timestamps(1)));
           [~,nfftmax]=max(syllable_data{3,k}(gt2fftbands{gtmax},syllable_threshold_timestamps(1)));
           syllable_stats{2,k}=gt2fftbands{gtmax}(nfftmax)/Nfft*fs/2/1e3; % start frequency
           [~,gtmax]=max(syllable_threshold(:,syllable_threshold_timestamps(end)));
           [~,nfftmax]=max(syllable_data{3,k}(gt2fftbands{gtmax},syllable_threshold_timestamps(end)));
           syllable_stats{3,k}=gt2fftbands{gtmax}(nfftmax)/Nfft*fs/2/1e3; % final frequency
           syllable_stats{8,k}=syllable_onset(k)*frame_shift/fs; % start syllable time
           syllable_stats{9,k}=syllable_offset(k)*frame_shift/fs; % end syllable time
           syllable_stats{13,k}=(syllable_stats{9,k} - syllable_stats{8,k})*1e3; % duration before noise reduction

           % mapping syllable_silhouette_gt in syllable_silhouette_fft
           syllable_silhouette_gt = syllable_threshold(:,syllable_threshold_timestamps)>0;
           syllable_stats{7,k}=length(syllable_threshold_timestamps)*frame_shift/fs*1e3; % duration after noise reduction
           gt_occ=sum(syllable_silhouette_gt,2);
           gt_occ_filt=filter([1 1 1]./3,1,gt_occ)>1/3;

           % syllable energy
           syllable_en=[];
           syllable_en_sum=0;
           totnb_fftbins=0;
           for framendx=syllable_threshold_timestamps
               gtbin=find(syllable_threshold(:,framendx)>0);
               fftbins=[];
               for gtbinndx=gtbin
                   fftbins=[fftbins gt2fftbands{gtbinndx}];
               end
               syllable_en_frame=sum(syllable_data{3,k}(fftbins,framendx));
               syllable_en_sum=syllable_en_sum+syllable_en_frame;
               syllable_en=[syllable_en;syllable_data{3,k}(fftbins,framendx)];
               totnb_fftbins=totnb_fftbins+length(fftbins);
           end
           syllable_stats{11,k}=10*log10(max(syllable_en_sum,10^(min_syllable_total_energy/10)));
           syllable_stats{12,k}=10*log10(max(syllable_en));   % peak energy

           % syllable frequency stats
           gt_range=find(gt_occ_filt)';
           if isempty(gt_range)
               ndx_remove(k)=1;
               continue;
           end
           freq_acc=0;
           for gtn=gt_range
               fftsubband=syllable_data{3,k}(gt2fftbands{gtn},syllable_threshold_timestamps);
               maxval_fft_subband=max(max(fftsubband));
               fft_gtval=gt2fftbands{gtn}(sum(fftsubband==maxval_fft_subband,2)==1);
               fft_gtval=fft_gtval(1);
               freq_acc=freq_acc+gt_occ(gtn)*fft_gtval/Nfft*fs/2/1e3;
           end
           syllable_stats{10,k}=freq_acc/sum(gt_occ);
           fftlowerband=syllable_data{3,k}(gt2fftbands{gt_range(1)},syllable_threshold_timestamps);
           fftupperband=syllable_data{3,k}(gt2fftbands{gt_range(end)},syllable_threshold_timestamps);
           maxval_fft_rangemin=max(max(fftlowerband));
           maxval_fft_rangemax=max(max(fftupperband));

           fft_rangemin=gt2fftbands{gt_range(1)}(sum(fftlowerband==maxval_fft_rangemin,2)==1);
           fft_rangemin=fft_rangemin(1);
           fft_rangemax=gt2fftbands{gt_range(end)}(sum(fftupperband==maxval_fft_rangemax,2)==1);
           fft_rangemax=fft_rangemax(1);

           syllable_stats{4,k}=min(syllable_stats{2,k},fft_rangemin/Nfft*fs/2/1e3); % minimum frequency
           %syllable_stats{4,k}=min(gt2fftbands{gt_range(1)}/Nfft*fs/2/1e3);
           syllable_stats{5,k}=max(syllable_stats{3,k},fft_rangemax/Nfft*fs/2/1e3); % maximum frequency
           %syllable_stats{5,k}=min(gt2fftbands{gt_range(end)}/Nfft*fs/2/1e3);
           syllable_stats{6,k}=syllable_stats{5,k}-syllable_stats{4,k}; % frequency bandwidth

       else
           ndx_remove(k)=1;
       end

    end

    if ~isempty(ndx_remove)

        % filtering based on too low total energy
        syllables_total_energy=cell2mat(syllable_stats(11,:));
        ndx_remove=ndx_remove + (syllables_total_energy <= min_syllable_total_energy);

        % filtering based on too low peak energy
        syllables_peak_energy=cell2mat(syllable_stats(12,:));
        ndx_remove=ndx_remove + (syllables_peak_energy <= min_syllable_peak_amplitude);

        % filtering based on too short duration (after noise reduction)
        syllables_duration=cell2mat(syllable_stats(7,:));
        ndx_remove=ndx_remove + (syllables_duration < min_syllable_duration);

        % filtering based on too long duration (after noise reduction)
        ndx_remove=ndx_remove + (syllables_duration > max_syllable_duration);
    end

    %     % filtering based on too short duration
    %     syllables_duration=cell2mat(syllable_stats(13,:));
    %     ndx_remove=ndx_remove + (syllables_duration <= min_syllable_duration);

    % apply syllable removal
    syllable_stats(:,ndx_remove>0)=[];
    syllable_data(:,ndx_remove>0)=[];
    syllable_onset(ndx_remove>0)=[];
    syllable_offset(ndx_remove>0)=[];

    % inter syllable distance computation
    nb_of_syllables=size(syllable_data,2);
    syllable_distance=[syllable_onset(2:end) - syllable_offset(1:end-1) 0];
    for k=1:nb_of_syllables
        if k==nb_of_syllables
            syllable_stats{14,k}=-100; % distance to next syllable
        else
            syllable_stats{14,k}=syllable_distance(k)*frame_shift/fs*1e3; % distance to next syllable
        end
    end

    % filestats
    filestats.TotNbFrames=TotNbFrames;
    filestats.syllable_dur='';
    filestats.syllable_activity='';
    filestats.syllable_distance='';
    filestats.nb_of_syllables=0;
    filestats.syllable_count_per_minute='';
    filestats.syllable_count_per_second='';
    if ~isempty(syllable_stats)

        % file statistics
        filestats.syllable_dur = cell2mat(syllable_stats(13,:));
        filestats.syllable_activity = sum(filestats.syllable_dur)/filestats.TotNbFrames;
        filestats.syllable_distance = cell2mat(syllable_stats(14,:));
        filestats.nb_of_syllables = length(filestats.syllable_dur);

        % syllable starting times
        syllable_onset_frames=zeros(1,ceil(syllable_stats{8,end}./frame_shift*fs));
        syllable_onset_frames(floor(cell2mat(syllable_stats(8,:))./frame_shift*fs))=1;

        % minute
        framewin=60*floor(fs/frame_shift);
        ind1=1:framewin:length(syllable_onset_frames)-framewin;
        ind2=(1:framewin)';
        syllable_split_per_minute=sum(syllable_onset_frames(ind1(ones(framewin,1),:)+ind2(:,ones(1,length(ind1)))),1);
        filestats.syllable_count_per_minute = syllable_split_per_minute';

        % second
        framewin=1*floor(fs/frame_shift);
        ind1=1:framewin:length(syllable_onset_frames)-framewin-floor(framewin/2);
        ind2=(1:framewin)';
        syllable_split_per_second=sum(syllable_onset_frames(ind1(ones(framewin,1),:)+ind2(:,ones(1,length(ind1)))),1);
        filestats.syllable_count_per_second = syllable_split_per_second';

    end
end

% syllable_activity_stats_refine
function [syllables, fs, syllable_dur, syllable_distance, syllable_activity, syllable_count_per_minute, syllable_count_per_second] = syllable_activity_stats_refine(handles, datasetName, Nfft)

    if ~exist('Nfft', 'var')
        Nfft=512;
    end
    %fs=250000;
    fs=handles.config{7};
    frame_shift=floor(handles.frame_shift_ms*fs);

    % Accumulate GT sonogram frames
    dataset_stats.syllable_dur=[];
    dataset_stats.syllable_distance=[];
    dataset_stats.syllable_activity=[];
    dataset_stats.syllable_count_per_minute=[];
    dataset_stats.syllable_count_per_second=[];
    dataset_stats.file_length=[];
    dataset_stats.filenames=[];
    dataset_stats.length=0;
    Xn_frames=0; Xn_tot=0;
    nb_of_syllables=0;

    % Gammatone features data
    load(fullfile(handles.datasetdir,datasetName),'dataset_content','dataset_dir');
    flist=dataset_content;

    for fname = flist
        [~, filename]= fileparts(fname{1});
        syllable_file=fullfile(dataset_dir, sprintf('%s.mat', filename));
        if exist(syllable_file,'file'),
            load(syllable_file,'syllable_data','syllable_stats','filestats');
            syllable_data(2,:)={[]};
            syllable_use=cell2mat(syllable_stats(1,:));
            syllable_data=syllable_data(:,syllable_use==1);

            if filestats.nb_of_syllables >=1

                % accumulate syllable stats
                dataset_stats.syllable_dur = [dataset_stats.syllable_dur filestats.syllable_dur];
                dataset_stats.syllable_distance = [dataset_stats.syllable_distance filestats.syllable_distance];
                dataset_stats.file_length = [dataset_stats.file_length; filestats.syllable_activity*filestats.TotNbFrames];
                dataset_stats.syllable_count_per_minute = [dataset_stats.syllable_count_per_minute; filestats.syllable_count_per_minute ];
                dataset_stats.syllable_count_per_second = [dataset_stats.syllable_count_per_second; filestats.syllable_count_per_second ];
                dataset_stats.length = dataset_stats.length + filestats.TotNbFrames;
                dataset_stats.filenames = [dataset_stats.filenames syllable_data(1,:)];

                % accumulate psd
                for syllableID = 1:filestats.nb_of_syllables
                    E=cell2mat(syllable_data(4,syllableID));
                    E(E==0)=1;
                    sumXn=sum(cell2mat(syllable_data(3,syllableID))./(ones(Nfft,1)*E),2);
                    Xn_tot = Xn_tot + sumXn;
                    Xn_frames=Xn_frames+length(E);
                end
                nb_of_syllables=nb_of_syllables+filestats.nb_of_syllables;

            end
        end
        clear syllable_data filestats;
    end

    % PSD
    psdn = Xn_tot / Xn_frames;

    % syllable activity
    dataset_stats.syllable_activity = sum(dataset_stats.file_length)/dataset_stats.length;
    dataset_stats.nb_of_syllables = nb_of_syllables;
    dataset_stats.recording_time = dataset_stats.length*frame_shift/fs;
    dataset_stats.syllable_time = Xn_frames*frame_shift/fs;

    % save to data set file
    save(fullfile(handles.datasetdir,datasetName),'dataset_stats','psdn','-append','-v6');

end

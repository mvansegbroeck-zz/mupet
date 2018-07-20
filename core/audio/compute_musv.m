%TODO: Signal Functionality assesment required
% compute_musv
function [syllable_data, syllable_stats, filestats, fs] = compute_musv(datadir,flist,handles,existonly)
    % FFT
    Nfft=256*2;

    if ~exist('existonly', 'var')
        existonly=false;
    end

    % Gammatone filterbank
    NbChannels=64;
    fsMin=90000;
%     fs=250000;
    fs=handles.config{7};
    frame_shift=floor(handles.frame_shift_ms*fs);
    frame_win=floor(handles.frame_win_ms*fs);
    gtdir=fullfile(handles.audiodir);
    if ~exist(gtdir,'dir')
      mkdir(gtdir)
    end
    GTB=gammatone_matrix_sigmoid(Nfft*2,fs,NbChannels);

    % compute FFT of the audio
    cnt = 1;
    init_waitbar = 1;
    for fnameID = 1:length(flist)
         fname=flist{fnameID};
         [~, filename]= fileparts(fname);
         gtfile=fullfile(gtdir, sprintf('%s.mat', filename));

         % info
         fprintf('Processing file %s  ', filename);
         flag = false;

         if exist(gtfile,'file') && ~existonly,
             load(gtfile,'filestats');
             flag = ~isequal(filestats.configpar,handles.config);
         end

         if ~exist(gtfile,'file') || flag

             if init_waitbar==1
                h = waitbar(0,'Initializing processing...');
                init_waitbar=0;
             end
             waitbar(cnt/(2*length(flist)),h,sprintf('Processing files... (file %i of %i)',(cnt-1)/2+1,length(flist)));
             audiofile=fullfile(datadir, fname);

             clear info;
             if exist('audioread')
                 info=audioinfo(audiofile);
             else
                 [~,info.SampleRate]=wavread(audiofile);
                 info.TotalSamplesArray=wavread(audiofile,'size');
                 info.TotalSamples=info.TotalSamplesArray(1);
             end

             segment_samples=floor(info.SampleRate*handles.feature_ext_segment_duration); % seconds to samples
             nb_of_segments=ceil(info.TotalSamples/segment_samples);
             segment_start_rewind=0;
             frame_start=1;

             resample_normal=true;
             try
                 tmp=resample(audio_segment(1:min(100,info.TotalSamples)),fs,info.SampleRate);
             catch
                 resample_normal=false;
             end

             syllable_data=[];
             for segmentID = 1:nb_of_segments
                 audio_start=(segmentID-1)*segment_samples+1-segment_start_rewind;
                 audio_end=min(segmentID*segment_samples,info.TotalSamples);
                 if exist('audioread')
                    audio_segment=audioread(audiofile,[audio_start audio_end]);
                 else
                    audio_segment=wavread(audiofile,[audio_start audio_end]);
                 end
                 if info.SampleRate < fsMin
                     errordlg(sprintf('Sampling rate of audio file %s is too low (<%i kHz). \nPlease delete audio file in directory to proceed.', fname, fsOrig),'Audio file sampling rate too low');
                     continue;
                 end
                 [syllable_data_segment,segment_start_rewind,~,nb_of_frames]=compute_musv_segment(handles,audio_segment,info.SampleRate,GTB,frame_start,audiofile,resample_normal);
                 frame_start=frame_start+nb_of_frames;
                 if ~isempty(syllable_data_segment)
                     syllable_data=[syllable_data syllable_data_segment];
                 end
             end
             TotNbFrames=floor((info.TotalSamples/info.SampleRate*fs-frame_win+frame_shift)/frame_shift);

             % compute syllable stats for file
             [syllable_data, syllable_stats, filestats] = syllable_activity_file_stats(handles, audiofile, TotNbFrames, syllable_data);
             filestats.configpar=handles.config;

             save(gtfile,'syllable_data','syllable_stats','filestats','-v6');

         else
             if nargout>0
                 load(gtfile,'syllable_data','syllable_stats','filestats');
             end
         end
         fprintf('Done.\n');
         cnt = cnt + 2;
    end
    if exist('h','var')
        close(h);
    end
end
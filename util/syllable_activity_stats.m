% ------------------------------------------------------------------------
% Copyright (C) 2015 University of Southern California, SAIL, U.S.
% Author: Maarten Van Segbroeck
% Mail: maarten@sipi.usc.edu
% Date: 2015-20-1
% ------------------------------------------------------------------------

function syllable_activity_stats(handles, wavefile_list, dataset_filename, Nfft) 

if ~exist('Nfft', 'var')
    Nfft=512;
end
fs=250000;
frame_shift=floor(handles.frame_shift_ms*fs);

gtdir=fullfile(handles.audiodir);

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
dataset_content={};

for wavefileID = 1:length(wavefile_list)
    [~, wavefile]= fileparts(wavefile_list{wavefileID});
    syllable_file=fullfile(gtdir, sprintf('%s.mat', wavefile));
    if exist(syllable_file,'file'), 
        % info
        fprintf('Processing file %s', wavefile);        
        load(syllable_file,'syllable_data','filestats');
        dataset_content{end+1}=sprintf('%s.mat', wavefile);
        
        %[syllables, fs, filestats] = syllable_activity_file_stats(handles, wavefile);
                
        % accumulate syllable stats
        dataset_stats.syllable_dur = [dataset_stats.syllable_dur filestats.syllable_dur];
        dataset_stats.syllable_distance = [dataset_stats.syllable_distance filestats.syllable_distance];
        dataset_stats.file_length = [dataset_stats.file_length; filestats.syllable_activity*filestats.TotNbFrames]; 
        dataset_stats.syllable_count_per_minute = [dataset_stats.syllable_count_per_minute; filestats.syllable_count_per_minute ]; 
        dataset_stats.syllable_count_per_second = [dataset_stats.syllable_count_per_second; filestats.syllable_count_per_second ]; 
        dataset_stats.length = dataset_stats.length + filestats.TotNbFrames;
        dataset_stats.filenames = [dataset_stats.filenames syllable_data(1,:)];
        
        % accumulate psd
        Xf=cell2mat(syllable_data(3,:));
        E=cell2mat(syllable_data(4,:));        
        Xn=Xf./(ones(Nfft,1)*E);
        Xn(isinf(Xn))=0;
        Xn_tot = Xn_tot + sum(Xn,2);
        Xn_frames=Xn_frames+size(Xn,2);
        nb_of_syllables=nb_of_syllables+size(syllable_data,2);
        
        fprintf('\n');
    end

end
           
% PSD
psdn = Xn_tot / Xn_frames;
      
% syllable activity
dataset_stats.syllable_activity = sum(dataset_stats.file_length)/dataset_stats.length;
dataset_stats.nb_of_syllables = nb_of_syllables;
dataset_stats.recording_time = dataset_stats.length*frame_shift/fs;
dataset_stats.syllable_time = Xn_frames*frame_shift/fs;

% save to data set file
dataset_dir=handles.audiodir;
save(dataset_filename,'dataset_content','dataset_dir');
save(dataset_filename,'dataset_stats','-append');
save(dataset_filename,'psdn','fs','-append');

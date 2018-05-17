% ------------------------------------------------------------------------
% Copyright (C) 2015 University of Southern California, SAIL, U.S.
% Author: Maarten Van Segbroeck
% Mail: maarten@sipi.usc.edu
% Date: 2015-20-1
% ------------------------------------------------------------------------

function [syllables, fs, syllable_dur, syllable_distance, syllable_activity, syllable_count_per_minute, syllable_count_per_second] = syllable_activity_stats_refine(handles, datasetName, Nfft) 

if ~exist('Nfft', 'var')
    Nfft=512;
end
fs=250000;
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
Tot_frames=0;

% Gammatone features data
load(fullfile(handles.datasetdir,datasetName),'dataset_content','dataset_dir');
flist=dataset_content;

for fname = flist
    [~, filename]= fileparts(fname{1});
    syllable_file=fullfile(dataset_dir, sprintf('%s.mat', filename));
    if exist(syllable_file,'file'), 
        load(syllable_file,'syllable_data','TotNbFrames');
        syllable_use=cell2mat(syllable_data(7,:)); 
        syllable_data=syllable_data(:,syllable_use==1);
        
        [syllables, fs, syllable_dur, syllable_distance, syllable_activity, syllable_count_per_minute, syllable_count_per_second] = syllable_activity_file_stats(handles, syllable_file);

        % accumulate syllable stats
        dataset_stats.syllable_dur = [dataset_stats.syllable_dur syllable_dur];
        dataset_stats.syllable_distance = [dataset_stats.syllable_distance syllable_distance];
        dataset_stats.file_length = [dataset_stats.file_length; syllable_activity*TotNbFrames]; 
        dataset_stats.syllable_count_per_minute = [dataset_stats.syllable_count_per_minute; syllable_count_per_minute ]; 
        dataset_stats.syllable_count_per_second = [dataset_stats.syllable_count_per_second; syllable_count_per_second ]; 
        dataset_stats.length = dataset_stats.length + TotNbFrames;
        dataset_stats.filenames = [dataset_stats.filenames syllables(1,:)];
        
        % accumulate psd
        Xf=cell2mat(syllable_data(3,:));
        E=cell2mat(syllable_data(4,:));
        Xn=Xf./(ones(Nfft,1)*E);
        Xn_tot = Xn_tot + sum(Xn,2);
        Xn_frames=Xn_frames+size(Xn,2);        
        nb_of_syllables=nb_of_syllables+size(syllable_data,2);
        Tot_frames=Tot_frames+TotNbFrames;
        
    end

end
           
% PSD
psdn = Xn_tot / Xn_frames;
      
% syllable activity
% syllable activity
dataset_stats.syllable_activity = sum(dataset_stats.file_length)/dataset_stats.length;
dataset_stats.nb_of_syllables = nb_of_syllables;
dataset_stats.recording_time = Tot_frames*frame_shift/fs;
dataset_stats.syllable_time = Xn_frames*frame_shift/fs;

% save to data set file
save(fullfile(handles.datasetdir,datasetName),'dataset_stats','psdn','-append');

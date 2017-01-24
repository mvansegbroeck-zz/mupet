% ------------------------------------------------------------------------
% Copyright (C) 2015 University of Southern California, SAIL, U.S.
% Author: Maarten Van Segbroeck
% Mail: maarten@sipi.usc.edu
% Date: 2015-20-1
% ------------------------------------------------------------------------

function [syllable_data,segment_start_rewind,nb_of_syllables,nbFrames] = compute_musv_segment(handles,segment,fsOrig,GTB,frame_start,audiofile,resample_normal)

% parameters
Nfft=512;

% % noise removal
% if handles.denoising
%     min_syllable_duration=5;
%     min_syllable_energy=-1;
% else
%     min_syllable_duration=3;
%     min_syllable_energy=-2;
% end

% energy
logE_thr=0.2;
smooth_fac=floor(5*(0.0016/handles.frame_shift_ms));
smooth_fac_low=10;
grow_fac=floor(3*(0.0016/handles.frame_shift_ms));

% frequency
fsMin=90000;
fs=250000;
frame_shift=floor(handles.frame_shift_ms*fs);
frame_win=floor(handles.frame_win_ms*fs);

if fsOrig < fsMin
 errordlg(sprintf('Sampling rate of audio file %s is too low (<%i kHz). \nPlease delete audio file in directory to proceed.', fname, fsOrig),'Audio file sampling rate too low');
end
if fsOrig ~= fs
    if resample_normal
        segment=resample(segment,fs,fsOrig);
    else        
        T=length(segment)/fsOrig;
        dsfac=fix(sqrt(2^31*fs/fsOrig));   
        segment=resample(segment,dsfac,fix(fsOrig/fs*dsfac));
        segment=segment(1:floor(T*fs));
    end
end

% compute MUSV features
fmin=35000;
fmax=110000;
Nmin=floor(Nfft/(fs/2)*fmin);
Nmax=floor(Nfft/(fs/2)*fmax);
[gt_sonogram, sonogram, E_low, E_usv, T]=FE_GT_spectra(segment, fs, frame_win, frame_shift, Nfft, Nmin, Nmax); 

% Gaussian noise floor estimation by median
logE = log(E_usv);
logE_noise = median(logE);
logE_norm = logE - logE_noise;
logE_low = log(E_low);
logE_low_noise = median(logE_low);
logE_low_norm = logE_low - logE_low_noise;

% syllable activity detection 
if handles.denoising
    sad = double(smooth( (logE_norm-logE_low_norm),smooth_fac)>logE_thr);
    sad = double(smooth(sad, grow_fac)>0); % syllable region growing
    sad_low = double(smooth( (logE_low_norm),smooth_fac_low)>logE_thr);
    sad_low = double(smooth(sad_low, grow_fac)>0); % syllable region growing
    sad = (sad-sad_low)>0;
else    
    sad = double(smooth(logE_norm,smooth_fac)>logE_thr);
    sad = double(smooth(sad, grow_fac)>0); % syllable region growing
end
    
start_sad = find((sad(1:end-1)-sad(2:end)) < -.5);
end_sad = find((sad(1:end-1)-sad(2:end)) > .5);
segment_start_rewind=floor((length(segment)-T)/fs*fsOrig);
nbFrames=size(gt_sonogram,2);
%imagesc(gt_sonogram); axis xy; hold on; plot(15*sad,'r'); plot(20*sad_low,'m'); plot(10*((sad-sad_low)>0),'g'); hold off; zoom xon; pause

if ~isempty(end_sad) && ~isempty(start_sad)
    if end_sad(1)<start_sad(1)
        end_sad(1)=[];
    end
    if ~isempty(end_sad)
        se_sad_T=min(length(start_sad),length(end_sad));
        if start_sad(end)>end_sad(end)
           segment_start_rewind=floor((length(segment)-min(T,start_sad(end)*frame_shift))/fs*fsOrig);
           nbFrames=start_sad(end);
        end    
        start_sad=start_sad(1:se_sad_T);
        end_sad=end_sad(1:se_sad_T);         
    end
else
    start_sad=[];
    end_sad=[];
end

% normalize sonogram by median filtering
noise_floor_GT=median(gt_sonogram,2);
noise_floor_X=median(sonogram,2);
GT = gt_sonogram - repmat(noise_floor_GT, 1, size(gt_sonogram,2));
X = sonogram - repmat(noise_floor_X, 1, size(sonogram,2));
% X=sonogram;

% spectral noise floor
[counts,vals]=hist(GT(:),100);
[sigma_noise, mu_noise] = gaussfit( vals, counts./sum(counts));

% syllable selection
syllable_data=cell(7,length(end_sad));
nb_of_syllables=length(end_sad);
for k=1:nb_of_syllables    
    syllable_data{1,k}=audiofile;
    syllable_data{2,k}=GT(:,start_sad(k):end_sad(k)-1); % gt
    syllable_data{3,k}=X(:,start_sad(k):end_sad(k)-1); % fft  
    syllable_data{4,k}=E_usv(:,start_sad(k):end_sad(k)-1)*(Nmax-Nmin); % energy
    syllable_data{5,k}=frame_start+start_sad(k)-1;    
    syllable_data{6,k}=frame_start+end_sad(k)-1;   
    syllable_data{7,k}=1;    % syllable considered for analysis
    syllable_data{8,k}=sigma_noise; 
    syllable_data{9,k}=mu_noise; 
end

syllable_onset=cell2mat(syllable_data(5,:));
syllable_offset=cell2mat(syllable_data(6,:));
syllable_distance = [syllable_onset(2:end) - syllable_offset(1:end-1) 0];
syllables_to_remove = [];
for k=1:nb_of_syllables    
%     fprintf('%.4f %.2f %.2f\n',syllable_data{5,k}*frame_shift/fs, (syllable_data{6,k}-syllable_data{5,k})*frame_shift/fs*1e3 ,syllable_distance(k)*frame_shift/fs*1e3);
    if syllable_distance(k)*frame_shift/fs*1e3 < handles.config{5} && syllable_distance(k)*frame_shift/fs*1e3 > 0
        syllable_data{2,k+1}=GT(:,start_sad(k):end_sad(k+1)-1);
        syllable_data{3,k+1}=X(:,start_sad(k):end_sad(k+1)-1); % fft  
        syllable_data{4,k+1}=E_usv(:,start_sad(k):end_sad(k+1)-1)*(Nmax-Nmin); % energy
        syllable_data{4,k+1}=E_usv(:,start_sad(k):end_sad(k+1)-1)*(Nmax-Nmin); % energy
        syllable_data{5,k+1}=syllable_data{5,k};    
        syllable_data{6,k+1}=syllable_data{6,k+1};   
        syllable_data{7,k+1}=1;    % syllable considered for analysis
        syllable_data{8,k+1}= syllable_data{8,k}; 
        syllable_data{9,k+1}=syllable_data{9,k}; 
        syllables_to_remove = [syllables_to_remove k];
    end
end

if ~isempty(syllables_to_remove)
    syllable_data(:,syllables_to_remove)=[];
    nb_of_syllables=size(syllable_data,2);
end

% select syllables
syllable_nbframes=zeros(nb_of_syllables,1);
syllable_energy=zeros(nb_of_syllables,1);
syllable_constant=zeros(nb_of_syllables,1);
for k=1:nb_of_syllables
    syllable_nbframes(k)=size(syllable_data{3,k},2); % nb of syllable frames
    syllable_energy(k)=max(max(log(abs(syllable_data{3,k}+1e-5))));
    syllable_constant(k)=sum(syllable_data{2,k}(:,1)-syllable_data{2,k}(:,end))~=0;
end

% remove constant patches
syllable_selection = syllable_constant ;
syllable_data(:,~syllable_selection)=[];
nb_of_syllables=size(syllable_data,2);

% % % remove too short/long syllables   
% % syllable_selection1 = syllable_nbframes >= min_syllable_duration;
% % 
% % % remove low energy syllables
% % syllable_selection2 = syllable_energy > min_syllable_energy;
% % 
% % % remove constant patches
% % syllable_selection3 = syllable_constant ;
% % 
% % % remove low frequency syllables
% % syllable_selection=(syllable_selection1+syllable_selection2+syllable_selection3)==3;
% % syllable_data(:,~syllable_selection)=[];
% % nb_of_syllables=size(syllable_data,2);

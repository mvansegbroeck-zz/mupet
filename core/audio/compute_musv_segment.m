% compute_musv_segment
function [syllable_data,segment_start_rewind,nb_of_syllables,nbFrames] = compute_musv_segment(handles,audio_segment,fsOrig,GTB,frame_start,audiofile,resample_normal)

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
fs=handles.config{7};
frame_shift=floor(handles.frame_shift_ms*fs);
frame_win=floor(handles.frame_win_ms*fs);

if fsOrig < fsMin
 errordlg(sprintf('Sampling rate of audio file %s is too low (<%i kHz). \nPlease delete audio file in directory to proceed.', fname, fsOrig),'Audio file sampling rate too low');
end
if fsOrig ~= fs
    if resample_normal
        audio_segment=resample(audio_segment,fs,fsOrig);
    else
        T=length(audio_segment)/fsOrig;
        dsfac=fix(sqrt(2^31*fs/fsOrig));
        audio_segment=resample(audio_segment,dsfac,fix(fsOrig/fs*dsfac));
        audio_segment=audio_segment(1:floor(T*fs));
    end
end

% compute MUSV features
fmin=handles.config{8};
fmax=handles.config{9};
Nmin=floor(Nfft/(fs/2)*fmin);
Nmax=floor(Nfft/(fs/2)*fmax);
[gt_sonogram, sonogram, E_low, E_usv, T]=FE_GT_spectra(handles, audio_segment, fs, frame_win, frame_shift, Nfft, Nmin, Nmax);

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
segment_start_rewind=floor((length(audio_segment)-T)/fs*fsOrig);
nbFrames=size(gt_sonogram,2);
%imagesc(gt_sonogram); axis xy; hold on; plot(15*sad,'r'); plot(20*sad_low,'m'); plot(10*((sad-sad_low)>0),'g'); hold off; zoom xon; pause

if ~isempty(end_sad) && ~isempty(start_sad)
    if end_sad(1)<start_sad(1)
        end_sad(1)=[];
    end
    if ~isempty(end_sad)
        se_sad_T=min(length(start_sad),length(end_sad));
        if start_sad(end)>end_sad(end)
           segment_start_rewind=floor((length(audio_segment)-min(T,start_sad(end)*frame_shift))/fs*fsOrig);
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
[sigma_noise, mu_noise] = gaussfit( vals, counts./sum(counts), handles);

% syllable selection
syllable_data=cell(6,length(end_sad));
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
    if syllable_distance(k)*frame_shift/fs*1e3 < handles.config{6} && syllable_distance(k)*frame_shift/fs*1e3 > 0
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

end

% FE_GT_spectra
function [lp,Xf,E_low, E_usv,T]=FE_GT_spectra(handles, sam,fs,FrameLen,FrameShift,Nfft,Nmin,Nmax,W,M)

    GTfloor=1e-3;

    filterbank_type=handles.config{11};
    number_filterbank_filters=handles.config{10};
    minimum_usv_frequency=handles.config{8};
    maximum_usv_frequency=handles.config{9};

    if ~exist('W', 'var')
        if filterbank_type == 0
            W = gammatone_matrix_sigmoid(Nfft*2, fs, number_filterbank_filters);
        else
            W = gammatone_matrix_linear(Nfft*2, fs, number_filterbank_filters, minimum_usv_frequency, maximum_usv_frequency);
        end
    end
    if ~exist('M', 'var')
        M=1;
    end

    % truncate as in ReadWave
    NbFr=floor( (length(sam)-FrameLen+FrameShift)/FrameShift);
    sam=sam(1:NbFr*FrameShift+FrameLen-FrameShift);

    % % Low pass removal
    % fmax=0.99*fs/2;
    % sam=[0 reshape(sam,1,length(sam))];
    % T=length(sam);

    % Low pass removal
    fmin=25000;
    fmax=0.99*fs/2;
    [b,a] = cheby1(8,  0.5, [fmin fmax]/(fs/2));
    sam=filter(b, a, [0 reshape(sam,1,length(sam))]);
    T=length(sam);

    % framing
    ind1=1:FrameShift:length(sam)-1-FrameLen+FrameShift;

    % new
    win=hamming(FrameLen);
    Xf=zeros(Nfft,NbFr);
    for k=1:NbFr
        x=sam(ind1(k):ind1(k)+FrameLen-1)';
        xwin=win.*x;
        X=fft(xwin,2*Nfft);
        Xf(:,k)=X(1:Nfft);
    end
    Xf=abs(Xf).^2;

    % Energy and norm
    E_low=sum(Xf(1:Nmin,:))./Nmin;
    E_usv=sum(Xf(Nmin+1:Nmax,:))./(Nmax-Nmin);

    % GT
    Xf_hp=Xf;
    Xf_hp(1:Nmin,:)=0;
    lp=max(W*Xf_hp,GTfloor);
    lp=log(lp);
    lp=arma_filtering(lp,M);

end
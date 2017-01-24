% ------------------------------------------------------------------------
% Copyright (C) 2015 University of Southern California, SAIL, U.S.
% Author: Maarten Van Segbroeck
% Mail: maarten@sipi.usc.edu
% Date: 2015-20-1
% ------------------------------------------------------------------------

function show_dataset_stats(handles,datasetNames,fs,Nfft) 

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
perc_quant=0.7;
syllable_activity_threshold=0.005;
barcolors={[1 102/256 102/256], [1 153/256 153/256], [0.5 0.5 0.5], [102/256 153/256 1] ,[153/256 204/256 1]};
datasetnames=cell(1,length(datasetNames));

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
    [sigma,mu]=gaussfit(1:length(psdline), psdline);
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
    varY=std(syl_activity);
    
    % syllable stats
    syl_count_mean=mean(dataset_stats.syllable_count_per_second(dataset_stats.syllable_count_per_second>0));   
    syl_count_var=var(dataset_stats.syllable_count_per_second(dataset_stats.syllable_count_per_second>0));
    syllable_dist_mean=mean(dataset_stats.syllable_distance);   
    syllable_dist_var=var(dataset_stats.syllable_distance);    
    syllable_dur_mean=mean(dataset_stats.syllable_dur);
    syllable_dur_var=var(dataset_stats.syllable_dur);

    fprintf('\nStatistics of dataset "%s"\n',datasetnames{datasetID});
    fprintf('  PSD curve:   %.2f kHz (mean), %.2f kHz (variance)\n',(muf/1e3),(sigmaf/1e3));    
    fprintf('  frequency bandwidth:   %.2f kHz\n',(bwq/1e3));    
    fprintf('  syllables/second:   %.1f (mean), %.1f (variance)\n',syl_count_mean,syl_count_var);    
    fprintf('  inter-syllable distance:   %.0f ms (mean), %.0f ms (variance)\n',syllable_dist_mean,syllable_dist_var);    
    fprintf('  syllables duration:   %.0f ms (mean), %.0f (variance)\n',syllable_dur_mean,syllable_dur_var);
    
end

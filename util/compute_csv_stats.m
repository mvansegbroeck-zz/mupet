% ------------------------------------------------------------------------
% Copyright (C) 2015 University of Southern California, SAIL, U.S.
% Author: Maarten Van Segbroeck
% Mail: maarten@sipi.usc.edu
% Date: 2015-20-1
% ------------------------------------------------------------------------

function compute_csv_stats(wav_dir,wav_items,handles) 

init_waitbar = 1;
cnt = 1;
for fileID = 1:length(wav_items)
    
    if init_waitbar==1             
       h = waitbar(0,'Initializing exporting process...');    
       init_waitbar=0;
    end 
    waitbar(cnt/(2*length(wav_items)),h,sprintf('Exporting syllable statistics to csv format... (file %i of %i)',(cnt-1)/2+1,length(wav_items))); 
         
    [~, syllable_stats, ~, fs]=compute_musv(wav_dir,wav_items(fileID),handles,true);
   
    handles.syllable_stats = syllable_stats;
    handles.sample_frequency = fs;
    handles.filename = wav_items{fileID};
    export_csv_files_syllables(handles);     
    
    cnt = cnt + 2;
end
if exist('h','var')
    close(h);
end

% process_restart
function process_restart(handles)

    wav_items=get(handles.wavList,'string');
    for k=1:length(wav_items)
        [~,filename]=fileparts(wav_items{k});
        syllable_file=fullfile(handles.audiodir, sprintf('%s.mat', filename));
        if exist(syllable_file,'file'),
            delete(syllable_file);
        end
    end
    msgbox(sprintf(' ***            Processing restart succeeded.            *** '),'MUPET info');

end
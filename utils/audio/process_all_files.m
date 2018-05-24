% process_all_files
function handles=process_all_files(handles)

    wav_items=get(handles.wavList,'string');
    wav_dir=get(handles.wav_directory,'string');
    if ~isempty(wav_dir)
        compute_musv(wav_dir,wav_items,handles);
    end
    msgbox(sprintf(' ***              All files processed              *** '),'MUPET info');

end
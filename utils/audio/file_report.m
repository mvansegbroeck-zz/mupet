% file_report
function handles=file_report(handles)

    wav_items=get(handles.wavList,'string');
    wav_dir=get(handles.wav_directory,'string');
    if ~isempty(wav_dir)
        compute_csv_stats(wav_dir,wav_items,handles);
    end
    msgbox(sprintf('***              All files exported to CSV files              ***\n See folder %s/CSV',handles.audiodir),'MUPET info');

end
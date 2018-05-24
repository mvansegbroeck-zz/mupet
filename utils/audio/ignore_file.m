% ignore_file
function handles=ignore_file(handles)

    wav_items=get(handles.wavList,'string');
    selected_wav=get(handles.wavList,'value');
    if ~isempty(wav_items)
        handles.flist(strcmp(handles.flist,wav_items{selected_wav}))=[];
        wav_items(selected_wav)=[];
        set(handles.wavList,'value',1);
        set(handles.wavList,'string',wav_items);
    end
end
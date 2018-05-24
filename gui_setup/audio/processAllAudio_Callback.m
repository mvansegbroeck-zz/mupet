function processAllAudio_Callback(hObject, eventdata, handles)
handles=process_all_files(handles);
guidata(hObject, handles);
end
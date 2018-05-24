function editAudioSettings_Callback(hObject, eventdata, handles)
create_configfile(handles);
edit(handles.configfile);
end
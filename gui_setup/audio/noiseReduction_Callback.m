function noiseReduction_Callback(hObject, eventdata, handles)
handles=noise_reduction(hObject, handles);
guidata(hObject, handles);
end
% noise_reduction
%TODO: Figure out use, not called anywhere originally
function handles=noise_reduction(hObject, handles)
    button_state = get(hObject,'Value');
    if button_state == get(hObject,'Max')
        set(hObject,'ForegroundColor',[0 .75 0.35]);
        set(hObject,'String','denoise ON');
        handles.denoising=true;
        handles.origaudiodir=handles.audiodir;
        handles.audiodir=sprintf('%s_denoiseON',handles.audiodir);
    elseif button_state == get(hObject,'Min')
        set(hObject,'ForegroundColor',[0 0 0]);
        set(hObject,'String','denoise OFF');
        handles.denoising=false;
        handles.audiodir=handles.origaudiodir;
    end
end
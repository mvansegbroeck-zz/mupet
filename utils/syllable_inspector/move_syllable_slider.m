function move_syllable_slider(handles)

    if isempty(handles.syllable_stats)
        errordlg('Please select and process an audio file.','No audio file selected/processed')
    else
        syllable_ndx = round(get(handles.syllableSlider,'Value')./(get(handles.syllableSlider,'Max')) * (size(handles.syllable_stats,2)-1) + 1);
        % make syllable patch
        show_syllables(handles,syllable_ndx);
    end

end
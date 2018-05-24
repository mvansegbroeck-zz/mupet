% processAudioFile
function handles=process_file(handles)
    wav_items=get(handles.wavList,'string');
    selected_wav=get(handles.wavList,'value');
    wav_dir=get(handles.wav_directory,'string');
    if ~isempty(wav_dir)
        [syllable_data, syllable_stats, filestats, fs]=compute_musv(wav_dir,wav_items(selected_wav),handles);
        handles.syllable_stats = syllable_stats;
        handles.syllable_data = syllable_data;
        handles.sample_frequency = fs;
        handles.filename = wav_items{selected_wav};
        nb_syllables=filestats.nb_of_syllables;
        if nb_syllables >= 1
            set(handles.syllableSlider,'Value',0);
            if nb_syllables==1
                set(handles.syllableSlider,'Visible','off');
            else
                set(handles.syllableSlider,'Visible','on');
                if nb_syllables==2
                    set(handles.syllableSlider,'Max',1);
                else
                    set(handles.syllableSlider,'Max',nb_syllables-2);
                end
                set(handles.syllableSlider,'Value',0);
                set(handles.syllableSlider,'Min',0);
                set(handles.syllableSlider,'SliderStep',[1/(double(nb_syllables-1)) 1/(double(nb_syllables-1))]);
            end
            syllable_ndx=1;

            % make syllable patch
            show_syllables(handles,syllable_ndx);
        else
            errordlg(sprintf(' ***              No syllables found in file              *** '),'MUPET info');
        end
    end
end
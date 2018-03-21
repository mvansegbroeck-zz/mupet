% load_configfile
function handles = load_configfile(handles)

    configfile=handles.configfile;
    try
        [parameterfield,vals]=textread(configfile,'%s%f','delimiter',',');

        noise_reduction_ndx=cellfun(@isempty,strfind(parameterfield,'noise-reduction'))==0;
        min_syllable_duration_ndx=cellfun(@isempty,strfind(parameterfield,'minimum-syllable-duration'))==0;
        max_syllable_duration_ndx=cellfun(@isempty,strfind(parameterfield,'maximum-syllable-duration'))==0;
        min_syllable_total_energy_ndx=cellfun(@isempty,strfind(parameterfield,'minimum-syllable-total-energy'))==0;
        min_syllable_peak_amplitude_ndx=cellfun(@isempty,strfind(parameterfield,'minimum-syllable-peak-amplitude'))==0;
        min_syllable_distance_ndx=cellfun(@isempty,strfind(parameterfield,'minimum-syllable-distance'))==0;

        handles.config{1} = vals(noise_reduction_ndx);
        if (handles.config{1}<0) || (handles.config{1}>10)
            ME = MException('MyComponent:noSuchVariable','Verify noise reduction parameter');
            throw(ME);
        end
        handles.config{2} = vals(min_syllable_duration_ndx);
        if (handles.config{2}<0)
            ME = MException('MyComponent:noSuchVariable','Verify minimum syllable duration parameter');
            throw(ME);
        end
        handles.config{3} = vals(max_syllable_duration_ndx);
        if (handles.config{3}>handles.repertoire_unit_size_seconds)
            ME = MException('MyComponent:noSuchVariable','Verify maximum syllable duration parameter');
            throw(ME);
        end
        handles.config{4}= vals(min_syllable_total_energy_ndx);
        handles.config{5} = vals(min_syllable_peak_amplitude_ndx);
        handles.config{6} = vals(min_syllable_distance_ndx);
        if (handles.config{6}<0)
            ME = MException('MyComponent:noSuchVariable','Verify syllable distance parameter');
            throw(ME);
        end
        msgbox(sprintf(' ***  Settings successfully loaded ***'),'MUPET info');
    catch ME
        if strcmp(ME.identifier,'MATLAB:dataread:TroubleReading')
            msgbox(sprintf(' *** Incorrect format of config file. Using default settings ***'),'MUPET info');
        else
            msgbox(sprintf(' ***  %s Using default settings ***',ME.message),'MUPET info');
        end
        handles.config{1}=handles.configdefault{1};
        handles.config{2}=handles.configdefault{2};
        handles.config{3}=handles.configdefault{3};
        handles.config{4}=handles.configdefault{4};
        handles.config{5}=handles.configdefault{5};
        handles.config{6}=handles.configdefault{6};
        create_configfile(handles);
    end

end
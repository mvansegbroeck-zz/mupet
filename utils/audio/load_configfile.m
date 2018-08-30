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
        sample_frequency_ndx=cellfun(@isempty,strfind(parameterfield,'sample-frequency'))==0;
        min_usv_frequency_ndx=cellfun(@isempty,strfind(parameterfield,'minimum-usv-frequency'))==0;
        max_usv_frequency_ndx=cellfun(@isempty,strfind(parameterfield,'maximum-usv-frequency'))==0;
        number_filterbank_filters_ndx=cellfun(@isempty,strfind(parameterfield,'number-filterbank-filters'))==0;
        filterbank_type_ndx=cellfun(@isempty,strfind(parameterfield,'filterbank-type'))==0;
        
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
        handles.config{7}= vals(sample_frequency_ndx);
        if (handles.config{7}<90000) || (handles.config{7}>300000)
            ME = MException('MyComponent:noSuchVariable','Verify USV sampling frequency');
            throw(ME);
        end
        handles.config{8} = vals(min_usv_frequency_ndx);
        if (handles.config{8}>handles.config{7}/2) || (handles.config{8}<20000) || (handles.config{8}>handles.config{9}) || ((handles.config{9}-handles.config{8})<50000)
            ME = MException('MyComponent:noSuchVariable','Verify min USV frequency.\n Make sure it is higher than 20kHz.\n');
            throw(ME);
        end
        handles.config{9} = vals(max_usv_frequency_ndx);
        if (handles.config{9}>handles.config{7}/2) || (handles.config{9}<handles.config{8}) || ((handles.config{9}-handles.config{8})<50000)
            ME = MException('MyComponent:noSuchVariable','Verify max USV frequency.\n Make sure it is smaller than half of the sampling frequency and at least 50kHz higher than the min USV frequency.\n');
            throw(ME);
        end
        handles.config{10} = vals(number_filterbank_filters_ndx);
        if (handles.config{10}<32) || (handles.config{10}>256)
            ME = MException('MyComponent:noSuchVariable','Verify number of filterbank filters parameter (min: 32, max: 256)');
            throw(ME);
        end
        handles.config{11} = vals(filterbank_type_ndx);
        if (handles.config{11}~=0) && (handles.config{11}~=1)
            ME = MException('MyComponent:noSuchVariable','Verify filterbank type parameter (0: non-linear, 1: linear)');
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
        handles.config{7}=handles.configdefault{7};
        handles.config{8}=handles.configdefault{8};
        handles.config{9}=handles.configdefault{9};
        handles.config{10}=handles.configdefault{10};
        handles.config{11}=handles.configdefault{11};
        create_configfile(handles, true);
    end

end
% create_configfile
function handles = create_configfile(handles, flag)

    if ~exist('flag', 'var')
        flag=false;
    end

    if ~exist(handles.configfile,'file') || flag
        configfile=handles.configfile;
        configfile_string=sprintf('%s%s%s', ...
            sprintf('noise-reduction,%.1f\n',handles.configdefault{1}), ...
            sprintf('minimum-syllable-duration,%.1f\n',handles.configdefault{2}), ...
            sprintf('maximum-syllable-duration,%.1f\n',handles.configdefault{3}), ...
            sprintf('minimum-syllable-total-energy,%.1f\n',handles.configdefault{4}), ...
            sprintf('minimum-syllable-peak-amplitude,%.1f\n',handles.configdefault{5}), ...
            sprintf('minimum-syllable-distance,%.1f',handles.configdefault{6}));
        fileID=fopen(configfile,'w');
        fwrite(fileID, configfile_string);
        fclose(fileID);

        % set settings
        handles.config{1}=handles.configdefault{1};
        handles.config{2}=handles.configdefault{2};
        handles.config{3}=handles.configdefault{3};
        handles.config{4}=handles.configdefault{4};
        handles.config{5}=handles.configdefault{5};
        handles.config{6}=handles.configdefault{6};

    end
end
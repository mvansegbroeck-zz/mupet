% create_configfile
function handles = create_configfile(handles, flag)

    if ~exist('flag', 'var')
        flag=false;
    end
    
    if ~exist(handles.configfile,'file') || flag
        configfile=handles.configfile;
        configfile_string=sprintf('%s%s%s', ...
            sprintf('noise-reduction,%i\n',handles.configdefault{1}), ...
            sprintf('minimum-syllable-duration,%i\n',handles.configdefault{2}), ...
            sprintf('maximum-syllable-duration,%i\n',handles.configdefault{3}), ...
            sprintf('minimum-syllable-total-energy,%i\n',handles.configdefault{4}), ...
            sprintf('minimum-syllable-peak-amplitude,%i\n',handles.configdefault{5}), ...
            sprintf('minimum-syllable-distance,%i\n',handles.configdefault{6}), ...
            sprintf('sample-frequency,%i\n',handles.configdefault{7}), ...
            sprintf('minimum-usv-frequency,%i\n',handles.configdefault{8}), ...
            sprintf('maximum-usv-frequency,%i\n',handles.configdefault{9}), ...
            sprintf('number-filterbank-filters,%i\n',handles.configdefault{10}), ...
            sprintf('filterbank-type,%i\n',handles.configdefault{11}));
        
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
        handles.config{7}=handles.configdefault{7};
        handles.config{8}=handles.configdefault{8};
        handles.config{9}=handles.configdefault{9};
        handles.config{10}=handles.configdefault{10};
        handles.config{11}=handles.configdefault{11};

    end
end
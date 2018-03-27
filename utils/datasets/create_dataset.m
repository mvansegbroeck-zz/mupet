% create_dataset
function create_dataset(handles)

    wav_dir=get(handles.wav_directory,'string');
    if isempty(wav_dir)
        errordlg('Please select an audio directory first.','No data directory name');
    else
        datasetName=get(handles.datasetName,'String');
        if isempty(datasetName)
            errordlg('Please give a name for the dataset.','No dataset name');
            choice='No';
        elseif exist(fullfile(handles.datasetdir,sprintf('%s.mat',datasetName)))
            choice = questdlg('A dataset with same name already exists. Overwrite?', ...
                        'Dataset exists', ...
                        'Yes','No','No');
        else
            choice='Yes';
        end
        if strcmp(choice,'Yes')
            if ~isempty(handles.flist)
                compute_musv(wav_dir,handles.flist,handles,true);
            end
            if ~exist(handles.datasetdir,'dir')
                mkdir(handles.datasetdir);
            end
            wav_items=get(handles.wavList,'string');
            fprintf('Creating data set: %s\n', datasetName);
            dataset_matfile = fullfile(handles.datasetdir,sprintf('%s.mat',datasetName));
            syllable_activity_stats(handles, wav_items, dataset_matfile);
            datasetNames=dir(fullfile(handles.datasetdir,'*.mat'));
            set(handles.datasetList,'value',1);
            set(handles.datasetList,'string',strrep({datasetNames.name},'.mat',''));
            fprintf('Done.\n');
        end
    end

end

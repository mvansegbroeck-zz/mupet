% refresh_datasets
function refresh_datasets(handles)

    datasetNames=dir(fullfile(handles.datasetdir,'*.mat'));
    set(handles.datasetList,'string',strrep({datasetNames.name},'.mat',''));

end
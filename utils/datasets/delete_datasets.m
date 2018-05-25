% delete_datasets
function delete_datasets(handles)

    dataset_items=get(handles.datasetList,'string');
    selected_dataset=get(handles.datasetList,'value');
    if ~isempty(dataset_items)
        delete(fullfile(handles.datasetdir,sprintf('%s.mat',dataset_items{selected_dataset})));
        datasetNames=dir(fullfile(handles.datasetdir,'*.mat'));
        set(handles.datasetList,'value',1);
        set(handles.datasetList,'string',strrep({datasetNames.name},'.mat',''));
    end
end
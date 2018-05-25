% print_content
function print_content(handles)

    dataset_items=get(handles.datasetList,'string');
    if ~isempty(dataset_items)
        export_csv_dataset_content(dataset_items, handles);
    end
    msgbox(sprintf('***              All data sets exported to CSV files              ***\n See folder %s/CSV',handles.datasetdir),'MUPET info');

end
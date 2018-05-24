% exportRepertoires
function export_repertoires(handles)
    repertoire_content=dir(fullfile(handles.repertoiredir,sprintf('*_N*.mat')));
    repertoire_items={repertoire_content.name};
    repertoire_items = sort_nat(repertoire_items);
    if isempty(repertoire_items)
        errordlg('Please create a repertoire first.','No repertoire created');
    else
        export_csv_repertoires(handles,repertoire_items);
        export_csv_model_stats_repertoires(handles,repertoire_items);
        msgbox(sprintf('***              All repertoires exported to CSV files              ***\n See folder %s/CSV',handles.repertoiredir),'MUPET info');
    end
end
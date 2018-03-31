% refine_repertoire
function refine_repertoire(handles)
    repertoire_items=get(handles.repertoireList,'string');
    selected_repertoire=get(handles.repertoireList,'value');
    if isempty(repertoire_items)
        errordlg('Please create a repertoire first.','No repertoire created');
    else
        refine_selected_repertoire(handles,repertoire_items{selected_repertoire});
    end
    refresh_datasets(handles);
    refresh_repertoires(handles);
end
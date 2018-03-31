% show_repertoire
function show_repertoire(handles)
    repertoire_items=get(handles.repertoireList,'string');
    selected_repertoire=get(handles.repertoireList,'value');
    if isempty(repertoire_items)
        errordlg('Please create a repertoire first.','No repertoire created');
    else
        show_repertoire_figures(handles,repertoire_items{selected_repertoire});
    end
end
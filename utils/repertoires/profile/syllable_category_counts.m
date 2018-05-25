% syllable_category_counts
function syllable_category_counts(handles)
    repertoire_items=get(handles.repertoireList,'string');
    categories=get(handles.categories,'String');
    NbCategories=str2double(categories(get(handles.categories,'Value')));
    if isempty(repertoire_items)
        errordlg('Please create a repertoire first.','No repertoire created');
    else
        show_syllable_category_counts(handles,repertoire_items,NbCategories);
    end
end
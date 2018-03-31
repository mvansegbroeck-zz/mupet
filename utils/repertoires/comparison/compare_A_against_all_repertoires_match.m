% compare_A_against_all_repertoires_match
function compare_A_against_all_repertoires_match(handles)
    repertoire_A=get(handles.selectedRepertoireA,'string');
    repertoire_items=get(handles.repertoireList,'string');
    if isempty(repertoire_A)
        errordlg('Please select base repertoire A.','Select repertoire');
    else
        if length(repertoire_items)<2
            errordlg('Please compare between multiple repertoires.','Create more repertoires');
        else
            compare_repertoires_match(handles,repertoire_items,repertoire_A);
        end
    end
    set(handles.selectedRepertoireA,'string','');
end
% delete_repertoires
function delete_repertoires(handles)
    repertoire_items=get(handles.repertoireList,'string');
    selected_repertoire=get(handles.repertoireList,'value');
    if ~isempty(repertoire_items)
        delete(fullfile(handles.repertoiredir,repertoire_items{selected_repertoire}));
        ndx_delete=strcmp(repertoire_items,repertoire_items{selected_repertoire});
        repertoire_items(ndx_delete)=[];
        repertoire_content=strcat(handles.repertoiredir,'/',repertoire_items);
        units=get(handles.nbunits,'String');
        NbUnits=str2double(units(get(handles.nbunits,'Value')));
        categoriesel=cellfun(@num2str,mat2cell([5:5:length(repertoire_content)*NbUnits]',ones(length(repertoire_content)*NbUnits/5,1)),'un',0);
        if ~isempty(categoriesel)
            set(handles.categories,'string',categoriesel);
        end
        set(handles.repertoireList,'value',1);
        set(handles.repertoireList,'string',repertoire_items);
    end
    set(handles.selectedRepertoireA,'string','');
end
% set_nbUnits
function set_nbUnits(handles)
    units=get(handles.nbunits,'String');
    NbUnits=str2double(units(get(handles.nbunits,'Value')));
    repertoire_content=dir(fullfile(handles.repertoiredir,sprintf('*_N%i.mat',NbUnits)));
    repertoire_refined_content=dir(fullfile(handles.repertoiredir,sprintf('*_N%i*+.mat',NbUnits)));
    repertoire_content(end+1:end+length(repertoire_refined_content))=repertoire_refined_content;
    categoriesel=cellfun(@num2str,mat2cell([5:5:length(repertoire_content)*NbUnits]',ones(length(repertoire_content)*NbUnits/5,1)),'un',0);
    if ~isempty(categoriesel)
        set(handles.categories,'string',categoriesel);
    end
    set(handles.repertoireList,'value',1);
    set(handles.repertoireList,'string',{repertoire_content.name});
    set(handles.selectedRepertoireA,'string','');
end
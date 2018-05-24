% buildRepertoire
function build_repertoire(handles)
    dataset_items=get(handles.datasetList,'string');
    selected_dataset=get(handles.datasetList,'value');
    if isempty(dataset_items)
        errordlg('Please create a dataset first.','No dataset created');
    else
        load(fullfile(handles.datasetdir,sprintf('%s.mat',dataset_items{selected_dataset})),'dataset_dir');
        units=get(handles.nbunits,'String');
        NbUnits=str2double(units(get(handles.nbunits,'Value')));
        datasetName=dataset_items{selected_dataset};
        [~,repertoireName]=fileparts(sprintf('%s.mat',datasetName));
        repertoireFile=fullfile(handles.repertoiredir,sprintf('%s_N%i.mat',repertoireName,NbUnits));
        if ~exist(repertoireFile,'file')
            [bases, activations, bic, logL, syllable_similarity, syllable_correlation, repertoire_similarity, err, NbChannels, NbPatternFrames, NbUnits, NbIter, ndx_V] = repertoire_learning(handles,datasetName,NbUnits);
            if isempty(bases)
                errordlg('Repertoire learning stopped. Too few syllables were detected in the audio data.','repertoire error');
            else
                if ~exist(handles.repertoiredir,'dir')
                    mkdir(handles.repertoiredir);
                end
                save(repertoireFile,'bases','activations','bic','logL','syllable_similarity','syllable_correlation','repertoire_similarity','NbUnits','NbChannels','NbPatternFrames','NbUnits','NbIter','dataset_dir','ndx_V','datasetName','-v6');
            end
        else
            errordlg('Requested repertoire exist. Delete first for rebuild.','Repertoire exist');
        end
        repertoire_content=dir(fullfile(handles.repertoiredir,sprintf('*_N%i.mat',NbUnits)));
        repertoire_refined_content=dir(fullfile(handles.repertoiredir,sprintf('*_N%i*+.mat',NbUnits)));
        repertoire_content(end+1:end+length(repertoire_refined_content))=repertoire_refined_content;
        set(handles.repertoireList,'value',1);
        set(handles.repertoireList,'string',{repertoire_content.name});
        categoriesel=cellfun(@num2str,mat2cell([5:5:length(repertoire_content)*NbUnits]',ones(length(repertoire_content)*NbUnits/5,1)),'un',0);
        if ~isempty(categoriesel)
            set(handles.categories,'string',categoriesel);
        end
    end
end
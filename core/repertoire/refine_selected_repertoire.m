% refine_selected_repertoire
function refine_selected_repertoire(handles,repertoireName)

    repertoiredir=handles.repertoiredir;
    repertoire_filename=fullfile(repertoiredir,repertoireName);
    refined_repertoire_filename=strrep(repertoire_filename,'.mat','+.mat');

    NbIterRefine=10;

    choice='Yes';
    if exist(refined_repertoire_filename,'file') || ~isempty(strfind(repertoire_filename,'+.mat'));
    %     qstring='Repertoire was already refined. This operation will overwrite the existing repertoire. Would you like to continue refining?';
    %     choice=questdlg(qstring, 'Further repertoire refinement','Yes','No','No');
        qstring='Repertoire was already refined.';
        errordlg(qstring, 'Repertoire refined stopped');
        choice='No';
    end

    load(repertoire_filename,'datasetName');
    datasetNameRefine=fullfile(handles.datasetdir, sprintf('%s+.mat',datasetName));
    if exist(datasetNameRefine,'file')
        qstring='Dataset was already refined through a different repertoire.';
        qstring=sprintf('Dataset %s already exists. Probably refined through a different repertoire.', sprintf('%s+',datasetName)) ;
        errordlg(qstring, 'Multiple dataset refinements conflict');
        choice='No';
    end

    switch choice
        case 'No'
            return;
        case 'Yes'
            % load
            load(repertoire_filename,'bases','activations','NbUnits','NbChannels','NbPatternFrames','NbIter','dataset_dir','ndx_V','datasetName');

            x = inputdlg('Enter space-separated numbers:', sprintf('Units to be removed from repertoire %s:',strrep(repertoireName,'.mat','')),[1 80]);

            if isempty(x)
                return
            elseif isempty(str2num(x{:}))
                 errordlg('Invalid input.','Repertoire refinement stopped',[1 80]);
            else
                units = fix(str2num(x{:}));
                units = unique(units);

                if ~isempty(find(units > NbUnits | units <= 0, 1))
                    errordlg('Invalid input.','Repertoire refinement stopped',[1 80]);
                else

                    % remove elements from repertoire
                    remove_ndx_refine=vertcat(ndx_V{units});

                    % compute initial centroid for refined repertoire learning
                    bases_tmp=bases;
                    bases_init=bases;
                    bases_tmp(units)=[];
                    bases_init(units)=bases_tmp(1:length(units));
    %                 bases_init(units)=bases_tmp(end-length(units)+1:end);
                    W_init=zeros(NbChannels*(NbPatternFrames+1),NbUnits);
                    for k=1:NbUnits
                        W_init(:,k)=reshape(bases_init{k},NbChannels*(NbPatternFrames+1),1);
                    end
                    W_init=W_init';

                    % recompute repertoire
                    [bases, activations, bic, logL, syllable_similarity, syllable_correlation, repertoire_similarity, err, NbChannels, NbPatternFrames, NbUnits, NbIter, ndx_V, datasetNameRefined,msg] = repertoire_learning(handles, datasetName, NbUnits, NbChannels, NbIterRefine, remove_ndx_refine, W_init);
                    if isempty(bases)
                        if isempty(msg)
                            errordlg('Repertoire learning stopped. Too few syllables were detected in the audio data.','repertoire error');
                        else
                            errordlg(msg,'repertoire error');
                        end
                    else
                        % save
                        [~,datasetName]=fileparts(datasetNameRefined);
                        save(refined_repertoire_filename,'bases','activations','bic','logL','syllable_similarity','syllable_correlation','repertoire_similarity','NbUnits','NbChannels','NbPatternFrames','NbIter','dataset_dir','remove_ndx_refine','ndx_V','datasetName','-v6');
                        set(handles.repertoireList,'value',1);
                        delete(repertoire_filename);
                    end
                end
            end
    end
end
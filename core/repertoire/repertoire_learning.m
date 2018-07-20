% repertoire_learning
function [bases, activations, bic, logL, syllable_similarity, syllable_correlation, repertoire_similarity, err, NbChannels, NbPatternFrames, NbUnits, NbIter, ndx_V, datasetNameRefine,msg] = repertoire_learning(handles, datasetName, NbUnits, NbChannels, NbIter, remove_ndx_refine, W_init)

    % Inputs
    if ~exist('NbChannels', 'var')
       NbChannels=64;
    end
    if ~exist('NbUnits', 'var')
       NbUnits=100;
    end
    if ~exist('NbIter', 'var')
       NbIter=100;
    end
    if ~exist('remove_ndx_refine', 'var')
        remove_ndx_refine=[];
    end
    if ~exist('W_init', 'var')
        W_init=[];
    end

    NbPatternFrames=handles.patch_window;
    fs=handles.config{7};
    %fs=250000;
    frame_shift=floor(handles.frame_shift_ms*fs);
    min_nb_of_syllables=handles.repertoire_learning_min_nb_syllables_fac*NbUnits;

    % Gammatone features data
    load(fullfile(handles.datasetdir,datasetName),'dataset_content','dataset_dir','fs');
    flist=dataset_content;

    if isempty(remove_ndx_refine)
        h = waitbar(0,'Creating repertoire...');
    else
        h = waitbar(0,'Refining repertoire...');
    end

    % Accumulate GT sonogram frames
    V=[];
    backtrace.file=[];
    backtrace.start=[];
    fprintf('\nComputing input matrix\n');
    for fname = flist
         [~, filename]= fileparts(fname{1});
         syllable_file=fullfile(dataset_dir, sprintf('%s.mat', filename));

         if exist(syllable_file,'file'),
            fprintf('Loading MUSV of %s\n', filename);
            load(syllable_file,'syllable_data','filestats');
            syllable_data(3,:)={[]};

            % make input matrix
            Vi = mk_input_repertoire_learning(syllable_data(2,:), NbChannels, NbPatternFrames, filestats.TotNbFrames);
            V=[V Vi];
            backtrace.file=[backtrace.file syllable_data(1,:)];
            backtrace.start=[backtrace.start syllable_data(5,:)];

         else
            continue;
         end
    end

    if size(V,2) < min_nb_of_syllables
       msg=sprintf('WARNING: total number of detected syllables is less than %i\nBuild a smaller repertoire.\n', min_nb_of_syllables);
       errordlg(msg,'Repertoire learning stopped');
       bases={}; activations=[]; err=inf;
       return
    end

    % prepare data
    Vnorm = sqrt(sum(V.^2,1));
    remove_ndx = Vnorm<eps(max(Vnorm));
    V(:,remove_ndx)=[];

    % refinement
    msg='';
    datasetNameRefine=datasetName;
    if ~isempty(remove_ndx_refine)

        for fname = flist
            [~, filename]= fileparts(fname{1});
            syllable_file=fullfile(dataset_dir, sprintf('%s.mat', filename));
            audiofile=syllable_file;
            first_occur1=find(not(cellfun('isempty', strfind(backtrace.file,sprintf('%s.wav',filename)))),1);
            try
            	ndx1=not(cellfun('isempty', strfind(backtrace.file(remove_ndx_refine),sprintf('%s.wav',filename))));
                first_occur2=find(not(cellfun('isempty', strfind(backtrace.file,sprintf('%s.WAV',filename)))),1);
                ndx2=not(cellfun('isempty', strfind(backtrace.file(remove_ndx_refine),sprintf('%s.WAV',filename))));
                if ~isempty(first_occur1)
                    ndx_remove=remove_ndx_refine(ndx1)-first_occur1+1;
                elseif ~isempty(first_occur2)
                    ndx_remove=remove_ndx_refine(ndx2)-first_occur2+1;
                else
                    ndx_remove=[];
                end
            catch
                 msg='Files were already refined from another repertoire.';
                 bases=[];activations=[];err=[];NbChannels=[];
                 NbPatternFrames=[];NbUnits=[];NbIter=[];ndx_V=[];datasetNameRefine=[];
                 return;
            end


            % update syllable stats
            load(syllable_file,'syllable_data','syllable_stats','filestats');
            syllable_use=ones(1,filestats.nb_of_syllables);
            syllable_use(ndx_remove)=0;
            configpar=filestats.configpar;

            % update file stats
            syllable_stats_orig = syllable_stats;
            [syllable_data, syllable_stats, filestats] = syllable_activity_file_stats(handles, audiofile, filestats.TotNbFrames, syllable_data, syllable_use);
            filestats.configpar=configpar;
            save(syllable_file,'syllable_stats_orig','syllable_data','syllable_stats','filestats','-append','-v6');

        end

        % refine data set
        datasetNameRefine=sprintf('%s+.mat',datasetName);
        save(fullfile(handles.datasetdir,datasetNameRefine),'dataset_content','dataset_dir','fs','-v6');
        syllable_activity_stats_refine(handles, datasetNameRefine);
        delete(fullfile(handles.datasetdir,sprintf('%s.mat',datasetName)));

        % input matrix
        V(:,remove_ndx_refine)=[];
    end

    % learn base patterns
    if isempty(remove_ndx_refine)
        fprintf('Learning repertoire unit\n');
        waitbar(0.5,h,'Clustering into repertoire units...');
    else
        waitbar(0.5,h,'Updating repertoire units...');
    end

    [W,~,J,~,bic,logL,syllable_similarity,syllable_correlation,repertoire_similarity]=kmeans_clustering(V', NbUnits, NbChannels, NbIter, W_init);
    W=W';

    % track input syllables
    ndx_V=cell(NbUnits,1);
    for k=1:NbUnits
       ndx_V{k}=find(J==k);
    end

    % sort bases
    [number_of_calls]=hist(J,NbUnits);
    [~, ndx_sort]=sort(number_of_calls,'descend');
    W=W(:,ndx_sort);
    syllable_similarity=syllable_similarity(:,ndx_sort);
    syllable_correlation=syllable_correlation(:,ndx_sort);
    ndx_V=ndx_V(ndx_sort);
    activations=zeros(size(J));
    for k=1:NbUnits
       activations(J==ndx_sort(k))=k;
    end

    % prepare outputs
    bases=cell(NbUnits,1);
    for kk=1:NbUnits
        bases{kk} = reshape(W(1:NbChannels*(NbPatternFrames+1),kk),NbChannels,(NbPatternFrames+1));
    end

    % reconstruction error
    whs=W(:,activations);
    err = sum(sum( (V-whs).^2))./size(V,2);

    if exist('h','var')
        close(h);
    end

end

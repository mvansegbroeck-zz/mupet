% ------------------------------------------------------------------------
% Copyright (C) 2015 University of Southern California, SAIL, U.S.
% Author: Maarten Van Segbroeck
% Mail: maarten@sipi.usc.edu
% Date: 2015-20-1
% ------------------------------------------------------------------------

function [bases, activations, err, NbChannels, NbPatternFrames, NbUnits, NbIter, ndx_V, datasetNameRefine] = repertoire_learning(handles, datasetName, NbUnits, NbChannels, NbPatternFrames, NbIter, remove_ndx_refine, W_init) 

    % FFT
    if ~exist('Nfft', 'var')
       Nfft=512;
    end
    % Inputs
    if ~exist('NbChannels', 'var')
       NbChannels=64;
    end
    if ~exist('NbPatternFrames', 'var')
       NbPatternFrames=100;
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
    min_nb_of_syllables=5*NbUnits;

    % Gammatone features data
    load(fullfile(handles.datasetdir,datasetName),'dataset_content','dataset_dir','fs');
    flist=dataset_content;

    % Accumulate GT sonogram frames
    V=[];
    backtrace.file=[];
    backtrace.start=[];
    fprintf('\nComputing input matrix\n');
    for fname = flist
         [~, filename]= fileparts(fname{1});
         syllable_file=fullfile(dataset_dir, sprintf('%s.mat', filename));

         if exist(syllable_file), 
            fprintf('Loading MUSV of %s\n', filename);
            load(syllable_file,'syllable_data','TotNbFrames');
            GT=syllable_data(2,:);
            filenames=syllable_data(1,:);        
            syllable_start=syllable_data(5,:);            

            % make input matrix
            Vi = mk_input_repertoire_learning(GT, NbChannels, NbPatternFrames, TotNbFrames);
            V=[V Vi];
            backtrace.file=[backtrace.file filenames];        
            backtrace.start=[backtrace.start syllable_start];

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
    datasetNameRefine=datasetName;
    if ~isempty(remove_ndx_refine)

        for fname = flist        
            [~, filename]= fileparts(fname{1});
            syllable_file=fullfile(dataset_dir, sprintf('%s.mat', filename));
            first_occur1=find(not(cellfun('isempty', strfind(backtrace.file,sprintf('%s.wav',filename)))),1);
            ndx1=find(not(cellfun('isempty', strfind(backtrace.file(remove_ndx_refine),sprintf('%s.wav',filename))))); 
            first_occur2=find(not(cellfun('isempty', strfind(backtrace.file,sprintf('%s.WAV',filename)))),1);
            ndx2=find(not(cellfun('isempty', strfind(backtrace.file(remove_ndx_refine),sprintf('%s.WAV',filename)))));  
            ndx=[first_occur1+ndx1-1;first_occur2+ndx2-1];
            load(syllable_file,'syllable_data','TotNbFrames');
            if ~isempty(first_occur1)            
                ndx_remove=remove_ndx_refine(ndx1)-first_occur1+1;
            elseif ~isempty(first_occur2)
                ndx_remove=remove_ndx_refine(ndx2)-first_occur2+1;            
            else
                ndx_remove=[];
            end
            syllable_data(7,ndx_remove)={0};
            save(syllable_file,'syllable_data','TotNbFrames');  
        end

        % refine data set 
        datasetNameRefine=sprintf('%s+.mat',datasetName);
        save(fullfile(handles.datasetdir,datasetNameRefine),'dataset_content','dataset_dir','fs');   
        syllable_activity_stats_refine(handles, datasetNameRefine);
        delete(fullfile(handles.datasetdir,sprintf('%s.mat',datasetName)));

        % input matrix
        V(:,remove_ndx_refine)=[];
    end

    % learn base patterns
    fprintf('Learning base patterns\n');
    [W,esq,J,remove_ndx]=kmeans_clustering(V', NbUnits, NbChannels, NbIter, W_init);
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
    
end

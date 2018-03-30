% export_csv_repertoires
function export_csv_repertoires(handles,repertoireNames)

    csvdir=fullfile(handles.repertoiredir,'CSV');
    if ~exist(csvdir,'dir')
      mkdir(csvdir)
    end

    % csv header
    csv_header=sprintf('%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s\n', ...
        'repertoire unit (RU) number', ...
        'number of syllables', ...
        'syllable-to-centroid distance (mean)', ...
        'syllable-to-centroid distance (std)', ...
        'syllable-to-centroid correlation (mean)', ...
        'syllable-to-centroid correlation (std)', ...
        'final freq - start freq (+/- kHz)', ...
        'mean freq - start freq (+/- kHz)', ...
        'mean freq - final freq (+/- kHz)', ...
        'average frequency bandwidth (kHz)', ...
        'RU duration (msec)');
    csv_header1=sprintf('%s,%s,%s,%s,%s,%s\n', ...
        'dataset', ...
        'repertoire file', ...
        'syllable number', ...
        'syllable start time (sec)', ...
        'syllable end time (sec)', ...
        'repertoire unit (RU) number');

    for repertoireID = 1:length(repertoireNames)
        repertoireName=repertoireNames{repertoireID};
        repertoire_filename=fullfile(handles.repertoiredir,repertoireName);

        fprintf('Exporting repertoire %s \n', strrep(repertoireName,'.mat','') );

        % load
        load(repertoire_filename,'activations','NbUnits','ndx_V','datasetName','bic','logL','syllable_similarity','syllable_correlation','repertoire_similarity');
        H=activations';

        [number_of_calls]=hist(H,NbUnits);
        %[percentage_of_calls,~]=sort(number_of_calls./sum(number_of_calls)*100,'descend');
        number_of_calls=sort(number_of_calls,'descend');

        csvfile=fullfile(csvdir, strrep(repertoireName,'.mat','.csv'));
        fid = fopen(csvfile,'wt');
        fwrite(fid, csv_header);

        csvfile1=fullfile(csvdir, strrep(repertoireName,'.mat','_syllable_sequence.csv'));
        fid1 = fopen(csvfile1,'wt');
        fwrite(fid1, csv_header1);

        % Gammatone features data
        datasetfile = fullfile(handles.datasetdir,datasetName);
        if ~exist(sprintf('%s.mat', datasetfile),'file')
            datasetfile = fullfile(handles.datasetdir,sprintf('%s+',datasetName));
        end
        load(datasetfile,'dataset_content','dataset_dir','fs');
        flist=dataset_content;

        % Accumulate GT sonogram frames
        freq_start=[];
        freq_final=[];
        freq_min=[];
        freq_max=[];
        freq_mean=[];
        freq_bw=[];
        syl_tot_en=[];
        syl_dur=[];
        syl_cnts=0;
        repertoire_unit_sequence=cell(length(flist),1);
        fnameID = 1;
        for fname = flist
             [~, filename]= fileparts(fname{1});
             syllable_file=fullfile(dataset_dir, sprintf('%s.mat', filename));

             if exist(syllable_file,'file'),
                fprintf('Loading MUSV of %s\n', filename);

                load(syllable_file,'syllable_stats');
                nb_syllables = size(syllable_stats,2);
                repertoire_unit_sequence{fnameID} = activations(syl_cnts+1:syl_cnts + nb_syllables);
                syl_cnts = syl_cnts + size(syllable_stats,2);
                if ~strcmp(repertoire_filename(end-4:end),'+.mat') && strcmp(datasetfile(end),'+'),
                    load(syllable_file,'syllable_stats_orig');
                    syllable_stats=syllable_stats_orig;
                end

                freq_start=[freq_start syllable_stats{2,:}];
                freq_final=[freq_final syllable_stats{3,:}];
                freq_min=[freq_min syllable_stats{4,:}];
                freq_max=[freq_max syllable_stats{5,:}];
                freq_bw=[freq_bw syllable_stats{6,:}];
                freq_mean=[freq_mean syllable_stats{10,:}];
                syl_tot_en=[syl_tot_en syllable_stats{11,:}];
                syl_dur=[syl_dur syllable_stats{13,:}];

             else
                continue;
             end

             for syllableID = 1:nb_syllables
                 syllable_seq_info=sprintf('%s,%s,%i,%.4f,%.4f,%i\n', ...
                     datasetName, ...
                     filename, ...
                     syllableID, ...
                     syllable_stats{8,syllableID}, ...
                     syllable_stats{9,syllableID}, ...
                     repertoire_unit_sequence{fnameID}(syllableID));
                fwrite(fid1, syllable_seq_info);
             end

             fnameID = fnameID + 1;
        end
        fclose(fid1);

        plus_sign={'','+'};
        for unitID = 1:length(number_of_calls)

            % final - start
            % if final>>start and mean frequency between (upward)
            % if final<<start and mean frequency between (upward)
            % if final~=start and mean frequency between and bandwidth small (flat)
            % ...
            freq_final_minus_start=freq_final(ndx_V{unitID})-freq_start(ndx_V{unitID});
            [tmp1,tmp2]=hist(freq_final_minus_start,5); [tmp3,tmp4]=max(tmp1); freq_final_minus_start_avg=tmp2(tmp4);

            freq_mean_minus_start=freq_mean(ndx_V{unitID})-freq_start(ndx_V{unitID});
    %         [tmp1,tmp2]=hist(freq_mean_minus_start,5); [tmp3,tmp4]=max(tmp1); freq_mean_minus_start_avg=tmp2(tmp4);
            freq_mean_minus_start_avg=mean(freq_mean_minus_start);
            freq_min_minus_start=freq_min(ndx_V{unitID})-freq_start(ndx_V{unitID});
    %         [tmp1,tmp2]=hist(freq_min_minus_start,5); [tmp3,tmp4]=max(tmp1); freq_min_minus_start_avg=tmp2(tmp4);
            freq_min_minus_start_avg=mean(freq_min_minus_start);
            freq_max_minus_start=freq_max(ndx_V{unitID})-freq_start(ndx_V{unitID});
    %         [tmp1,tmp2]=hist(freq_max_minus_start,5); [tmp3,tmp4]=max(tmp1); freq_max_minus_start_avg=tmp2(tmp4);
            freq_max_minus_start_avg=mean(freq_max_minus_start);

            freq_mean_minus_final=freq_mean(ndx_V{unitID})-freq_final(ndx_V{unitID});
    %         [tmp1,tmp2]=hist(freq_mean_minus_final,5); [tmp3,tmp4]=max(tmp1); freq_mean_minus_final_avg=tmp2(tmp4);
            freq_mean_minus_final_avg=mean(freq_mean_minus_final);
            freq_min_minus_final=freq_min(ndx_V{unitID})-freq_final(ndx_V{unitID});
    %         [tmp1,tmp2]=hist(freq_min_minus_final,5); [tmp3,tmp4]=max(tmp1); freq_min_minus_final_avg=tmp2(tmp4);
            freq_min_minus_final_avg=mean(freq_min_minus_final);
            freq_max_minus_final=freq_max(ndx_V{unitID})-freq_final(ndx_V{unitID});
    %         [tmp1,tmp2]=hist(freq_max_minus_final,5); [tmp3,tmp4]=max(tmp1); freq_max_minus_final_avg=tmp2(tmp4);
            freq_max_minus_final_avg=mean(freq_max_minus_final);

            [tmp1,tmp2]=hist(freq_start(ndx_V{unitID}),5); [tmp3,tmp4]=max(tmp1); freq_start_avg=tmp2(tmp4);
            [tmp1,tmp2]=hist(freq_final(ndx_V{unitID}),5); [tmp3,tmp4]=max(tmp1); freq_final_avg=tmp2(tmp4);
            [tmp1,tmp2]=hist(freq_min(ndx_V{unitID}),5); [tmp3,tmp4]=max(tmp1); freq_min_avg=tmp2(tmp4);
            [tmp1,tmp2]=hist(freq_max(ndx_V{unitID}),5); [tmp3,tmp4]=max(tmp1); freq_max_avg=tmp2(tmp4);
            [tmp1,tmp2]=hist(freq_bw(ndx_V{unitID}),5); [tmp3,tmp4]=max(tmp1); freq_bw_avg=tmp2(tmp4);
            [tmp1,tmp2]=hist(freq_mean(ndx_V{unitID}),5); [tmp3,tmp4]=max(tmp1); freq_mean_avg=tmp2(tmp4);
            [tmp1,tmp2]=hist(syl_tot_en(ndx_V{unitID}),5); [tmp3,tmp4]=max(tmp1); syl_en_avg=tmp2(tmp4);
            [tmp1,tmp2]=hist(syl_dur(ndx_V{unitID}),5); [tmp3,tmp4]=max(tmp1); syl_dur_avg=tmp2(tmp4);

            % print unit information
            dataset_info=sprintf('%i,%i,%.4f,%.4f,%.4f,%.4f,%+.2f,%+.2f,%+.2f,%.2f,%.2f\n', ...
                unitID, ...
                number_of_calls(unitID), ...
                syllable_similarity(1,unitID), ...
                syllable_similarity(2,unitID), ...
                syllable_correlation(1,unitID), ...
                syllable_correlation(2,unitID), ...
                freq_final_minus_start_avg, ...
                freq_mean_minus_start_avg, ...
                freq_mean_minus_final_avg, ...
                freq_bw_avg, ...
                syl_dur_avg);
            fwrite(fid, dataset_info);
        end
        fclose(fid);
    end
end
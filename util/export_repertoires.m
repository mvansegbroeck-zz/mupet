% ------------------------------------------------------------------------
% Copyright (C) 2015 University of Southern California, SAIL, U.S.
% Author: Maarten Van Segbroeck
% Mail: maarten@sipi.usc.edu
% Date: 2015-20-1
% ------------------------------------------------------------------------

function export_repertoires(handles,repertoireNames) 

    csvdir=fullfile(handles.repertoiredir,'CSV');
    if ~exist(csvdir)
      mkdir(csvdir)
    end

    % csv header
    csv_header=sprintf('%s,%s,%s,%s,%s,%s,%s\n', ...
        'syllable unit number', ...
        'number of calls', ...
        'final freq - start freq (+/- kHz)', ...    
        'mean freq - start freq (+/- kHz)', ...     
        'mean freq - final freq (+/- kHz)', ...
        'frequency bandwidth (kHz)', ...
        'syllable unit duration (msec)');

    for repertoireID = 1:length(repertoireNames)
        repertoireName=repertoireNames{repertoireID};
        repertoire_filename=fullfile(handles.repertoiredir,repertoireName);

        % load
        load(repertoire_filename,'activations','NbUnits','ndx_V','datasetName');    
        H=activations';

        [number_of_calls]=hist(H,NbUnits);
        %[percentage_of_calls,~]=sort(number_of_calls./sum(number_of_calls)*100,'descend');
        number_of_calls=sort(number_of_calls,'descend');

        csvfile=fullfile(csvdir, strrep(repertoireName,'.mat','.csv'));
        fid = fopen(csvfile,'wt');
        fwrite(fid, csv_header);

        % Gammatone features data
        load(fullfile(handles.datasetdir,datasetName),'dataset_content','dataset_dir','fs');
        flist=dataset_content;

        % Accumulate GT sonogram frames
        freq_start=[];
        freq_final=[];
        freq_min=[];
        freq_max=[];
        freq_mean=[];
        freq_bw=[];
        syl_en=[];
        syl_dur=[];
        for fname = flist
             [~, filename]= fileparts(fname{1});
             syllable_file=fullfile(dataset_dir, sprintf('%s.mat', filename));

             if exist(syllable_file), 
                fprintf('Loading MUSV of %s\n', filename);
                load(syllable_file,'syllable_stats','TotNbFrames');

                freq_start=[freq_start syllables{2,:}];
                freq_final=[freq_final syllables{3,:}];
                freq_min=[freq_min syllables{4,:}];
                freq_max=[freq_max syllables{5,:}];
                freq_bw=[freq_bw syllables{6,:}];
                freq_mean=[freq_mean syllables{10,:}];
                syl_en=[syl_en syllables{7,:}];
                syl_dur=[syl_dur syllables{13,:}];

             else
                continue;
             end
        end

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
            [tmp1,tmp2]=hist(syl_en(ndx_V{unitID}),5); [tmp3,tmp4]=max(tmp1); syl_en_avg=tmp2(tmp4);
            [tmp1,tmp2]=hist(syl_dur(ndx_V{unitID}),5); [tmp3,tmp4]=max(tmp1); syl_dur_avg=tmp2(tmp4);    

            % print unit information
            dataset_info=sprintf('%i,%i,%+.2f,%+.2f,%+.2f,%.2f,%.2f\n', ...
                unitID, ...
                number_of_calls(unitID), ...
                freq_final_minus_start_avg, ...
                freq_mean_minus_start_avg, ...   
                freq_mean_minus_final_avg, ...
                freq_bw_avg, ...
                syl_dur_avg);
            fwrite(fid, dataset_info);
        end
        fclose(fid);
end


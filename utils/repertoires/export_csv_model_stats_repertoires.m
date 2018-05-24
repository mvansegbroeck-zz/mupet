% export_csv_model_stats_repertoires
function export_csv_model_stats_repertoires(handles, repertoireNames)

    csvdir=fullfile(handles.repertoiredir,'CSV');
    if ~exist(csvdir,'dir')
      mkdir(csvdir)
    end

    % csv header
    csv_header=sprintf('%s,%s,%s,%s\n', ...
        'repertoire name', ...
        'overall repertoire modeling score', ...
        'average log-likelihood', ...
        'Bayesian Information Criterion (BIC)');

    csvfile=fullfile(csvdir, 'repertoire_modeling_info.csv');
    fid = fopen(csvfile,'wt');
    fwrite(fid, csv_header);

    for repertoireID = 1:length(repertoireNames)
        repertoireName=repertoireNames{repertoireID};
        repertoire_filename=fullfile(handles.repertoiredir,repertoireName);

        % load
        load(repertoire_filename,'bic','logL','repertoire_similarity');

        repertoire_info=sprintf('%s,%.3f,%.1f,%.1f\n', ...
                strrep(repertoireName,'.mat',''), ...
                repertoire_similarity(1), ...
                logL, ...
                bic);
        fwrite(fid, repertoire_info);
    end
    fclose(fid);
end
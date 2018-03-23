% export_csv_dataset_content
function export_csv_dataset_content(dataset_items, handles)

    csvdir=fullfile(handles.datasetdir,'CSV');
    if ~exist(csvdir)
      mkdir(csvdir)
    end

    % csv header
    csv_header=sprintf('%s,%s,%s\n', ...
        'data set', ...
        'file path', ...
        'file name');

    csvfile=fullfile(csvdir, sprintf('datasets_file_content.csv'));
    fid = fopen(csvfile,'wt');
    fwrite(fid, csv_header);

    for dataset_ndx = 1:length(dataset_items)
        datasetname=dataset_items{dataset_ndx};
        load(fullfile(handles.datasetdir,sprintf('%s.mat',datasetname)),'dataset_content','dataset_dir');

        fprintf('\nContent of dataset "%s"\n',sprintf('%s.mat',dataset_items{dataset_ndx}));
        fprintf('directory:   %s\n',dataset_dir);
        for k=1:length(dataset_content)
            % command window
            if k==1
                fprintf('files:       %s\n',dataset_content{k});
            else
                fprintf('             %s\n',dataset_content{k});
            end
            % print syllable information
            dataset_info=sprintf('%s,%s,%s\n', ...
                datasetname, ...
                dataset_dir, ...
                dataset_content{k});
            fwrite(fid, dataset_info);
        end

    end

    fclose(fid);

end
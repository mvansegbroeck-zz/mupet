% ------------------------------------------------------------------------
% Copyright (C) 2015 University of Southern California, SAIL, U.S.
% Author: Maarten Van Segbroeck
% Mail: maarten@sipi.usc.edu
% Date: 2015-20-1
% ------------------------------------------------------------------------

function delete_datasets(handles)

dataset_items=get(handles.dataset_list,'string');
selected_dataset=get(handles.dataset_list,'value');
if ~isempty(dataset_items)
    delete(fullfile(handles.datasetdir,sprintf('%s.mat',dataset_items{selected_dataset})));
    datasetNames=dir(fullfile(handles.datasetdir,'*.mat'));
    set(handles.dataset_list,'value',1);
    set(handles.dataset_list,'string',strrep({datasetNames.name},'.mat',''));
end
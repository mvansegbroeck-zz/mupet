% ------------------------------------------------------------------------
% Copyright (C) 2015 University of Southern California, SAIL, U.S.
% Author: Maarten Van Segbroeck
% Mail: maarten@sipi.usc.edu
% Date: 2015-20-1
% ------------------------------------------------------------------------

function refresh_datasets(handles)

datasetNames=dir(fullfile(handles.datasetdir,'*.mat'));
set(handles.dataset_list,'string',strrep({datasetNames.name},'.mat',''));
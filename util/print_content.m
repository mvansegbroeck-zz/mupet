% ------------------------------------------------------------------------
% Copyright (C) 2015 University of Southern California, SAIL, U.S.
% Author: Maarten Van Segbroeck
% Mail: maarten@sipi.usc.edu
% Date: 2015-20-1
% ------------------------------------------------------------------------

function print_content(handles)

dataset_items=get(handles.dataset_list,'string');
if ~isempty(dataset_items)
    export_csv_dataset_content(dataset_items, handles);
end
msgbox(sprintf('***              All data sets exported to CSV files              ***\n See folder %s/CSV',handles.datasetdir),'MUPET info');

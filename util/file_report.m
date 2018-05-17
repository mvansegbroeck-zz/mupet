% ------------------------------------------------------------------------
% Copyright (C) 2015 University of Southern California, SAIL, U.S.
% Author: Maarten Van Segbroeck
% Mail: maarten@sipi.usc.edu
% Date: 2015-20-1
% ------------------------------------------------------------------------

function file_report(handles)

wav_items=get(handles.wav_list,'string');
wav_dir=get(handles.wav_directory,'string');
if ~isempty(wav_dir)
    compute_csv_stats(wav_dir,wav_items,handles);
end
msgbox(sprintf('***              All files exported to CSV files              ***\n See folder %s/CSV',handles.audiodir),'MUPET info');
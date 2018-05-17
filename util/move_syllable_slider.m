% ------------------------------------------------------------------------
% Copyright (C) 2015 University of Southern California, SAIL, U.S.
% Author: Maarten Van Segbroeck
% Mail: maarten@sipi.usc.edu
% Date: 2015-20-1
% ------------------------------------------------------------------------

function move_syllable_slider(handles)

if isempty(handles.syllable_stats)
    errordlg('Please select and process an audio file.','No audio file selected/processed')
else
    syllable_ndx = round(get(handles.syllable_slider,'Value')./(get(handles.syllable_slider,'Max')) * (size(handles.syllable_stats,2)-1) + 1);
    % make syllable patch
    show_syllables(handles,syllable_ndx);        
end

% ------------------------------------------------------------------------
% Copyright (C) 2015 University of Southern California, SAIL, U.S.
% Author: Maarten Van Segbroeck
% Mail: maarten@sipi.usc.edu
% Date: 2015-20-1
% ------------------------------------------------------------------------

function handles=ignore_file(handles)

wav_items=get(handles.wav_list,'string');
selected_wav=get(handles.wav_list,'value');
if ~isempty(wav_items)
    handles.flist(strcmp(handles.flist,wav_items{selected_wav}))=[];    
    wav_items(selected_wav)=[];
    set(handles.wav_list,'value',1);
    set(handles.wav_list,'string',wav_items); 
end

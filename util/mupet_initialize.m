% ------------------------------------------------------------------------
% Copyright (C) 2015 University of Southern California, SAIL, U.S.
% Author: Maarten Van Segbroeck
% Mail: maarten@sipi.usc.edu
% Date: 2015-20-1
% ------------------------------------------------------------------------

function handles=mupet_initialize(handles)

handles.flist='';
handles.datadir='';
handles.repertoiredir='repertoires';
handles.datasetdir='datasets';
handles.denoising=false;

handles.frame_shift_ms=0.0004; % ms
handles.frame_win_ms=0.002; % ms

set(handles.nbunits,'Value',4);
units=get(handles.nbunits,'String');
NbUnits=str2double(units(get(handles.nbunits,'Value')));
repertoire_content=dir(fullfile(handles.repertoiredir,sprintf('*_N%i.mat',NbUnits)));
repertoire_refined_content=dir(fullfile(handles.repertoiredir,sprintf('*_N%i*+.mat',NbUnits)));
repertoire_content(end+1:end+length(repertoire_refined_content))=repertoire_refined_content;
set(handles.repertoire_list,'string',{repertoire_content.name});
datasetNames=dir(fullfile(handles.datasetdir,'*.mat'));
set(handles.dataset_list,'string',strrep({datasetNames.name},'.mat',''));
handles.syllable_stats='';
handles.sample_frequency=0;
handles.filename='';
handles.patch_window=200 / handles.frame_shift_ms * 1e-3; % ms divided by frameshift
makeurl(handles.wiki,'https://github.com/mvansegbroeck/mupet/wiki/MUPET-wiki');
makeurl(handles.code,'https://github.com/mvansegbroeck/mupet/');
defaultFigPos=get(0,'DefaultFigurePosition');
set(0,'DefaultFigurePosition',[1 defaultFigPos(2) defaultFigPos(3) defaultFigPos(4)]);
[handles.FontSize1, handles.FontSize2, handles.FontSize3]=setGuiFonts(handles);
set(handles.syllable_slider,'Visible','off');
set(handles.syllable_axes_fft,'Visible','off');
set(handles.syllable_axes_gt,'Visible','off');
set(handles.noisereduction,'Visible','off');

% config file
handles.configdefault{1}=5; % noise_reduction_sigma_default
handles.configdefault{2}=8; % min_syllable_duration_default
handles.configdefault{3}=-15; % min_syllable_total_energy_default
handles.configdefault{4}=-25; % min_syllable_peak_amplitude_default
handles.configdefault{5}=5; % min_syllable_distance_default

handles.configfile=fullfile(pwd,'config.csv');
handles = create_configfile(handles, true);

% ------------------------------------------------------------------------
% Copyright (C) 2015 University of Southern California, SAIL, U.S.
% Author: Maarten Van Segbroeck
% Mail: mvansegbroeck@gmail.com
% Date: 08-22-2017
% Author: Arshdeep Singh
% Mail: arshdeep.dtu@gmail.com
% Date: 05-24-2018
% ------------------------------------------------------------------------

function varargout = mupet(varargin)

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @mupet_OpeningFcn, ...
                   'gui_OutputFcn',  @mupet_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
delete(findall(0,'tag','Msgbox_MUPET info'));
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end

end

% End initialization code - DO NOT EDIT
%%%
%%% MUPET INITIALIZATION
%%%
function mupet_OpeningFcn(hObject, eventdata, handles, varargin)
% Choose default command line output for mupet
handles.output = hObject;
% add path
% addpath util;
% Initalize mupet
handles=mupet_initialize(handles);
% Update handles structure
guidata(hObject, handles);
end

function varargout = mupet_OutputFcn(hObject, eventdata, handles)
% Get default command line output from handles structure
varargout{1} = handles.output;
end

%%% UTILITY FUNCTIONS - MUPET INITIALIZATION

function handles=mupet_initialize(handles)

    disp('                             _           ____    ___  ');
    disp('  _ __ ___  _   _ _ __   ___| |_  __   _|___ \  / _ \ ');
    disp(' | |_ \ _ \| | | | |_ \ / _ \ __| \ \ / / __) || | | |');
    disp(' | | | | | | |_| | |_) |  __/ |_   \ V / / __/ | |_| |');
    disp(' |_| |_| |_|\__,_| .__/ \___|\__|   \_/ |_____(_)___/ ');
    disp('                 |_|                                  ');

    %add 'utils' path
    addpath(genpath('./utils'))
    addpath(genpath('./gui_setup'))
    addpath(genpath('./core'))
%     handles.workspace_dir='';
    handles.flist='';
    handles.datadir='';
    handles.repertoiredir='repertoires';
    handles.datasetdir='datasets';
    handles.workspace_dir = pwd;
    handles.denoising=false;

    % feature extraction
    handles.feature_ext_segment_duration=10; % seconds
    handles.frame_shift_ms=0.0004*4; % ms
    handles.frame_win_ms=0.002; % ms

    % syllable detection
    handles.syllable_stats='';
    handles.sample_frequency=0;
    handles.filename='';
    handles.max_inter_syllable_distance=200;
    handles.psd_smoothing_window_freq=10;

    % repertoire learning
    handles.repertoire_learning_min_nb_syllables_fac=1;
    handles.repertoire_unit_size_seconds=200;
    handles.patch_window=handles.repertoire_unit_size_seconds/handles.frame_shift_ms*1e-3; % ms divided by frameshift

    % user interface
    makeurl(handles.wiki,'https://github.com/mvansegbroeck/mupet/wiki/MUPET-wiki');
    makeurl(handles.code,'https://github.com/mvansegbroeck/mupet/');
    [handles.FontSize1, handles.FontSize2, handles.FontSize3, handles.FontSize4]=setGuiFonts(handles);
    set(handles.syllableSlider,'Visible','off');
    set(handles.syllable_axes_fft,'Visible','off');
    set(handles.syllable_axes_gt,'Visible','off');
%     set(handles.noisereduction,'Visible','off');
    set(handles.nbunits,'Value',4);
    units=get(handles.nbunits,'String');
    NbUnits=str2double(units(get(handles.nbunits,'Value')));
    repertoire_content=dir(fullfile(handles.repertoiredir,sprintf('*_N%i.mat',NbUnits)));
    repertoire_refined_content=dir(fullfile(handles.repertoiredir,sprintf('*_N%i*+.mat',NbUnits)));
    repertoire_content(end+1:end+length(repertoire_refined_content))=repertoire_refined_content;
    set(handles.repertoireList,'string',{repertoire_content.name});
    datasetNames=dir(fullfile(handles.datasetdir,'*.mat'));
    set(handles.datasetList,'string',strrep({datasetNames.name},'.mat',''));

    % title
    mupet_title='MUPET v2.0';
    set(handles.mupet_title,'String',mupet_title,'Fontsize',handles.FontSize4)

    % config file
    handles.configdefault{1}=5; % noise_reduction_sigma_default
    handles.configdefault{2}=8; % min_syllable_duration_default
    handles.configdefault{3}=handles.repertoire_unit_size_seconds; % max_syllable_duration_default
    handles.configdefault{4}=-15; % min_syllable_total_energy_default
    handles.configdefault{5}=-25; % min_syllable_peak_amplitude_default
    handles.configdefault{6}=5; % min_syllable_distance_default
    handles.configdefault{7}=250000; % sample_frequency
    handles.configdefault{8}=35000; % minimum_usv_frequency
    handles.configdefault{9}=110000; % maximum_usv_frequency
    handles.configdefault{10}=64; % number_filterbank_filters
    handles.configdefault{11}=0; % filterbank_type, 0: non-linear, 1: linear
    
    handles.configfile=fullfile(handles.workspace_dir,'config.csv');
    handles = create_configfile(handles, true);
%     handles = load_configfile(handles);
    handles.workspace_dir = 0;
    handles.mupet_root_dir = pwd;
    
end


% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
handles.mupet_root_dir = pwd;
handles.workspace_dir = 0;
addpath(genpath('./utils'))
addpath(genpath('./gui_setup'))
addpath(genpath('./core'))
end
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

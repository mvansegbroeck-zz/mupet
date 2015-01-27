% ------------------------------------------------------------------------
% Copyright (C) 2015 University of Southern California, SAIL, U.S.
% Author: Maarten Van Segbroeck
% Mail: maarten@sipi.usc.edu
% Date: 2015-20-1
% ------------------------------------------------------------------------

function varargout = mupet(varargin)

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @mupet_OpeningFcn, ...
                   'gui_OutputFcn',  @mupet_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end

% End initialization code - DO NOT EDIT


% --- Executes just before mupet is made visible.
function mupet_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to mupet (see VARARGIN)

% Choose default command line output for mupet
handles.output = hObject;
handles.flist='';
handles.datadir='';
handles.basedir='bases';
handles.datasetdir='datasets';
addpath util;
set(handles.nbunits,'Value',4);
units=get(handles.nbunits,'String');
NbUnits=str2double(units(get(handles.nbunits,'Value')));
base_content=dir(fullfile(handles.basedir,sprintf('*_N%i.mat',NbUnits)));
set(handles.repertoire_list,'string',{base_content.name});
datasetNames=dir(fullfile(handles.datasetdir,'*.mat'));
set(handles.dataset_list,'string',strrep({datasetNames.name},'.mat',''));
handles.syllables='';
handles.sample_frequency=0;
handles.filename='';
handles.patch_window=120;
defaultFigPos=get(0,'DefaultFigurePosition');
set(0,'DefaultFigurePosition',[1 defaultFigPos(2) defaultFigPos(3) defaultFigPos(4)]);
[handles.FontSize1, handles.FontSize2, handles.FontSize3]=setGuiFonts(handles);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes mupet wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = mupet_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


%%% AUDIO FILES
function opendir_Callback(hObject, eventdata, handles)
handles.datadir = uigetdir;
filelist1=dir(fullfile(handles.datadir,'*.WAV'));
filelist2=dir(fullfile(handles.datadir,'*.wav'));
if (length(filelist1)+length(filelist2)) > 0,
    handles.flist={ filelist1.name filelist2.name };
    content=handles.flist;
else
    content=sprintf('No wave files found in directory\n');        
end
guidata(hObject, handles);
set(handles.wav_directory,'string',handles.datadir);
set(handles.wav_list,'string',content); 

function wav_list_Callback(hObject, eventdata, handles)

function wav_list_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function process_file_Callback(hObject, eventdata, handles)
wav_items=get(handles.wav_list,'string');
selected_wav=get(handles.wav_list,'value');
wav_dir=get(handles.wav_directory,'string');
if ~isempty(wav_dir)
    compute_musv(wav_dir,wav_items(selected_wav),handles);
    [syllables, fs] = syllable_activity_file_stats(wav_dir, wav_items{selected_wav});
    handles.syllables = syllables;
    handles.sample_frequency = fs;
    handles.filename = wav_items{selected_wav};
    if length(syllables) >= 1
        set(handles.syllable_slider,'Value',0);
        set(handles.syllable_slider,'Max',length(syllables)-2);
        set(handles.syllable_slider,'Min',0);
        set(handles.syllable_slider,'SliderStep',[1/(double(length(syllables)-1)) 0.01]);
        syllable_ndx=1;

        % make syllable patch
        show_syllables(handles,syllable_ndx);

        % update handles
        guidata(hObject, handles);
    end
end

function process_all_Callback(hObject, eventdata, handles)
wav_items=get(handles.wav_list,'string');
wav_dir=get(handles.wav_directory,'string');
if ~isempty(wav_dir)
    compute_musv(wav_dir,wav_items,handles);
end

function file_report_Callback(hObject, eventdata, handles)
wav_items=get(handles.wav_list,'string');
selected_wav=get(handles.wav_list,'value');
wav_dir=get(handles.wav_directory,'string');
if ~isempty(wav_dir)
    compute_musv(wav_dir,wav_items(selected_wav),handles);
    syllables = syllable_activity_file_stats(wav_dir, wav_items{selected_wav});
    show_file_stats(wav_items{selected_wav},syllables);
end

%%% SYLLABLE INSPECTOR

function syllable_slider_Callback(hObject, eventdata, handles)
if isempty(handles.syllables)
    errordlg('Please select and process an audio file.','No audio file selected/processed')
else
    syllable_ndx = round(get(handles.syllable_slider,'Value')./(get(handles.syllable_slider,'Max')) * (length(handles.syllables)-1) + 1);    
    % make syllable patch
    show_syllables(handles,syllable_ndx);        
end

% --- Executes during object creation, after setting all properties.
function syllable_slider_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



%%% DATASETS
function create_dataset_Callback(hObject, eventdata, handles)
wav_dir=get(handles.wav_directory,'string');
if isempty(wav_dir)
    errordlg('Please select an audio directory first.','No data directory name');
else
    dataset_content=dir(fullfile(handles.datadir,'GT64','*.mat'));
    dataset_dir=handles.datadir;
    datasetName=get(handles.dataset_name,'String');
    if isempty(datasetName)
        errordlg('Please give a name for the dataset.','No dataset name');
        choice='No';
    elseif exist(fullfile(handles.datasetdir,sprintf('%s.mat',datasetName)))
        choice = questdlg('A dataset with same name already exists. Overwrite?', ...
                    'Dataset exists', ...
                    'Yes','No','No');
    else          
        choice='Yes';
    end
    if strcmp(choice,'Yes')
        if ~isempty(handles.flist)
            compute_musv(wav_dir,handles.flist,handles);
        end
        if ~exist(handles.datasetdir,'dir')
            mkdir(handles.datasetdir);
        end
        wav_items=get(handles.wav_list,'string');        
        fprintf('Creating data set: %s\n', datasetName);
        dataset_matfile = fullfile(handles.datasetdir,sprintf('%s.mat',datasetName));
        syllable_activity_stats(wav_dir, wav_items, dataset_matfile);
        datasetNames=dir(fullfile(handles.datasetdir,'*.mat'));
        set(handles.dataset_list,'value',1);
        set(handles.dataset_list,'string',strrep({datasetNames.name},'.mat',''));            
        fprintf('Done.\n');
    end
end

function print_content_Callback(hObject, eventdata, handles)
dataset_items=get(handles.dataset_list,'string');
selected_dataset=get(handles.dataset_list,'value');
if ~isempty(dataset_items)
    load(fullfile(handles.datasetdir,sprintf('%s.mat',dataset_items{selected_dataset})),'dataset_content','dataset_dir');
    fprintf('\nContent of dataset "%s"\n',sprintf('%s.mat',dataset_items{selected_dataset}));
    fprintf('directory:   %s\n',dataset_dir);
    for k=1:length(dataset_content)
        if k==1
            fprintf('files:       %s\n',dataset_content(k).name);
        else
            fprintf('             %s\n',dataset_content(k).name);
        end
    end
end

function dataset_list_Callback(hObject, eventdata, handles)

function dataset_list_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function refresh_datasets_Callback(hObject, eventdata, handles)
datasetNames=dir(fullfile(handles.datasetdir,'*.mat'));
set(handles.dataset_list,'string',strrep({datasetNames.name},'.mat',''));

function delete_dataset_Callback(hObject, eventdata, handles)
dataset_items=get(handles.dataset_list,'string');
selected_dataset=get(handles.dataset_list,'value');
if ~isempty(dataset_items)
    delete(fullfile(handles.datasetdir,sprintf('%s.mat',dataset_items{selected_dataset})));
    datasetNames=dir(fullfile(handles.datasetdir,'*.mat'));
    set(handles.dataset_list,'value',selected_dataset-1);
    set(handles.dataset_list,'string',strrep({datasetNames.name},'.mat',''));
end

function dataset_name_Callback(hObject, eventdata, handles)

function dataset_name_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%% USV PROFILE

function show_psd_Callback(hObject, eventdata, handles)
datasetNames=dir(fullfile(handles.datasetdir,'*.mat'));
if isempty(datasetNames)
    errordlg('Please create a dataset first.','No dataset created');
else
    show_psd_curve(handles,datasetNames);
end

function show_freq_bandwidth_Callback(hObject, eventdata, handles)
datasetNames=dir(fullfile(handles.datasetdir,'*.mat'));
if isempty(datasetNames)
    errordlg('Please create a dataset first.','No dataset created');
else
    show_freq_bandwidth(handles,datasetNames);
end

function show_vocalization_time_Callback(hObject, eventdata, handles)
datasetNames=dir(fullfile(handles.datasetdir,'*.mat'));
if isempty(datasetNames)
    errordlg('Please create a dataset first.','No dataset created');
else
    show_vocalization_time(handles,datasetNames);
end

function syllable_rate_Callback(hObject, eventdata, handles)
datasetNames=dir(fullfile(handles.datasetdir,'*.mat'));
if isempty(datasetNames)
    errordlg('Please create a dataset first.','No dataset created');
else
    show_syllable_counts(handles,datasetNames);
end

function syllable_duration_Callback(hObject, eventdata, handles)
datasetNames=dir(fullfile(handles.datasetdir,'*.mat'));
if isempty(datasetNames)
    errordlg('Please create a dataset first.','No dataset created');
else
    show_syllable_duration(handles,datasetNames);
end

function syllable_distance_Callback(hObject, eventdata, handles)
datasetNames=dir(fullfile(handles.datasetdir,'*.mat'));
if isempty(datasetNames)
    errordlg('Please create a dataset first.','No dataset created');
else
    show_syllable_distance(handles,datasetNames);
end

function print_dataset_stats_Callback(hObject, eventdata, handles)
datasetNames=dir(fullfile(handles.datasetdir,'*.mat'));
if isempty(datasetNames)
    errordlg('Please create a dataset first.','No dataset created');
else
    show_dataset_stats(handles,datasetNames);
end

%%% REPERTOIRES

% --- Executes on button press in build_repertoire.
function build_repertoire_Callback(hObject, eventdata, handles)
dataset_items=get(handles.dataset_list,'string');
selected_dataset=get(handles.dataset_list,'value');
if isempty(dataset_items)
    errordlg('Please create a dataset first.','No dataset created');
else
    load(fullfile(handles.datasetdir,sprintf('%s.mat',dataset_items{selected_dataset})),'dataset_dir');
    units=get(handles.nbunits,'String');
    NbUnits=str2double(units(get(handles.nbunits,'Value')));    
    [~,repertoireName]=fileparts(sprintf('%s.mat',dataset_items{selected_dataset}));
    repertoireFile=fullfile(handles.basedir,sprintf('%s_N%i.mat',repertoireName,NbUnits));
    if ~exist(repertoireFile,'file')
        [bases, activations, err, NbChannels, NbPatternFrames, NbUnits, NbIter] = repertoire_learning(dataset_dir,NbUnits);
        if isempty(bases)
            errordlg('Repertoire learning stopped. Too few syllables were detected in the audio data.','repertoire error');
        else
            if ~exist(handles.basedir,'dir')
                mkdir(handles.basedir);
            end
            save(repertoireFile,'bases','activations','NbUnits','NbChannels','NbPatternFrames','NbUnits','NbIter');
        end
    else
        errordlg('Requested repertoire exist. Delete first for rebuild.','Repertoire exist');
    end
    base_content=dir(fullfile(handles.basedir,sprintf('*_N%i.mat',NbUnits)));
    set(handles.repertoire_list,'string',{base_content.name});
    categoriesel=cellfun(@num2str,mat2cell([5:5:length(base_content)*NbUnits]',ones(length(base_content)*NbUnits/5,1)),'un',0);
    if ~isempty(categoriesel)
        set(handles.categories,'string',categoriesel);
    end
end

function nbunits_Callback(hObject, eventdata, handles)
units=get(handles.nbunits,'String');
NbUnits=str2double(units(get(handles.nbunits,'Value')));
base_content=dir(fullfile(handles.basedir,sprintf('*_N%i.mat',NbUnits)));
categoriesel=cellfun(@num2str,mat2cell([5:5:length(base_content)*NbUnits]',ones(length(base_content)*NbUnits/5,1)),'un',0);
if ~isempty(categoriesel)
    set(handles.categories,'string',categoriesel);
end
set(handles.repertoire_list,'string',{base_content.name});
set(handles.selected_repertoire_A,'string','');
set(handles.selected_repertoire_B,'string','');

function nbunits_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function repertoire_list_Callback(hObject, eventdata, handles)

function repertoire_list_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function refresh_repertoires_Callback(hObject, eventdata, handles)
units=get(handles.nbunits,'String');
NbUnits=str2double(units(get(handles.nbunits,'Value')));
base_content=dir(fullfile(handles.basedir,sprintf('*_N%i.mat',NbUnits)));
categoriesel=cellfun(@num2str,mat2cell([5:5:length(base_content)*NbUnits]',ones(length(base_content)*NbUnits/5,1)),'un',0);
if ~isempty(categoriesel)
    set(handles.categories,'string',categoriesel);
end
set(handles.repertoire_list,'string',{base_content.name});
set(handles.selected_repertoire_A,'string','');
set(handles.selected_repertoire_B,'string','');

function delete_repertoire_Callback(hObject, eventdata, handles)
repertoire_items=get(handles.repertoire_list,'string');
selected_repertoire=get(handles.repertoire_list,'value');
if ~isempty(repertoire_items)
    delete(fullfile(handles.basedir,repertoire_items{selected_repertoire}));
    ndx_delete=strcmp(repertoire_items,repertoire_items{selected_repertoire});
    repertoire_items(ndx_delete)=[];
    base_content=strcat(handles.basedir,'/',repertoire_items);
    units=get(handles.nbunits,'String');
    NbUnits=str2double(units(get(handles.nbunits,'Value')));
    categoriesel=cellfun(@num2str,mat2cell([5:5:length(base_content)*NbUnits]',ones(length(base_content)*NbUnits/5,1)),'un',0);
    if ~isempty(categoriesel)
        set(handles.categories,'string',categoriesel);
    end
    set(handles.repertoire_list,'value',selected_repertoire-1);
    set(handles.repertoire_list,'string',repertoire_items);
end
set(handles.selected_repertoire_A,'string','');
set(handles.selected_repertoire_B,'string','');

% REPERTOIRE PROFILE

function show_repertoire_Callback(hObject, eventdata, handles)
repertoire_items=get(handles.repertoire_list,'string');
selected_repertoire=get(handles.repertoire_list,'value');
if isempty(repertoire_items)
    errordlg('Please create a repertoire first.','No repertoire created');
else
    show_repertoire(handles,repertoire_items{selected_repertoire});
end

function categories_Callback(hObject, eventdata, handles)

function categories_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function syllable_category_counts_Callback(hObject, eventdata, handles)
repertoire_items=get(handles.repertoire_list,'string');
categories=get(handles.categories,'String');
NbCategories=str2double(categories(get(handles.categories,'Value')));   
if isempty(repertoire_items)
    errordlg('Please create a repertoire first.','No repertoire created');
else
    show_syllable_category_counts(handles,repertoire_items,NbCategories);
end

% REPERTOIRE COMPARISON

function select_repertoire_A_Callback(hObject, eventdata, handles)
repertoire_items=get(handles.repertoire_list,'string');
selected_repertoire=get(handles.repertoire_list,'value');
if isempty(repertoire_items)
    errordlg('Please create a repertoire first.','No repertoire created');
else
    set(handles.selected_repertoire_A,'string',repertoire_items{selected_repertoire});
end
    
function select_repertoire_B_Callback(hObject, eventdata, handles)
repertoire_items=get(handles.repertoire_list,'string');
selected_repertoire=get(handles.repertoire_list,'value');
if isempty(repertoire_items)
    errordlg('Please create a repertoire first.','No repertoire created');
else
    set(handles.selected_repertoire_B,'string',repertoire_items{selected_repertoire});
end

function compare_A_against_B_Callback(hObject, eventdata, handles)
repertoire_items=cell(2,1);
repertoire_items{1}=get(handles.selected_repertoire_A,'string');
repertoire_items{2}=get(handles.selected_repertoire_B,'string');
if sum(cellfun(@isempty,repertoire_items))
    errordlg('Please select two repertoires.','Select repertoires');
else
    compare_A_against_B(handles,repertoire_items);
end
set(handles.selected_repertoire_A,'string','');
set(handles.selected_repertoire_B,'string','');

function compare_A_against_all_repertoires_Callback(hObject, eventdata, handles)
repertoire_A=get(handles.selected_repertoire_A,'string');
repertoire_items=get(handles.repertoire_list,'string');
if isempty(repertoire_A)
    errordlg('Please select base repertoire A.','Select repertoire');
else
    if length(repertoire_items)<2
       errordlg('Please create more than one repertoire first.','Create more repertoires');
    else
       repertoire_items=get(handles.repertoire_list,'string');
       compare_A_against_all_repertoires(handles,repertoire_items,repertoire_A);
    end
end

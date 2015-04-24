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
delete(findall(0,'tag','Msgbox_MUPET info'));
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
handles.repertoiredir='repertoires';
handles.datasetdir='datasets';
addpath util;
set(handles.nbunits,'Value',4);
units=get(handles.nbunits,'String');
NbUnits=str2double(units(get(handles.nbunits,'Value')));
repertoire_content=dir(fullfile(handles.repertoiredir,sprintf('*_N%i.mat',NbUnits)));
repertoire_refined_content=dir(fullfile(handles.repertoiredir,sprintf('*_N%i*+.mat',NbUnits)));
repertoire_content(end+1:end+length(repertoire_refined_content))=repertoire_refined_content;
set(handles.repertoire_list,'string',{repertoire_content.name});
datasetNames=dir(fullfile(handles.datasetdir,'*.mat'));
set(handles.dataset_list,'string',strrep({datasetNames.name},'.mat',''));
handles.syllables='';
handles.sample_frequency=0;
handles.filename='';
handles.patch_window=120;
makeurl(handles.wiki,'https://github.com/mvansegbroeck/mupet/wiki/MUPET-wiki');
makeurl(handles.code,'https://github.com/mvansegbroeck/mupet/');
defaultFigPos=get(0,'DefaultFigurePosition');
set(0,'DefaultFigurePosition',[1 defaultFigPos(2) defaultFigPos(3) defaultFigPos(4)]);
[handles.FontSize1, handles.FontSize2, handles.FontSize3]=setGuiFonts(handles);
set(handles.syllable_slider,'Visible','off');
set(handles.syllable_axes_fft,'Visible','off');
set(handles.syllable_axes_gt,'Visible','off');

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
crit = '^[^.]+';
rxResult1 = regexp( {filelist1.name}, crit );
rxResult2 = regexp( {filelist2.name}, crit );
if (length(filelist1)+length(filelist2)) > 0,
    handles.flist=unique({ filelist1.name filelist2.name });
    handles.flist([cellfun(@isempty,rxResult1)==true cellfun(@isempty,rxResult2)==true])=[];    
    content=handles.flist;
    [~,handles.audiodir]=fileparts(handles.datadir);
    handles.audiodir=fullfile('audio',handles.audiodir);
    if ~exist(handles.audiodir,'dir')
       mkdir(handles.audiodir); 
    end
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
    [syllables, fs] = syllable_activity_file_stats(handles, wav_items{selected_wav});
    handles.syllables = syllables;
    handles.sample_frequency = fs;
    handles.filename = wav_items{selected_wav};
    nb_syllables=size(syllables,2);
    if nb_syllables >= 1
        set(handles.syllable_slider,'Value',0);
        if nb_syllables==1            
            set(handles.syllable_slider,'Visible','off');
        else
            set(handles.syllable_slider,'Visible','on');
            if nb_syllables==2
                set(handles.syllable_slider,'Max',1);
            else
                set(handles.syllable_slider,'Max',nb_syllables-2);
            end
            set(handles.syllable_slider,'Value',0);
            set(handles.syllable_slider,'Min',0);
            set(handles.syllable_slider,'SliderStep',[1/(double(nb_syllables-1)) 1/(double(nb_syllables-1))]);
        end
        syllable_ndx=1;

        % make syllable patch
        show_syllables(handles,syllable_ndx);

        % update handles
        guidata(hObject, handles);
    else        
         errordlg(sprintf(' ***              No syllables found in file              *** '),'MUPET info');   
    end
end

function ignore_file_Callback(hObject, eventdata, handles)
wav_items=get(handles.wav_list,'string');
selected_wav=get(handles.wav_list,'value');
if ~isempty(wav_items)
    handles.flist(strcmp(handles.flist,wav_items{selected_wav}))=[];    
    wav_items(selected_wav)=[];
    set(handles.wav_list,'value',1);
    set(handles.wav_list,'string',wav_items); 
    % update handles
    guidata(hObject, handles);
end

function process_all_Callback(hObject, eventdata, handles)
wav_items=get(handles.wav_list,'string');
wav_dir=get(handles.wav_directory,'string');
if ~isempty(wav_dir)
    compute_musv(wav_dir,wav_items,handles);
end
msgbox(sprintf(' ***              All files processed              *** '),'MUPET info');

function file_report_Callback(hObject, eventdata, handles)
wav_items=get(handles.wav_list,'string');
wav_dir=get(handles.wav_directory,'string');
if ~isempty(wav_dir)
    for fileID = 1:length(wav_items)
        compute_musv(wav_dir,wav_items,handles);
        [syllables, fs] = syllable_activity_file_stats(handles, wav_items{fileID});
        handles.syllables = syllables;
        handles.sample_frequency = fs;
        handles.filename = wav_items{fileID};
        export_csv_files_syllables(wav_dir, handles);        
    end
end
msgbox(sprintf('***              All files exported to CSV files              ***\n See folder %s/CSV',handles.audiodir),'MUPET info');

%%% SYLLABLE INSPECTOR

function syllable_slider_Callback(hObject, eventdata, handles)
if isempty(handles.syllables)
    errordlg('Please select and process an audio file.','No audio file selected/processed')
else
    syllable_ndx = round(get(handles.syllable_slider,'Value')./(get(handles.syllable_slider,'Max')) * (size(handles.syllables,2)-1) + 1);
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
        syllable_activity_stats(handles, wav_items, dataset_matfile);
        datasetNames=dir(fullfile(handles.datasetdir,'*.mat'));
        set(handles.dataset_list,'value',1);
        set(handles.dataset_list,'string',strrep({datasetNames.name},'.mat',''));            
        fprintf('Done.\n');
    end
end

function print_content_Callback(hObject, eventdata, handles)
dataset_items=get(handles.dataset_list,'string');
if ~isempty(dataset_items)
    export_csv_dataset_content(dataset_items, handles);
end
msgbox(sprintf('***              All data sets exported to CSV files              ***\n See folder %s/CSV',handles.datasetdir),'MUPET info');

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
    set(handles.dataset_list,'value',1);
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
    %show_dataset_stats(handles,datasetNames);
    export_csv_dataset_stats(handles,datasetNames);
end
msgbox(sprintf('***       All data sets stats exported to CSV files       ***\n See folder %s/CSV',handles.datasetdir),'MUPET info');

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
    datasetName=dataset_items{selected_dataset};
    [~,repertoireName]=fileparts(sprintf('%s.mat',datasetName));
    repertoireFile=fullfile(handles.repertoiredir,sprintf('%s_N%i.mat',repertoireName,NbUnits));
    if ~exist(repertoireFile,'file')
        [bases, activations, err, NbChannels, NbPatternFrames, NbUnits, NbIter, ndx_V] = repertoire_learning(handles,datasetName,NbUnits);
        if isempty(bases)
            errordlg('Repertoire learning stopped. Too few syllables were detected in the audio data.','repertoire error');
        else
            if ~exist(handles.repertoiredir,'dir')
                mkdir(handles.repertoiredir);
            end
            save(repertoireFile,'bases','activations','NbUnits','NbChannels','NbPatternFrames','NbUnits','NbIter','dataset_dir','ndx_V','datasetName');
        end
    else
        errordlg('Requested repertoire exist. Delete first for rebuild.','Repertoire exist');
    end
    repertoire_content=dir(fullfile(handles.repertoiredir,sprintf('*_N%i.mat',NbUnits)));
    repertoire_refined_content=dir(fullfile(handles.repertoiredir,sprintf('*_N%i*+.mat',NbUnits)));
    repertoire_content(end+1:end+length(repertoire_refined_content))=repertoire_refined_content;
    set(handles.repertoire_list,'value',1);
    set(handles.repertoire_list,'string',{repertoire_content.name});
    categoriesel=cellfun(@num2str,mat2cell([5:5:length(repertoire_content)*NbUnits]',ones(length(repertoire_content)*NbUnits/5,1)),'un',0);
    if ~isempty(categoriesel)
        set(handles.categories,'string',categoriesel);
    end
end

function nbunits_Callback(hObject, eventdata, handles)
units=get(handles.nbunits,'String');
NbUnits=str2double(units(get(handles.nbunits,'Value')));
repertoire_content=dir(fullfile(handles.repertoiredir,sprintf('*_N%i.mat',NbUnits)));
repertoire_refined_content=dir(fullfile(handles.repertoiredir,sprintf('*_N%i*+.mat',NbUnits)));
repertoire_content(end+1:end+length(repertoire_refined_content))=repertoire_refined_content;
categoriesel=cellfun(@num2str,mat2cell([5:5:length(repertoire_content)*NbUnits]',ones(length(repertoire_content)*NbUnits/5,1)),'un',0);
if ~isempty(categoriesel)
    set(handles.categories,'string',categoriesel);
end
set(handles.repertoire_list,'value',1);
set(handles.repertoire_list,'string',{repertoire_content.name});
set(handles.selected_repertoire_A,'string','');

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
repertoire_content=dir(fullfile(handles.repertoiredir,sprintf('*_N%i.mat',NbUnits)));
repertoire_refined_content=dir(fullfile(handles.repertoiredir,sprintf('*_N%i*+.mat',NbUnits)));
repertoire_content(end+1:end+length(repertoire_refined_content))=repertoire_refined_content;
categoriesel=cellfun(@num2str,mat2cell([5:5:length(repertoire_content)*NbUnits]',ones(length(repertoire_content)*NbUnits/5,1)),'un',0);
if ~isempty(categoriesel)
    set(handles.categories,'string',categoriesel);
end
set(handles.repertoire_list,'string',sort({repertoire_content.name}));
set(handles.selected_repertoire_A,'string','');

function delete_repertoire_Callback(hObject, eventdata, handles)
repertoire_items=get(handles.repertoire_list,'string');
selected_repertoire=get(handles.repertoire_list,'value');
if ~isempty(repertoire_items)
    delete(fullfile(handles.repertoiredir,repertoire_items{selected_repertoire}));
    ndx_delete=strcmp(repertoire_items,repertoire_items{selected_repertoire});
    repertoire_items(ndx_delete)=[];
    repertoire_content=strcat(handles.repertoiredir,'/',repertoire_items);
    units=get(handles.nbunits,'String');
    NbUnits=str2double(units(get(handles.nbunits,'Value')));
    categoriesel=cellfun(@num2str,mat2cell([5:5:length(repertoire_content)*NbUnits]',ones(length(repertoire_content)*NbUnits/5,1)),'un',0);
    if ~isempty(categoriesel)
        set(handles.categories,'string',categoriesel);
    end
    set(handles.repertoire_list,'value',1);
    set(handles.repertoire_list,'string',repertoire_items);
end
set(handles.selected_repertoire_A,'string','');

function export_repertoires_Callback(hObject, eventdata, handles)
units=get(handles.nbunits,'String');
NbUnits=str2double(units(get(handles.nbunits,'Value')));
repertoire_items=get(handles.repertoire_list,'string');
if isempty(repertoire_items)
    errordlg('Please create a repertoire first.','No repertoire created');
else
    export_repertoires(handles,repertoire_items);
end

% REPERTOIRE PROFILE

function show_repertoire_Callback(hObject, eventdata, handles)
repertoire_items=get(handles.repertoire_list,'string');
selected_repertoire=get(handles.repertoire_list,'value');
if isempty(repertoire_items)
    errordlg('Please create a repertoire first.','No repertoire created');
else
    show_repertoire(handles,repertoire_items{selected_repertoire});
end

function refine_repertoire_Callback(hObject, eventdata, handles)
repertoire_items=get(handles.repertoire_list,'string');
selected_repertoire=get(handles.repertoire_list,'value');
if isempty(repertoire_items)
    errordlg('Please create a repertoire first.','No repertoire created');
else
    refine_repertoire(handles,repertoire_items{selected_repertoire});
end
refresh_datasets_Callback(hObject, eventdata, handles);
refresh_repertoires_Callback(hObject, eventdata, handles);

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
    
function compare_A_against_all_repertoires_match_Callback(hObject, eventdata, handles)
repertoire_A=get(handles.selected_repertoire_A,'string');
repertoire_items=get(handles.repertoire_list,'string');
if isempty(repertoire_A)
    errordlg('Please select base repertoire A.','Select repertoire');
else
    compare_A_against_all_repertoires_match(handles,repertoire_items,repertoire_A);
end
set(handles.selected_repertoire_A,'string','');

function compare_A_against_all_repertoires_activity_Callback(hObject, eventdata, handles)
repertoire_A=get(handles.selected_repertoire_A,'string');
repertoire_items=get(handles.repertoire_list,'string');
if isempty(repertoire_A)
    errordlg('Please select base repertoire A.','Select repertoire');
else
    if length(repertoire_items)<2
       errordlg('Please create more than one repertoire first.','Create more repertoires');
    else
       repertoire_items=get(handles.repertoire_list,'string');
       compare_A_against_all_repertoires_activity(handles,repertoire_items,repertoire_A);
    end
end

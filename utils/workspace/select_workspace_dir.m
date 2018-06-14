% load_wavfiles
function handles=select_workspace_dir(handles)
    handles.workspace_dir = uigetdir(matlabroot, 'Select Workspace Directory');
    handles.workspace_dir = check_workspace_dir(handles);
%     set(handles.workspaceDir,fullfile(handles.workspace_dir))
    set(handles.workspaceDir,'string',fullfile(handles.workspace_dir));
    handles.datasetdir = fullfile(handles.workspace_dir,'datasets');
    refresh_datasets(handles);
    handles.repertoiredir = fullfile(handles.workspace_dir,'repertoires');
    refresh_repertoires(handles)
    handles.configfile=fullfile(handles.workspace_dir,'config.csv');
%     handles.audiodir = 
%     filelist1=dir(fullfile(handles.datadir,'*.WAV'));
%     filelist2=dir(fullfile(handles.datadir,'*.wav'));
%     crit = '^[^.]+';
%     rxResult1 = regexp( {filelist1.name}, crit );
%     rxResult2 = regexp( {filelist2.name}, crit );
%     if (length(filelist1)+length(filelist2)) > 0,
%         handles.flist=unique({ filelist1.name filelist2.name });
%         handles.flist([cellfun(@isempty,rxResult1)==true cellfun(@isempty,rxResult2)==true])=[];
%         content=handles.flist;
%         [~,handles.audiodir]=fileparts(handles.datadir);
%         handles.audiodir=fullfile('audio',handles.audiodir);
%         if ~exist(handles.audiodir,'dir')
%            mkdir(handles.audiodir);
%         end
%     else
%         content=sprintf('No wave files found in directory\n');
%     end
%     set(handles.wav_directory,'string',handles.datadir);
%     set(handles.wavList,'value',1);
%     set(handles.wavList,'string',content);
end
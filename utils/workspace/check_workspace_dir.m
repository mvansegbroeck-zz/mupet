function workspaceDir = check_workspace_dir(handles)
    if (handles.workspace_dir == 0)
        error_str_part_1 = 'No workspace has been selected ';
        error_str_part_2 = char(handles.mupet_root_dir);
        error_str_part_3 = ' will be set as your workspace folder. If you wish to select a different directory for your workspace, please choose the intended directory after closing the dialog box.';
        %Show error dilaog to inform user about auto-selection of workspace
        %directory
        errordlg([error_str_part_1 error_str_part_2 error_str_part_3],'Workspace Error');
        %handles.workspace_dir = handles.mupet_root_dir;
        workspaceDir = handles.mupet_root_dir;
    else
        workspaceDir = handles.workspace_dir;
    end
end
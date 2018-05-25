% default_configfile
function handles = default_configfile(handles)
    create_configfile(handles,true);
    msgbox(sprintf(' ***  Settings changed to default values. ***'),'MUPET info');
end
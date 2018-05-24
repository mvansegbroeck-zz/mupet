% setGuiFonts
function [FontSize1, FontSize2, FontSize3, FontSize4]=setGuiFonts(handles)
    % make all fonts bigger on a mac-osx computer
    persistent fontDefault
    fontDefault = [];
    FontSize1=10;
    FontSize2=9;
    FontSize3=8;
    FontSize4=24;
    FontSize5=16;
    if isempty(fontDefault)
        if ismac()
            FontSize1=FontSize1*1.15;
            FontSize2=FontSize2*1.15;
            FontSize3=FontSize3*1.25;
            FontSize4=FontSize4*1.25;
            FontSize5=FontSize5*1.25;
        end
        if ispc()
            FontSize1=FontSize1*.9;
            FontSize2=FontSize2*.9;
            FontSize3=FontSize3*.9;
            FontSize4=FontSize4*.9;
            FontSize5=FontSize5*.9;
        end
        for afield = fieldnames(handles)'
            afield = afield{1}; %#ok<FXSET>
            try %#ok<TRYNC>
                if ismac()
                    set(handles.(afield),'FontSize',FontSize1);
                    if ~isempty(handles.(afield).String)
                        if strcmp(handles.(afield).String,'MUPET')
                        set(handles.(afield),'FontSize',FontSize4);
                        elseif strcmp(handles.(afield).String,'Mice Ultrasonic Profile ExTractor')
                        set(handles.(afield),'FontSize',FontSize5);
                        end
                    end
                    % decrease font size
%                     bgc=get(handles.(afield),'BackgroundColor');
%                     if (sum(fix(bgc*1e5)==[92549 83921 83921])+sum(fix(bgc*1e5)==[70196 78039 100000]))>1
%                         set(handles.(afield),'BackgroundColor',[1 1 1]);
%                     end
                end
                if ispc()
                    set(handles.(afield),'FontSize',FontSize1);
                    if ~isempty(handles.(afield).String)
                        if strcmp(handles.(afield).String,'MUPET')
                        set(handles.(afield),'FontSize',FontSize4);
                        elseif strcmp(handles.(afield).String,'Mice Ultrasonic Profile ExTractor')
                        set(handles.(afield),'FontSize',FontSize5);
                        end
                    end
                    % decrease font size
%                     bgc=get(handles.(afield),'BackgroundColor');
%                     if (sum(fix(bgc*1e5)==[92549 83921 83921])+sum(fix(bgc*1e5)==[70196 78039 100000]))>1
%                         set(handles.(afield),'BackgroundColor',[1 1 1]);
%                     end
                end
                set(handles.(afield),'FontName','default'); % decrease font size
            end
        end
        fontDefault=1; % do not perform this step again.
    end
end

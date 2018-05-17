function decreaseFontSizesIfReq(handles)
% make all fonts smaller on a non-mac-osx computer
persistent fontSizeDecreased
fontSizeDecreased = [];
if ismac()
    % No MAC OSX detected; decrease font sizes
    if isempty(fontSizeDecreased)
        for afield = fieldnames(handles)'
            afield = afield{1}; %#ok<FXSET>
            try %#ok<TRYNC>
                set(handles.(afield),'FontSize',get(handles.(afield),'FontSize')*1.25); % decrease font size
            end
        end
        fontSizeDecreased=1; % do not perform this step again.
    end
end

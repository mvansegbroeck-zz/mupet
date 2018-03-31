% make_url
function makeurl(h,url,varargin)

    FOREGROUNDCOLOR = 'b';
    CLICKEDCOLOR    = 'b';

    if nargin < 2, error('Not enough input arguments.'); end
    if ~strcmp(get(h,'style'),'text'), error('The UICONTROL h must be of style text.'); end
    if exist('varargin','var')
       L = length(varargin);
       if rem(L,2) ~= 0, error('Parameters/Values must come in pairs.'); end
       for i = 1:2:L
          switch lower(varargin{i}(1))
          case 'f', FOREGROUNDCOLOR = varargin{i+1};
          case 'c',    CLICKEDCOLOR = varargin{i+1};
          end
       end
    end

    if ischar(CLICKEDCOLOR), CLICKEDCOLOR = ['''' CLICKEDCOLOR '''']; end

    OldUnits = get(h,'Units'); set(h,'Units','pixels');
    Ext   = get(h,'Extent');
    Pos   = get(h,'Pos');
    Horiz = get(h,'HorizontalAlignment');

    ButtonDownFcn =  ...
       ['set([gcbo getappdata(gcbo,''hFrame'')],''ForeGroundColor'', ' CLICKEDCOLOR ');'];
    ButtonDownFcn = [ ButtonDownFcn 'web(''' url ''',''-browser'');' ];
    set(h,'ForegroundColor',FOREGROUNDCOLOR, ...
       'ButtonDownFcn',ButtonDownFcn,'Enable','Inactive','Units',OldUnits);

end

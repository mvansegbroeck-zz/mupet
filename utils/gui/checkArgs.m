% checkArgs
function [h, nancolor] = checkArgs(args)
% checkArgs  Validate input arguments to freezeColors

    nargs = length(args);
    error(nargchk(0,3,nargs,'struct'))

    %grab handle from first argument if we have an odd number of arguments
    if mod(nargs,2),
        h = args{1};
        if ~ishandle(h),
            error('JRI:freezeColors:checkArgs:invalidHandle',...
                'The first argument must be a valid graphics handle (to an axis)')
        end
        % 4/2010 check if object to be frozen is a colorbar
        if strcmp(get(h,'Tag'),'Colorbar'),
          if ~exist('cbfreeze.m'),
            warning('JRI:freezeColors:checkArgs:cannotFreezeColorbar',...
                ['You seem to be attempting to freeze a colorbar. This no longer'...
                'works. Please read the help for freezeColors for the solution.'])
          else
            cbfreeze(h);
            return
          end
        end
        args{1} = [];
        nargs = nargs-1;
    else
        h = gca;
    end

    %set nancolor if that option was specified
    nancolor = [nan nan nan];
    if nargs == 2,
        if strcmpi(args{end-1},'nancolor'),
            nancolor = args{end};
            if ~all(size(nancolor)==[1 3]),
                error('JRI:freezeColors:checkArgs:badColorArgument',...
                    'nancolor must be [r g b] vector');
            end
            nancolor(nancolor>1) = 1; nancolor(nancolor<0) = 0;
        else
            error('JRI:freezeColors:checkArgs:unrecognizedOption',...
                'Unrecognized option (%s). Only ''nancolor'' is valid.',args{end-1})
        end
    end

end
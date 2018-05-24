% getParentAxes
function hAx = getParentAxes(h)
% getParentAxes  Return enclosing axes of a given object (could be self)

    error(nargchk(1,1,nargin,'struct'))
    %object itself may be an axis
    if strcmp(get(h,'type'),'axes'),
        hAx = h;
        return
    end

    parent = get(h,'parent');
    if (strcmp(get(parent,'type'), 'axes')),
        hAx = parent;
    else
        hAx = getParentAxes(parent);
    end
end
function ref = fGetRefPoint(Object)
if isfield(Object,'PosStart')
    if ~isempty(Object.PosStart)
        if all(all(Object.Results(:,3:4) == Object.PosStart(:,1:2)))
            ref = 1;
        elseif all(all(Object.Results(:,3:4) == Object.PosCenter(:,1:2)))
            ref = 2;
        else
            ref = 3;
        end
    else
        ref = 2;
    end
else
    ref = 2;
end
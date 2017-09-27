function aspect=GetAxesAspectRatio(hAxes)
try
    set(hAxes,'Units','pixel');
catch ME
    aspect=1;
    return;
end
pos=get(hAxes,'Position');
set(hAxes,'Units','normalized');
aspect=pos(4)/pos(3);
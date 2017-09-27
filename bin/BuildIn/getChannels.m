function stidx = getChannels(hMainGui)
if strcmp(get(hMainGui.ToolBar.ToolChannels(5),'State'),'on')
    stidx = 1:hMainGui.Values.MaxIdx(1);
else
    stidx = hMainGui.Values.FrameIdx(1);
end
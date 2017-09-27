function idx = getFrameIdx(hMainGui)
%hMainGui=getappdata(0,'hMainGui');
idx = hMainGui.Values.FrameIdx(1);
if length(hMainGui.Values.FrameIdx)>2
    idx(2) = hMainGui.Values.FrameIdx(idx+1);
else
    idx(2) = hMainGui.Values.FrameIdx(2);
end
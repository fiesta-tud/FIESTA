function n = getChIdx
hMainGui=getappdata(0,'hMainGui');
if length(hMainGui.Values.FrameIdx)>2
    n = hMainGui.Values.FrameIdx(1)+1;
else
    n = 2;
end



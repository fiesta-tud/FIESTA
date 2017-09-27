function fMidPanel(func,varargin)
switch func
    case 'sFrame'
        sFrame(varargin{1});
    case 'eFrame'
        eFrame(varargin{1});
    case 'Update'
        Update(varargin{1});
end

function Update(hMainGui)
global TimeInfo
idx = getFrameIdx(hMainGui);
if length(hMainGui.Values.FrameIdx)<3
    idx(1) = 1;
end
set(hMainGui.MidPanel.tInfoTime,'String',sprintf('Time: %0.3f s',(TimeInfo{idx(1)}(idx(2))-TimeInfo{idx(1)}(1))/1000));
fShow('Image');

function sFrame(hMainGui)
idx=round(get(hMainGui.MidPanel.sFrame,'Value'));
if length(hMainGui.Values.FrameIdx)>2
    n = hMainGui.Values.FrameIdx(1)+1;
else
    n = 2;
end

if idx<1
    hMainGui.Values.FrameIdx(n)=1;
elseif idx>hMainGui.Values.MaxIdx(n)
    hMainGui.Values.FrameIdx(n)=hMainGui.Values.MaxIdx(n);
else
    hMainGui.Values.FrameIdx(n)=idx;
end
hMainGui.Values.FrameIdx = real(hMainGui.Values.FrameIdx);
setappdata(0,'hMainGui',hMainGui);
set(hMainGui.MidPanel.eFrame,'String',int2str(hMainGui.Values.FrameIdx(n)));
Update(hMainGui);

function eFrame(hMainGui)
try
    idx=round(str2double(get(hMainGui.MidPanel.eFrame,'String')));
catch
end

if length(hMainGui.Values.FrameIdx)>2
    n = hMainGui.Values.FrameIdx(1)+1;
else
    n = 2;
end

if idx<1
    hMainGui.Values.FrameIdx(n)=1;
elseif idx>hMainGui.Values.MaxIdx(n)
    hMainGui.Values.FrameIdx(n)=hMainGui.Values.MaxIdx(n);
elseif ~isnan(idx)
    hMainGui.Values.FrameIdx(n)=idx;
end
setappdata(0,'hMainGui',hMainGui);
set(hMainGui.MidPanel.eFrame,'String',int2str(hMainGui.Values.FrameIdx(n)));
set(hMainGui.MidPanel.sFrame,'Value',hMainGui.Values.FrameIdx(n));
Update(hMainGui);
function fToolBar(func,varargin)
switch func
    case 'Cursor'
        ToolCursor(varargin{1});
    case 'Pan'
        ToolPan(varargin{1});
    case 'ZoomIn'
        ToolZoomIn(varargin{1});
    case 'Region'
        ToolRegion(varargin{1});
    case 'RectRegion'
        ToolRectRegion(varargin{1});
    case 'NormImage'
        ToolNormImage(varargin{1});
    case 'ThreshImage'
        ToolThreshImage(varargin{1});
    case 'KymoGraph'
        ToolKymoGraph(varargin{1});
    case 'SwitchChannel'
        SwitchChannel(varargin{1});
    case 'SwitchColors'
        SwitchColors(varargin{1});
    case 'Overlay'
        Overlay;
end

function ToolCursor(hMainGui)
set(hMainGui.ToolBar.ToolCursor,'State','on');
set(hMainGui.ToolBar.ToolRegion,'State','off');
set(hMainGui.ToolBar.ToolRectRegion,'State','off');
hMainGui.Values.CursorDownPos(:)=0;
hMainGui.CursorMode='Normal';
set(hMainGui.fig,'pointer','arrow');
setappdata(0,'hMainGui',hMainGui);
fRightPanel('AllToolsOff',hMainGui);
hMainGui=getappdata(0,'hMainGui');
SetZoom(hMainGui);

function ToolRegion(hMainGui)
global Stack;
if ~isempty(Stack)
    set(hMainGui.ToolBar.ToolCursor,'State','off');
    set(hMainGui.ToolBar.ToolRegion,'State','on');
    set(hMainGui.ToolBar.ToolRectRegion,'State','off');
    hMainGui.Values.CursorDownPos(:)=0;
    hMainGui.CursorMode='Region';
    setappdata(0,'hMainGui',hMainGui);
    fRightPanel('AllToolsOff',hMainGui);
    hMainGui=getappdata(0,'hMainGui');
    SetZoom(hMainGui);
else
    set(hMainGui.ToolBar.ToolRegion,'State','off');
end


function ToolRectRegion(hMainGui)
global Stack;
if ~isempty(Stack)
    set(hMainGui.ToolBar.ToolCursor,'State','off');
    set(hMainGui.ToolBar.ToolRegion,'State','off');
    set(hMainGui.ToolBar.ToolRectRegion,'State','on');
    hMainGui.Values.CursorDownPos(:)=0;
    hMainGui.CursorMode='RectRegion';
    setappdata(0,'hMainGui',hMainGui);
    fRightPanel('AllToolsOff',hMainGui);
    hMainGui=getappdata(0,'hMainGui');
    SetZoom(hMainGui);
else
    set(hMainGui.ToolBar.ToolRectRegion,'State','off');
end

function ToolNormImage(hMainGui)
global Stack;
if ~isempty(Stack)
    set(hMainGui.ToolBar.ToolNormImage,'State','on');
    set(hMainGui.ToolBar.ToolThreshImage,'State','off');
    set(hMainGui.ToolBar.ToolKymoGraph,'State','off');
    set(hMainGui.Menu.mZProjection,'Enable','on');
    fLeftPanel('NormPanel',hMainGui);
    set(hMainGui.MidPanel.pView,'Visible','on');
    set(hMainGui.MidPanel.pKymoGraph,'Visible','off');
    set(get(hMainGui.MidPanel.pFrame,'Children'),'Enable','on');
    hMainGui.CurrentAxes = 'View';
    hMainGui=DeleteSelectRegion(hMainGui);
    hMainGui.Values.CursorDownPos(:)=0;     
    setappdata(0,'hMainGui',hMainGui);
    fShared('UpdateMenu',hMainGui);
else
    set(hMainGui.ToolBar.ToolNormImage,'State','off');
end

function ToolThreshImage(hMainGui)
global Stack;
if ~isempty(Stack)
    set(hMainGui.ToolBar.ToolNormImage,'State','off');
    set(hMainGui.ToolBar.ToolThreshImage,'State','on');
    set(hMainGui.ToolBar.ToolKymoGraph,'State','off');
    set(hMainGui.Menu.mZProjection,'Enable','off');
    fLeftPanel('ThreshPanel',hMainGui);
    set(hMainGui.MidPanel.pView,'Visible','on');
    set(hMainGui.MidPanel.pKymoGraph,'Visible','off');
    set(get(hMainGui.MidPanel.pFrame,'Children'),'Enable','on');
    hMainGui.CurrentAxes = 'View';
    hMainGui=DeleteSelectRegion(hMainGui);
    hMainGui.Values.CursorDownPos(:)=0;     
    setappdata(0,'hMainGui',hMainGui);
else
    set(hMainGui.ToolBar.ToolThreshImage,'State','off');
end

function ToolKymoGraph(hMainGui)
global Stack;
if ~isempty(Stack)&&~isempty(hMainGui.KymoImage)
    set(hMainGui.ToolBar.ToolNormImage,'State','off');
    set(hMainGui.ToolBar.ToolThreshImage,'State','off');
    set(hMainGui.ToolBar.ToolKymoGraph,'State','on');
    fLeftPanel('NormPanel',hMainGui);
    set(hMainGui.MidPanel.pView,'Visible','off');
    set(hMainGui.MidPanel.pKymoGraph,'Visible','on');
    set(get(hMainGui.MidPanel.pFrame,'Children'),'Enable','off');
    hMainGui.CurrentAxes = 'Kymo';
    hMainGui=DeleteSelectRegion(hMainGui);
    hMainGui.Values.CursorDownPos(:)=0;        
    setappdata(0,'hMainGui',hMainGui);
else
    set(hMainGui.ToolBar.ToolKymoGraph,'State','off');
end

function SwitchColors(nColor)
global Stack;
if ~isempty(Stack)
    hMainGui=getappdata(0,'hMainGui');
    nCh = hMainGui.Values.FrameIdx(1);
    set(hMainGui.ToolBar.ToolColors,'State','off');
    set(hMainGui.ToolBar.ToolColors(nColor),'State','on');
    hMainGui.Values.StackColor(nCh) = nColor;
    setappdata(0,'hMainGui',hMainGui);
    fLeftPanel('UpdateKymo',hMainGui);
    fShow('Image');
end

function Overlay
global Stack;
if ~isempty(Stack)
    hMainGui=getappdata(0,'hMainGui');
    s = get(hMainGui.ToolBar.ToolChannels(5),'State');
    set(hMainGui.ToolBar.ToolColors,'Visible',s,'State','off');
    nCh = hMainGui.Values.FrameIdx(1);
    set(hMainGui.ToolBar.ToolColors(hMainGui.Values.StackColor(nCh)),'State','on');
    set(hMainGui.Menu.mColorOverlay,'Checked',s);
    fShow('Image');
    fShow('Tracks');
    if ~isempty(hMainGui.KymoImage) 
        hMainGui=getappdata(0,'hMainGui');
        fRightPanel('ShowKymoGraph',hMainGui);
    end
end

function SwitchChannel(nCh)
global Stack;
global Config;
global Molecule;
global Filament;
if ~isempty(Stack)
    hMainGui=getappdata(0,'hMainGui');
    set(hMainGui.ToolBar.ToolChannels(1:4),'State','off');
    set(hMainGui.ToolBar.ToolChannels(nCh),'State','on');
    hMainGui.Values.FrameIdx(1) = nCh;
    nColor = hMainGui.Values.StackColor(nCh);
    set(hMainGui.ToolBar.ToolColors,'State','off');
    set(hMainGui.ToolBar.ToolColors(nColor),'State','on');
    idx = min([nCh+1 length(hMainGui.Values.FrameIdx)]);
    k = strfind(Config.Threshold.Filter,'+background');
    if ~isempty(k)
        Config.Threshold.Filter = [Config.Threshold.Filter(1:k) 'background'];
    end
    z = hMainGui.Values.MaxIdx(idx);
    f = real(hMainGui.Values.FrameIdx(idx));
    if z>1&&f>0
      %set Frame Slider
      slider_step(1) = 1/z;
      slider_step(2) = 10/z;
      if (max(slider_step)>=1)||(min(slider_step)<=0)
        slider_step=[0.1 0.1];
      end
      set(hMainGui.MidPanel.sFrame,'sliderstep',slider_step,...
            'max',z,'min',1,'Value',f,'Enable','on')

      %set Frame Textbox
      set(hMainGui.MidPanel.eFrame,'Enable','on','String',num2str(f));  
    end
    if z==1
      %set Frame Slider
      slider_step(1) = 1/z;
      slider_step(2) = 10/z;
      if (max(slider_step)>=1)||(min(slider_step)<=0)
        slider_step=[0.1 0.1];
      end
      set(hMainGui.MidPanel.sFrame,'sliderstep',slider_step,...
        'max',z,'min',0,'Value',1,'Enable','off')

      %set Frame Textbox
      set(hMainGui.MidPanel.eFrame,'Enable','off','String','1');  
    end
    setappdata(0,'hMainGui',hMainGui);
    fLeftPanel('Update',hMainGui);    
    fShow('SelectChannel',Molecule);
    fShow('SelectChannel',Filament);
    if ~isempty(hMainGui.KymoImage) 
        hMainGui=getappdata(0,'hMainGui');
        fRightPanel('ShowKymoGraph',hMainGui);
    end
end

function SetZoom(hMainGui)
Zoom=hMainGui.ZoomView;
if ~isempty(Zoom.globalXY)
    Zoom.currentXY=get(hMainGui.MidPanel.aView,{'xlim','ylim'});
    x_total=Zoom.globalXY{1}(2)-Zoom.globalXY{1}(1);
    x_current=Zoom.currentXY{1}(2)-Zoom.currentXY{1}(1);
    Zoom.level=round(-log(x_current/x_total)*8);
    hMainGui.ZoomView=Zoom;
end
Zoom=hMainGui.ZoomKymo;
if ~isempty(Zoom.globalXY)
    Zoom.currentXY=get(hMainGui.MidPanel.aKymoGraph,{'xlim','ylim'});
    x_total=Zoom.globalXY{1}(2)-Zoom.globalXY{1}(1);
    x_current=Zoom.currentXY{1}(2)-Zoom.currentXY{1}(1);
    Zoom.level=round(-log(x_current/x_total)*8);
    hMainGui.ZoomKymo=Zoom;
end
setappdata(0,'hMainGui',hMainGui);

function hMainGui=DeleteSelectRegion(hMainGui)
if ~isempty(hMainGui.Plots.SelectRegion)
    try
        delete(hMainGui.Plots.SelectRegion);
    catch
        delete(findobj(hMainGui.MidPanel.aView,'Tag','pSelectRegion'));
    end
    hMainGui.Plots.SelectRegion=[];
else
    delete(findobj(hMainGui.MidPanel.aView,'Tag','pSelectRegion'));
end
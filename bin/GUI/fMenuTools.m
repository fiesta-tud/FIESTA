function fMenuTools(func,varargin)
switch func
    case 'MeasureLine'
        MeasureLine(varargin{1});
    case 'MeasureSegLine'
        MeasureSegLine(varargin{1});
    case 'MeasureFreehand'
        MeasureFreehand(varargin{1});
    case 'MeasureRect'
        MeasureRect(varargin{1});       
    case 'MeasureEllipse'
        MeasureEllipse(varargin{1});
    case 'MeasurePolygon'
        MeasurePolygon(varargin{1});
    case 'ScanLine'
        ScanLine(varargin{1});
    case 'ScanSegLine'
        ScanSegLine(varargin{1});
    case 'ScanFreehand'
        ScanFreehand(varargin{1});      
    case 'ShowKymoGraph'
        ShowKymoGraph(varargin{1});   
end

function MeasureLine(hMainGui)
fRightPanel('ToolsMeasurePanel',hMainGui);
fToolBar('Cursor',hMainGui);
hMainGui=getappdata(0,'hMainGui');
set(hMainGui.RightPanel.pTools.bLine,'Value',1);
hMainGui.CursorMode=get(hMainGui.RightPanel.pTools.bLine,'UserData');
hMainGui.Values.CursorDownPos(:)=0;
setappdata(0,'hMainGui',hMainGui);

function MeasureSegLine(hMainGui)
fRightPanel('ToolsMeasurePanel',hMainGui);
fToolBar('Cursor',hMainGui);
hMainGui=getappdata(0,'hMainGui');
set(hMainGui.RightPanel.pTools.bSegLine,'Value',1);
hMainGui.CursorMode=get(hMainGui.RightPanel.pTools.bSegLine,'UserData');
hMainGui.Values.CursorDownPos(:)=0;
setappdata(0,'hMainGui',hMainGui);

function MeasureFreehand(hMainGui)
fRightPanel('ToolsMeasurePanel',hMainGui);
fToolBar('Cursor',hMainGui);
hMainGui=getappdata(0,'hMainGui');
set(hMainGui.RightPanel.pTools.bFreehand,'Value',1);
hMainGui.CursorMode=get(hMainGui.RightPanel.pTools.bFreehand,'UserData');
hMainGui.Values.CursorDownPos(:)=0;
setappdata(0,'hMainGui',hMainGui);

function MeasureRect(hMainGui)
fRightPanel('ToolsMeasurePanel',hMainGui);
fToolBar('Cursor',hMainGui);
hMainGui=getappdata(0,'hMainGui');
set(hMainGui.RightPanel.pTools.bRectangle,'Value',1);
hMainGui.CursorMode=get(hMainGui.RightPanel.pTools.bRectangle,'UserData');
hMainGui.Values.CursorDownPos(:)=0;
setappdata(0,'hMainGui',hMainGui);

function MeasureEllipse(hMainGui)
fRightPanel('ToolsMeasurePanel',hMainGui);
fToolBar('Cursor',hMainGui);
hMainGui=getappdata(0,'hMainGui');
set(hMainGui.RightPanel.pTools.bEllipse,'Value',1);
hMainGui.CursorMode=get(hMainGui.RightPanel.pTools.bEllipse,'UserData');
hMainGui.Values.CursorDownPos(:)=0;
setappdata(0,'hMainGui',hMainGui);

function MeasurePolygon(hMainGui)
fRightPanel('ToolsMeasurePanel',hMainGui);
fToolBar('Cursor',hMainGui);
hMainGui=getappdata(0,'hMainGui');
set(hMainGui.RightPanel.pTools.bPolygon,'Value',1);
hMainGui.CursorMode=get(hMainGui.RightPanel.pTools.bPolygon,'UserData');
hMainGui.Values.CursorDownPos(:)=0;
setappdata(0,'hMainGui',hMainGui);

function ScanLine(hMainGui)
fRightPanel('ToolsScanPanel',hMainGui);
fToolBar('Cursor',hMainGui);
hMainGui=getappdata(0,'hMainGui');
set(hMainGui.RightPanel.pTools.bLineScan,'Value',1);
hMainGui.CursorMode=get(hMainGui.RightPanel.pTools.bLineScan,'UserData');
hMainGui.Values.CursorDownPos(:)=0;
setappdata(0,'hMainGui',hMainGui);

function ScanSegLine(hMainGui)
fRightPanel('ToolsScanPanel',hMainGui);
fToolBar('Cursor',hMainGui);
hMainGui=getappdata(0,'hMainGui');
set(hMainGui.RightPanel.pTools.bSegLineScan,'Value',1);
hMainGui.CursorMode=get(hMainGui.RightPanel.pTools.bSegLineScan,'UserData');
hMainGui.Values.CursorDownPos(:)=0;
setappdata(0,'hMainGui',hMainGui);

function ScanFreehand(hMainGui)
fRightPanel('ToolsScanPanel',hMainGui);
fToolBar('Cursor',hMainGui);
hMainGui=getappdata(0,'hMainGui');
hMainGui.CursorMode='normal';
fRightPanel('CreateFilamentScan',hMainGui);
hMainGui=getappdata(0,'hMainGui');
hMainGui.Values.CursorDownPos(:)=0;
setappdata(0,'hMainGui',hMainGui);

function ShowKymoGraph(hMainGui)
fRightPanel('ToolsScanPanel',hMainGui);
fToolBar('Cursor',hMainGui);
hMainGui=getappdata(0,'hMainGui');
set(hMainGui.RightPanel.pTools.cShowKymoGraph,'Value',1);
fRightPanel('ShowKymoGraph',hMainGui);
hMainGui.Values.CursorDownPos(:)=0;
setappdata(0,'hMainGui',hMainGui);

function fDataGui(func,varargin)
switch (func)
    case 'Create'
        try
            Create(varargin{1},varargin{2});
        catch
            return;
        end
    case 'SetAdvanced'
        SetAdvanced(varargin{1});
    case 'Draw'
        Draw(varargin{1},varargin{2});
    case 'PlotXY'
        PlotXY(varargin{1});
    case 'Comment'
        Comment(varargin{1});
    case 'PlotDisTime'
        PlotDisTime(varargin{1});
    case 'PlotIntLen'
        PlotIntLen(varargin{1});
    case 'PlotVelTim'
        PlotVelTim(varargin{1});
    case 'DeletePoints'
        DeletePoints(varargin{1});
    case 'DeleteObject'
        DeleteObject(varargin{1});
    case 'Navigation'
        Navigation(varargin{1});
    case 'Switch'
        Switch(varargin{1});
    case 'FitMissingPoints'
        FitMissingPoints(varargin{1}); 
    case 'Tags'
        Tags(varargin{1});
    case 'Undo'
        Undo(varargin{1}); 
    case 'Split'
        Split(varargin{1});          
    case 'SelectAll'
        SelectAll(varargin{1});          
    case 'Correction'
        Correction(varargin{1});
    case 'XAxisList'
        XAxisList(varargin{1});        
    case 'CheckYAxis2'
        CheckYAxis2(varargin{1});              
    case 'bToggleToolCursor'
        bToggleToolCursor(varargin{1});  
    case 'bToolPan'
        bToolPan(varargin{1});
    case 'bToolZoomIn'
        bToolZoomIn(varargin{1});
    case 'Export'
        Export(varargin{1});
    case 'ChangeReference'
        ChangeReference(varargin{1});
    case 'OnlyChecked'
        OnlyChecked(varargin{:});
    case 'SetChannel'
        SetChannel;
    case 'SetComments'
        SetComments;
end

function hDataGui = Create(Type,idx)
global Molecule;
global Filament;
hDataGui=getappdata(0,'hDataGui');
hDataGui.Type=Type;
eNext='on';
if idx==1
    ePrevious='off';
else
    ePrevious='on';
end
if strcmp(Type,'Molecule')
    idx = min([idx length(Molecule)]);
    idx = max([1 idx]);
    Object=Molecule(idx);
    if idx==length(Molecule)
        eNext = 'off';
    end      
    refEnable = 'off';
else
    idx = min([idx length(Filament)]);
    idx = max([1 idx]);
    Object=Filament(idx);
    if idx==length(Filament)
        eNext = 'off';
    end
    refEnable = 'on';
end
hDataGui.idx=idx;
h=findobj('Tag','hDataGui');
if numel(h)>1
    delete(h);
    h = [];
end
[lXaxis,lYaxis]=CreatePlotList(Object,Type);
if isempty(h)
    hDataGui.fig = figure('Units','normalized','DockControls','off','IntegerHandle','off','MenuBar','none','Name',Object.Name,...
                          'NumberTitle','off','HandleVisibility','callback','Tag','hDataGui',...
                          'Visible','off','Resize','off','WindowStyle','normal');
                      
    fPlaceFig(hDataGui.fig,'big');
    
    if ispc
        set(hDataGui.fig,'Color',[236 233 216]/255);
    end
    
    c = get(hDataGui.fig,'Color');

    hDataGui.pPlotPanel = uipanel('Parent',hDataGui.fig,'Position',[0.35 0.55 0.63 0.4],'Tag','PlotPanel','BackgroundColor','white');
    
    hDataGui.aPlot = axes('Parent',hDataGui.pPlotPanel,'OuterPosition',[0 0 1 1],'Tag','Plot','NextPlot','add','TickDir','out','Layer','top',...
                          'XLimMode','manual','YLimMode','manual');
                      
    columnname = {'','','','','','','','','','',''};
    if mean(Object.Results(2:end,2)-Object.Results(1:end-1,2))<0.1
        columnformat = {'logical','numeric','bank','bank','bank','bank','bank','bank', 'bank', 'bank', 'char'};
    else
        columnformat = {'logical','numeric','short','bank','bank','bank','bank','bank', 'bank', 'bank', 'char'};
    end
    columneditable = logical([ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]);
    
    hDataGui.tTable = uitable('Parent',hDataGui.fig,'Units','normalized','Position',[0.02 0.02 0.96 0.48],'Tag','tTable','Enable','on',...            
                              'ColumnName', columnname,'ColumnFormat', columnformat,'ColumnEditable', columneditable,'RowName',[]);

    hDataGui.tName = uicontrol('Parent',hDataGui.fig,'Units','normalized','FontSize',10,'FontWeight','bold',...
                              'HorizontalAlignment','left','Position',[0.02 0.96 0.15 0.02],...
                              'String',Object.Name,'Style','text','Tag','tName','BackgroundColor',c);

    hDataGui.tFile = uicontrol('Parent',hDataGui.fig,'Units','normalized','FontSize',10,'FontAngle','italic',...
                              'HorizontalAlignment','left','Position',[0.19 0.96 0.3 0.02],...
                              'String',Object.File,'Style','text','Tag','tFile','BackgroundColor',c);
                          
    hDataGui.eComments = uicontrol('Parent',hDataGui.fig,'Units','normalized','FontSize',10,'Callback','fDataGui(''SetComments'');',...
                              'HorizontalAlignment','left','Position',[0.51 0.955 0.3 0.03],...
                              'String',Object.Comments,'Style','edit','Tag','eComments','BackgroundColor','white');
                          
    hDataGui.tIndex = uicontrol('Parent',hDataGui.fig,'Units','normalized','FontSize',10,'HorizontalAlignment','left',...
                                'Position',[0.02 0.93 0.1 0.02],'String',['Index: ' num2str(idx)],'Style','text','Tag','tIndex','BackgroundColor',c);                       
    
    hDataGui.tChannel = uicontrol('Parent',hDataGui.fig,'Units','normalized','FontSize',10,'HorizontalAlignment','left',...
                                'Position',[0.24 0.93 0.06 0.02],'String','Channel:','Style','text','Tag','tChannel','BackgroundColor',c);  
                           
    hDataGui.eChannel = uicontrol('Parent',hDataGui.fig,'Style','edit','Units','normalized',...
                                         'Position',[0.31 0.93 0.03 0.02],'Tag','eChannel','Fontsize',10,...
                                         'String',num2str(Object.Channel),'BackgroundColor','white','HorizontalAlignment','center',...
                                         'Callback', 'fDataGui(''SetChannel'');');  

                  
    hDataGui.bPrevious = uicontrol('Parent',hDataGui.fig,'Style','pushbutton','Units','normalized','Callback','fDataGui(''Navigation'',-1);',...
                             'Position',[0.02 0.89 0.1 0.03],'String','Previous','Tag','bPrevious','Enable',ePrevious);
                         
    hDataGui.bDelete = uicontrol('Parent',hDataGui.fig,'Units','normalized','Callback','fDataGui(''DeleteObject'',getappdata(0,''hDataGui''));',...
                             'Position',[0.13 0.89 0.1 0.03],'String','Delete','Tag','bDelete');
   
    hDataGui.bNext = uicontrol('Parent',hDataGui.fig,'Units','normalized','Callback','fDataGui(''Navigation'',1);',...
                             'Position',[0.24 0.89 0.1 0.03],'String','Next','Tag','bNext','Enable',eNext);

    hDataGui.cCorrection = uicontrol('Parent',hDataGui.fig,'Units','normalized','Callback','fDataGui(''Correction'',getappdata(0,''hDataGui''));',...
                                'Position',[0.02 0.855 0.12 0.02],'String','Apply corrections','Style','checkbox','BackgroundColor',c,'Tag','cCorrection','Value',Object.Drift);

    hDataGui.tReference = uicontrol('Parent',hDataGui.fig,'Units','normalized','FontSize',10,'HorizontalAlignment','left',...
                                  'Position',[0.16 0.855 0.1 0.02],'String','Reference Point:','Style','text','Tag','tReference','BackgroundColor',c);
     
    hDataGui.lReference = uicontrol('Parent',hDataGui.fig,'TooltipString','Change reference point for this filament only', 'Units','normalized','Callback','fDataGui(''ChangeReference'',getappdata(0,''hDataGui''),0);','Enable',refEnable,...
                                 'Style','popupmenu','FontSize',8,'Position',[0.26 0.855 0.085 0.02],'String',{'start', 'center', 'end'},'Tag','lReference','BackgroundColor','white', 'Value', fGetRefPoint(Object));                        
            
    hDataGui.gColor = uibuttongroup('Parent',hDataGui.fig,'Title','Color','Tag','bColor','Units','normalized','Position',[0.02 0.75 0.15 0.1],'BackgroundColor',c);

    hDataGui.rBlue = uicontrol('Parent',hDataGui.gColor,'Units','normalized','Position',[0.025 0.725 0.4 0.25],...
                               'String','Blue','Style','radiobutton','BackgroundColor',c,'Tag','rBlue','UserData',[0 0 1]);

    hDataGui.rGreen = uicontrol('Parent',hDataGui.gColor,'Units','normalized','Position',[0.025 0.4 0.4 0.25],...
                                'String','Green','Style','radiobutton','BackgroundColor',c,'Tag','rGreen','UserData',[0 1 0]);

    hDataGui.rRed = uicontrol('Parent',hDataGui.gColor,'Units','normalized','Position',[0.025 0.025 0.4 0.25],...
                              'String','Red','Style','radiobutton','BackgroundColor',c,'Tag','rRed','UserData',[1 0 0]);

    hDataGui.rMagenta = uicontrol('Parent',hDataGui.gColor,'Units','normalized','Position',[0.475 0.725 0.5 0.25],...
                               'String','Magenta','Style','radiobutton','BackgroundColor',c,'Tag','rMagenta','UserData',[1 0 1]);

    hDataGui.rCyan = uicontrol('Parent',hDataGui.gColor,'Units','normalized','Position',[0.475 0.4 0.5 0.25],...
                                  'String','Cyan','Style','radiobutton','BackgroundColor',c,'Tag','rCyan','UserData',[0 1 1]);

    hDataGui.rPink = uicontrol('Parent',hDataGui.gColor,'Units','normalized','Position',[0.475 0.025 0.5 0.25],...
                                 'String','Pink','Style','radiobutton','BackgroundColor',c,'Tag','rPink ','UserData',[1 0.5 0.5]);

    set(hDataGui.gColor,'SelectionChangeFcn',@selcbk);

    set(hDataGui.gColor,'SelectedObject',findobj('UserData',Object.Color,'Parent',hDataGui.gColor));

    hDataGui.pTags = uipanel('Parent',hDataGui.fig,'Title','Tags','Tag','bTags','Units','normalized','Position',[0.18 0.75 0.16 0.1],'BackgroundColor',c);

    hDataGui.tTags = uicontrol('Parent',hDataGui.pTags,'Style','text','Units','normalized',...
                               'Position',[0.05 0.75 0.5 0.25],'Tag','tTags','Fontsize',10,...
                                'String','Choose tag:','BackgroundColor',c,'HorizontalAlignment','left');  
                                     
    hDataGui.lTags = uicontrol('Parent',hDataGui.pTags,'Style','popupmenu','Units','normalized',...
                                         'Position',[0.525 0.75 0.45 0.25],'Tag','eTags','Fontsize',10,...
                                         'String',num2cell(1:63)','BackgroundColor','white','HorizontalAlignment','center');  
                                                      
    hDataGui.bApplyTag = uicontrol('Parent',hDataGui.pTags,'Units','normalized','TooltipString','Tag points with selected tag','Callback','fDataGui(''Tags'',getappdata(0,''hDataGui''));',...
                                'Position',[0.1 0.35 0.8 0.25],'String','Apply Tag','Tag','bApplyTag');
                            
    hDataGui.bClearTag = uicontrol('Parent',hDataGui.pTags,'Units','normalized','TooltipString','Clear selected tag','Callback','fDataGui(''Tags'',getappdata(0,''hDataGui''));',...
                                'Position',[0.1 0.05 0.8 0.25],'String','Clear Tag','Tag','bClearTag');
                            
    hDataGui.pPlot = uipanel('Parent',hDataGui.fig,'Title','Plot','Tag','gPlot','Position',[0.02 0.55 0.32 0.2],'BackgroundColor',c);

    hDataGui.tXaxis = uicontrol('Parent',hDataGui.pPlot,'Units','normalized','Style','text','FontSize',10,'Position',[0.05 0.8 0.33 0.18],...
                                'HorizontalAlignment','left','String','X Axis:','Tag','lXaxis','BackgroundColor',c);

    hDataGui.lXaxis = uicontrol('Parent',hDataGui.pPlot,'Units','normalized','Callback','fDataGui(''XAxisList'',getappdata(0,''hDataGui''));',...
                                'Style','popupmenu','FontSize',8,'Position',[0.4 0.8 0.55 0.18],'String',lXaxis.list,'Tag','lXaxis','UserData',lXaxis,'BackgroundColor','white');

    hDataGui.tYaxis = uicontrol('Parent',hDataGui.pPlot,'Units','normalized','Style','text','FontSize',10,'Position',[0.05 0.6 0.33 0.18],...
                                'HorizontalAlignment','left','String','Y Axis (left):','Tag','lYaxis','BackgroundColor',c);

    hDataGui.lYaxis = uicontrol('Parent',hDataGui.pPlot,'Units','normalized','Callback','fDataGui(''Draw'',getappdata(0,''hDataGui''),0);',...
                                'Style','popupmenu','FontSize',8,'Position',[0.4 0.6 0.55 0.18],'String',lYaxis(1).list,'Tag','lYaxis','UserData',lYaxis,'BackgroundColor','white');                        

    hDataGui.cYaxis2 = uicontrol('Parent',hDataGui.pPlot,'Units','normalized','Callback','fDataGui(''CheckYAxis2'',getappdata(0,''hDataGui''));',...
                                'Position',[0.05 0.46 0.9 0.12],'String','Add second plot','Style','checkbox','BackgroundColor',c,'Tag','cYaxis2','Value',0,'Enable','off');

    hDataGui.tYaxis2 = uicontrol('Parent',hDataGui.pPlot,'Units','normalized','Style','text','FontSize',10,'Position',[0.05 0.26 0.33 0.18],...
                                'HorizontalAlignment','left','String','Y Axis (right):','Tag','lYaxis','Enable','off','BackgroundColor',c);

    hDataGui.lYaxis2 = uicontrol('Parent',hDataGui.pPlot,'Units','normalized','Callback','fDataGui(''Draw'',getappdata(0,''hDataGui''),0);',...
                                'Style','popupmenu','FontSize',8,'Position',[0.4 0.26 0.55 0.18],'String',lYaxis(1).list,'Tag','lYaxis2','UserData',lYaxis,'Enable','off','BackgroundColor','white');                        

    hDataGui.bExport = uicontrol('Parent',hDataGui.pPlot,'Units','normalized','Callback','fDataGui(''Export'',getappdata(0,''hDataGui''));',...
                                 'FontSize',10,'Position',[0.05 0.1 0.9 0.14],'String','Export','Tag','bExport','UserData','Export');

    hDataGui.tPrint = uicontrol('Parent',hDataGui.pPlot,'Units','normalized','Style','text','BackgroundColor',c,...
                                'FontSize',8,'Position',[0.05 0.01 0.9 0.08],'String','(for printing use export to PDF)','Tag','tPrint');
    
    hDataGui.bSelectAll = uicontrol('Parent',hDataGui.fig,'Units','normalized','Callback','fDataGui(''SelectAll'',getappdata(0,''hDataGui''));',...
                             'Position',[0.025 0.51 0.1 0.025],'String','Select all','Tag','bSelectAll','UserData',1);                    
                         
    hDataGui.bClear = uicontrol('Parent',hDataGui.fig,'Units','normalized','Callback','fDataGui(''SelectAll'',getappdata(0,''hDataGui''));',...
                             'Position',[0.13 0.51 0.1 0.025],'String','Clear selection','Tag','bClear','UserData',0);                         
    
    hDataGui.bDeletePoints = uicontrol('Parent',hDataGui.fig,'Units','normalized','Callback','fDataGui(''DeletePoints'',getappdata(0,''hDataGui''));',...
                             'Position',[0.235 0.51 0.1 0.025],'String','Delete points','Tag','bDelete');
                         
    hDataGui.bSplit = uicontrol('Parent',hDataGui.fig,'Units','normalized','Callback','fDataGui(''Split'',getappdata(0,''hDataGui''));',...
                             'Position',[0.35 0.51 0.2 0.025],'String','Create new track','Tag','bSplit');
   
    hDataGui.bInsertPoints = uicontrol('Parent',hDataGui.fig,'Units','normalized','Callback','fDataGui(''FitMissingPoints'',getappdata(0,''hDataGui''));',...
                             'Position',[0.565 0.51 0.2 0.025],'String','Track missing frames','Tag','bInsertPoints');
                         
    hDataGui.bSwitch = uicontrol('Parent',hDataGui.fig,'Units','normalized','Callback','fDataGui(''Switch'',getappdata(0,''hDataGui''));',...
                                'Position',[0.78 0.51 0.2 0.025],'String','Switch MT orientation','Tag','bDelete');
                            
    hDataGui.tFrame = uicontrol('Parent',hDataGui.fig,'Units','normalized','FontSize',10,'HorizontalAlignment','left',...
                             'Position',[0.85 0.96 0.05 0.02],'String','Frame:','Style','text','Tag','tFrame','BackgroundColor',c);

    hDataGui.tFrameValue = uicontrol('Parent',hDataGui.fig,'Units','normalized','FontSize',10,'HorizontalAlignment','right',...
                                  'Position',[0.9 0.96 0.05 0.02],'String','','Style','text','Tag','tFrameValue','BackgroundColor',c);

    j = findjobj(hDataGui.fig,'class','label');
    set(j,'VerticalAlignment',1);
    set(hDataGui.fig, 'WindowButtonMotionFcn', @UpdateCursor);
    set(hDataGui.fig, 'WindowButtonUpFcn',@ButtonUp);
    set(hDataGui.fig, 'WindowButtonDownFcn',@ButtonDown);
    set(hDataGui.fig, 'KeyPressFcn',@KeyPress);
    set(hDataGui.fig, 'KeyReleaseFcn',@KeyRelease);
    set(hDataGui.fig, 'CloseRequestFcn',@Close);
    set(hDataGui.fig, 'WindowScrollWheelFcn',@Scroll);  
    set(hDataGui.tTable, 'CellEditCallback',@Select);
    set(hDataGui.tTable, 'CellSelectionCallback',@ReturnFocus);
else
    setappdata(hDataGui.fig,'Object',Object);
    set(hDataGui.fig,'Name',Object.Name,'WindowStyle','normal','Visible','on');
    set(hDataGui.tName,'String',Object.Name);
    set(hDataGui.tFile,'String',Object.File);
    set(hDataGui.tIndex,'String',['Index: ' num2str(idx)]);
    set(hDataGui.bPrevious,'Enable',ePrevious);
    set(hDataGui.bNext,'Enable',eNext);
    set(hDataGui.cCorrection,'Value',Object.Drift);
    set(hDataGui.eChannel,'String',num2str(Object.Channel));
    set(hDataGui.lReference,'Value', fGetRefPoint(Object));
    set(hDataGui.eComments,'String', Object.Comments,'ForegroundColor','k','HorizontalAlignment','left','Enable','on','ButtonDownFcn','');
    set(hDataGui.gColor,'SelectedObject',findobj('UserData',Object.Color,'Parent',hDataGui.gColor));

    x=get(hDataGui.lXaxis,'Value');
    if x>length(lXaxis.list)
        set(hDataGui.lXaxis,'Value',length(lXaxis.list));            
    end
    set(hDataGui.lXaxis,'String',lXaxis.list,'UserData',lXaxis);    
    set(hDataGui.lYaxis,'UserData',lYaxis);    
    set(hDataGui.lYaxis2,'UserData',lYaxis);        
    if x==length(lXaxis.list)
        CreateHistograms(hDataGui);
    end
    figure(hDataGui.fig);
end
hDataGui.CursorDownPos = [0 0];
hDataGui.Zoom = struct('currentXY',[],'globalXY',[],'level',[],'aspect',GetAxesAspectRatio(hDataGui.aPlot));
hDataGui.SelectRegion = struct('X',[],'Y',[],'plot',[]);
hDataGui.ZoomRegion = struct('X',[],'Y',[],'plot',[]);
hDataGui.CursorMode='Normal';
if isempty(get(hDataGui.eComments,'String'))
    set(hDataGui.eComments,'String', 'Comments','ForegroundColor',[0.5 0.5 0.5],'HorizontalAlignment','center','Enable','inactive','ButtonDownFcn',@Clear);
end

CreateTable(hDataGui,[num2cell(false(size(Object.Results,1),1)) num2cell(Object.Results(:,1:9)) getTags(Object.Results)]);
Check = false(size(Object.Results,1),1);

setappdata(0,'hDataGui',hDataGui);
setappdata(hDataGui.fig,'Object',Object);
setappdata(hDataGui.fig,'Check',Check);
try
    XAxisList(hDataGui);
catch
    delete(hDataGui.fig);
    Create(Type,idx);
end

function Clear(h,~)
set(h,'String','','Enable','on','ForegroundColor','k','HorizontalAlignment','left','ButtonDownFcn','')
uicontrol(h);

function CreateTable(hDataGui,data)
set(hDataGui.tTable,'Units','pixels');
Pos = get(hDataGui.tTable,'Position');
set(hDataGui.tTable,'Units','normalized');
if strcmp(hDataGui.Type,'Molecule')
    columnname = {'Select','Frame','Time[sec]','XPosition[nm]','YPosition[nm]','ZPosition[nm]','Distance[nm]','FWHM[nm]','Amplitude[counts]','Position Error[nm]','Tags'};
else
    columnname = {'Select','Frame','Time[sec]','XPosition[nm]','YPosition[nm]','ZPosition[nm]','Distance[nm]','Length[nm]','Amplitude[counts]','Orientation[rad]','Tags'};
end
columnweight = [ 0.5, 0.6, 0.8, 1.3, 1.3, 1.3, 1.3, 1, 1.3, 1.5, 0.6];
columnwidth = fix(columnweight*Pos(3)/sum(columnweight));
columnwidth(9) = columnwidth(9) + fix(Pos(3))-sum(columnwidth) - 4;
if size(data,1)>19
    columnwidth(9) = columnwidth(9) - 16;
end
set(hDataGui.tTable,'Data',data,'ColumnName',columnname,'ColumnWidth',num2cell(columnwidth));

function selcbk(hObject,eventdata) %#ok<INUSD>
global Molecule;
global Filament;
global KymoTrackMol;
global KymoTrackFil;
hDataGui=getappdata(0,'hDataGui');
hMainGui=getappdata(0,'hMainGui');
color=get(get(hDataGui.gColor,'SelectedObject'),'UserData');
Object=getappdata(hDataGui.fig,'Object');
Object.Color=color;
setappdata(hDataGui.fig,'Object',Object);
if strcmp(hDataGui.Type,'Molecule')
    Molecule(hDataGui.idx)=Object;
    try
        set(Molecule(hDataGui.idx).PlotHandles(1),'Color',color);
        k=findobj('Parent',hMainGui.MidPanel.aView,'-and','UserData',Molecule(hDataGui.idx).Name);
        set(k,'Color',color);           
        k=find([KymoTrackMol.Index]==hDataGui.idx);
        if ~isempty(k)
            set(KymoTrackMol(k).PlotHandles(1),'Color',color);   
        end
    catch
    end
else
    Filament(hDataGui.idx)=Object;
    try
        set(Filament(hDataGui.idx).PlotHandles(1),'Color',color);
        k=findobj('Parent',hMainGui.MidPanel.aView,'-and','UserData',Microtuble(hDataGui.idx).Name);
        set(k,'Color',color);           
        k=find([KymoTrackFil.Index]==hDataGui.idx);
        if ~isempty(k)
            set(KymoTrackFil(k).PlotHandles(1),'Color',color);            
        end
    catch
    end
end
ReturnFocus([],[]);

function Navigation(n)
hDataGui=getappdata(0,'hDataGui');
Create(hDataGui.Type,hDataGui.idx+n);

function DeleteObject(hDataGui)
global Molecule;
global Filament;
MolSelect = zeros(size([Molecule.Selected]));
FilSelect = zeros(size([Filament.Selected]));
n=0;
if strcmp(hDataGui.Type,'Molecule')
    MolSelect(hDataGui.idx)=1; 
    if length(MolSelect)==hDataGui.idx
        n=-1;
    end
else
    FilSelect(hDataGui.idx)=1; 
    if length(FilSelect)==hDataGui.idx
        n=-1;
    end
end
fShared('DeleteTracks',getappdata(0,'hMainGui'),MolSelect,FilSelect);
if hDataGui.idx==1 && n==-1
    close(hDataGui.fig);
else
    Create(hDataGui.Type,hDataGui.idx+n);
end

function ChangeReference(hDataGui)
global Filament;
refPoint = get(hDataGui.lReference,'Value');
Object = getappdata(hDataGui.fig,'Object');
Check = getappdata(hDataGui.fig,'Check');
if refPoint == 1
    Object.Results(:,3:5) = Object.PosStart;
elseif refPoint == 2
    Object.Results(:,3:5) = Object.PosCenter;
else
    Object.Results(:,3:5) = Object.PosEnd;
end
Filament(hDataGui.idx) = Object;
fShow('Image');
fShow('Tracks');
CreateTable(hDataGui,[num2cell(Check) num2cell(Object.Results(:,1:9)) getTags(Object.Results)]);
setappdata(hDataGui.fig,'Object',Object);
[lXaxis,lYaxis]=CreatePlotList(Object,hDataGui.Type);
set(hDataGui.lXaxis,'UserData',lXaxis);    
set(hDataGui.lYaxis,'UserData',lYaxis);    
set(hDataGui.lYaxis2,'UserData',lYaxis); 
Draw(hDataGui,0);

function Tags(hDataGui)
global Molecule;
global Filament;
Object = getappdata(hDataGui.fig,'Object');
Check = getappdata(hDataGui.fig,'Check');
v = get(hDataGui.lTags,'Value');
tags = fliplr(dec2bin(Object.Results(:,end))=='1');
if gcbo == hDataGui.bApplyTag
    if size(tags,2)<v+1
        t = 1;
    else
        t = double(tags(:,v+1)==0);
        t = t(Check==1);
    end
else
    if size(tags,2)<v+1
        t = 0;
    else
        t = tags(:,v+1)==1;
        t = -double(t);
        t = t(Check==1);
    end
end
idx = Check==1;
Object.Results(idx,end) = Object.Results(idx,end) + t*2^(v);
Check(:) = 0;
setappdata(hDataGui.fig,'Check',Check);
CreateTable(hDataGui,[num2cell(Check) num2cell(Object.Results(:,1:9)) getTags(Object.Results)]);
setappdata(hDataGui.fig,'Object',Object);
if strcmp(hDataGui.Type,'Molecule')==1
    Molecule(hDataGui.idx)=Object;
else
    Filament(hDataGui.idx)=Object;
end
Draw(hDataGui,-1);

function Export(hDataGui)
fExportDataGui('Create',hDataGui.Type,hDataGui.idx);
ReturnFocus([],[]);
    
function tags = getTags(Results)
t = fliplr(dec2bin(Results(:,end))=='1');
tags = cell(size(t,1),1);
for n = 1:size(t,1)
    if t(n,1) == 1
        tags{n} = ' i';
    end
    for m = 2:size(t,2)
        if t(n,m)==1
            tags{n} = [tags{n} ',' num2str(m-1)];
        end
    end
    if ~isempty(tags{n})
        if tags{n}(1)==','
            tags{n}(1) = ' ';
        end    
    end
end

function Draw(hDataGui,ax)
%get object data
Object=getappdata(hDataGui.fig,'Object');
%save current view
xy=get(hDataGui.aPlot,{'xlim','ylim'});

%get plot colums
x=get(hDataGui.lXaxis,'Value');
XList=get(hDataGui.lXaxis,'UserData');
XPlot=XList.data{x};

y=get(hDataGui.lYaxis,'Value');
YList=get(hDataGui.lYaxis,'UserData');
if ~isempty(XPlot)
    YPlot{1}=YList(x).data{y};
else
    XPlot=YList(x).data{y}(:,1);
    YPlot{1}=YList(x).data{y}(:,2);
    XList.list{x}=YList(x).list{y};
    XList.units{x}=YList(x).units{y};
    YList(x).list{y}='number of data points';    
    YList(x).units{y}='';
end 
                  
cla(hDataGui.aPlot,'reset');
%hDataGui.aPlot = axes('Parent',hDataGui.pPlotPanel,'OuterPosition',[0 0 1 1],'TickDir','out',...
   %                   'XLimMode','manual','YLimMode','manual'); 
hDataGui.DataPlot = [];                  
set(0,'CurrentFigure',hDataGui.fig);                  
setappdata(0,'hDataGui',hDataGui);                 
hold on     
xscale=1;
yscale=1;
if strcmp(XList.units{x},'[nm]')
    if x==1 
        if (max(XPlot)-min(XPlot))>5000
            xscale=1000;
            XList.units{x}=['[' char(956) 'm]'];
            yscale=1000;
            YList(x).units{y}=['[' char(956) 'm]'];
        end
    else
        if max(XPlot)>5000
            xscale=1000;
            XList.units{x}=['[' char(956) 'm]'];    
        end
    end
end
if strcmp(YList(x).units{y},'[nm]') 
    if x==1 
        if (max(YPlot{1})-max(YPlot{1}))>5000
            yscale=1000;
            YList(x).units{y}=['[' char(956) 'm]'];
            xscale=1000;
            XList.units{x}=['[' char(956) 'm]']; 
        end
    else
        if max(YPlot{1})>5000
            yscale=1000;
            YList(x).units{y}=['[' char(956) 'm]'];   
        end
    end
end
if strcmp(YList(x).units{y},'[nm/s]') && max(YPlot{1})>5000
    yscale=1000;
    YList(x).units{y}=['[' char(956) 'm/s]'];
end
if x<length(XList.data)
    FilXY = [];
    if x==1
        Dis=norm([Object.Results(1,3)-Object.Results(end,3) Object.Results(1,4)-Object.Results(end,4)]);     
        if strcmp(hDataGui.Type,'Filament')
            FilXY=cell(1,4);
            lData=length(Object.Data);
            VecX=zeros(lData,2);
            VecY=zeros(lData,2);
            VecU=zeros(lData,2);
            VecV=zeros(lData,2);
            Length=mean(Object.Results(:,7)); 
            for i=1:lData
                n=size(Object.Data{i},1);     
                if n>1
                    line(hDataGui.aPlot,(Object.Data{i}(:,1)-min(XPlot))/xscale,(Object.Data{i}(:,2)-min(YPlot{1}))/yscale,'Color','red','LineStyle','-','Marker','none');
                    if Dis<=2*Object.PixelSize
                        VecX(i,:)=[Object.Data{i}(ceil(n/4),1) Object.Data{i}(fix(3*n/4),1)]-min(XPlot);
                        VecY(i,:)=[Object.Data{i}(ceil(n/4),2) Object.Data{i}(fix(3*n/4),2)]-min(YPlot{1});                    
                        VecU(i,:)=[Object.Data{i}(ceil(n/4)+1,1) Object.Data{i}(fix(3*n/4)+1,1)]-min(XPlot);
                        VecV(i,:)=[Object.Data{i}(ceil(n/4)+1,2) Object.Data{i}(fix(3*n/4)+1,2)]-min(YPlot{1});
                    end
                    FilXY{1} = min([(Object.Data{i}(:,1)'-min(XPlot)) FilXY{1}]);
                    FilXY{2} = max([(Object.Data{i}(:,1)'-min(XPlot)) FilXY{2}]);                    
                    FilXY{3} = min([(Object.Data{i}(:,2)'-min(YPlot{1})) FilXY{3}]);
                    FilXY{4} = max([(Object.Data{i}(:,2)'-min(YPlot{1})) FilXY{4}]);                    
                end
            end
            if Dis<=2*Object.PixelSize
                VecX=mean(VecX);
                VecY=mean(VecY);                
                VecU=mean(VecU);
                VecV=mean(VecV);                            
                U=(VecU-VecX)./sqrt((VecU-VecX).^2+(VecV-VecY).^2);
                V=(VecV-VecY)./sqrt((VecU-VecX).^2+(VecV-VecY).^2);                
                fill(hDataGui.aPlot,[VecX(1)+Length/20*U(1) VecX(1)+Length/40*V(1) VecX(1)-Length/40*V(1)]/xscale,[VecY(1)+Length/20*V(1) VecY(1)-Length/40*U(1) VecY(1)+Length/40*U(1)]/yscale,'r','EdgeColor','none');
                if lData>1
                    fill(hDataGui.aPlot,[VecX(2)+Length/20*U(2) VecX(2)+Length/40*V(2) VecX(2)-Length/40*V(2)]/xscale,[VecY(2)+Length/20*V(2) VecY(2)-Length/40*U(2) VecY(2)+Length/40*U(2)]/yscale,'r','EdgeColor','none');                
                end
            end
        end
        if Dis>2*Object.PixelSize     
            try
                n(1) = find(Object.Results(:,6)<Dis/4,1,'last');
                n(2) = find(Object.Results(:,6)<Dis/2,1,'last');
                n(3) = find(Object.Results(:,6)<3*Dis/4,1,'last');
                n(4) = size(Object.Results,1);     
                VecX=[Object.Results(n(1),3) Object.Results(n(2),3) Object.Results(n(3),3)]-min(XPlot);
                VecY=[Object.Results(n(1),4) Object.Results(n(2),4) Object.Results(n(3),4)]-min(YPlot{1});                    
                VecU=[mean(Object.Results(n(1)+1:n(2),3)) mean(Object.Results(n(2)+1:n(3),3)) mean(Object.Results(n(3)+1:n(4),3))]-min(XPlot);
                VecV=[mean(Object.Results(n(1)+1:n(2),4)) mean(Object.Results(n(2)+1:n(3),4)) mean(Object.Results(n(3)+1:n(4),4))]-min(YPlot{1});
                U=(VecU-VecX)./sqrt((VecU-VecX).^2+(VecV-VecY).^2);
                V=(VecV-VecY)./sqrt((VecU-VecX).^2+(VecV-VecY).^2);    
                for m = 1:3
                    fill(hDataGui.aPlot,[VecX(m)+Dis/15*U(m) VecX(m)+Dis/30*V(m) VecX(m)-Dis/30*V(m)]/xscale,[VecY(m)+Dis/15*V(m) VecY(m)-Dis/30*U(m) VecY(m)+Dis/30*U(m)]/yscale,[0.8 0.8 0.8],'EdgeColor','none');
                end   
            catch
            end
        end
        
        XPlot=XPlot-min(XPlot);
        YPlot{1}=YPlot{1}-min(YPlot{1});        
    end

    %get checked table entries
    Check = getappdata(hDataGui.fig,'Check');
    k=find(Check==1);

    if strcmp(get(hDataGui.cYaxis2,'Enable'),'on') && get(hDataGui.cYaxis2,'Value')

        y2=get(hDataGui.lYaxis2,'Value');
        YList2=get(hDataGui.lYaxis2,'UserData');    
        YPlot{2}=YList2(x).data{y2};
        yscale(2) = 1;
        if strcmp(YList2(x).units{y2},'[nm]') && max(YPlot{2})>5000
            yscale(2)=1000;
            YList2(x).units{y2}=['[' char(956) 'm]'];
        end
    else 
        YList2 = [];
        y2=[];
    end
    for n = 1:numel(YPlot)
        if numel(YPlot)>1
            if n==1
                astr = 'left';
                c = [0 0.4470 0.7410];
            else
                astr = 'right';
                c = [0.8500 0.3250 0.0980];
            end
            yyaxis(hDataGui.aPlot,astr);
        else
            astr = [];
            c = [0 0.4470 0.7410];
        end
        hDataGui.DataPlot(n) = line(hDataGui.aPlot,XPlot/xscale,YPlot{n}/yscale(n),'Color',c);
        tags = fliplr(dec2bin(Object.Results(:,end))=='1');
        if any(any(tags))
            line(hDataGui.aPlot,XPlot(tags(:,1))/xscale,YPlot{n}(tags(:,1))/yscale(n),'Color','blue','LineStyle','none','Marker','+','MarkerSize',4);  
            c=[1 0.5 0.5; 1 0.5 0; 0.8 0.1 0.56; 0.8 1 0.3; 1 1 1; 0 0.5 1; 0.5 0.5 1];
            c = repmat(c,9,1);
            s = {'s','^','*','<','d','>','p','v','h'};
            for m = 2:size(tags,2)
                line(hDataGui.aPlot,XPlot(tags(:,m))/xscale,YPlot{n}(tags(:,m))/yscale(n),'Color',c(m-1,:),'MarkerFaceColor',c(m-1,:),'LineStyle','none','Marker',s{ceil((m-1)/7)},'MarkerSize',6);
            end
        end
        if k>0
            line(hDataGui.aPlot,XPlot(k)/xscale,YPlot{n}(k)/yscale(n),'Color','green','LineStyle','none','Marker','o');
        end
        set(hDataGui.aPlot,'TickDir','out','YTickMode','auto');
        SetLabels(hDataGui,XList,YList,YList2,x,y,y2);
        if ~isempty(FilXY)
            XPlot=[FilXY{1} FilXY{2}];
            YPlot{n}=[FilXY{3} FilXY{4}];
        end   
        if length(XPlot)>1
            SetAxis(hDataGui.aPlot,XPlot/xscale,YPlot{n}/yscale(n),x,astr);
        else
            axis auto;
        end
        set(hDataGui.DataPlot(n),'Marker','.','MarkerSize',12);
    end
else
    hDataGui.DataPlot=bar(hDataGui.aPlot,XPlot/xscale,YPlot{1}/yscale(1),'BarWidth',1,'EdgeColor','black','FaceColor','blue','LineWidth',1);
    SetAxis(hDataGui.aPlot,XPlot/xscale,YPlot{1}/yscale(1),NaN,[]); 
    SetLabels(hDataGui,XList,YList,[],x,y,[]);
end
hold off;
if xy{1}(2)~=1&&xy{2}(2)~=1 && ax==-1
    set(hDataGui.aPlot,{'xlim','ylim'},xy);
else
    hDataGui.Zoom.globalXY = get(hDataGui.aPlot,{'xlim','ylim'});
    hDataGui.Zoom.currentXY = hDataGui.Zoom.globalXY;
    hDataGui.Zoom.level = 0;
end
setappdata(0,'hDataGui',hDataGui);
ReturnFocus([],[]);

function SetAxis(a,X,Y,idx,mode)
if ~isempty(mode)
   yyaxis(a,mode); 
end
set(a,'Units','pixel');
pos=get(a,'Position');
set(a,'Units','normalized');
if idx==1
    xy{1}=[-ceil(max(-X)) ceil(max(X))]+[-0.01 0.01]*(max(X)-min(X));
    xy{2}=[-ceil(max(-Y)) ceil(max(Y))]+[-0.01 0.01]*(max(Y)-min(Y));
else
    xy{1}=[min(X) max(X)];
    xy{2}=[min(Y) max(Y)];
end
if all(~isnan(xy{1}))&&all(~isnan(xy{2}))
    if idx==1
        lx=max(X)-min(X);
        ly=max(Y)-min(Y);
        if ly>lx
            xy{1}(2)=min(X)+lx/2+ly/2;
            xy{1}(1)=min(X)+lx/2-ly/2;
        else
            xy{2}(2)=min(Y)+ly/2+lx/2;            
            xy{2}(1)=min(Y)+ly/2-lx/2;
        end
        lx=xy{1}(2)-xy{1}(1);
        xy{1}(1)=xy{1}(1)-lx*(pos(3)/pos(4)-1)/2;
        xy{1}(2)=xy{1}(2)+lx*(pos(3)/pos(4)-1)/2;
        set(a,{'xlim','ylim'},xy,'YDir','reverse');
    else
        set(a,{'xlim','ylim'},xy,'YDir','normal');
        if isnan(idx)
            XTick=get(a,'XTick');
            s=length(XTick);
            xy{1}(1)=2*XTick(1)-XTick(2); 
            xy{1}(2)=2*XTick(s)-XTick(s-1); 
            xy{2}(1)=0;
        end
        YTick=get(a,'YTick');
        s=length(YTick);
        if YTick(1)~=0
            xy{2}(1)=2*YTick(1)-YTick(2); 
        end            
        xy{2}(2)=2*YTick(s)-YTick(s-1); 
        set(a,{'xlim','ylim'},xy,'YDir','normal');
    end
end

function SetLabels(hDataGui,XList,YList,YList2,x,y,y2)
if ~isempty(y2)
    yyaxis(hDataGui.aPlot,'left');
end
xlabel(hDataGui.aPlot,[XList(1).list{x} '  ' XList.units{x}]);
ylabel(hDataGui.aPlot,[YList(x).list{y} '  ' YList(x).units{y}]);
if ~isempty(y2)
    yyaxis(hDataGui.aPlot,'right');
    ylabel(hDataGui.aPlot,[YList2(x).list{y2} '  ' YList2(x).units{y2}]);
end

function KeyPress(~,evnt)
hDataGui=getappdata(0,'hDataGui');
if strcmp(hDataGui.CursorMode,'Normal');
    switch(evnt.Key)
        case 'shift' 
            hDataGui.CursorMode='Zoom';
            CData = [NaN,NaN,NaN,NaN,1,1,1,1,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,1,1,NaN,2,NaN,2,1,1,NaN,NaN,NaN,NaN,NaN,NaN;NaN,1,2,NaN,2,1,1,NaN,2,NaN,1,NaN,NaN,NaN,NaN,NaN;NaN,1,NaN,2,NaN,1,1,2,NaN,2,1,NaN,NaN,NaN,NaN,NaN;1,NaN,2,NaN,2,1,1,NaN,2,NaN,2,1,NaN,NaN,NaN,NaN;1,2,1,1,1,1,1,1,1,1,NaN,1,NaN,NaN,NaN,NaN;1,NaN,1,1,1,1,1,1,1,1,2,1,NaN,NaN,NaN,NaN;1,2,NaN,2,NaN,1,1,2,NaN,2,NaN,1,NaN,NaN,NaN,NaN;NaN,1,2,NaN,2,1,1,NaN,2,NaN,1,NaN,NaN,NaN,NaN,NaN;NaN,1,NaN,2,NaN,1,1,2,NaN,2,1,2,NaN,NaN,NaN,NaN;NaN,NaN,1,1,2,NaN,2,NaN,1,1,1,1,2,NaN,NaN,NaN;NaN,NaN,NaN,NaN,1,1,1,1,NaN,2,1,1,1,2,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,2,1,1,1,2,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,2,1,1,1,2;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,2,1,1,1;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,2,1,2;];
            set(hDataGui.fig,'Pointer','custom','PointerShapeCData',CData,'PointerShapeHotSpot',[6 6]);
            hDataGui.CursorDownPos(:)=0;        
            if ~isempty(hDataGui.SelectRegion.plot)
                delete(hDataGui.SelectRegion.plot);    
                hDataGui.SelectRegion.plot=[];
            end
        otherwise
            hDataGui.CursorMode='Normal';
            set(hDataGui.fig,'pointer','arrow');
    end
    setappdata(0,'hDataGui',hDataGui);
end

function KeyRelease(~, evnt) 
hDataGui=getappdata(0,'hDataGui');
set(0,'CurrentFigure',hDataGui.fig);
cp=get(hDataGui.aPlot,'currentpoint');
cp=cp(1,[1 2]);
if strcmp(hDataGui.CursorMode,'Zoom');
    if strcmp(evnt.Key,'shift')
        if all(hDataGui.CursorDownPos~=0) && all(hDataGui.CursorDownPos~=cp) 
            xy{1} =  [min(hDataGui.ZoomRegion.X) max(hDataGui.ZoomRegion.X)];
            xy{2} =  [min(hDataGui.ZoomRegion.Y) max(hDataGui.ZoomRegion.Y)];
            set(hDataGui.aPlot,{'xlim','ylim'},xy);
            hDataGui.Zoom.currentXY = xy;
            x_total=hDataGui.Zoom.globalXY{1}(2)-hDataGui.Zoom.globalXY{1}(1);
            y_total=hDataGui.Zoom.globalXY{2}(2)-hDataGui.Zoom.globalXY{2}(1);    
            x_current=hDataGui.Zoom.currentXY{1}(2)-hDataGui.Zoom.currentXY{1}(1);
            y_current=hDataGui.Zoom.currentXY{2}(2)-hDataGui.Zoom.currentXY{2}(1);   
            hDataGui.Zoom.level = -log((x_current/x_total +  y_current/y_total)/2)*8;
        end
        if ~isempty(hDataGui.ZoomRegion.plot)
            delete(hDataGui.ZoomRegion.plot);    
            hDataGui.ZoomRegion.plot=[];
        end
        hDataGui.CursorDownPos(:)=0;     
        hDataGui.CursorMode='Normal';
        setappdata(0,'hDataGui',hDataGui);
        set(hDataGui.fig,'pointer','arrow');
    end
end
 setappdata(0,'hDataGui',hDataGui);
 
function ButtonDown(hObject, eventdata) %#ok<INUSD>
hDataGui=getappdata(0,'hDataGui');
set(0,'CurrentFigure',hDataGui.fig);
cp=get(hDataGui.aPlot,'currentpoint');
cp=cp(1,[1 2]);
pos = get(hDataGui.pPlotPanel,'Position');
cpFig = get(hDataGui.fig,'currentpoint');
cpFig = cpFig(1,[1 2]);
if all(cpFig>=[pos(1) pos(2)]) && all(cpFig<=[pos(1)+pos(3) pos(2)+pos(4)]) 
    if strcmp(get(hDataGui.fig,'SelectionType'),'normal')
        hDataGui.CursorMode='Normal';
        if all(hDataGui.CursorDownPos==0)
            hDataGui.SelectRegion.X=cp(1);
            hDataGui.SelectRegion.Y=cp(2);
            hDataGui.SelectRegion.plot=line(hDataGui.aPlot,cp(1),cp(2),'Color','black','LineStyle',':','Tag','pSelectRegion');                   
            hDataGui.CursorDownPos=cp;                   
        end
    elseif strcmp(get(hDataGui.fig,'SelectionType'),'extend')
        if strcmp(hDataGui.CursorMode,'Normal');
            hDataGui.CursorMode='Pan';
            hDataGui.CursorDownPos=cp;  
            CData=[NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,1,1,NaN,1,1,NaN,1,1,NaN,NaN,NaN,NaN;NaN,NaN,NaN,1,2,2,1,2,2,1,2,2,1,1,NaN,NaN;NaN,NaN,NaN,1,2,2,2,2,2,2,2,2,1,2,1,NaN;NaN,NaN,NaN,NaN,1,2,2,2,2,2,2,2,2,2,1,NaN;NaN,NaN,NaN,1,1,2,2,2,2,2,2,2,2,2,1,NaN;NaN,NaN,1,2,2,2,2,2,2,2,2,2,2,2,1,NaN;NaN,NaN,1,2,2,2,2,2,2,2,2,2,2,2,1,NaN;NaN,NaN,1,2,2,2,2,2,2,2,2,2,2,1,NaN,NaN;NaN,NaN,NaN,1,2,2,2,2,2,2,2,2,2,1,NaN,NaN;NaN,NaN,NaN,NaN,1,2,2,2,2,2,2,2,1,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,1,2,2,2,2,2,2,1,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,1,2,2,2,2,2,2,1,NaN,NaN,NaN;];
            set(hDataGui.fig,'Pointer','custom','PointerShapeCData',CData,'PointerShapeHotSpot',[10 9]);
        elseif strcmp(hDataGui.CursorMode,'Zoom');
            if all(hDataGui.CursorDownPos==0)
                hDataGui.ZoomRegion.X=cp(1);
                hDataGui.ZoomRegion.Y=cp(2);
                hDataGui.ZoomRegion.plot=line(hDataGui.aPlot,cp(1),cp(2),'Color','black','LineStyle','--','Tag','pZoomRegion');                   
                hDataGui.CursorDownPos=cp;                   
            end
        end
    end
end
setappdata(0,'hDataGui',hDataGui);

function ButtonUp(hObject, eventdata) %#ok<INUSD>
hDataGui=getappdata(0,'hDataGui');
set(0,'CurrentFigure',hDataGui.fig);
Check=getappdata(hDataGui.fig,'Check');
xy=get(hDataGui.aPlot,{'xlim','ylim'});
cp=get(hDataGui.aPlot,'currentpoint');
cp=cp(1,[1 2]);
X=get(hDataGui.DataPlot(1),'XData');
Y=get(hDataGui.DataPlot,'YData');
if strcmp(hDataGui.CursorMode,'Normal')    
    k = [];
    d = [];
    if all(hDataGui.CursorDownPos==cp)
        if iscell(Y)
            yyaxis(hDataGui.aPlot,'left');
            dx=((xy{1}(2)-xy{1}(1))/25);
            dy=((xy{2}(2)-xy{2}(1))/25);
            d = [d;(X-cp(1)).^2+(Y{1}-cp(2)).^2];
            k = [k find(abs(X-cp(1))<dx & abs(Y{1}-cp(2))<dy)];
            
            yyaxis(hDataGui.aPlot,'right');
            dx=((xy{1}(2)-xy{1}(1))/25);
            dy=((xy{2}(2)-xy{2}(1))/25);
            d = [d;(X-cp(1)).^2+(Y{2}-cp(2)).^2];
            k = [k find(abs(X-cp(1))<dx & abs(Y{2}-cp(2))<dy)];
            [~,t]=min(min(d));
            if ~isempty(k) && any(k==t)
                Check(t) = ~Check(t);
            else
                k = [];
            end
        else
            dx=((xy{1}(2)-xy{1}(1))/40);
            dy=((xy{2}(2)-xy{2}(1))/40);
            k=find( abs(X-cp(1))<dx & abs(Y-cp(2))<dy);
            [~,t]=min((X(k)-cp(1)).^2+(Y(k)-cp(2)).^2);
            Check(k(t)) = ~Check(k(t));
        end
    elseif all(hDataGui.CursorDownPos~=0)
        hDataGui.SelectRegion.X=[hDataGui.SelectRegion.X hDataGui.SelectRegion.X(1)];
        hDataGui.SelectRegion.Y=[hDataGui.SelectRegion.Y hDataGui.SelectRegion.Y(1)];
        if iscell(Y)
            for n = 1:length(Y)
                IN = inpolygon(X,Y{n},hDataGui.SelectRegion.X,hDataGui.SelectRegion.Y);
                Check(IN) = ~Check(IN);
                k=[k find(IN==1)];
            end
        else
            IN = inpolygon(X,Y,hDataGui.SelectRegion.X,hDataGui.SelectRegion.Y);
            Check(IN) = ~Check(IN);
            k=find(IN==1);
        end
    end
    hDataGui.CursorDownPos(:)=0;        
    if ~isempty(hDataGui.SelectRegion.plot)
        delete(hDataGui.SelectRegion.plot);    
        hDataGui.SelectRegion.plot=[];
    end
    if ~isempty(k)
        data = get(hDataGui.tTable,'Data');
        data(:,1) = num2cell(Check);
        set(hDataGui.tTable,'Data',data);
    end
elseif strcmp(hDataGui.CursorMode,'Pan')    
    hDataGui.CursorDownPos(:)=0;    
    hDataGui.CursorMode='Normal';
    set(hDataGui.fig,'pointer','arrow');
elseif strcmp(hDataGui.CursorMode,'Zoom')  
    if all(hDataGui.CursorDownPos~=0) && all(hDataGui.CursorDownPos~=cp) 
        xy{1} =  [min(hDataGui.ZoomRegion.X) max(hDataGui.ZoomRegion.X)];
        xy{2} =  [min(hDataGui.ZoomRegion.Y) max(hDataGui.ZoomRegion.Y)];
        set(hDataGui.aPlot,{'xlim','ylim'},xy);
        hDataGui.Zoom.currentXY = xy;
        x_total=hDataGui.Zoom.globalXY{1}(2)-hDataGui.Zoom.globalXY{1}(1);
        y_total=hDataGui.Zoom.globalXY{2}(2)-hDataGui.Zoom.globalXY{2}(1);    
        x_current=hDataGui.Zoom.currentXY{1}(2)-hDataGui.Zoom.currentXY{1}(1);
        y_current=hDataGui.Zoom.currentXY{2}(2)-hDataGui.Zoom.currentXY{2}(1);   
        hDataGui.Zoom.level = -log((x_current/x_total +  y_current/y_total)/2)*8;
    else
        if strcmp(get(hDataGui.fig,'SelectionType'),'extend') || strcmp(get(hDataGui.fig,'SelectionType'),'open')
            hDataGui.Zoom.level = hDataGui.Zoom.level + 1;
        else
            hDataGui.Zoom.level = hDataGui.Zoom.level - 1 ;
        end
        setappdata(0,'hDataGui',hDataGui);
        Scroll([],[]);
        hDataGui = getappdata(0,'hDataGui');
    end
    if ~isempty(hDataGui.ZoomRegion.plot)
        delete(hDataGui.ZoomRegion.plot);    
        hDataGui.ZoomRegion.plot=[];
    end
    hDataGui.CursorDownPos(:)=0;    
end
setappdata(hDataGui.fig,'Check',Check);
setappdata(0,'hDataGui',hDataGui);
Draw(hDataGui,-1);


function UpdateCursor(hObject, eventdata) %#ok<INUSD>
hDataGui=getappdata(0,'hDataGui');
set(0,'CurrentFigure',hDataGui.fig);
Object=getappdata(hDataGui.fig,'Object');
pos = get(hDataGui.pPlotPanel,'Position');
cpFig = get(hDataGui.fig,'currentpoint');
cpFig = cpFig(1,[1 2]);
xy=get(hDataGui.aPlot,{'xlim','ylim'});
cp=get(hDataGui.aPlot,'currentpoint');
cp=cp(1,[1 2]);
X=get(hDataGui.DataPlot(1),'XData');
Y=get(hDataGui.DataPlot(1),'YData');
if all(cpFig>=[pos(1) pos(2)]) && all(cpFig<=[pos(1)+pos(3) pos(2)+pos(4)])
    if strcmp(hDataGui.CursorMode,'Normal')
        dx=((xy{1}(2)-xy{1}(1))/40);
        dy=((xy{2}(2)-xy{2}(1))/40);
        k=find( abs(X-cp(1))<dx & abs(Y-cp(2))<dy);
        [~,t]=min((X(k)-cp(1)).^2+(Y(k)-cp(2)).^2);
        set(hDataGui.tFrameValue,'String',num2str(Object.Results(k(t),1)));
        if all(hDataGui.CursorDownPos~=0)
            hDataGui.SelectRegion.X=[hDataGui.SelectRegion.X cp(1)];
            hDataGui.SelectRegion.Y=[hDataGui.SelectRegion.Y cp(2)];
            if ~isempty(hDataGui.SelectRegion.plot)
                delete(hDataGui.SelectRegion.plot);    
                hDataGui.SelectRegion.plot=[];
            end
            hDataGui.SelectRegion.plot = line(hDataGui.aPlot,[hDataGui.SelectRegion.X hDataGui.SelectRegion.X(1)] ,[hDataGui.SelectRegion.Y hDataGui.SelectRegion.Y(1)],'Color','black','LineStyle',':','Tag','pSelectRegion');
        end
        set(hDataGui.fig,'pointer','arrow');
    elseif strcmp(hDataGui.CursorMode,'Pan')
        if all(hDataGui.CursorDownPos~=0)
            Zoom=hDataGui.Zoom;
            xy=Zoom.currentXY;
            xy{1}=xy{1}-(cp(1)-hDataGui.CursorDownPos(1));
            xy{2}=xy{2}-(cp(2)-hDataGui.CursorDownPos(2));
            if xy{1}(1)<Zoom.globalXY{1}(1)
                xy{1}=xy{1}-xy{1}(1)+Zoom.globalXY{1}(1);
            end
            if xy{1}(2)>Zoom.globalXY{1}(2)
                xy{1}=xy{1}-xy{1}(2)+Zoom.globalXY{1}(2);
            end
            if xy{2}(1)<Zoom.globalXY{2}(1)
                xy{2}=xy{2}-xy{2}(1)+Zoom.globalXY{2}(1);
            end
            if xy{2}(2)>Zoom.globalXY{2}(2)
                xy{2}=xy{2}-xy{2}(2)+Zoom.globalXY{2}(2);
            end
            set(hDataGui.aPlot,{'xlim','ylim'},xy);
            hDataGui.Zoom.currentXY=xy;
        end
        CData=[NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,1,1,NaN,1,1,NaN,1,1,NaN,NaN,NaN,NaN;NaN,NaN,NaN,1,2,2,1,2,2,1,2,2,1,1,NaN,NaN;NaN,NaN,NaN,1,2,2,2,2,2,2,2,2,1,2,1,NaN;NaN,NaN,NaN,NaN,1,2,2,2,2,2,2,2,2,2,1,NaN;NaN,NaN,NaN,1,1,2,2,2,2,2,2,2,2,2,1,NaN;NaN,NaN,1,2,2,2,2,2,2,2,2,2,2,2,1,NaN;NaN,NaN,1,2,2,2,2,2,2,2,2,2,2,2,1,NaN;NaN,NaN,1,2,2,2,2,2,2,2,2,2,2,1,NaN,NaN;NaN,NaN,NaN,1,2,2,2,2,2,2,2,2,2,1,NaN,NaN;NaN,NaN,NaN,NaN,1,2,2,2,2,2,2,2,1,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,1,2,2,2,2,2,2,1,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,1,2,2,2,2,2,2,1,NaN,NaN,NaN;];
        set(hDataGui.fig,'Pointer','custom','PointerShapeCData',CData,'PointerShapeHotSpot',[10 9]);    
    elseif strcmp(hDataGui.CursorMode,'Zoom')
        if all(hDataGui.CursorDownPos~=0)
            hDataGui.ZoomRegion.X=[hDataGui.ZoomRegion.X(1) hDataGui.ZoomRegion.X(1) cp(1) cp(1) hDataGui.ZoomRegion.X(1)];
            hDataGui.ZoomRegion.Y=[hDataGui.ZoomRegion.Y(1) cp(2) cp(2) hDataGui.ZoomRegion.Y(1) hDataGui.ZoomRegion.Y(1)];
            if ~isempty(hDataGui.ZoomRegion.plot)
                delete(hDataGui.ZoomRegion.plot);    
                hDataGui.ZoomRegion.plot=[];
            end
            hDataGui.ZoomRegion.plot = line(hDataGui.aPlot,hDataGui.ZoomRegion.X ,hDataGui.ZoomRegion.Y,'Color','black','LineStyle','--','Tag','pZoomRegion');
        end
        CData = [NaN,NaN,NaN,NaN,1,1,1,1,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,1,1,NaN,2,NaN,2,1,1,NaN,NaN,NaN,NaN,NaN,NaN;NaN,1,2,NaN,2,1,1,NaN,2,NaN,1,NaN,NaN,NaN,NaN,NaN;NaN,1,NaN,2,NaN,1,1,2,NaN,2,1,NaN,NaN,NaN,NaN,NaN;1,NaN,2,NaN,2,1,1,NaN,2,NaN,2,1,NaN,NaN,NaN,NaN;1,2,1,1,1,1,1,1,1,1,NaN,1,NaN,NaN,NaN,NaN;1,NaN,1,1,1,1,1,1,1,1,2,1,NaN,NaN,NaN,NaN;1,2,NaN,2,NaN,1,1,2,NaN,2,NaN,1,NaN,NaN,NaN,NaN;NaN,1,2,NaN,2,1,1,NaN,2,NaN,1,NaN,NaN,NaN,NaN,NaN;NaN,1,NaN,2,NaN,1,1,2,NaN,2,1,2,NaN,NaN,NaN,NaN;NaN,NaN,1,1,2,NaN,2,NaN,1,1,1,1,2,NaN,NaN,NaN;NaN,NaN,NaN,NaN,1,1,1,1,NaN,2,1,1,1,2,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,2,1,1,1,2,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,2,1,1,1,2;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,2,1,1,1;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,2,1,2;];
        set(hDataGui.fig,'Pointer','custom','PointerShapeCData',CData,'PointerShapeHotSpot',[6 6]);
    end
    setappdata(0,'hDataGui',hDataGui);
else 
    set(hDataGui.tFrameValue,'String','');
    set(hDataGui.fig,'pointer','arrow');
end

function Close(hObject,eventdata) %#ok<INUSD>
hDataGui=getappdata(0,'hDataGui');
try
    hDataGui.idx=0;
    setappdata(0,'hDataGui',hDataGui);
    set(hDataGui.fig,'Visible','off','WindowStyle','normal');
    fShared('ReturnFocus');
    fShow('Tracks');
catch
    delete(hDataGui.fig);
end


function DeletePoints(hDataGui)
global Filament;
global Molecule;
hMainGui=getappdata(0,'hMainGui');
Object = getappdata(hDataGui.fig,'Object');
Check = getappdata(hDataGui.fig,'Check');
if sum(Check)<size(Object.Results,1)
    Object.Results(Check==1,:)=[];
    Object.Results(:,6)=fDis(Object.Results(:,3:5));
    Object.TrackingResults(Check==1)=[];
    if strcmp(hDataGui.Type,'Filament')==1
        Object.PosStart(Check==1,:)=[];
        Object.PosCenter(Check==1,:)=[];   
        Object.PosEnd(Check==1,:)=[];
        Object.Data(Check==1)=[];        
    end
    if ~isempty(Object.PathData)
        Object.PathData(Check==1,:)=[];   
    end
    Check( Check==1 ) = [];
    CreateTable(hDataGui,[num2cell(Check) num2cell(Object.Results(:,1:9)) getTags(Object.Results)]);
    setappdata(hDataGui.fig,'Object',Object);
    if strcmp(hDataGui.Type,'Molecule')==1
        Molecule(hDataGui.idx)=Object;
    else
        Filament(hDataGui.idx)=Object;
    end
    [lXaxis,lYaxis]=CreatePlotList(Object,hDataGui.Type);
    set(hDataGui.lXaxis,'UserData',lXaxis);    
    set(hDataGui.lYaxis,'UserData',lYaxis);    
    set(hDataGui.lYaxis2,'UserData',lYaxis);        
    setappdata(hDataGui.fig,'Check',Check);
    Draw(hDataGui,0);
    fRightPanel('UpdateKymoTracks',hMainGui);
    X=Object.Results(:,3)/hMainGui.Values.PixSize;
    Y=Object.Results(:,4)/hMainGui.Values.PixSize;
    if length(X)==1
        X(1,2)=X;
        Y(1,2)=Y;
    end
    set(Object.PlotHandles(1,1),'XData',X,'YData',Y,'MarkerIndices',1:5:length(Y));
    drawnow
end

function SetComments
global Filament;
global Molecule;
hDataGui=getappdata(0,'hDataGui');
Object = getappdata(hDataGui.fig,'Object');
Object.Comments = get(hDataGui.eComments,'String');
if strcmp(hDataGui.Type,'Molecule')==1
    Molecule(hDataGui.idx)=Object;
else
    Filament(hDataGui.idx)=Object;
end
setappdata(hDataGui.fig,'Object',Object);
if isempty(Object.Comments)
    set(hDataGui.eComments,'String', 'Comments','ForegroundColor',[0.5 0.5 0.5],'HorizontalAlignment','center','Enable','inactive','ButtonDownFcn',@Clear);
end

function SetChannel
global Filament;
global Molecule;
hDataGui=getappdata(0,'hDataGui');
Object = getappdata(hDataGui.fig,'Object');
if Object.Drift==1
    fMsgDlg({'This track has been corrected, therefore',' changing in channel might yield corrupt results.','','Undo correction to set channel for this track!'},'warn');
    set(hDataGui.eChannel,'String',num2str(Object.Channel));
else
    hMainGui=getappdata(0,'hMainGui');
    Object.Channel = str2double(get(hDataGui.eChannel,'String'));
    if isnan(Object.Channel) 
        Object.Channel = 1;
    end
    setappdata(hDataGui.fig,'Object',Object)
    if strcmp(hDataGui.Type,'Molecule')==1
        Molecule(hDataGui.idx)=Object;
    else
        Filament(hDataGui.idx)=Object;
    end
    fShow('Image');
    fShow('Tracks');
end

function Switch(hDataGui)
global Filament;
if strcmp(hDataGui.Type,'Filament')==1
    Object=getappdata(hDataGui.fig,'Object');
    Check = getappdata(hDataGui.fig,'Check');
    PosStart=Object.PosStart;
    PosEnd=Object.PosEnd;
    Orientation=Object.Results(:,9);
    k = find(Check==1)';
    for n = k
        Object.Data{n}=flipud(Object.Data{n});
        Orientation(n)=mod(Orientation(n)+pi,2*pi);
        PosStart(n,:)=Object.PosEnd(n,:);
        PosEnd(n,:)=Object.PosStart(n,:);    
    end
    if all(Object.PosStart(:,1:2)==Object.Results(:,3:4))
        Object.Results(:,3:5)=PosStart;
    elseif all(Object.PosEnd(:,1:2)==Object.Results(:,3:4))
        Object.Results(:,3:5)=PosEnd;
    end
    Object.PosStart=PosStart;
    Object.PosEnd=PosEnd;    
    Object.Results(:,9)=Orientation;   
    Object.Results(:,6)=fDis(Object.Results(:,3:5));
    Filament(hDataGui.idx)=Object;
    [lXaxis,lYaxis]=CreatePlotList(Object,hDataGui.Type);
    set(hDataGui.lXaxis,'UserData',lXaxis);    
    set(hDataGui.lYaxis,'UserData',lYaxis);    
    set(hDataGui.lYaxis2,'UserData',lYaxis);        
    Check(:)=0;
    CreateTable(hDataGui,[num2cell(Check) num2cell(Object.Results(:,1:9)) getTags(Object.Results)]);
    setappdata(hDataGui.fig,'Check',Check);
    setappdata(hDataGui.fig,'Object',Object);
    Draw(hDataGui,0);
end
ReturnFocus([],[]);

function Split(hDataGui)
global Filament;
global Molecule;
hMainGui=getappdata(0,'hMainGui');
Object=getappdata(hDataGui.fig,'Object');
Check = getappdata(hDataGui.fig,'Check');
if sum(Check)<length(Check)
    Object.Results(Check==0,:)=[];
    Object.Results(:,6)=fDis(Object.Results);
    Object.TrackingResults(Check==0)=[];
    if strcmp(hDataGui.Type,'Filament')==1
        Object.PosCenter(Check==0,:)=[];   
        Object.PosStart(Check==0,:)=[];
        Object.PosEnd(Check==0,:)=[];
        Object.Data(Check==0)=[];
    end
    if ~isempty(Object.PathData)
        Object.PathData(Check==0,:)=[];      
    end
    Object.Name=sprintf('New %s',Object.Name);
    if strcmp(hDataGui.Type,'Molecule')
        Molecule(length(Molecule)+1)=Object;
        fRightPanel('UpdateList',hMainGui.RightPanel.pData.MolList,Molecule,hMainGui.RightPanel.pData.sMolList,hMainGui.Menu.ctListMol);
    elseif strcmp(hDataGui.Type,'Filament')
        Filament(length(Filament)+1)=Object;
        fRightPanel('UpdateList',hMainGui.RightPanel.pData.FilList,Filament,hMainGui.RightPanel.pData.sFilList,hMainGui.Menu.ctListFil);    
    end
    DeletePoints(hDataGui);
    fShow('Tracks');
    if strcmp(hDataGui.Type,'Molecule')
        Object = Molecule(hDataGui.idx);
    elseif strcmp(hDataGui.Type,'Filament')
        Object = Filament(hDataGui.idx);
    end
    setappdata(hDataGui.fig,'Object',Object);
    set(hDataGui.bNext,'Enable','on');
end
ReturnFocus([],[]);

function Correction(hDataGui)
global Molecule;
global Filament;
Object=getappdata(hDataGui.fig,'Object');
hMainGui=getappdata(0,'hMainGui');
Drift=getappdata(hMainGui.fig,'Drift');
if numel(Drift) >= Object.Channel && ~isempty(Drift{Object.Channel})
    Check = getappdata(hDataGui.fig,'Check');
    Object = fCorrectPos(Object,Drift{Object.Channel},get(hDataGui.cCorrection,'Value'));
    if strcmp(hDataGui.Type,'Molecule')==1
        Molecule(hDataGui.idx)=Object;
    else
        Filament(hDataGui.idx)=Object;
    end
    CreateTable(hDataGui,[num2cell(Check) num2cell(Object.Results(:,1:9)) getTags(Object.Results)]);
    setappdata(hDataGui.fig,'Object',Object);
    [lXaxis,lYaxis]=CreatePlotList(Object,hDataGui.Type);
    set(hDataGui.lXaxis,'String',lXaxis.list,'UserData',lXaxis);    
    set(hDataGui.lYaxis,'UserData',lYaxis);    
    set(hDataGui.lYaxis2,'UserData',lYaxis); 
    x=get(hDataGui.lXaxis,'Value');
    if x==length(lXaxis.list)
        CreateHistograms(hDataGui);
    end
    Draw(hDataGui,0);
end
ReturnFocus([],[]);

function Select(~, ~)
hDataGui=getappdata(0,'hDataGui');
data = get(hDataGui.tTable,'Data');
Check = cell2mat(data(:,1));
setappdata(hDataGui.fig,'Check',Check);
Draw(hDataGui,-1);
ReturnFocus([],[]);

function SelectAll(hDataGui)
data = get(hDataGui.tTable,'Data');
if get(gcbo,'UserData')==1
    Check = true(size(data,1),1);
else
    Check = false(size(data,1),1);
end
data(:,1) = num2cell(Check);
CreateTable(hDataGui,data);
setappdata(hDataGui.fig,'Check',Check);
Draw(hDataGui,-1);
ReturnFocus([],[]);

function [lXaxis,lYaxis]=CreatePlotList(Object,Type)
vel=CalcVelocity(Object);
%create list for X-Axis
n=4;
lXaxis.list{1}='x-position';
lXaxis.data{1}=Object.Results(:,3);
lXaxis.units{1}='[nm]';
lXaxis.list{2}='time';
lXaxis.data{2}=Object.Results(:,2);
lXaxis.units{2}='[s]';
lXaxis.list{3}='distance(to origin)';
lXaxis.data{3}=Object.Results(:,6);
lXaxis.units{3}='[nm]';
if ~isempty(Object.PathData)
    lXaxis.list{n}='distance(along path)';
    lXaxis.data{n}=real(Object.PathData(:,4));
    lXaxis.units{n}='[nm]';
    n=n+1;
end
lXaxis.list{n}='histogram';
lXaxis.data{n}=[];

%create Y-Axis list for xy-plot
lYaxis(1).list{1}='y-position';
lYaxis(1).data{1}=Object.Results(:,4);
lYaxis(1).units{1}='[nm]';

%create Y-Axis list for time plot
n=2;
lYaxis(2).list{1}='distance(to origin)';
lYaxis(2).data{1}=Object.Results(:,6);
lYaxis(2).units{1}='[nm]';
if ~isempty(Object.PathData)
    lYaxis(2).list{n}='distance(along path)';
    lYaxis(2).data{n}=real(Object.PathData(:,4));
    lYaxis(2).units{n}='[nm]';
    lYaxis(2).list{n+1}='sideways(to path)';
    lYaxis(2).data{n+1}=Object.PathData(:,5);
    lYaxis(2).units{n+1}='[nm]';
    n=n+2;
    if ~any(isnan(Object.PathData(:,6)))
        lYaxis(2).list{n}='height (above path)';
        lYaxis(2).data{n}=Object.PathData(:,6);   
        lYaxis(2).units{n}='[nm]';
        n=n+1;   
    end
end

lYaxis(2).list{n}='velocity';
lYaxis(2).data{n}=vel;
lYaxis(2).units{n}='[nm/s]';
n=n+1;

if strcmp(Type,'Molecule')==1
    if strcmp(Object.Type,'symmetric')
        lYaxis(2).list{n}='width(FWHM)';
    else
        lYaxis(2).list{n}='average width(FWHM)';
    end
    lYaxis(2).data{n}=Object.Results(:,7);
    lYaxis(2).units{n}='[nm]';    
    lYaxis(2).list{n+1}='amplitude';
    lYaxis(2).data{n+1}=Object.Results(:,8);
    lYaxis(2).units{n+1}='[ABU]';    
    n=n+2;
    if strcmp(Object.Type,'symmetric')
        lYaxis(2).list{n}='intensity(volume)';
        lYaxis(2).data{n}=2*pi*(Object.Results(:,7)/Object.PixelSize/(2*sqrt(2*log(2)))).^2.*Object.Results(:,8);       
        lYaxis(2).units{n}='[ABU]';        
        n=n+1;
    end
else
    lYaxis(2).list{n}='length';
    lYaxis(2).data{n}=Object.Results(:,7);       
    lYaxis(2).units{n}='[nm]';       
    lYaxis(2).list{n+1}='average amplitude';
    lYaxis(2).data{n+1}=Object.Results(:,8);
    lYaxis(2).units{n+1}='[ABU]';        
    lYaxis(2).list{n+2}='orientation(angle to x-axis)';
    lYaxis(2).data{n+2}=Object.Results(:,9);
    lYaxis(2).units{n+2}='[rad]';        
    n=n+3;
end

lYaxis(2).list{n}='x-position';
lYaxis(2).data{n}=Object.Results(:,3);
lYaxis(2).units{n}='[nm]';
lYaxis(2).list{n+1}='y-position';
lYaxis(2).data{n+1}=Object.Results(:,4);   
lYaxis(2).units{n+1}='[nm]';
n=n+2;
if ~any(isnan(Object.Results(:,5)))
    lYaxis(2).list{n}='z-position';
    lYaxis(2).data{n}=Object.Results(:,5);   
    lYaxis(2).units{n}='[nm]';
    n=n+1;    
end
if strcmp(Type,'Molecule')==1
    lYaxis(2).list{n}='fit error of center';
    lYaxis(2).data{n}=Object.Results(:,9);        
    lYaxis(2).units{n}='[nm]'; 
    n=n+1;
    if strcmp(Object.Type,'stretched')
        lYaxis(2).list{n}='width of major axis(FWHM)';
        lYaxis(2).data{n}=Object.Results(:,10);   
        lYaxis(2).units{n}='[nm]';        
        lYaxis(2).list{n+1}='width of minor axis(FWHM)';
        lYaxis(2).data{n+1}=Object.Results(:,11);      
        lYaxis(2).units{n+1}='[nm]';              
        lYaxis(2).list{n+2}='orientation(angle to x-axis)';    
        lYaxis(2).data{n+2}=Object.Results(:,12);      
        lYaxis(2).units{n+2}='[rad]';              
    elseif strcmp(Object.Type,'ring1')
        lYaxis(2).list{n}='radius ring';
        lYaxis(2).data{n}=Object.Results(:,10);      
        lYaxis(2).units{n}='[nm]';                    
        lYaxis(2).list{n+1}='amplitude ring';
        lYaxis(2).data{n+1}=Object.Results(:,11);                
        lYaxis(2).units{n+1}='[ABU]';                    
        lYaxis(2).list{n+2}='width (FWHM) ring';   
        lYaxis(2).data{n+2}=Object.Results(:,12);                
        lYaxis(2).units{n+2}='[nm]';     
    elseif strcmp(Object.Type,'diatom')
        lYaxis(2).list{n}='distance chloroplast';
        lYaxis(2).data{n}=Object.Results(:,10);      
        lYaxis(2).units{n}='[nm]';                    
        lYaxis(2).list{n+1}='separation chloroplasts';
        lYaxis(2).data{n+1}=Object.Results(:,11);                
        lYaxis(2).units{n+1}='[nm]';                    
        lYaxis(2).list{n+2}='orientation(angle to x-axis)';
        lYaxis(2).data{n+2}=Object.Results(:,12);                
        lYaxis(2).units{n+2}='[rad]';     
    end
end

%create Y-Axis list for distance plot
lYaxis(3)=lYaxis(2);
lYaxis(3).list(1)=[];
lYaxis(3).data(1)=[];
lYaxis(3).units(1)=[];
n=4;
if ~isempty(Object.PathData)
    lYaxis(3).list(1)=[];
    lYaxis(3).data(1)=[];
    lYaxis(3).units(1)=[];
    lYaxis(4)=lYaxis(3);
    n=5;
end

%create list for histograms
lYaxis(n).list{1}='velocity';
lYaxis(n).units{1}='[nm/s]';
lYaxis(n).data{1}=[];

lYaxis(n).list{2}='pairwise-distance';
lYaxis(n).units{2}='[nm]';
lYaxis(n).data{2}=[];
k=3;
if ~isempty(Object.PathData)
    lYaxis(n).list{k}='pairwise-distance (path)';
    lYaxis(n).data{k}=[];
    lYaxis(n).units{k}='[nm]';
    k=k+1;
end

lYaxis(n).list{k}='amplitude';
lYaxis(n).units{k}='[ABU]';
lYaxis(n).data{k}=[];
if strcmp(Type,'Molecule')==1
    lYaxis(n).list{k+1}='intensity (volume)';
    lYaxis(n).units{k+1}='[ABU]';
    lYaxis(n).data{k+1}=[];
else
    lYaxis(n).list{k+1}='length';
    lYaxis(n).units{k+1}='[nm]';
    lYaxis(n).data{k+1}=[];
end
lYaxis(n).list{k+2}='z-position';
lYaxis(n).units{k+2}='[nanometer]';
lYaxis(n).data{k+2}=[];

function CreateHistograms(hDataGui)
Object=getappdata(hDataGui.fig,'Object');
lYaxis=get(hDataGui.lYaxis,'UserData');
vel=CalcVelocity(Object);
n=length(lYaxis);
barchoice=[1 2 4 5 10 20 25 50 100 200 250 500 1000 2000 5000 10000 50000 10^5 10^6 10^7 10^8];

total=(max(vel)-min(vel))/15;
[~,t]=min(abs(total-barchoice));
barwidth=barchoice(t(1));
x=fix(min(vel)/barwidth)*barwidth-barwidth:barwidth:ceil(max(vel)/barwidth)*barwidth+barwidth;
num = hist(vel,x);
lYaxis(n).data{1}=[x' num']; 

XPos=Object.Results(:,3);
YPos=Object.Results(:,4);
ZPos=Object.Results(:,5);
if any(isnan(ZPos))
    ZPos(:)=0;
end
pairwise=zeros(length(XPos));
for i=1:length(XPos)
    pairwise(:,i)=sqrt((XPos-XPos(i)).^2 + (YPos-YPos(i)).^2 + (ZPos-ZPos(i)).^2);
end
p=tril(pairwise,-1);
pairwise=p(p>1);
x=round(min(pairwise)-10):1:round(max(pairwise)+10);
num = hist(pairwise,x);
lYaxis(n).data{2}=[x' num']; 
k=3;
if isfield(Object,'PathData')
    if ~isempty(Object.PathData)
        Dis=real(Object.PathData(:,4));
        pairwise=zeros(length(Dis));
        for i=1:length(Dis)
            pairwise(:,i)=Dis-Dis(i);
        end
        p=tril(pairwise,-1);
        pairwise=p(p>1);
        x=round(min(pairwise)-10):1:round(max(pairwise)+10);
        num = hist(pairwise,x);
        lYaxis(n).data{k}=[x' num']; 
        k=k+1;
    end
end

Amp=Object.Results(:,8);
total=(max(Amp)-min(Amp))/15;
[~,t]=min(abs(total-barchoice));
barwidth=barchoice(t(1));
x=fix(min(Amp)/barwidth)*barwidth-barwidth:barwidth:ceil(max(Amp)/barwidth)*barwidth+barwidth;
num = hist(Amp,x);
lYaxis(n).data{k}=[x' num'];

if strcmp(hDataGui.Type,'Molecule')==1
    Int=2*pi*Object.Results(:,7).^2.*Object.Results(:,8);
    total=(max(Int)-min(Int))/15;
    [~,t]=min(abs(total-barchoice));
    barwidth=barchoice(t(1));
    x=fix(min(Int)/barwidth)*barwidth-barwidth:barwidth:ceil(max(Int)/barwidth)*barwidth+barwidth;
    num = hist(Int,x);
    lYaxis(n).data{k+1}=[x' num'];
else
    Len=Object.Results(:,7);
    total=(max(Len)-min(Len))/15;
    [~,t]=min(abs(total-barchoice));
    barwidth=barchoice(t(1));
    x=fix(min(Len)/barwidth)*barwidth-barwidth:barwidth:ceil(max(Len)/barwidth)*barwidth+barwidth;
    num = hist(Len,x);
    lYaxis(n).data{k+1}=[x' num'];
end


Z=Object.Results(:,5);
if all(isnan(Z)) 
    total=(max(Z)-min(Z))/15;
    [~,t]=min(abs(total-barchoice));
    barwidth=barchoice(t(1));
    x=fix(min(Z)/barwidth)*barwidth-barwidth:barwidth:ceil(max(Z)/barwidth)*barwidth+barwidth;
    h = histogram(Z,x);
    lYaxis(n).data{k+2}=[x' num'];
else
    lYaxis(n).data{k+2} = [];
end
set(hDataGui.lYaxis,'UserData',lYaxis);

function XAxisList(hDataGui)
x=get(hDataGui.lXaxis,'Value');
y=get(hDataGui.lYaxis,'Value');
y2=get(hDataGui.lYaxis2,'Value');
s=get(hDataGui.lXaxis,'UserData');
a=get(hDataGui.lYaxis,'UserData');
enable='off';
enable2='off';
if x>1 && x<length(s.list)
    enable='on';
    if get(hDataGui.cYaxis2,'Value')==1
        enable2='on';
    end
end
if length(a(x).list)<y
    set(hDataGui.lYaxis,'Value',1);
end
if length(a(x).list)<y2
    set(hDataGui.lYaxis2,'Value',1);
end    
set(hDataGui.lYaxis,'String',a(x).list);
set(hDataGui.lYaxis2,'String',a(x).list);
set(hDataGui.cYaxis2,'Enable',enable);
set(hDataGui.tYaxis2,'Enable',enable2);
set(hDataGui.lYaxis2,'Enable',enable2);
if x==length(s.list) && isempty(a(x).data{1});
    CreateHistograms(hDataGui);
end
Draw(hDataGui,0);

function CheckYAxis2(hDataGui)
c=get(hDataGui.cYaxis2,'Value');
enable='off';
if c==1
    enable='on';
end
set(hDataGui.tYaxis2,'Enable',enable);
set(hDataGui.lYaxis2,'Enable',enable);
Draw(hDataGui,0);

function vel=CalcVelocity(Object)
XYZ = Object.Results(:,3:5);
nData=size(XYZ,1);
if any(isnan(XYZ(:,3)))
    XYZ(:,3)=0;
end
if nData>1
    vel=zeros(nData,1);
    vel(1)=sqrt(sum((XYZ(2,:)-XYZ(1,:)).^2))/(Object.Results(2,2)-(Object.Results(1,2)));
    vel(nData)=sqrt(sum((XYZ(nData,:)-XYZ(nData-1,:)).^2))/(Object.Results(nData,2)-(Object.Results(nData-1,2)));
    for i=2:nData-1
       vel(i)= (sqrt(sum((XYZ(i+1,:)-XYZ(i,:)).^2)) + sqrt(sum((XYZ(i,:)-XYZ(i-1,:)).^2)))/(Object.Results(i+1,2)-(Object.Results(i-1,2)));
    end
else
    vel=0;
end

function Scroll(hObject,eventdata) %#ok<INUSL>
hDataGui=getappdata(0,'hDataGui');
set(0,'CurrentFigure',hDataGui.fig);
pos = get(hDataGui.pPlotPanel,'Position');
cpFig = get(hDataGui.fig,'currentpoint');
cpFig = cpFig(1,[1 2]);
xy=get(hDataGui.aPlot,{'xlim','ylim'});
cp=get(hDataGui.aPlot,'currentpoint');
cp=cp(1,[1 2]);
if all(cpFig>=[pos(1) pos(2)]) && all(cpFig<=[pos(1)+pos(3) pos(2)+pos(4)])
    Zoom=hDataGui.Zoom;
    if ~isempty(eventdata)
        level=Zoom.level-eventdata.VerticalScrollCount;
    else
        level=Zoom.level;
    end
    if level<1
        Zoom.currentXY=Zoom.globalXY;
        Zoom.level=0;
    else
        x_total=Zoom.globalXY{1}(2)-Zoom.globalXY{1}(1);
        y_total=Zoom.globalXY{2}(2)-Zoom.globalXY{2}(1);    
        x_current=Zoom.currentXY{1}(2)-Zoom.currentXY{1}(1);
        y_current=Zoom.currentXY{2}(2)-Zoom.currentXY{2}(1);        
        p=exp(-level/8);
        cp=cp(1,[1 2]);
        if strcmp(get(hDataGui.aPlot,'YDir'),'reverse')
            if (y_current/x_current) >= Zoom.aspect
                new_scale_y = y_total*p;
                new_scale_x = new_scale_y/Zoom.aspect;
            else
                new_scale_x = x_total*p;
                new_scale_y = new_scale_x*Zoom.aspect;
            end
        else
            new_scale_y = y_total*p;
            new_scale_x = x_total*p;
        end
        xy{1}=[cp(1)-(cp(1)-Zoom.currentXY{1}(1))/x_current*new_scale_x cp(1)+(Zoom.currentXY{1}(2)-cp(1))/x_current*new_scale_x];
        xy{2}=[cp(2)-(cp(2)-Zoom.currentXY{2}(1))/y_current*new_scale_y cp(2)+(Zoom.currentXY{2}(2)-cp(2))/y_current*new_scale_y];
        if xy{1}(1)<Zoom.globalXY{1}(1)
            xy{1}=xy{1}-xy{1}(1)+Zoom.globalXY{1}(1);
        end
        if xy{1}(2)>Zoom.globalXY{1}(2)
            xy{1}=xy{1}-xy{1}(2)+Zoom.globalXY{1}(2);
        end
        if xy{2}(1)<Zoom.globalXY{2}(1)
            xy{2}=xy{2}-xy{2}(1)+Zoom.globalXY{2}(1);
        end
        if xy{2}(2)>Zoom.globalXY{2}(2)
            xy{2}=xy{2}-xy{2}(2)+Zoom.globalXY{2}(2);
        end
        Zoom.currentXY=xy;
        Zoom.level=level;
    end
    set(hDataGui.aPlot,{'xlim','ylim'},Zoom.currentXY);
    hDataGui.Zoom=Zoom;
    setappdata(0,'hDataGui',hDataGui);
end

function ReturnFocus(~,~)
hDataGui=getappdata(0,'hDataGui');
warning off MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame
javaFrame = get(hDataGui.fig,'JavaFrame');
javaFrame.getAxisComponent.requestFocus;

function FitMissingPoints(hDataGui)
global Filament;
global Molecule;
global Config;
global Stack;
global TimeInfo;
if isempty(Stack)
    fMsgDlg('Stack required','error');
    return;
end
hMainGui = getappdata(0,'hMainGui');
idx=hDataGui.idx;
Type=hDataGui.Type;
if strcmp(Type,'Molecule')
    Object=Molecule(idx);
    params.find_molecules=0;
    params.find_beads=1;
else
    Object=Filament(idx);
    params.find_molecules=1;
    params.find_beads=0;
end
if Object.Drift == 1
    fMsgDlg('Not possible with Drift corrected tracks','error');
    return;
end
answer = fInputDlg({'Enter starting frame','Enter last frame'},{num2str(Object.Results(1,1)),num2str(Object.Results(end,1))});
if length(answer)>1
    if isnan(str2double(answer{1})) || isnan(str2double(answer{2}))
        fMsgDlg('Wrong frame input','error');
        return;
    end
    fitframes = str2double(answer{1}):min([str2double(answer{2}) size(Stack{Object.Channel},3)]);
    k = ismember(fitframes',Object.Results(:,1));
    fitframes = fitframes(~k);
    if ~isempty(fitframes)
        params.dynamicfil = 0;
%        params.transform = hMainGui.Values.TformChannel{Object.Channel};
        params.bead_model=Config.Model;
        params.max_beads_per_region=Config.MaxFunc;
        params.scale=Config.PixSize;
        params.ridge_model = 'quadratic';
        params.area_threshold=Config.Threshold.Area;
        params.height_threshold=Config.Threshold.Height;
        params.fwhm_estimate=Config.Threshold.FWHM;
        params.border_margin=0;
        params.include_data=Config.OnlyTrack.IncludeData;
        if isempty(Config.ReduceFitBox)
            params.reduce_fit_box = 1;
        else
            params.reduce_fit_box = Config.ReduceFitBox;
        end
        params.focus_correction = Config.FilFocus;
        params.min_cod=Config.Threshold.Fit;
        params.threshold = 0;
        params.binary_image_processing = [];
        params.background_filter='none';
        params.display = 0;
        params.options = optimset( 'Display', 'off');
        params.options.MaxFunEvals = [];
        params.options.MaxIter = [];
        params.options.TolFun = [];
        params.options.TolX = [];
        if length(TimeInfo)>=Object.Channel && ~isempty(TimeInfo{Object.Channel})
            params.creation_time_vector = (TimeInfo{Object.Channel}-TimeInfo{Object.Channel}(1))/1000;
            %check wether imaging was done during change of date
            k = params.creation_time_vector<0;
            params.creation_time_vector(k) = params.creation_time_vector(k) + 24*60*60;
        end
        h=progressdlg('String',sprintf('Tracking - Frame: %d',fitframes(1)),'Min',1,'Max',length(fitframes),'Cancel','on','Parent',hDataGui.fig);
        for n = fitframes
            I = Stack{Object.Channel}(:,:,n);
            [y,x] = size(I);
            idx = [find(Object.Results(:,1)<n,1,'last') find(Object.Results(:,1)>n,1,'first')];
            if numel(idx)<2
                if idx(1)==1
                    idx(2) = 2;
                    s = 0;
                    e = 1;
                else
                    idx(2) = idx(1)-1;
                    s = idx(1);
                    e = idx(1)+1;
                end
            else
                s = idx(1);
                e = idx(2);
            end
            c = (n-Object.Results(idx(1),1))/(Object.Results(idx(2),1)-Object.Results(idx(1),1));
            if strcmp(Type,'Molecule')
                X = round( (Object.Results(idx(1),3)*(1-c)+Object.Results(idx(2),3)*c)/params.scale);
                Y = round( (Object.Results(idx(1),4)*(1-c)+Object.Results(idx(2),4)*c)/params.scale);
            else
                nData(1) = size(Object.Data{idx(1)},1);
                nData(2) = size(Object.Data{idx(2)},1);
                fX = zeros(max(nData),2);
                fY = zeros(max(nData),2);
                for m = 1:2
                    if nData(m) ~=max(nData)
                        new_vector = 1:(nData(m)-1)/(max(nData)-1):nData(m);
                        old_vector = 1:nData(m);
                        fX(:,m) = interp1(old_vector,Object.Data{idx(m)}(:,1),new_vector);
                        fY(:,m) = interp1(old_vector,Object.Data{idx(m)}(:,2),new_vector);
                    else
                        fX(:,m) = Object.Data{idx(m)}(:,1);
                        fY(:,m) = Object.Data{idx(m)}(:,2);
                    end
                end
                X = round( (fX(:,1)*(1-c) + fX(:,2)*c)/params.scale);
                Y = round( (fY(:,1)*(1-c) + fY(:,2)*c)/params.scale);
            end
            k = X<1 | X>x | Y<1 | Y>y;
            X(k) = [];
            Y(k) = [];
            fidx = Y + (X - 1).*y;
            bw_region = zeros(size(I));
            bw_region(fidx) = 1;
            SE = strel('disk', ceil(params.fwhm_estimate/2/params.scale) , 4);
            bw_region(:,:,1) = imdilate(bw_region(:,:,1),SE);
            params.bw_region = bw_region;
            Obj = ScanImage(I,params,n);
            if ~isempty(Obj) && numel(Obj)<2
                if strcmp(Type,'Molecule') && isempty(Obj.data{1})
                    Object.Results = [Object.Results(1:s,:); zeros(1,size(Object.Results,2)); Object.Results(e:end,:)];
                    Object.Results(s+1,1) = single(n);
                    Object.Results(s+1,2) = Obj.time;
                    Object.Results(s+1,3) = Obj.center_x(1);
                    Object.Results(s+1,4) = Obj.center_y(1);
                    Object.Results(s+1,5) = NaN;
                    Object.Results(s+1,7) = Obj.width(1,1);
                    Object.Results(s+1,8) = Obj.height(1,1);
                    Object.Results(s+1,9) = single(sqrt((Obj.com_x(2,1))^2+(Obj.com_y(2,1))^2));
                    try
                        if strcmp(Object.Type,'stretched')
                            Object.Results(s+1,9:10) = Obj.data{1}';
                            Object.Results(s+1,11) = single(mod(Obj.orientation(1,1),2*pi));
                            Object.Results(s+1,12) = 1;
                        elseif strcmp(Object.Type,'ring1')
                            Object.Results(s+1,9:11) = Obj.data{1}(1,:);
                            Object.Results(s+1,12) = 1;
                        else
                            Object.Results(s+1,10) = 1;
                        end
                    catch
                        Object.Results(s+1,10) = 1;
                        if size(Object.Results,2)>10
                            Object.Results(:,11:end) = [];
                        end
                    end
                    if Config.OnlyTrack.IncludeData == 1
                        Object.TrackingResults = [Object.TrackingResults(1:s) Obj.points{1} Object.TrackingResults(e:end)];
                    else
                        Object.TrackingResults = [Object.TrackingResults(1:s) cell(1,1) Object.TrackingResults(e:end)];
                    end  
                elseif strcmp(Type,'Filament') && ~isempty(Obj.data{1})
                    Object.Results = [Object.Results(1:s,:); zeros(1,size(Object.Results,2)); Object.Results(e:end,:)];
                    Object.Results(s+1,1) = single(n);
                    Object.Results(s+1,2) = Obj.time;
                    Object.Results(s+1,3) = Obj.center_x(1);
                    Object.Results(s+1,4) = Obj.center_y(1);
                    Object.Results(s+1,5) = NaN;
                    Object.Results(s+1,7) = Obj.length(1,1);
                    Object.Results(s+1,8) = Obj.height(1,1);
                    Object.Results(s+1,9) = single(mod(Obj.orientation(1,1),2*pi));
                    Object.Results(s+1,10) = 1;
                    data = [Obj.data{1}(:,1:2) ones(size(Obj.data{1},1),1)*NaN Obj.data{1}(:,3:end)];
                    Object.Data = [Object.Data(1:s) data Object.Data(e:end)];
                    Object.PosCenter = [Object.PosCenter(1:s,:); Object.Results(s+1,3:4) NaN; Object.PosCenter(e:end,:)];
                    Object.PosStart = [];
                    Object.PosEnd = [];
                    Object = fAlignFilament(Object,Config);
                    if Config.OnlyTrack.IncludeData == 1
                        Object.TrackingResults = [Object.TrackingResults(1:s) Obj.points{1} Object.TrackingResults(e:end)];
                    else
                        Object.TrackingResults = [Object.TrackingResults(1:s) cell(1,1) Object.TrackingResults(e:end)];
                    end  
                end
            end
            if isempty(h)
                continue
            end
            t = find(n==fitframes);
            if t<length(fitframes)
                h=progressdlg(t,sprintf('Tracking - Frame: %d',fitframes(t+1)));
            end
        end
        progressdlg('close');
        Object.Results(:,6) = fDis(Object.Results(:,3:5));
        if strcmp(hDataGui.Type,'Molecule')==1
            Molecule(hDataGui.idx)=Object;
        else
            Filament(hDataGui.idx)=Object;
        end
        fRightPanel('UpdateKymoTracks',hMainGui);
        X=Object.Results(:,3)/hMainGui.Values.PixSize;
        Y=Object.Results(:,4)/hMainGui.Values.PixSize;
        if length(X)==1
            X(1,2)=X;
            Y(1,2)=Y;
        end
        set(Object.PlotHandles(1,1),'XData',X,'YData',Y,'MarkerIndices',1:5:length(Y));
        drawnow
        Create(hDataGui.Type,hDataGui.idx);
    end
end


% 
% params=Config;
% params.find_molecules=1;
% params.find_beads=1;
% if strcmp(Type,'Molecule')
%     Object=Molecule(idx);
%     params.find_molecules=0;
%     if isempty(Object.Tags)
%         Object.Tags=uint8(zeros(size(Object.Results,1),1));
%     end
% %     return %not implemented yet
% else
%     idx = min([idx length(Filament)]);
%     idx = max([1 idx]);
%     Object=Filament(idx);
%     if isempty(Object.Tags)
%         Object.Tags=uint8(zeros(size(Object.Results,1),2));
%     end
%     params.find_beads=0;
% end
% if Object.Drift
%     warndlg('Not possible with Drift corrected tracks');
%     return
% end
% if fitspecific==0
%     missFrames=setdiff(Object.Results(1,1):Object.Results(end,1),Object.Results(:,1));
% else
%     missFrames=str2double(inputdlg('Enter frame to be tracked:'));
%     if ~isempty(find(Object.Results(:,1)==missFrames));
%         warndlg('Frame already tracked');
%         return
%     end
% end
% if length(Stack)==1
%     params=setparams(params, 1);
%     StackC=Stack{1};
% else
%     params=setparams(params, Object.Channel);
%     StackC=Stack{Object.Channel};
% end
% params.fitmissing=1;
% h=progressdlg('String','Fitting missing points','Min',0,'Max',length(missFrames),'Parent',hDataGui.fig,'cancel','on');
% i=1;
% nottracked=[];
% for n=missFrames
%     tmp = abs(Object.Results(:,1)-n);
%     [framediff, nearestid] = min(tmp); %index of closest value
%     if framediff==0
%         return
%     end
%     if fitspecific==0 
%         if Object.Results(nearestid,1)>n&&nearestid~=1
%             useid=nearestid-1;
%         else
%             useid=nearestid;
%         end
%     else
%         useframe=str2double(inputdlg('Enter frame to be taken as reference:','Reference Frame', 1, {num2str(Object.Results(nearestid,1), '%i')}));
%         useid=find(Object.Results(:,1)==useframe);
%     end
%     if hDataGui.fitagain==1
%         useid=nearestid+1;
%     end
%     [y,x] = size(StackC(:,:,1));
%     bw_region = zeros(y,x);
%     if strcmp(Type,'Molecule')&&fitspecific==0
%         X = round(interp1([Object.Results(useid,1) Object.Results(useid+1,1)],[Object.Results(useid,3) Object.Results(useid+1,3)],n)/params.scale);
%         Y = round(interp1([Object.Results(useid,1) Object.Results(useid+1,1)],[Object.Results(useid,4) Object.Results(useid+1,4)],n)/params.scale);
%     elseif strcmp(Type,'Molecule')&&fitspecific==1
%         X = round(Object.Results(useid,3)/params.scale);
%         Y = round(Object.Results(useid,4)/params.scale);
%     else
%         X = round(Object.Data{useid}(:,1)/params.scale);
%         Y = round(Object.Data{useid}(:,2)/params.scale);
%     end
%     k = X<1 | X>x | Y<1 | Y>y;
%     X(k) = [];
%     Y(k) = [];
%     idx = Y + (X - 1).*y;
%     bw_region(idx) = 1;
%     SE = strel('disk', ceil(params.fwhm_estimate/2/params.scale) , 4);
%     bw_region(:,:) = imdilate(bw_region(:,:),SE);
%     params.bw_region = bw_region;
%     newobj=ScanImage(StackC(:,:,n),params,n);
%     if ~isempty(newobj)
%         l_id=zeros(length(newobj.data),1);
%         for m=1:length(newobj.data)
%             [~,l_id(m)]=size(newobj.data{m});
%         end
%         [maxl, id] = max(l_id);
%         if (maxl>5&&strcmp(Type,'Filament'))||strcmp(Type,'Molecule')
%             [Object]=fInsertObj(Object, newobj, id, n);
%         else
%             nottracked=[nottracked n];
%         end
%     else
%         nottracked=[nottracked n];
%     end
%     if isempty(h)
%         break
%     end
%     h=progressdlg(i);
%     i=i+1;
% end
% Check = false(size(Object.Results,1),1); 
% tocheck=[setxor(nottracked, missFrames)'; alreadytracked];
% for i=1:length(tocheck)
%     Check(find(Object.Results(:,1)==tocheck(i)))=1;
% end
% Object.Results(:,5)=fDis(Object.Results(:,3:4));
% setappdata(hDataGui.fig,'Check',Check);
% setappdata(hDataGui.fig,'Object',Object);
% if ~isempty(nottracked)
%     button = questdlg(['not tracked:' num2str(nottracked) '. Approach from other side?']);
%     if strcmp(button, 'Yes')
%         hDataGui.fitagain=1;
%         FitMissingPoints(getappdata(0,'hDataGui'), fitspecific, tocheck);
%         hDataGui.fitagain=0;
%     end
% end
% if strcmp(hDataGui.Type,'Molecule')==1
%     Molecule(hDataGui.idx)=Object;
% else
%     Filament(hDataGui.idx)=Object;
% end
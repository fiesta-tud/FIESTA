function fMergeGui(func,varargin)
switch func
    case 'Create'
        Create(varargin{1},varargin{2});
    case 'Update'
        Update(varargin{1});        
    case 'Draw'
        Draw(varargin{1});  
    case 'bToggleToolCursor'
        bToggleToolCursor(varargin{1});  
    case 'bToolPan'
        bToolPan(varargin{1});
    case 'bToolZoomIn'
        bToolZoomIn(varargin{1});
    case 'bToggleToolRegion'
        bToggleToolRegion(varargin{1});
    case 'bToggleToolRectRegion'
        bToggleToolRectRegion(varargin{1});
    case 'Add'
        Add(varargin{1});
    case 'Delete'
        Delete(varargin{1});
    case 'DelEntry'
        DelEntry(varargin{1});
    case 'OK'
        OK(varargin{1});
end

function Create(Mode,List)
global Molecule;
global Filament;
if strcmp(Mode,'Molecule')
    Objects=Molecule;
else
    Objects=Filament;
end

h=findobj('Tag','hMergeGui');
close(h)

hMergeGui.fig = figure('Units','normalized','DockControls','off','IntegerHandle','off','MenuBar','none','Name','FIESTA Merge Tracks',...
                      'NumberTitle','off','HandleVisibility','callback','Tag','hMergeGui',...
                      'Visible','off','Resize','off','Color',[0.9255 0.9137 0.8471],'WindowStyle','modal');            
                  
fPlaceFig(hMergeGui.fig,'big');

if ispc
    set(hMergeGui.fig,'Color',[236 233 216]/255);
end

c = get(hMergeGui.fig,'Color');

hMergeGui.pPlotPanel = uipanel('Parent',hMergeGui.fig,'Position',[0.4 0.55 0.575 0.42],'Tag','PlotPanel','BackgroundColor','white');

hMergeGui.aPlot = axes('Parent',hMergeGui.pPlotPanel,'Units','normalized','OuterPosition',[0 0 1 1],'Tag','Plot','TickDir','in');

columnname = {'','','','','',''};
columnformat = {'logical','char','numeric','bank','bank','bank'};
columneditable = logical([ 1, 0, 0, 0, 0, 0]);

hMergeGui.tTable = uitable('Parent',hMergeGui.fig,'Units','normalized','Position',[0.025 0.05 0.95 0.45],'Tag','tTable','Enable','on',...            
                           'ColumnName', columnname,'ColumnFormat', columnformat,'ColumnEditable', columneditable,'RowName',[]);

str=cell(length(List),1);
for i=1:length(List)
    str{i}=Objects(List(i)).Name;
end
hMergeGui.lMerge = uicontrol('Parent',hMergeGui.fig,'Units','normalized','BackgroundColor',[1 1 1],'Callback','fMergeGui(''Draw'',getappdata(0,''hMergeGui''));',...
                             'Position',[0.05 0.55 0.3 0.19],'String',str,'Style','listbox','Value',1,'Tag','lMerge');

str=cell(length(Objects),1);
for i=1:length(Objects)
    str{i}=Objects(i).Name;
end
hMergeGui.lAll = uicontrol('Parent',hMergeGui.fig,'Units','normalized','BackgroundColor',[1 1 1],...
                           'Position',[0.05 0.78 0.3 0.19],'String',str,'Style','listbox','Value',1,'Tag','lAll');                         

hMergeGui.bAdd = uicontrol('Parent',hMergeGui.fig,'Units','normalized','Callback','fMergeGui(''Add'',getappdata(0,''hMergeGui''));',...
                           'Position',[0.05 0.75 0.145 0.025],'String','Add','Tag','bAdd');

hMergeGui.bDelete = uicontrol('Parent',hMergeGui.fig,'Units','normalized','Callback','fMergeGui(''Delete'',getappdata(0,''hMergeGui''));',...
                              'Position',[0.205 0.75 0.145 0.025],'String','Delete','Tag','bDelete');
                          
hMergeGui.bDelEntry = uicontrol('Parent',hMergeGui.fig,'Units','normalized','Callback','fMergeGui(''DelEntry'',getappdata(0,''hMergeGui''));',...
                               'Position',[0.025 0.51 0.075 0.025],'String','Delete','Tag','bDelEntry');

hMergeGui.bOK = uicontrol('Parent',hMergeGui.fig,'Units','normalized','Callback','fMergeGui(''OK'',getappdata(0,''hMergeGui''));',...
                          'Position',[0.575 0.01 0.175 0.03],'String','OK','Tag','bOK');

hMergeGui.bCancel = uicontrol('Parent',hMergeGui.fig,'Units','normalized','Callback','close(gcf);',...
                              'Position',[0.8 0.01 0.175 0.03],'String','Cancel','Tag','bCancel');
                          
hMergeGui.tWarning = uicontrol('Parent',hMergeGui.fig,'Units','normalized','FontSize',10,'FontWeight','bold','ForegroundColor',[1 0 0],...
                               'Position',[0.11 0.51 0.3 0.02],'String','Warning: Overlaying frames detected !!!','Style','text','Tag','tWarning','Visible','off');
            
hMergeGui.tFrame = uicontrol('Parent',hMergeGui.fig,'Units','normalized','FontSize',10,'HorizontalAlignment','left',...
                         'Position',[0.85 0.97 0.05 0.02],'String','Frame:','Style','text','Tag','tFrame','BackgroundColor',c);

hMergeGui.tFrameValue = uicontrol('Parent',hMergeGui.fig,'Units','normalized','FontSize',10,'HorizontalAlignment','right',...
                              'Position',[0.9 0.97 0.05 0.02],'String','','Style','text','Tag','tFrameValue','BackgroundColor',c);

set(hMergeGui.fig, 'WindowButtonMotionFcn', @UpdateCursor);
set(hMergeGui.fig, 'WindowButtonDownFcn',@ButtonDown);
set(hMergeGui.fig, 'WindowButtonUpFcn',@ButtonUp);
set(hMergeGui.fig, 'WindowScrollWheelFcn',@Scroll);  
set(hMergeGui.tTable, 'CellEditCallback',@Select);

hMergeGui.CursorDownPos = [0 0];
hMergeGui.SelectRegion = struct('X',[],'Y',[],'plot',[]);
hMergeGui.Zoom = struct('currentXY',[],'globalXY',[],'level',[],'aspect',GetAxesAspectRatio(hMergeGui.aPlot));
hMergeGui.CursorMode='Normal';

hMergeGui.List=List;
hMergeGui.Mode=Mode;

setappdata(hMergeGui.fig,'Objects',Objects);
UpdateData(hMergeGui);

function UpdateData(hMergeGui)
Objects=getappdata(hMergeGui.fig,'Objects');
List=hMergeGui.List;
str=cell(length(List),1);
nData=0;
for n = 1:length(List)
    str{n} = Objects(List(n)).Name;
    nData = nData + size(Objects(List(n)).Results,1);
end    
set(hMergeGui.lMerge,'String',str);
Data = zeros(nData,6);
s = 1;
for n = List
    e = size(Objects(n).Results,1)-1;
    Data(s:s+e,1) = n;
    Data(s:s+e,2:5) = double(Objects(n).Results(:,1:4));
    s = s+e+1;
end
Data=sortrows(Data,2);
nData=size(Data,1);
for n=1:nData
    k=find(Data(n,2)==Data(:,2));
    if length(k)>1
        Data(n,6)=1;
    end
end
setappdata(hMergeGui.fig,'Data',Data);
UpdateTable(hMergeGui)

function UpdateTable(hMergeGui)
Objects=getappdata(hMergeGui.fig,'Objects');
Data = getappdata(hMergeGui.fig,'Data');
nData = size(Data,1);
Table = cell(nData,6);
Check = false(nData,1);
for n=1:nData
    Table{n,2} = Objects(Data(n,1)).Name;
end
Table(:,1) = num2cell(Check);
Table(:,3:6) = num2cell(Data(:,2:5));
CreateTable(hMergeGui,Table);
setappdata(hMergeGui.fig,'Data',Data);
setappdata(hMergeGui.fig,'Check',Check);
setappdata(0,'hMergeGui',hMergeGui);
if any(Data(:,6)==1)
    set(hMergeGui.tWarning,'Visible','on');
    set(hMergeGui.bOK,'Enable','off');
else
    set(hMergeGui.tWarning,'Visible','off');
    set(hMergeGui.bOK,'Enable','on');
end
Draw(hMergeGui);

function Draw(hMergeGui)
set(0,'CurrentFigure',hMergeGui.fig);    
cla(hMergeGui.aPlot);
Data = getappdata(hMergeGui.fig,'Data');
Check = getappdata(hMergeGui.fig,'Check');
if get(hMergeGui.lMerge,'Value')>length(hMergeGui.List)
    set(hMergeGui.lMerge,'Value',length(hMergeGui.List));
end
XPlot = Data(:,4)-min(Data(:,4));
YPlot = Data(:,5)-min(Data(:,5));
if (max(XPlot)-min(XPlot)) > 5000 || (max(YPlot)-min(YPlot)) > 5000
    xscale=1000;
    yscale=1000;
    units='[?m]';
else
    xscale=1;
    yscale=1;
    units='[nm]';
end
hMergeGui.DataPlot = plot(hMergeGui.aPlot,XPlot/xscale,YPlot/yscale,'Color','blue','LineStyle','-','Marker','*');
k = find( hMergeGui.List(get(hMergeGui.lMerge,'Value'))==Data(:,1));
if ~isempty(k)
    line(hMergeGui.aPlot,XPlot(k)/xscale,YPlot(k)/yscale,'Color','cyan','LineStyle','none','Marker','*');
end
k = find(Data(:,6)==1);
if ~isempty(k)
    line(hMergeGui.aPlot,XPlot(k)/xscale,YPlot(k)/yscale,'Color','red','LineStyle','none','Marker','o');
end
k = find(Check==1);
if ~isempty(k)
    line(hMergeGui.aPlot,XPlot(k)/xscale,YPlot(k)/yscale,'Color','green','LineStyle','none','Marker','o');
end
if isempty(hMergeGui.Zoom.currentXY)
    SetAxis(hMergeGui.aPlot,XPlot/xscale,YPlot/yscale);
    hMergeGui.Zoom.globalXY = get(hMergeGui.aPlot,{'xlim','ylim'});
    hMergeGui.Zoom.currentXY = hMergeGui.Zoom.globalXY;
    hMergeGui.Zoom.level = 0;
else
    set(hMergeGui.aPlot,{'xlim','ylim'},hMergeGui.Zoom.currentXY,'YDir','reverse');
end
xlabel(hMergeGui.aPlot,['X-Position  ' units]);
ylabel(hMergeGui.aPlot,['Y-Position  ' units]);
setappdata(0,'hMergeGui',hMergeGui);

function SetAxis(a,X,Y)
set(a,'Units','pixel');
pos=get(a,'Position');
set(a,'Units','normalized');
xy{1}=[-ceil(max(-X)) ceil(max(X))];
xy{2}=[-ceil(max(-Y)) ceil(max(Y))];
if all(~isnan(xy{1}))&&all(~isnan(xy{2}))
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
end

function Add(hMergeGui)
idx=get(hMergeGui.lAll,'Value');
k=find(idx==hMergeGui.List,1);
if isempty(k)
    hMergeGui.List=sort([hMergeGui.List idx]);
end
hMergeGui.Zoom.currentXY = [];
setappdata(0,'hMergeGui',hMergeGui);
UpdateData(hMergeGui);

function Delete(hMergeGui)
idx=get(hMergeGui.lMerge,'Value');
hMergeGui.List(idx)=[];
if get(hMergeGui.lMerge,'Value')>length(hMergeGui.List)
    set(hMergeGui.lMerge,'Value',length(hMergeGui.List));
end
hMergeGui.Zoom.currentXY = [];
setappdata(0,'hMergeGui',hMergeGui);
UpdateData(hMergeGui);

function DelEntry(hMergeGui)
Data = getappdata(hMergeGui.fig,'Data');
Check = getappdata(hMergeGui.fig,'Check');
Objects = getappdata(hMergeGui.fig,'Objects');
Data(Check==1,:)=[];
nData=size(Data,1);
for i=1:nData
    k=find(Data(i,2)==Data(:,2));
    if length(k)>1
        Data(i,6)=1;
    else
        Data(i,6)=0;
    end
end
hMergeGui.List(~ismember(hMergeGui.List,Data(:,1))) = [];
str = cell(length(hMergeGui.List),1);
for n = 1:length(hMergeGui.List)
    str{n} = Objects(hMergeGui.List(n)).Name;
end    
set(hMergeGui.lMerge,'String',str);
setappdata(hMergeGui.fig,'Data',Data);
hMergeGui.Zoom.currentXY = [];
UpdateTable(hMergeGui);

function OK(hMergeGui)
global Molecule;
global Filament;
global KymoTrackMol;
global KymoTrackFil;
global Config;
hMainGui = getappdata(0,'hMainGui');
Data = getappdata(hMergeGui.fig,'Data');
Objects = getappdata(hMergeGui.fig,'Objects');
List = hMergeGui.List;
nData = size(Data,1);
nList = length(List);
Results = single( zeros(nData,size(Objects(Data(1,1)).Results,2)) );
PosCenter= single( zeros(nData,3) );
ObjData = cell(1,nData);
TrackingResults = cell(1,nData);
for n = 1:nData
    k = find( Objects( Data(n,1) ).Results(:,1) == Data(n,2),1 );
    Results(n,:) = Objects( Data(n,1) ).Results(k,:);
    TrackingResults{n} = Objects(Data(n,1)).TrackingResults{k};
    if strcmp(hMergeGui.Mode,'Filament')
        PosCenter(n,:) = Objects( Data(n,1) ).PosCenter(k,:);
        ObjData{n} = Objects(Data(n,1)).Data{k};
    end
end
Results(:,6) = fDis( Results(:,3:5) );
Objects(List(1)).Results = Results;
Objects(List(1)).TrackingResults = TrackingResults;
Objects(List(1)).PathData = [];
Objects(List(1)).Selected = 0;
if strcmp(hMergeGui.Mode,'Molecule')
    KymoTrackObj = KymoTrackMol;
elseif strcmp(hMergeGui.Mode,'Filament')
    Objects(List(1)).PosCenter = PosCenter;
    Objects(List(1)).PosStart = [];
    Objects(List(1)).PosEnd = [];
    Objects(List(1)).Data = ObjData;
    Objects(List(1)) = fAlignFilament(Objects(List(1)),Config);
    KymoTrackObj = KymoTrackFil;    
end
kList=[];
KymoTrack=[];
for n=1:nList
    k=find( List(n)==[KymoTrackObj.Index] );
    if ~isempty(k)
        KymoTrack=[KymoTrack; KymoTrackObj(k).Track]; %#ok<AGROW>
        kList=[kList k]; %#ok<AGROW>
        delete(KymoTrackObj(k).PlotHandles);
    end
end
if ~isempty(kList)
    nTrack=kList(1);
    idx=KymoTrackObj(nTrack).Index;
    KymoTrack=sortrows(KymoTrack,1);
    set(0,'CurrentFigure',hMainGui.fig);
    KymoTrackObj(nTrack).PlotHandles(1,1) = line(hMainGui.MidPanel.aKymoGraph,KymoTrack(:,2),KymoTrack(:,1),'Color',Objects(idx).Color,'Visible','off');
    if Objects(idx).Visible
        set(KymoTrackObj(nTrack).PlotHandles(1,1),'Visible','on','LineStyle','-');
    end
    KymoTrackObj(nTrack).Track=KymoTrack;
    KymoTrackObj(kList(2:length(kList)))=[];
end
for n=1:length(KymoTrackObj)
    cIndex=sum(List(2:nList)<KymoTrackObj(n).Index);
    KymoTrackObj(n).Index=KymoTrackObj(n).Index-cIndex;
end
Objects(List(2:nList))=[];
if strcmp(hMergeGui.Mode,'Molecule')==1
    KymoTrackMol=KymoTrackObj;
    Molecule=Objects;
    fRightPanel('UpdateList',hMainGui.RightPanel.pData.MolList,Objects,hMainGui.RightPanel.pData.sMolList,hMainGui.Menu.ctListMol);
else
    KymoTrackFil=KymoTrackObj;
    Filament=Objects;
    fRightPanel('UpdateList',hMainGui.RightPanel.pData.FilList,Objects,hMainGui.RightPanel.pData.sFilList,hMainGui.Menu.ctListFil);
end
fRightPanel('UpdateKymoTracks',hMainGui);
fShow('Image');
fShow('Tracks');
close(hMergeGui.fig);

function UpdateCursor(hObject, eventdata) %#ok<INUSD>
hMergeGui=getappdata(0,'hMergeGui');
pos = get(hMergeGui.pPlotPanel,'Position');
cpFig = get(hMergeGui.fig,'currentpoint');
cpFig = cpFig(1,[1 2]);
xy=get(hMergeGui.aPlot,{'xlim','ylim'});
cp=get(hMergeGui.aPlot,'currentpoint');
cp=cp(1,[1 2]);
X=get(hMergeGui.DataPlot,'XData');
Y=get(hMergeGui.DataPlot,'YData');
Data=getappdata(hMergeGui.fig,'Data');
if all(cpFig>=[pos(1) pos(2)]) && all(cpFig<=[pos(1)+pos(3) pos(2)+pos(4)])
    if strcmp(hMergeGui.CursorMode,'Normal')
        dx=((xy{1}(2)-xy{1}(1))/40);
        dy=((xy{2}(2)-xy{2}(1))/40);
        k=find( abs(X-cp(1))<dx & abs(Y-cp(2))<dy);
        [~,t]=min((X(k)-cp(1)).^2+(Y(k)-cp(2)).^2);
        set(hMergeGui.tFrameValue,'String',num2str(Data(k(t),2)));
        if all(hMergeGui.CursorDownPos~=0)
            hMergeGui.SelectRegion.X=[hMergeGui.SelectRegion.X cp(1)];
            hMergeGui.SelectRegion.Y=[hMergeGui.SelectRegion.Y cp(2)];
            if ~isempty(hMergeGui.SelectRegion.plot)
                delete(hMergeGui.SelectRegion.plot);    
                hMergeGui.SelectRegion.plot=[];
            end
            hMergeGui.SelectRegion.plot = line(hMergeGui.aPlot,[hMergeGui.SelectRegion.X hMergeGui.SelectRegion.X(1)] ,[hMergeGui.SelectRegion.Y hMergeGui.SelectRegion.Y(1)],'Color','black','LineStyle',':','Tag','pSelectRegion');
        end
        set(hMergeGui.fig,'pointer','arrow');
    else
        if all(hMergeGui.CursorDownPos~=0)
            Zoom=hMergeGui.Zoom;
            xy=Zoom.currentXY;
            xy{1}=xy{1}-(cp(1)-hMergeGui.CursorDownPos(1));
            xy{2}=xy{2}-(cp(2)-hMergeGui.CursorDownPos(2));
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
            set(hMergeGui.aPlot,{'xlim','ylim'},xy);
            hMergeGui.Zoom.currentXY=xy;
        end
        CData=[NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,1,1,NaN,1,1,NaN,1,1,NaN,NaN,NaN,NaN;NaN,NaN,NaN,1,2,2,1,2,2,1,2,2,1,1,NaN,NaN;NaN,NaN,NaN,1,2,2,2,2,2,2,2,2,1,2,1,NaN;NaN,NaN,NaN,NaN,1,2,2,2,2,2,2,2,2,2,1,NaN;NaN,NaN,NaN,1,1,2,2,2,2,2,2,2,2,2,1,NaN;NaN,NaN,1,2,2,2,2,2,2,2,2,2,2,2,1,NaN;NaN,NaN,1,2,2,2,2,2,2,2,2,2,2,2,1,NaN;NaN,NaN,1,2,2,2,2,2,2,2,2,2,2,1,NaN,NaN;NaN,NaN,NaN,1,2,2,2,2,2,2,2,2,2,1,NaN,NaN;NaN,NaN,NaN,NaN,1,2,2,2,2,2,2,2,1,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,1,2,2,2,2,2,2,1,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,1,2,2,2,2,2,2,1,NaN,NaN,NaN;];
        set(hMergeGui.fig,'Pointer','custom','PointerShapeCData',CData,'PointerShapeHotSpot',[10 9]);    
    end
    setappdata(0,'hMergeGui',hMergeGui);
else 
    set(hMergeGui.tFrameValue,'String','');
    set(hMergeGui.fig,'pointer','arrow');
end

function ButtonDown(hObject, eventdata) %#ok<INUSD>
hMergeGui=getappdata(0,'hMergeGui');
cp=get(hMergeGui.aPlot,'currentpoint');
cp=cp(1,[1 2]);
pos = get(hMergeGui.pPlotPanel,'Position');
cpFig = get(hMergeGui.fig,'currentpoint');
cpFig = cpFig(1,[1 2]);
if all(cpFig>=[pos(1) pos(2)]) && all(cpFig<=[pos(1)+pos(3) pos(2)+pos(4)]) 
    if strcmp(get(hMergeGui.fig,'SelectionType'),'normal')
        hMergeGui.CursorMode='Normal';
        if all(hMergeGui.CursorDownPos==0)
            hMergeGui.SelectRegion.X=cp(1);
            hMergeGui.SelectRegion.Y=cp(2);
            hMergeGui.SelectRegion.plot=line(hMergeGui.aPlot,cp(1),cp(2),'Color','black','LineStyle',':','Tag','pSelectRegion');                   
            hMergeGui.CursorDownPos=cp;                   
        end
    elseif strcmp(get(hMergeGui.fig,'SelectionType'),'extend')
        hMergeGui.CursorMode='Pan';
        hMergeGui.CursorDownPos=cp;  
        CData=[NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,1,1,NaN,1,1,NaN,1,1,NaN,NaN,NaN,NaN;NaN,NaN,NaN,1,2,2,1,2,2,1,2,2,1,1,NaN,NaN;NaN,NaN,NaN,1,2,2,2,2,2,2,2,2,1,2,1,NaN;NaN,NaN,NaN,NaN,1,2,2,2,2,2,2,2,2,2,1,NaN;NaN,NaN,NaN,1,1,2,2,2,2,2,2,2,2,2,1,NaN;NaN,NaN,1,2,2,2,2,2,2,2,2,2,2,2,1,NaN;NaN,NaN,1,2,2,2,2,2,2,2,2,2,2,2,1,NaN;NaN,NaN,1,2,2,2,2,2,2,2,2,2,2,1,NaN,NaN;NaN,NaN,NaN,1,2,2,2,2,2,2,2,2,2,1,NaN,NaN;NaN,NaN,NaN,NaN,1,2,2,2,2,2,2,2,1,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,1,2,2,2,2,2,2,1,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,1,2,2,2,2,2,2,1,NaN,NaN,NaN;];
        set(hMergeGui.fig,'Pointer','custom','PointerShapeCData',CData,'PointerShapeHotSpot',[10 9]);
    end
end
setappdata(0,'hMergeGui',hMergeGui);

function ButtonUp(hObject, eventdata) %#ok<INUSD>
hMergeGui=getappdata(0,'hMergeGui');
Check=getappdata(hMergeGui.fig,'Check');
xy=get(hMergeGui.aPlot,{'xlim','ylim'});
cp=get(hMergeGui.aPlot,'currentpoint');
cp=cp(1,[1 2]);
pos = get(hMergeGui.pPlotPanel,'Position');
cpFig = get(hMergeGui.fig,'currentpoint');
cpFig = cpFig(1,[1 2]);
X=get(hMergeGui.DataPlot,'XData');
Y=get(hMergeGui.DataPlot,'YData');
if strcmp(hMergeGui.CursorMode,'Normal')    
    if all(cpFig>=[pos(1) pos(2)]) && all(cpFig<=[pos(1)+pos(3) pos(2)+pos(4)]) 
        if all(hMergeGui.CursorDownPos==cp)
            dx=((xy{1}(2)-xy{1}(1))/40);
            dy=((xy{2}(2)-xy{2}(1))/40);
            k=find( abs(X-cp(1))<dx & abs(Y-cp(2))<dy);
            [~,t]=min((X(k)-cp(1)).^2+(Y(k)-cp(2)).^2);
            Check(k(t)) = ~Check(k(t));
        else
            hMergeGui.SelectRegion.X=[hMergeGui.SelectRegion.X hMergeGui.SelectRegion.X(1)];
            hMergeGui.SelectRegion.Y=[hMergeGui.SelectRegion.Y hMergeGui.SelectRegion.Y(1)];
            IN = inpolygon(X,Y,hMergeGui.SelectRegion.X,hMergeGui.SelectRegion.Y);
            Check(IN) = ~Check(IN);
            k=find(IN==1);
        end
    else
        k=[];
    end
    hMergeGui.CursorDownPos(:)=0;        
    if ~isempty(hMergeGui.SelectRegion.plot)
        delete(hMergeGui.SelectRegion.plot);    
        hMergeGui.SelectRegion.plot=[];
    end
    if ~isempty(k)
        data = get(hMergeGui.tTable,'Data');
        data(:,1) = num2cell(Check);
        set(hMergeGui.tTable,'Data',data);
    end
else
    hMergeGui.CursorDownPos(:)=0;    
    hMergeGui.CursorMode='Normal';
    set(hMergeGui.fig,'pointer','arrow');
end
setappdata(0,'hMergeGui',hMergeGui);
setappdata(hMergeGui.fig,'Check',Check);
Draw(hMergeGui);


function CreateTable(hMergeGui,data)
set(hMergeGui.tTable,'Units','pixels');
Pos = get(hMergeGui.tTable,'Position');
set(hMergeGui.tTable,'Units','normalized');
columnname = {'Select','Name','Frame','Time[sec]','XPosition[nm]','YPosition[nm]'};
columnweight = [ 0.5, 1.5, 0.8, 0.8, 1.3, 1.3];
columnwidth = fix(columnweight*Pos(3)/sum(columnweight));
columnwidth(6) = columnwidth(6) + fix(Pos(3))-sum(columnwidth) - 2;
if size(data,1)>22
    columnwidth(6) = columnwidth(6) - 17;
end
set(hMergeGui.tTable,'Data',data,'ColumnName',columnname,'ColumnWidth',num2cell(columnwidth));

function Scroll(hObject,eventdata) %#ok<INUSL>
hMergeGui=getappdata(0,'hMergeGui');
pos = get(hMergeGui.pPlotPanel,'Position');
cpFig = get(hMergeGui.fig,'currentpoint');
cpFig = cpFig(1,[1 2]);
xy=get(hMergeGui.aPlot,{'xlim','ylim'});
cp=get(hMergeGui.aPlot,'currentpoint');
cp=cp(1,[1 2]);
if all(cpFig>=[pos(1) pos(2)]) && all(cpFig<=[pos(1)+pos(3) pos(2)+pos(4)])
    Zoom=hMergeGui.Zoom;
    level=Zoom.level-eventdata.VerticalScrollCount;
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
        if (y_current/x_current) >= Zoom.aspect
            new_scale_y = y_total*p;
            new_scale_x = new_scale_y/Zoom.aspect;
        else
            new_scale_x = x_total*p;
            new_scale_y = new_scale_x*Zoom.aspect;
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
    set(hMergeGui.aPlot,{'xlim','ylim'},Zoom.currentXY);
    hMergeGui.Zoom=Zoom;
    setappdata(0,'hMergeGui',hMergeGui);
end

function Select(~, ~)
hMergeGui=getappdata(0,'hMergeGui');
data = get(hMergeGui.tTable,'Data');
Check = cell2mat(data(:,1));
setappdata(hMergeGui.fig,'Check',Check);
Draw(hMergeGui);
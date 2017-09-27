%MainGUI of FIESTA
function fMainGui(func,varargin)
switch(func)
    case 'Create'
        MainGuiCreate;
    case 'InitGui'
        InitGui(varargin{1});
    case 'SelectObject'
        SelectObject(varargin{1},varargin{2},varargin{3},varargin{4});        
    case 'OpenObject'
        OpenObject(varargin{1},varargin{2},varargin{3});         
    case 'RenameObjectDone'
        RenameObjectDone(varargin{1},varargin{2},varargin{3});             
    case 'CheckRenameButtonUp'
        CheckRenameButtonUp(varargin{1},varargin{2},varargin{3});                
    case 'Exit'
        Exit(varargin{1},varargin{2})
    case 'UpdateCursor'
        UpdateCursor([],[]);
end

function MainGuiCreate
global Config;
global FiestaDir;
%title for the figure

if ~isempty(findobj('Tag','hMainGui'))
    close all hidden;
end

hMainGui.Version='Version 1.05.0005';
hMainGui.Date='June 30th, 2016';
hMainGui.Name=['FIESTA - Fluorescence Image Evaluation Software for Tracking and Analysis -- ' hMainGui.Version];

%create figure
hMainGui.fig= figure('Units','normalized','DockControls','off','IntegerHandle','off','Name',hMainGui.Name,'MenuBar','none',...
                     'NumberTitle','off','OuterPosition',[0.05 0.05 0.9 0.9],'HandleVisibility','callback','Tag','hMainGui',...
                     'Visible','off','NextPlot','add','InvertHardcopy','off','Interruptible','off','BusyAction','cancel');

if ispc
    set(hMainGui.fig,'Color',[236 233 216]/255);
end

%set(hMainGui.fig,'Units','pixel','Position',[50 50 1280 1024]);
%et(hMainGui.fig,'Units','normalized');

%create Menu
hMainGui.Menu=fMenuCreate(hMainGui);
%create ToolBar
hMainGui.ToolBar=fToolBarCreate(hMainGui);
%create LeftPanel
hMainGui.LeftPanel=fLeftPanelCreate(hMainGui);
%create MidPanel
hMainGui.MidPanel=fMidPanelCreate(hMainGui);
%create RightPanel
hMainGui.RightPanel=fRightPanelCreate(hMainGui);

%set(findobj(hMainGui.fig,'-property','KeyPressFcn'),'KeyPressFcn',@CheckKeyPress);
%set(findobj(hMainGui.fig,'-property','KeyReleaseFcn'),'KeyReleaseFcn',@CheckKeyRelease);

set(hMainGui.fig, 'WindowKeyPressFcn',@keypress);
set(hMainGui.fig, 'WindowKeyReleaseFcn',@keyrelease);
set(hMainGui.fig, 'CloseRequestFcn',@Exit);
set(hMainGui.fig, 'ResizeFcn',@ResizeGUI);

hMainGui=DefValues(hMainGui);

Config=fLoadConfig(FiestaDir.AppData);

hMainGui=DefStruct(hMainGui);

fShared('UpdateMenu',hMainGui);

setappdata(0,'hMainGui',hMainGui);

set(hMainGui.fig, 'WindowButtonMotionFcn', @UpdateCursor);
set(hMainGui.fig, 'WindowButtonDownFcn',@ButtonDown);
set(hMainGui.fig, 'WindowButtonUpFcn',@ButtonUp);    
set(hMainGui.fig, 'WindowScrollWheelFcn',@Scroll);  

set(hMainGui.fig,'Visible','on');
maximize(hMainGui.fig);

function Exit(hObject,eventdata) %#ok<INUSD>
global PathBackup;
button = fQuestDlg('Closing FIESTA, are you sure?','Close FIESTA',{'Yes','No'},'No');
if strcmp(button,'Yes')
    if ~isempty(PathBackup)
        path(PathBackup);
    end
    delete(findobj('Tag','hAboutGui'));
    delete(findobj('Tag','hAverageSpeedGui'));
    delete(findobj('Tag','hConfigGui'));
    delete(findobj('Tag','hDataGui'));
    delete(findobj('Tag','hExportGui'));
    delete(findobj('Tag','hMergeGui'));
    delete(findobj('Tag','hPathsStatsGui'));
    delete(findobj('Tag','hMainGui'));
    clear global;
end

function hMainGui=DefValues(hMainGui)
global DirRoot;
global DirCurrent;
global FiestaDir;
global BackUp;
if isempty(DirRoot)
    p = fileparts( mfilename('fullpath') );
    file_separator = strfind(p,filesep);
    DirRoot = p(1:file_separator(length(file_separator)-1));
end
if isdeployed
    if ismac
        FiestaDir.AppData = '~/Library/Fiesta/';
        DirCurrent = '~/';
    else
        FiestaDir.AppData = [winqueryreg('HKEY_CURRENT_USER','Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders','Local AppData') filesep 'Fiesta' filesep];
    end 
else
    FiestaDir.AppData = DirCurrent;
end
FiestaDir.Load=[];
FiestaDir.Save=[];
FiestaDir.Stack=DirCurrent;

hMainGui.File=[];

hMainGui.Values.FrameIdx=[1 0];
hMainGui.Values.MaxIdx=[1 1];
hMainGui.Values.PixSize=1;
hMainGui.Values.ScanSize=3;
hMainGui.Values.CursorDownPos=[0 0];
hMainGui.SelectMode=[];
hMainGui.SelectLast=[];
hMainGui.CurrentKey=[];
hMainGui.Plots.SelectRegion=[];
hMainGui.Plots.TrackInfo=[];
hMainGui.Values.TformChannel = {};

hMainGui.RegionColor=hsv(64);
                  
hMainGui.IsRunningUpdate=0;

hMainGui.Image=[];

hMainGui.CursorMode='Normal';

BackUp = [];

function hMainGui=DefStruct(hMainGui)
global Molecule;
global Filament;
global Stack;
global KymoTrackMol;
global KymoTrackFil;
global Queue;
global ServerQueue;
global Config;
hMainGui.Region = struct('Area',{},'Check',{},'X',{},'Y',{},'color',{});
hMainGui.Measure = struct('X',{},'Y',{});
hMainGui.Scan = struct('X',{},'Y',{});
hMainGui.ZoomView = struct('currentXY',[],'globalXY',[],'level',[],'aspect',GetAxesAspectRatio(hMainGui.MidPanel.aView));
hMainGui.ZoomKymo = struct('currentXY',[],'globalXY',[],'level',[],'aspect',GetAxesAspectRatio(hMainGui.MidPanel.aKymoGraph));
hMainGui.KymoImage=[];
hMainGui.CurrentAxes='View';
Stack=[];
Molecule=[];
Filament=[];
Molecule=fDefStructure(Molecule,'Molecule');
Filament=fDefStructure(Filament,'Filament');
KymoTrackMol=struct('Index',{},'Track',{},'PlotHandles',{});
KymoTrackFil=struct('Index',{},'Track',{},'PlotHandles',{});
setappdata(hMainGui.fig,'OffsetMap',[]);
Queue=[];
if ~isempty(Config.TrackingServer)
    set(hMainGui.Menu.mLoadServer,'Enable','off');
    set(hMainGui.Menu.mLoadObjServer,'Enable','off');
    set(hMainGui.Menu.mAddStackServer,'Enable','off');
    set(hMainGui.RightPanel.pButton.bAddServer,'Enable','off');    
    set(hMainGui.RightPanel.pQueue.bSrvRefresh,'Enable','off');    
end
ServerQueue=[];

function InitGui(hMainGui)
global Config;
global Stack;
y=size(Stack{1},1);
x=size(Stack{1},2);
z=size(Stack{1},3);
c=numel(Stack);

Config.FirstTFrame=1;
Config.FirstCFrame=1;
Config.LastFrame=z;

if c>1
    set(hMainGui.ToolBar.ToolChannels,'Visible','off','State','off');
    set(hMainGui.ToolBar.ToolChannels([1:c 5]),'Visible','on');
    set(hMainGui.ToolBar.ToolChannels(1),'State','on');
    set(hMainGui.ToolBar.ToolColors,'Visible','on');
else
    set(hMainGui.ToolBar.ToolChannels,'Visible','off','State','off');
    set(hMainGui.ToolBar.ToolColors,'Visible','off');
end

hMainGui.Values.PixMin = [];
hMainGui.Values.PixMax = [];
hMainGui.Values.MinStack  = [];
hMainGui.Values.MeanStack = [];
hMainGui.Values.MaxRelThresh = [];
hMainGui.Values.ScaleMin = [];
hMainGui.Values.ScaleMax = [];
hMainGui.Values.Thresh = [];
hMainGui.Values.RelThresh = [];
hMainGui.Values.StackColor = [];

MaxImage = zeros(y,x,c);
AverageImage = zeros(y,x,c);
for n = 1:c
    %find Max and Min Values for Stack
    PixMin = squeeze(min(min(Stack{n})));
    PixMax = squeeze(max(max(Stack{n})));
    hMainGui.Values.PixMin(n)=min(PixMin);
    hMainGui.Values.PixMax(n)=max(PixMax);

    hMainGui.Values.MinStack(n)=mean(PixMin);

    hMainGui.Values.MaxRelThresh(n)=2000;

    hMainGui.Values.ScaleMin(n)=round(mean(PixMin));
    hMainGui.Values.ScaleMax(n)=round(mean(PixMax));
    hMainGui.Values.Thresh(n)=min([round(mean2(Stack{n}(:,:,1))+5*std2(Stack{n}(:,:,1))) hMainGui.Values.PixMax(n)]);
    hMainGui.Values.RelThresh(n)=200;
    
    hMainGui.Values.StackColor(n) = n + 1;
    MaxImage(:,:,n) = max(Stack{n},[],3);
    AverageImage(:,:,n) = mean(Stack{n},3);
end

set(hMainGui.RightPanel.pTools.eKymoStart,'String','1');
set(hMainGui.RightPanel.pTools.eKymoEnd,'String',num2str(z));

set(hMainGui.MidPanel.tInfoTime,'String',sprintf('Time: %0.3f s',0));
%set Scale Images
SetScale(hMainGui);
setappdata(hMainGui.fig,'Config',Config);
%set zoom
if y/x >= hMainGui.ZoomView.aspect
    borders = ((y/hMainGui.ZoomView.aspect)-x)/2;
    hMainGui.ZoomView.globalXY = {[0.5-borders x+0.5+borders],[0.5 y+0.5]};
else
    borders = ((x*hMainGui.ZoomView.aspect)-y)/2;
    hMainGui.ZoomView.globalXY = {[0.5 x+0.5],[0.5-borders y+0.5+borders]}; 
end
hMainGui.ZoomView.currentXY=hMainGui.ZoomView.globalXY;
hMainGui.ZoomView.level=0;
%show Image
set(hMainGui.MidPanel.pView,'Visible','on');
set(hMainGui.MidPanel.pNoData,'Visible','off');
setappdata(0,'hMainGui',hMainGui);
setappdata(hMainGui.fig,'MaxImage',MaxImage);
setappdata(hMainGui.fig,'AverageImage',AverageImage);
fShared('UpdateMenu',hMainGui);   
fToolBar('SwitchChannel',1);
fShow('Tracks',hMainGui);
ResizeGUI;

function SetScale(hMainGui)
%create Intensity Scale
Scale=zeros(1024,1,3);
Scale(:,:,1) = 1024:-1:1;
Scale(:,:,2) = 1024:-1:1;
Scale(:,:,3) = 1024:-1:1;

Scale = Scale/1024;
%draw Norm Scalebar
image(hMainGui.LeftPanel.pNorm.aScaleBar,Scale)
axis(hMainGui.LeftPanel.pNorm.aScaleBar,'off');

%draw Thresh Scalebar
image(hMainGui.LeftPanel.pThresh.aScaleBar,Scale)
axis(hMainGui.LeftPanel.pThresh.aScaleBar,'off');

function [strInfo,List]=TrackLabels(Objects,KymoTrack,cp,dx,dy,PixSize,stidx)
p=1;
strInfo=[];
List=[];
if ~isempty(KymoTrack)
    idx = [KymoTrack.Index];
    obj = find([Objects(idx).Visible]==1 & [Objects(idx).Selected]>=0 & ismember([Objects(idx).Channel],stidx));
    for i = obj
        k = abs(KymoTrack(i).Track(:,2)-cp(1))<dx & abs(KymoTrack(i).Track(:,1)-cp(2))<dy;
        if any(k)
            strInfo{p}=Objects(idx(i)).Name; %#ok<AGROW>
            List(p)=idx(i); %#ok<AGROW>
            p=p+1;
        end
    end
else
    obj = find([Objects.Visible]==1 & [Objects.Selected]>=0 & ismember([Objects.Channel],stidx));
    for i = obj
        k = abs(Objects(i).Results(:,3)/PixSize-cp(1))<dx & abs(Objects(i).Results(:,4)/PixSize-cp(2))<dy;
        if any(k)
            strInfo{p}=Objects(i).Name; %#ok<AGROW>
            List(p)=i; %#ok<AGROW>
            p=p+1;
        end
    end
end

function UpdateCursor(hObject,eventdata) %#ok<INUSD>
global Molecule;
global Filament;
global KymoTrackMol;
global KymoTrackFil;
global Stack;
global TrackInfo;
global TimeInfo;
hMainGui=getappdata(0,'hMainGui');
PixSize=hMainGui.Values.PixSize;
xyMid=get(hMainGui.MidPanel.pView,'Position');
cpFig=get(hMainGui.fig,'CurrentPoint');
xyKymo=get(hMainGui.MidPanel.aKymoGraph,{'xlim','ylim'});
cpKymo=get(hMainGui.MidPanel.aKymoGraph,'currentpoint');
cpKymo=cpKymo(1,[1 2]);
xyView=get(hMainGui.MidPanel.aView,{'xlim','ylim'});
cpView=get(hMainGui.MidPanel.aView,'currentpoint');
stidx = getChannels(hMainGui);
if ~isempty(Stack)
    if real(getFrameIdx(hMainGui))>0
        [y,x,~]=size(Stack{1});
        xyView{1}=[max([1 xyView{1}(1)]) min([x xyView{1}(2)])];
        xyView{2}=[max([1 xyView{2}(1)]) min([y xyView{2}(2)])];
    end
end
if ~isempty(hMainGui.KymoImage)
    [y,x,~]=size(hMainGui.KymoImage);
    xyKymo{1}=[max([1 xyKymo{1}(1)]) min([x xyKymo{1}(2)])];
    xyKymo{2}=[max([1 xyKymo{2}(1)]) min([y xyKymo{2}(2)])];
end
cpView=cpView(1,[1 2]);
strInfo=[];
if all(hMainGui.Values.CursorDownPos==0)||strcmp(hMainGui.CurrentKey,'shift')
    if ~isempty(hMainGui.Plots.SelectRegion)
        hMainGui=DeleteSelectRegion(hMainGui);
    end
end
if all(cpFig>=[xyMid(1) xyMid(2)]) && all(cpFig<=[xyMid(1)+xyMid(3) xyMid(2)+xyMid(4)])
    if strcmp(get(hMainGui.ToolBar.ToolKymoGraph,'State'),'on')
        hMainGui.CurrentAxes='Kymo';
    else
        hMainGui.CurrentAxes='View';
    end
else
    hMainGui.CurrentAxes='none';    
    set(hMainGui.MidPanel.tInfoImage,'String','');
    set(hMainGui.MidPanel.tInfoCoord,'String','');   
    if ~strcmp(get(hMainGui.fig,'pointer'),'watch')
        set(hMainGui.fig,'pointer','arrow');    
    end   
end
if strcmp(hMainGui.CurrentAxes,'Kymo') && all(cpKymo>=[xyKymo{1}(1) xyKymo{2}(1)]) && all(cpKymo<=[xyKymo{1}(2) xyKymo{2}(2)])
    xy=xyKymo;
    cp=cpKymo;
    dx=((xy{1}(2)-xy{1}(1))/50);
    dy=((xy{2}(2)-xy{2}(1))/50);
    hMainGui.CurrentAxesHandle=hMainGui.MidPanel.aKymoGraph;
    if strcmp(hMainGui.CursorMode,'Normal')==1
        if any(hMainGui.Values.CursorDownPos~=0)
            %if user is holding button create selection region
             hMainGui.SelectRegion.X=[hMainGui.SelectRegion.X cp(1)];
             hMainGui.SelectRegion.Y=[hMainGui.SelectRegion.Y cp(2)];
             bx=[hMainGui.SelectRegion.X hMainGui.SelectRegion.X(1)];
             by=[hMainGui.SelectRegion.Y hMainGui.SelectRegion.Y(1)];
             if isempty(hMainGui.Plots.SelectRegion)
                 hMainGui.Plots.SelectRegion=line(hMainGui.MidPanel.aKymoGraph,bx,by,'Color','white','LineStyle',':','Tag','pSelectRegion','EraseMode','background');                     
             else
                 set(hMainGui.Plots.SelectRegion,'XData',bx,'YData',by);
             end
        else
            if ~isempty(KymoTrackMol)
                [strInfo,List]=TrackLabels(Molecule,KymoTrackMol,cp,dx,dy,PixSize,stidx);
                Mode='Molecule';
                Object=Molecule;
            end
            if ~isempty(KymoTrackFil)&&isempty(strInfo)
                [strInfo,List]=TrackLabels(Filament,KymoTrackFil,cp,dx,dy,PixSize,stidx);
                Mode='Filament';
                Object=Filament;
            end 
        end
        idx = real(getFrameIdx(hMainGui));
        Img=hMainGui.KymoImage;
        if all(size(Img(:,:,1))>=[round(cp(2)) round(cp(1))]) && all(round(cp)>0)
            v=Img(round(cp(2)),round(cp(1)), min(idx(1),size(Img,3)));
            set(hMainGui.MidPanel.tInfoImage,'String',sprintf('Image X: %03.0f     Y: %03.0f     Value: %d',round(cp(1)),round(cp(2)),v));
            t=ceil(cp(2));
            tstart=str2double(get(hMainGui.RightPanel.pTools.eKymoStart,'String'))-1;
            if t+tstart<=length(TimeInfo{idx(1)})
                time = (TimeInfo{idx(1)}(t+tstart)-TimeInfo{idx(1)}(1))/1000;
            else
                time = [];
            end
            set(hMainGui.MidPanel.tInfoCoord,'String',['Coordinates X: ' num2str(cp(1)*get(hMainGui.KymoGraph,'UserData')*hMainGui.Values.PixSize/1000,'%0.3f') ...
                ' ' char(956) 'm     Y: ' num2str(time,'%0.3f') ' s']);
        end
    end
elseif strcmp(hMainGui.CurrentAxes,'View') && all(cpView>=[xyView{1}(1) xyView{2}(1)]) && all(cpView<=[xyView{1}(2) xyView{2}(2)]) && strcmp(get(hMainGui.MidPanel.pView,'Visible'),'on')
    xy=xyView;
    cp=cpView;
    dx=((xy{1}(2)-xy{1}(1))/100);
    dy=((xy{2}(2)-xy{2}(1))/100);
    hMainGui.CurrentAxesHandle=hMainGui.MidPanel.aView; 
    if strcmp(hMainGui.CursorMode,'Normal')==1
        if any(hMainGui.Values.CursorDownPos~=0)
             color='black';
             if ~isempty(Stack)
                 color='white';
             end
            %if user is holding button create selection region
             hMainGui.SelectRegion.X=[hMainGui.SelectRegion.X cp(1)];
             hMainGui.SelectRegion.Y=[hMainGui.SelectRegion.Y cp(2)];
             bx=[hMainGui.SelectRegion.X hMainGui.SelectRegion.X(1)];
             by=[hMainGui.SelectRegion.Y hMainGui.SelectRegion.Y(1)];
             if isempty(hMainGui.Plots.SelectRegion)
                 hMainGui.Plots.SelectRegion=line(hMainGui.MidPanel.aView,bx,by,'Color',color,'LineStyle',':','Tag','pSelectRegion');                           
             else
                 try
                    set(hMainGui.Plots.SelectRegion,'XData',bx,'YData',by);
                 catch
                     hMainGui.Plots.SelectRegion = [];
                 end     
             end
        else
            if ~isempty(Stack)
                if all(isreal(getFrameIdx(hMainGui)))
                    idx = getFrameIdx(hMainGui);
                    Img = Stack{idx(1)}(:,:,idx(2));
                    v=Img(round(cp(2)),round(cp(1)));
                    set(hMainGui.MidPanel.tInfoImage,'String',sprintf('Image X: %03.0f     Y: %03.0f     Value: %d',round(cp(1)),round(cp(2)),v));
                else
                    set(hMainGui.MidPanel.tInfoImage,'String',sprintf('Image X: %03.0f     Y: %03.0f     ',round(cp(1)),round(cp(2))));
                end
            end
            set(hMainGui.MidPanel.tInfoCoord,'String',['Coordinates X: ' num2str(cp(1)*PixSize/1000,'%0.3f') ' ' char(956) 'm     Y: ' num2str(cp(2)*PixSize/1000,'%0.3f') ' ' char(956) 'm']);
            if all(hMainGui.Values.CursorDownPos==0)
                if ~isempty(Molecule)
                    [strInfo,List]=TrackLabels(Molecule,[],cp,dx,dy,PixSize,stidx);
                    Mode='Molecule';   
                    Object=Molecule;
                end
                if ~isempty(Filament)&&isempty(strInfo)
                    [strInfo,List]=TrackLabels(Filament,[],cp,dx,dy,PixSize,stidx);
                    Mode='Filament';   
                    Object=Filament;
                end                
            end
        end
    elseif strcmp(hMainGui.CursorMode,'Region')==1
        cp=round(cp);
        CData=[NaN,NaN,NaN,NaN,NaN,NaN,NaN,2,2,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,2,2,2,2,2,2,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,2,2,2,2,2,2,2,2,2,2,NaN,NaN,NaN;NaN,NaN,2,2,2,NaN,NaN,2,2,NaN,NaN,2,2,2,NaN,NaN;NaN,NaN,2,2,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,2,2,NaN,NaN;NaN,2,2,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,2,2,NaN;NaN,2,2,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,2,2,NaN;2,2,2,2,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,2,2,2,2;2,2,2,2,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,2,2,2,2;NaN,2,2,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,2,2,NaN;NaN,2,2,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,2,2,NaN;NaN,NaN,2,2,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,2,2,NaN,NaN;NaN,NaN,2,2,2,NaN,NaN,2,2,NaN,NaN,2,2,2,NaN,NaN;NaN,NaN,NaN,2,2,2,2,2,2,2,2,2,2,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,2,2,2,2,2,2,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,2,2,NaN,NaN,NaN,NaN,NaN,NaN,NaN;];
        set(hMainGui.fig,'Pointer','custom','PointerShapeCData',CData,'PointerShapeHotSpot',[8 8])
        nRegion=length(hMainGui.Region);
        if all(hMainGui.Values.CursorDownPos>0) && nRegion>0         
            hMainGui.Region(nRegion).X=[hMainGui.Region(nRegion).X cp(1)];
            hMainGui.Region(nRegion).Y=[hMainGui.Region(nRegion).Y cp(2)];
            bx=[hMainGui.Region(nRegion).X hMainGui.Region(nRegion).X(1)];
            by=[hMainGui.Region(nRegion).Y hMainGui.Region(nRegion).Y(1)];
            set(hMainGui.Plots.Region(nRegion),'XData',bx,'YData',by);
        end
    elseif strcmp(hMainGui.CursorMode,'RectRegion')==1
        cp=round(cp);
        set(hMainGui.fig,'pointer','crosshair');
        if all(hMainGui.Values.CursorDownPos>0)
            nRegion=length(hMainGui.Region);
            hMainGui.Region(nRegion).X=[hMainGui.Values.CursorDownPos(1) cp(1) cp(1) hMainGui.Values.CursorDownPos(1)];
            hMainGui.Region(nRegion).Y=[hMainGui.Values.CursorDownPos(2) hMainGui.Values.CursorDownPos(2) cp(2) cp(2)];
            bx=[hMainGui.Region(nRegion).X hMainGui.Values.CursorDownPos(1)];
            by=[hMainGui.Region(nRegion).Y hMainGui.Values.CursorDownPos(2)];
            set(hMainGui.Plots.Region(nRegion),'XData',bx,'YData',by);
        end
    elseif strcmp(hMainGui.CursorMode,'Pan')==0&&strcmp(hMainGui.CursorMode,'Zoom')==0
        set(hMainGui.fig,'pointer','crosshair')
        if all(hMainGui.Values.CursorDownPos>0)
            nMeasure=length(hMainGui.Measure);
            if strcmp(hMainGui.CursorMode,'Line')==1||strcmp(hMainGui.CursorMode,'SegLine')==1
                bx=[hMainGui.Measure(nMeasure).X cp(1)];
                by=[hMainGui.Measure(nMeasure).Y cp(2)];
            end
            if strcmp(hMainGui.CursorMode,'LineScan')==1||strcmp(hMainGui.CursorMode,'SegLineScan')==1
                bx=[hMainGui.Scan.X cp(1)];
                by=[hMainGui.Scan.Y cp(2)];
            end
            if strcmp(hMainGui.CursorMode,'Freehand')==1
                if max((hMainGui.Measure(nMeasure).X==cp(1))+(hMainGui.Measure(nMeasure).Y==cp(2)))<2
                    hMainGui.Measure(nMeasure).X=[hMainGui.Measure(nMeasure).X cp(1)];
                    hMainGui.Measure(nMeasure).Y=[hMainGui.Measure(nMeasure).Y cp(2)];
                end
                bx=[hMainGui.Measure(nMeasure).X cp(1)];
                by=[hMainGui.Measure(nMeasure).Y cp(2)];
            end
            if strcmp(hMainGui.CursorMode,'FreehandScan')==1
                if max((hMainGui.Scan.X==cp(1))+(hMainGui.Scan.Y==cp(2)))<2
                    hMainGui.Scan.X=[hMainGui.Scan.X cp(1)];
                    hMainGui.Scan.Y=[hMainGui.Scan.Y cp(2)];
                end
                bx=[hMainGui.Scan.X cp(1)];
                by=[hMainGui.Scan.Y cp(2)];
            end
            if strcmp(hMainGui.CursorMode,'Rectangle')==1
                hMainGui.Measure(nMeasure).X=[hMainGui.Values.CursorDownPos(1) cp(1) cp(1) hMainGui.Values.CursorDownPos(1)];
                hMainGui.Measure(nMeasure).Y=[hMainGui.Values.CursorDownPos(2) hMainGui.Values.CursorDownPos(2) cp(2) cp(2)];
                bx=[hMainGui.Measure(nMeasure).X hMainGui.Values.CursorDownPos(1)];
                by=[hMainGui.Measure(nMeasure).Y hMainGui.Values.CursorDownPos(2)]; 
            end
            if strcmp(hMainGui.CursorMode,'Ellipse')==1
                t=0:.01:2*pi;
                bx=(hMainGui.Measure(nMeasure).X+cp(1))/2+abs(hMainGui.Measure(nMeasure).X-cp(1))/2*cos(t);
                by=(hMainGui.Measure(nMeasure).Y+cp(2))/2+abs(hMainGui.Measure(nMeasure).Y-cp(2))/2*sin(t);
            end
            if strcmp(hMainGui.CursorMode,'Polygon')==1
                bx=[hMainGui.Measure(nMeasure).X cp(1) hMainGui.Measure(nMeasure).X(1)];
                by=[hMainGui.Measure(nMeasure).Y cp(2) hMainGui.Measure(nMeasure).Y(1)];
            end
            if ~isempty(strfind(hMainGui.CursorMode,'Scan'))
                set(hMainGui.Plots.Scan,'XData',bx,'YData',by);
            else
                set(hMainGui.Plots.Measure(nMeasure),'XData',bx,'YData',by);
            end
        end
    end
end
if ~isempty(strInfo)
    p=length(strInfo);
    if p>10
        p=10;
    end
    TrackInfo.List=List;
    TrackInfo.Mode=Mode;
    n=List(1);
    ct=1;
    ct(Object(n).Selected==2)=2;
    ct(Object(n).Selected==1)=3;
    Selected=[Object.Selected];
    o = [Object.PlotHandles];
    if ~isempty(o)
        set(o,'UIContextMenu',[]);
    end
    if all(Selected(List)<2)||strcmp(hMainGui.CurrentAxes,'Kymo')
        if isempty(hMainGui.Plots.TrackInfo)
            hMainGui.Plots.TrackInfo=text(cp(1)-dx,cp(2),strInfo(1:p),'Parent',hMainGui.CurrentAxesHandle,'BackgroundColor',[.7 .9 .7],'Tag','TrackInfo','UserData',TrackInfo);
        else
            try
                set(hMainGui.Plots.TrackInfo,'String',strInfo(1:p),'Position',[cp(1)-dx,cp(2)],'UserData',TrackInfo);
            catch
                hMainGui.Plots.TrackInfo=text(cp(1)-dx,cp(2),strInfo(1:p),'Parent',hMainGui.CurrentAxesHandle,'BackgroundColor',[.7 .9 .7],'Tag','TrackInfo','UserData',TrackInfo);
            end
        end
        if isempty(hMainGui.CurrentKey)
            set(hMainGui.Plots.TrackInfo,'UIContextMenu',hMainGui.Menu.ctTrack(ct).menu);
        else
            set(hMainGui.Plots.TrackInfo,'UIContextMenu',[]);
        end
    else
        k=find(Selected==2,1);
        set(Object(k).PlotHandles(1),'UIContextMenu',hMainGui.Menu.ctTrack(2).menu,'UserData',TrackInfo);
    end  
else
    hMainGui=DeleteTrackInfo(hMainGui);
end
if strcmp(hMainGui.CursorMode,'Pan')
    if all(hMainGui.Values.CursorDownPos>0)
        if strcmp(hMainGui.PanAxis,'Kymo')
            cp=cpKymo;    
            a=hMainGui.MidPanel.aKymoGraph;        
            Zoom=hMainGui.ZoomKymo;
        elseif strcmp(hMainGui.PanAxis,'View')
            cp=cpView;    
            a=hMainGui.MidPanel.aView;        
            Zoom=hMainGui.ZoomView;
        end
        xy=Zoom.currentXY;
        xy{1}=xy{1}-(cp(1)-hMainGui.Values.CursorDownPos(1));
        xy{2}=xy{2}-(cp(2)-hMainGui.Values.CursorDownPos(2));
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
        set(a,{'xlim','ylim'},xy);
        if strcmp(hMainGui.PanAxis,'Kymo')
             hMainGui.ZoomKymo.currentXY=xy;
        elseif strcmp(hMainGui.PanAxis,'View')
             hMainGui.ZoomView.currentXY=xy;
        end
    else
        if ~strcmp(hMainGui.CurrentAxes,'none') 
            CData=[NaN,NaN,NaN,NaN,NaN,NaN,NaN,1,1,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,1,1,NaN,1,2,2,1,1,1,NaN,NaN,NaN,NaN;NaN,NaN,1,2,2,1,1,2,2,1,2,2,1,NaN,NaN,NaN;NaN,NaN,1,2,2,1,1,2,2,1,2,2,1,NaN,1,NaN;NaN,NaN,NaN,1,2,2,1,2,2,1,2,2,1,1,2,1;NaN,NaN,NaN,1,2,2,1,2,2,1,2,2,1,2,2,1;NaN,1,1,NaN,1,2,2,2,2,2,2,2,1,2,2,1;1,2,2,1,1,2,2,2,2,2,2,2,2,2,2,1;1,2,2,2,1,2,2,2,2,2,2,2,2,2,1,NaN;NaN,1,2,2,2,2,2,2,2,2,2,2,2,2,1,NaN;NaN,NaN,1,2,2,2,2,2,2,2,2,2,2,2,1,NaN;NaN,NaN,1,2,2,2,2,2,2,2,2,2,2,1,NaN,NaN;NaN,NaN,NaN,1,2,2,2,2,2,2,2,2,2,1,NaN,NaN;NaN,NaN,NaN,NaN,1,2,2,2,2,2,2,2,1,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,1,2,2,2,2,2,2,1,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,1,2,2,2,2,2,2,1,NaN,NaN,NaN;];
            set(hMainGui.fig,'Pointer','custom','PointerShapeCData',CData,'PointerShapeHotSpot',[10 9]);    
        end
    end
end
setappdata(0,'hMainGui',hMainGui);

function ButtonDown(hObject,eventdata) %#ok<INUSD>
global Stack;
fShared('ReturnFocus');
hMainGui=getappdata(0,'hMainGui');
if ~strcmp(get(hMainGui.fig,'Pointer'),'watch')
    set(0,'CurrentFigure',hMainGui.fig);
    cpKymo=get(hMainGui.MidPanel.aKymoGraph,'currentpoint');
    cpKymo=cpKymo(1,[1 2]);
    cpView=get(hMainGui.MidPanel.aView,'currentpoint');
    cpView=cpView(1,[1 2]);
    xyView=get(hMainGui.MidPanel.aView,{'xlim','ylim'});
    TrackInfo = get(hMainGui.Plots.TrackInfo,'UserData');
    if isempty(Stack)
        color='black';
    else
        color='white';
    end
    if strcmp(get(hMainGui.fig,'SelectionType'),'normal')
        if strcmp(hMainGui.CurrentAxes,'View')
            cp=cpView;
            if ~isempty(Stack)
                [y,x,~]=size(Stack{1});
                xyView{1}=[max([1 xyView{1}(1)]) min([x xyView{1}(2)])];
                xyView{2}=[max([1 xyView{2}(1)]) min([y xyView{2}(2)])];              
                if all(hMainGui.Values.CursorDownPos==0) && all(cpView>=[xyView{1}(1) xyView{2}(1)]) && all(cpView<=[xyView{1}(2) xyView{2}(2)])
                    if strcmp(hMainGui.CursorMode,'Region')||strcmp(hMainGui.CursorMode,'RectRegion')
                       cp=round(cp);
                       nRegion=length(hMainGui.Region);
                       hMainGui.Region(nRegion+1).X=cp(1);
                       hMainGui.Region(nRegion+1).Y=cp(2);
                       hMainGui.Plots.Region(nRegion+1)=line(hMainGui.MidPanel.aView,cp(1),cp(2),'Color','white','LineStyle','--');
                       hMainGui.Values.CursorDownPos=cp;
                    elseif ~isempty(strfind(hMainGui.CursorMode,'Scan'))
                        fShared('DeleteScan',hMainGui);
                        hMainGui=getappdata(0,'hMainGui');
                        set(get(hMainGui.RightPanel.pTools.pKymoGraph,'Children'),'Enable','off');         
                        hMainGui.Scan(1).X=cp(1);
                        hMainGui.Scan(1).Y=cp(2); 
                        hMainGui.Plots.Scan=line(hMainGui.MidPanel.aView,cp(1),cp(2),'Color','white','LineStyle','-.','Tag','plotScan');
                        hMainGui.Values.CursorDownPos=cp;
                    elseif strcmp(hMainGui.CursorMode,'Normal')==0
                        nMeasure=length(hMainGui.Measure);
                        hMainGui.Measure(nMeasure+1).X=cp(1);
                        hMainGui.Measure(nMeasure+1).Y=cp(2);                
                        hMainGui.Measure(nMeasure+1).Dim=0;                                    
                        hMainGui.Plots.Measure(nMeasure+1)=line(hMainGui.MidPanel.aView,cp(1),cp(2),'Color','white','LineStyle',':');
                        hMainGui.Values.CursorDownPos=cp;
                    end
                end
            end
            if isempty(TrackInfo)&&strcmp(hMainGui.CursorMode,'Normal')
               hMainGui.SelectRegion.X=cp(1);
               hMainGui.SelectRegion.Y=cp(2);
               hMainGui.Plots.SelectRegion=line(hMainGui.MidPanel.aView,cp(1),cp(2),'Color',color,'LineStyle',':','Tag','pSelectRegion');                   
               hMainGui.Values.CursorDownPos=cp;                   
            end
        elseif strcmp(hMainGui.CurrentAxes,'Kymo')
            cp=cpKymo;
            if isempty(TrackInfo)&&strcmp(hMainGui.CursorMode,'Normal')
               hMainGui.SelectRegion.X=cp(1);
               hMainGui.SelectRegion.Y=cp(2);
               hMainGui.Plots.SelectRegion=line(hMainGui.MidPanel.aKymoGraph,cp(1),cp(2),'Color',color,'LineStyle',':','Tag','pSelectRegion');                   
               hMainGui.Values.CursorDownPos=cp;                   
            end
        end
    elseif strcmp(get(hMainGui.fig,'SelectionType'),'extend')&&~isempty(Stack)&&~strcmp(hMainGui.CurrentAxes,'none')&&(strcmp(hMainGui.CursorMode,'Normal')||strcmp(hMainGui.CursorMode,'Pan')||(strcmp(hMainGui.CursorMode,'Region')&&all(hMainGui.Values.CursorDownPos==0))||(strcmp(hMainGui.CursorMode,'RectRegion')&&all(hMainGui.Values.CursorDownPos==0)))
        hMainGui.PanAxis=hMainGui.CurrentAxes;
        hMainGui.CursorMode='Pan';
        if strcmp(hMainGui.CurrentAxes,'View')
            hMainGui.Values.CursorDownPos=cpView;
        elseif strcmp(hMainGui.CurrentAxes,'Kymo')
            hMainGui.Values.CursorDownPos=cpKymo;
        end
        CData=[NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,1,1,NaN,1,1,NaN,1,1,NaN,NaN,NaN,NaN;NaN,NaN,NaN,1,2,2,1,2,2,1,2,2,1,1,NaN,NaN;NaN,NaN,NaN,1,2,2,2,2,2,2,2,2,1,2,1,NaN;NaN,NaN,NaN,NaN,1,2,2,2,2,2,2,2,2,2,1,NaN;NaN,NaN,NaN,1,1,2,2,2,2,2,2,2,2,2,1,NaN;NaN,NaN,1,2,2,2,2,2,2,2,2,2,2,2,1,NaN;NaN,NaN,1,2,2,2,2,2,2,2,2,2,2,2,1,NaN;NaN,NaN,1,2,2,2,2,2,2,2,2,2,2,1,NaN,NaN;NaN,NaN,NaN,1,2,2,2,2,2,2,2,2,2,1,NaN,NaN;NaN,NaN,NaN,NaN,1,2,2,2,2,2,2,2,1,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,1,2,2,2,2,2,2,1,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,1,2,2,2,2,2,2,1,NaN,NaN,NaN;];
        set(hMainGui.fig,'Pointer','custom','PointerShapeCData',CData,'PointerShapeHotSpot',[10 9]);
    elseif strcmp(get(hMainGui.fig,'SelectionType'),'alt')&&strcmp(hMainGui.CursorMode,'Normal')&&isempty(TrackInfo)&&strcmp(hMainGui.CurrentKey,'control')
        if strcmp(hMainGui.CurrentAxes,'View')
            cp=cpView;
        elseif strcmp(hMainGui.CurrentAxes,'Kymo')
            cp=cpKymo;            
        end
        if ~strcmp(hMainGui.CurrentAxes,'none')
            hMainGui.SelectRegion.X=cp(1);
            hMainGui.SelectRegion.Y=cp(2);
            hMainGui.Plots.SelectRegion=line(hMainGui.CurrentAxes,cp(1),cp(2),'Color',color,'LineStyle',':','Tag','pSelectRegion');                   
            hMainGui.Values.CursorDownPos=cp;                   
        end
    end
    setappdata(0,'hMainGui',hMainGui);
end

function Scroll(hObject,eventdata) %#ok<INUSL>
global Molecule;
global Filament;
hMainGui=getappdata(0,'hMainGui');
if ~strcmp(hMainGui.CurrentAxes,'none') && all(hMainGui.Values.CursorDownPos==0) && ~strcmp(get(hMainGui.fig,'Pointer'),'watch') && (strcmp(get(hMainGui.MidPanel.pKymoGraph,'Visible'),'on') || strcmp(get(hMainGui.MidPanel.pView,'Visible'),'on'))
    if strcmp(hMainGui.CurrentAxes,'Kymo')
        Zoom=hMainGui.ZoomKymo;
        cp=get(hMainGui.MidPanel.aKymoGraph,'currentpoint');
    else
        Zoom=hMainGui.ZoomView;
        cp=get(hMainGui.MidPanel.aView,'currentpoint');
    end
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
    if strcmp(hMainGui.CurrentAxes,'Kymo')
        set(hMainGui.MidPanel.aKymoGraph,{'xlim','ylim'},Zoom.currentXY);
        hMainGui.ZoomKymo=Zoom;        
    else
        set(hMainGui.MidPanel.aView,{'xlim','ylim'},Zoom.currentXY);
        hMainGui.ZoomView=Zoom;
    end
    setappdata(0,'hMainGui',hMainGui);
end
if strcmp(hMainGui.CurrentAxes,'none')
    if strcmp(get(hMainGui.RightPanel.pData.pMoleculesPan,'Visible'),'on')
        List=hMainGui.RightPanel.pData.MolList;
        Object=Molecule;
        Slider=hMainGui.RightPanel.pData.sMolList;
        Context=hMainGui.Menu.ctListMol;
    elseif strcmp(get(hMainGui.RightPanel.pData.pFilamentsPan,'Visible'),'on')
        List=hMainGui.RightPanel.pData.FilList;
        Object=Filament;
        Slider=hMainGui.RightPanel.pData.sFilList;
        Context=hMainGui.Menu.ctListFil;  
    %elseif strcmp(get(hMainGui.RightPanel.pQueue.pServerPan,'Visible'),'on')
     %   List=hMainGui.RightPanel.pQueue.SrvList;
      %  Object=Queue;
       % Slider=hMainGui.RightPanel.pData.sSrvList;
       % Context=hMainGui.Menu.ctListSrv;  
 %   elseif strcmp(get(hMainGui.RightPanel.pQueue.pLocalPan,'Visible'),'on')
 %       List=hMainGui.RightPanel.pQueue.LocList;
 %       Object=Filament;
 %       Slider=hMainGui.RightPanel.pQueue.sLocList;
 %       Context=hMainGui.Menu.ctListLoc;  
    end
    value=round(get(Slider,'Value'));
    maxValue=get(Slider,'max');   
    minValue=get(Slider,'min');
    if minValue>0
        value=value-eventdata.VerticalScrollCount;
        value(value<minValue)=minValue;
        value(value>maxValue)=maxValue;
        set(Slider,'Value',value);
        fRightPanel('UpdateList',List,Object,Slider,Context);
    end
end

function SelectObject(hMainGui,Mode,n,button)
global Molecule;
global Filament;
global KymoTrackMol;
global KymoTrackFil;
if strcmp(button,'normal') && ~strcmp(hMainGui.CurrentKey,'control')
    for j=1:length(Molecule)
        if Molecule(j).Selected==1
            Molecule(j)=fShared('SelectOne',Molecule(j),KymoTrackMol,j,0);
        end
    end
    for j=1:length(Filament)
        if Filament(j).Selected==1
            Filament(j)=fShared('SelectOne',Filament(j),KymoTrackFil,j,0);   
        end
    end
end
if strcmp(Mode,'Molecule')==1
    Object=Molecule;
    KymoObject=KymoTrackMol;
    value=round(get(hMainGui.RightPanel.pData.sMolList,'Value'));
else
    Object=Filament;
    KymoObject=KymoTrackFil;    
    value=round(get(hMainGui.RightPanel.pData.sFilList,'Value'));
end
nObj=length(Object);
if imag(n)>0
    if nObj>8
        n=nObj-7-value+imag(n);
    else
        n=imag(n);
    end
end
if strcmp(button,'extend')
    last=hMainGui.SelectLast;
    current=n;
    step=(current-last)/abs(current-last);
    for j=last:step:current
        Object(j)=fShared('SelectOne',Object(j),KymoObject,j,1);
    end
    hMainGui.SelectLast=[];
    hMainGui.SelectMode=[];
else
    Object(n)=fShared('SelectOne',Object(n),KymoObject,n,[]);
    if Object(n).Selected==1
        hMainGui.SelectLast=n;
        hMainGui.SelectMode=Mode;
    else
        hMainGui.SelectLast=[];
        hMainGui.SelectMode=[];
    end
end
Selected = [Object.Selected];
hPlot = [Object.PlotHandles];
uistack(hPlot(Selected==1),'top');
if strcmp(Mode,'Molecule')==1
    Molecule=Object;
    KymoTrackMol=KymoObject;
    fRightPanel('UpdateList',hMainGui.RightPanel.pData.MolList,Molecule,hMainGui.RightPanel.pData.sMolList,hMainGui.Menu.ctListMol);
else
    Filament=Object;
    KymoTrackFil=KymoObject;    
    fRightPanel('UpdateList',hMainGui.RightPanel.pData.FilList,Filament,hMainGui.RightPanel.pData.sFilList,hMainGui.Menu.ctListFil);
end
setappdata(0,'hMainGui',hMainGui);

function RenameObject(hMainGui,Mode,n)
global Molecule;
global Filament;
fShared('BackUp',hMainGui);
if strcmp(Mode,'Molecule')==1
    Object=Molecule;
    hName=hMainGui.RightPanel.pData.MolList.Name(n);
    value=round(get(hMainGui.RightPanel.pData.sMolList,'Value'));
else
    Object=Filament;
    hName=hMainGui.RightPanel.pData.FilList.Name(n);    
    value=round(get(hMainGui.RightPanel.pData.sFilList,'Value'));    
end
nObj=length(Object);
if nObj>8
    idx=nObj-7-value+n;
else
    idx=n;
end
set(hMainGui.fig, 'WindowButtonMotionFcn', []);
set(hMainGui.fig, 'WindowButtonDownFcn',[]);
set(hMainGui.fig, 'WindowButtonUpFcn',sprintf('fMainGui(''CheckRenameButtonUp'',''%s'',''%d'',''%d'');',Mode,n,idx));
set(hMainGui.fig, 'WindowScrollWheelFcn',[]);    
set(hMainGui.fig, 'WindowKeyPressFcn',[]);
set(hMainGui.fig, 'WindowKeyReleaseFcn',[]);
set(hName,'Style','edit','Enable','on','BackgroundColor','white','ForegroundColor','black','Callback',sprintf('fMainGui(''RenameObjectDone'',''%s'',''%d'',''%d'');',Mode,n,idx));
uicontrol(hName);
hMainGui.CurrentKey=[];
setappdata(0,'hMainGui',hMainGui);

function CheckRenameButtonUp(Mode,n,idx)
hMainGui=getappdata(0,'hMainGui');
n=str2double(n);
if strcmp(Mode,'Molecule')==1
    hName=hMainGui.RightPanel.pData.MolList.Name(n);
else
    hName=hMainGui.RightPanel.pData.FilList.Name(n);    
end
if gco~=hName
    RenameObjectDone(Mode,num2str(n),idx)
end

function RenameObjectDone(Mode,n,idx)
global Molecule;
global Filament;
hMainGui=getappdata(0,'hMainGui');
n=str2double(n);
idx=str2double(idx);
if strcmp(Mode,'Molecule')
    hName=hMainGui.RightPanel.pData.MolList.Name(n);
    Molecule(idx).Name=get(hName,'String');
else
    hName=hMainGui.RightPanel.pData.FilList.Name(n);
    Filament(idx).Name=get(hName,'String');
end
set(hName,'Callback',[],'Enable','inactive','Style','text','BackgroundColor',get(get(hName,'Parent'),'BackgroundColor'));
fRightPanel('UpdateList',hMainGui.RightPanel.pData.MolList,Molecule,hMainGui.RightPanel.pData.sMolList,hMainGui.Menu.ctListMol);
fRightPanel('UpdateList',hMainGui.RightPanel.pData.FilList,Filament,hMainGui.RightPanel.pData.sFilList,hMainGui.Menu.ctListFil);
set(hMainGui.fig, 'WindowButtonMotionFcn', @UpdateCursor);
set(hMainGui.fig, 'WindowButtonDownFcn',@ButtonDown);
set(hMainGui.fig, 'WindowButtonUpFcn',@ButtonUp);    
set(hMainGui.fig, 'WindowScrollWheelFcn',@Scroll);    
set(hMainGui.fig, 'WindowKeyPressFcn',@keypress);
set(hMainGui.fig, 'WindowKeyReleaseFcn',@keyrelease);
fShared('ReturnFocus');

function SelectQueue(hMainGui,n,button)
global Queue;
if strcmp(button,'normal')
    for j=1:length(Queue)
        Queue(j).Selected=0;
    end
end
if n>0
    value=round(get(hMainGui.RightPanel.pQueue.sLocList,'Value'));
    nQue=length(Queue);
    if nQue>9
        n=nQue-8-value+n;
    end
    if strcmp(button,'extend')
        last=hMainGui.SelectLast;
        current=n;
        step=(current-last)/abs(current-last);
        for j=last:step:current
            Queue(j).Selected=1;
        end
        hMainGui.SelectLast=[];
        hMainGui.SelectMode=[];
    else
        Queue(n).Selected=1-Queue(n).Selected;
        if Queue(n).Selected==1
            hMainGui.SelectLast=n;
            hMainGui.SelectMode='LocalQueue';
        else
            hMainGui.SelectLast=[];
            hMainGui.SelectMode=[];
        end
    end
end
fRightPanel('UpdateQueue','Local');
setappdata(0,'hMainGui',hMainGui);

function SelectRegionObject(hMainGui,button)
global Molecule;
global Filament;
global KymoTrackMol;
global KymoTrackFil;
X=hMainGui.SelectRegion.X;
Y=hMainGui.SelectRegion.Y;
stidx = getChannels(hMainGui);
if strcmp(button,'normal') && ~strcmp(hMainGui.CurrentKey,'control')
    k = find([Molecule.Selected]==1);
    for n = k
        Molecule(n)=fShared('SelectOne',Molecule(n),KymoTrackMol,n,0);
    end
    k = find([Filament.Selected]==1);
    for n = k
        Filament(n)=fShared('SelectOne',Filament(n),KymoTrackFil,n,0);       
    end
end
if strcmp(hMainGui.CurrentAxes,'View')
    X = X * hMainGui.Values.PixSize;
    Y = Y * hMainGui.Values.PixSize;
    k = find( [Molecule.Visible]==1 & [Molecule.Selected]>-1 & ismember([Molecule.Channel],stidx));
    for n = k
        IN=inpolygon(Molecule(n).Results(:,3),Molecule(n).Results(:,4),X,Y);
        if sum(IN) > 0.9*size(Molecule(n).Results,1)
            Molecule(n) = fShared('SelectOne',Molecule(n),KymoTrackMol,n,[]);
        end
    end
    k = find( [Filament.Visible]==1 & [Filament.Selected]>-1 & ismember([Filament.Channel],stidx));
    for n = k
       IN=inpolygon(Filament(n).Results(:,3),Filament(n).Results(:,4),X,Y);
        if sum(IN)>0.9*size(Filament(n).Results,1)
            Filament(n)=fShared('SelectOne',Filament(n),KymoTrackFil,n,[]);
        end
    end        
elseif strcmp(hMainGui.CurrentAxes,'Kymo')
    idx = [KymoTrackMol.Index];
    obj = find([Molecule(idx).Visible]==1 & [Molecule(idx).Selected]>-1 & ismember([Molecule(idx).Channel],stidx));
    for n = obj
        IN=inpolygon(KymoTrackMol(n).Track(:,1),KymoTrackMol(n).Track(:,2),Y,X);
        if sum(IN)>0.9*size(KymoTrackMol(n).Track,1)
            Molecule(idx(n))=fShared('SelectOne',Molecule(idx(n)),KymoTrackMol,idx(n),[]);
        end
    end
    idx = [KymoTrackFil.Index];
    obj = find([Filament(idx).Visible]==1 & [Filament(idx).Selected]>-1 & ismember([Filament(idx).Channel],stidx));
    for n = obj
        IN=inpolygon(KymoTrackFil(n).Track(:,1),KymoTrackFil(n).Track(:,2),Y,X);
        if sum(IN)>0.9*size(KymoTrackFil(n).Track,1)
            Filament(idx(n))=fShared('SelectOne',Filament(idx(n)),KymoTrackFil,idx(n),[]);
        end
    end
end
Selected = [Molecule.Selected];
hPlot = [Molecule.PlotHandles];
uistack(hPlot(Selected==1),'top');
Selected = [Filament.Selected];
hPlot = [Filament.PlotHandles];
uistack(hPlot(Selected==1),'top');
hMainGui.SelectLast=[];
hMainGui.SelectMode=[];
fRightPanel('UpdateList',hMainGui.RightPanel.pData.MolList,Molecule,hMainGui.RightPanel.pData.sMolList,hMainGui.Menu.ctListMol);
fRightPanel('UpdateList',hMainGui.RightPanel.pData.FilList,Filament,hMainGui.RightPanel.pData.sFilList,hMainGui.Menu.ctListFil);
setappdata(0,'hMainGui',hMainGui);

function SelectRegionPoints(hMainGui)
global Molecule;
global Filament;
global KymoTrackMol;
global KymoTrackFil;
X=hMainGui.SelectRegion.X;
Y=hMainGui.SelectRegion.Y;
stidx = getChannels(hMainGui);
k = find([Molecule.Selected]==1);
for n = k
    Molecule(n)=fShared('SelectOne',Molecule(n),KymoTrackMol,n,0);
end
k = find([Filament.Selected]==1);
for n = k
    Filament(n)=fShared('SelectOne',Filament(n),KymoTrackFil,n,0);       
end
SelectedPoints = zeros(0,4);
if strcmp(hMainGui.CurrentAxes,'View')
    X = X * hMainGui.Values.PixSize;
    Y = Y * hMainGui.Values.PixSize;
    k = find( [Molecule.Visible]==1 & [Molecule.Selected]>-1 & ismember([Molecule.Channel],stidx));
    for n = k
        IN=inpolygon(Molecule(n).Results(:,3),Molecule(n).Results(:,4),X,Y);
        if any(IN)
            SelectedPoints = [SelectedPoints; ones(sum(IN),1)*n find(IN==1) Molecule(n).Results(IN,3) Molecule(n).Results(IN,4)];
        end
    end
    k = find( [Filament.Visible]==1 & [Filament.Selected]>-1 & ismember([Filament.Channel],stidx));
    for n = k
        IN=inpolygon(Filament(n).Results(:,3),Filament(n).Results(:,4),X,Y);
        if any(IN)
            SelectedPoints = [SelectedPoints; ones(sum(IN),1)*n*1i find(IN==1) Filament(n).Results(IN,3) Filament(n).Results(IN,4)];
        end
    end     
    line(hMainGui.MidPanel.aView,SelectedPoints(:,3)/hMainGui.Values.PixSize,SelectedPoints(:,4)/hMainGui.Values.PixSize,'Color','r','LineStyle','none','Marker','s','MarkerFaceColor',[1 0.84 0],'MarkerEdgeColor',[1 0.27 0],'Tag','pSelectedPoints');
elseif strcmp(hMainGui.CurrentAxes,'Kymo')
    idx = [KymoTrackMol.Index];
    obj = find([Molecule(idx).Visible]==1 & [Molecule(idx).Selected]>-1 & ismember([Molecule(idx).Channel],stidx));
    for n = obj
        IN=inpolygon(KymoTrackMol(n).Track(:,1),KymoTrackMol(n).Track(:,2),Y,X);
        if any(IN)
            idx_mol = KymoTrackMol(n).Index;
            [~,frame_idx] = ismember(KymoTrackMol(n).Track(IN,1),Molecule(idx_mol).Results(:,1));
            SelectedPoints = [SelectedPoints; ones(sum(IN),1)*idx_mol frame_idx KymoTrackMol(n).Track(IN,1) KymoTrackMol(n).Track(IN,2)];    
        end
    end
    idx = [KymoTrackFil.Index];
    obj = find([Filament(idx).Visible]==1 & [Filament(idx).Selected]>-1 & ismember([Filament(idx).Channel],stidx));
    for n = obj
        IN=inpolygon(KymoTrackFil(n).Track(:,1),KymoTrackFil(n).Track(:,2),Y,X);
        if any(IN)
            idx_fil = KymoTrackFil(n).Index;
            [~,frame_idx] = ismember(KymoTrackFil(n).Track(IN,1),Filament(idx_fil).Results(:,1));
            SelectedPoints = [SelectedPoints; ones(sum(IN),1)*idx_fil*1i frame_idx KymoTrackFil(n).Track(IN,1) KymoTrackFil(n).Track(IN,2)];    
        end
    end
    line(hMainGui.MidPanel.aKymoGraph,SelectedPoints(:,4),SelectedPoints(:,3),'Color','r','LineStyle','none','Marker','s','MarkerFaceColor',[1 0.84 0],'MarkerEdgeColor',[1 0.27 0],'Tag','pSelectedPoints');
end
hMainGui.SelectLast = [];
hMainGui.SelectMode = [];
hMainGui.SelectedPoints = SelectedPoints;
setappdata(0,'hMainGui',hMainGui);

function OpenObject(hMainGui,Mode,n)
global Molecule
global Filament;
fShared('BackUp',hMainGui);
v=[length(Molecule) length(Filament)]-6-n;
v(v<1)=1;
fDataGui('Create',Mode,n);
if strcmp(Mode,'Molecule')==1
    set(hMainGui.RightPanel.pData.sMolList,'Value',v(1));
    fRightPanel('UpdateList',hMainGui.RightPanel.pData.MolList,Molecule,hMainGui.RightPanel.pData.sMolList,hMainGui.Menu.ctListMol);
    if strcmp(get(hMainGui.RightPanel.pData.panel,'Visible'),'on')
        fRightPanel('DataMoleculesPanel',hMainGui);            
    end    
else
    set(hMainGui.RightPanel.pData.sFilList,'Value',v(2));
    fRightPanel('UpdateList',hMainGui.RightPanel.pData.FilList,Filament,hMainGui.RightPanel.pData.sFilList,hMainGui.Menu.ctListFil);
    if strcmp(get(hMainGui.RightPanel.pData.panel,'Visible'),'on')
        fRightPanel('DataFilamentsPanel',hMainGui);   
    end            
end
        
function ButtonUp(hObject,eventdata) %#ok<INUSD>
global Stack;
global Molecule;
global Filament;
global Queue;
hMainGui=getappdata(0,'hMainGui');
if ~strcmp(get(hMainGui.fig,'Pointer'),'watch')
    delete(findobj('Tag','pSelectRegion'));
    set(0,'CurrentFigure',hMainGui.fig);
    idx=real(getFrameIdx(hMainGui));

    TrackInfo = get(hMainGui.Plots.TrackInfo,'UserData');
    if isempty(TrackInfo)
        TrackInfo.Mode='';
    else
        try
            n=TrackInfo.List(1);
        catch
            hMainGui=DeleteTrackInfo(hMainGui);
        end
    end
    Measure2D=0;
    nMeasure=length(hMainGui.Measure);
    nRegion=length(hMainGui.Region);
    %check for left button
    if strcmp(get(hMainGui.fig,'SelectionType'),'normal')
        
        %check if mouse click is on right panel
        tag=get(get(gco,'Parent'),'Tag');
        if ~isempty(strfind(tag,'Pan'))
            pause(0.1);                    
            if strcmp(get(hMainGui.fig,'SelectionType'),'normal')
            %check if molecule or filament pan
                if strcmp(tag,'MoleculePan') && ~isempty(Molecule)
                    SelectObject(hMainGui,'Molecule',get(gco,'UserData')*1i,'normal');
                elseif strcmp(tag,'FilamentPan') && ~isempty(Filament)
                    SelectObject(hMainGui,'Filament',get(gco,'UserData')*1i,'normal');
                elseif strcmp(tag,'LocalPan') && ~isempty(Queue)
                    SelectQueue(hMainGui,get(gco,'UserData'),'normal');                         
                elseif strcmp(tag,'pLocalPan') && ~isempty(Queue)
                    SelectQueue(hMainGui,0,'normal');                         
                end
            end
        end

        %if cursor normal and track info is shown then select object
        if strcmp(hMainGui.CursorMode,'Normal')
            delete(findobj('Tag','pSelectedPoints'));
            hMainGui.SelectedPoints = [];
            if all(hMainGui.Values.CursorDownPos==0)
                if ~isempty(TrackInfo.Mode)
                    %check for double-click
                    pause(0.1);

                    if strcmp(get(hMainGui.fig,'SelectionType'),'normal')
                        SelectObject(hMainGui,TrackInfo.Mode,n,'normal');
                    end
                end
            else
                hMainGui.SelectRegion.X=[hMainGui.SelectRegion.X hMainGui.Values.CursorDownPos(1)];
                hMainGui.SelectRegion.Y=[hMainGui.SelectRegion.Y hMainGui.Values.CursorDownPos(2)];   
                hMainGui=DeleteSelectRegion(hMainGui);
                hMainGui.Values.CursorDownPos(:)=0;       
                if hMainGui.CurrentKey == 's'
                    SelectRegionPoints(hMainGui);
                else
                    SelectRegionObject(hMainGui,'normal');
                end
            end
        end
        %check if view window is active axis 
        if strcmp(hMainGui.CurrentAxes,'View')
            cp=get(hMainGui.MidPanel.aView,'currentpoint');
            cp=cp(1,[1 2]);
            %check if click happend
            if all(hMainGui.Values.CursorDownPos>0)&&~isempty(Stack)
                y=size(Stack{1},1);
                x=size(Stack{1},2);
                %create region if regiontool is selected
                if nRegion>0
                    if (strcmp(hMainGui.CursorMode,'Region')==1 && length(hMainGui.Region(nRegion).X)>5) || (strcmp(hMainGui.CursorMode,'RectRegion')==1 && all(round(cp/10)~=round(hMainGui.Values.CursorDownPos/10)))
                        cp=round(cp);
                        nRegion=length(hMainGui.Region);
                        hMainGui.Region(nRegion).Check=1;
                        hMainGui.Region(nRegion).X=[hMainGui.Region(nRegion).X hMainGui.Values.CursorDownPos(1)];
                        hMainGui.Region(nRegion).Y=[hMainGui.Region(nRegion).Y hMainGui.Values.CursorDownPos(2)];
                        hMainGui.Region(nRegion).Area=roipoly(y,x,hMainGui.Region(nRegion).X,hMainGui.Region(nRegion).Y);
                        hMainGui.Region(nRegion).color=hMainGui.RegionColor(ceil(rand*64),:);
                        fLeftPanel('RegUpdateList',hMainGui);
                        set(hMainGui.Plots.Region(nRegion),'Color',hMainGui.Region(nRegion).color,'Linestyle','--','UserData',nRegion,'UIContextMenu',hMainGui.Menu.ctRegion);
                        hMainGui.Values.CursorDownPos(:)=0;
                        setappdata(0,'hMainGui',hMainGui);
                    end
                end
                
                %create measure line if linetool is selected
                if strcmp(hMainGui.CursorMode,'Line')==1 && max(round(cp/10)~=round(hMainGui.Values.CursorDownPos/10))            
                    if max((hMainGui.Measure(nMeasure).X==cp(1))+(hMainGui.Measure(nMeasure).Y==cp(2)))<2
                        hMainGui.Measure(nMeasure).X=[hMainGui.Measure(nMeasure).X cp(1)];
                        hMainGui.Measure(nMeasure).Y=[hMainGui.Measure(nMeasure).Y cp(2)];
                    end
                    color=hMainGui.RegionColor(mod(nMeasure-1,24)+1,:);
                    set(hMainGui.Plots.Measure(nMeasure),'Color',color,'UserData',nMeasure,'UIContextMenu',hMainGui.Menu.ctMeasure);
                    hMainGui.Values.CursorDownPos(:)=0;
                    hMainGui.Measure(nMeasure).LenArea=hMainGui.Values.PixSize/1000*norm([hMainGui.Measure(nMeasure).X(2)-hMainGui.Measure(nMeasure).X(1) hMainGui.Measure(nMeasure).Y(2)-hMainGui.Measure(nMeasure).Y(1)]);
                    XI=linspace(hMainGui.Measure(nMeasure).X(1),hMainGui.Measure(nMeasure).X(2),ceil(hMainGui.Measure(nMeasure).LenArea*1000/hMainGui.Values.PixSize));
                    YI=linspace(hMainGui.Measure(nMeasure).Y(1),hMainGui.Measure(nMeasure).Y(2),ceil(hMainGui.Measure(nMeasure).LenArea*1000/hMainGui.Values.PixSize));
                    ZI = interp2(double(Stack{idx(1)}(:,:,idx(2))),XI,YI);
                    hMainGui.Measure(nMeasure).Mean=mean(ZI);
                    hMainGui.Measure(nMeasure).STD=std(ZI);
                    hMainGui.Measure(nMeasure).Integral=sum(ZI);
                    hMainGui.Measure(nMeasure).Dim=1;
                    fRightPanel('UpdateMeasure',hMainGui);
                end

                %create linescan if linescantool is selected
                if strcmp(hMainGui.CursorMode,'LineScan')==1 && max(round(cp/10)~=round(hMainGui.Values.CursorDownPos/10))  
                    if max((hMainGui.Scan.X==cp(1))+(hMainGui.Scan.Y==cp(2)))<2
                        hMainGui.Scan.X=[hMainGui.Scan.X cp(1)];
                        hMainGui.Scan.Y=[hMainGui.Scan.Y cp(2)];
                    end
                    hMainGui.Values.CursorDownPos(:)=0;
                    if ~isempty(findobj('Parent',hMainGui.MidPanel.aView,'-and','Tag','plotScan'))
                        delete(findobj('Parent',hMainGui.MidPanel.aView,'-and','Tag','plotScan'));
                    end        
                    setappdata(0,'hMainGui',hMainGui);
                    fRightPanel('NewScan',hMainGui);
                end

                %select new point if segmented line or polygon tool is selected
                if ((strcmp(hMainGui.CursorMode,'SegLine')==1)||(strcmp(hMainGui.CursorMode,'Polygon')==1))
                    if max((hMainGui.Measure(nMeasure).X==cp(1))+(hMainGui.Measure(nMeasure).Y==cp(2)))<2        
                        hMainGui.Measure(nMeasure).X=[hMainGui.Measure(nMeasure).X cp(1)];
                        hMainGui.Measure(nMeasure).Y=[hMainGui.Measure(nMeasure).Y cp(2)];
                    end
                    hMainGui.Values.CursorDownPos=cp;
                    setappdata(0,'hMainGui',hMainGui);
                end

                %select new point if segmented linescan tool is selected
                if strcmp(hMainGui.CursorMode,'SegLineScan')==1
                    if max((hMainGui.Scan.X==cp(1))+(hMainGui.Scan.Y==cp(2)))<2
                        hMainGui.Scan.X=[hMainGui.Scan.X cp(1)];
                        hMainGui.Scan.Y=[hMainGui.Scan.Y cp(2)];
                    end
                    hMainGui.Values.CursorDownPos=cp;
                    setappdata(0,'hMainGui',hMainGui);
                end
                
                if nMeasure>0
                    %create freehand measure if freehand tool is selected
                    if strcmp(hMainGui.CursorMode,'Freehand')==1 && length(hMainGui.Measure(nMeasure).X)>5
                        color=hMainGui.RegionColor(mod(nMeasure-1,24)+1,:);
                        set(hMainGui.Plots.Measure(nMeasure),'Color',color,'UserData',nMeasure,'UIContextMenu',hMainGui.Menu.ctMeasure);
                        hMainGui.Values.CursorDownPos(:)=0;
                        hMainGui.Measure(nMeasure).LenArea=0;
                        XI=hMainGui.Measure(nMeasure).X(1);
                        YI=hMainGui.Measure(nMeasure).Y(1);
                        len=0;
                        for i=1:length(hMainGui.Measure(nMeasure).X)-1;
                            hMainGui.Measure(nMeasure).LenArea=hMainGui.Measure(nMeasure).LenArea+hMainGui.Values.PixSize/1000*norm([hMainGui.Measure(nMeasure).X(i+1)-hMainGui.Measure(nMeasure).X(i) hMainGui.Measure(nMeasure).Y(i+1)-hMainGui.Measure(nMeasure).Y(i)]);
                            len=len+norm([hMainGui.Measure(nMeasure).X(i+1)-hMainGui.Measure(nMeasure).X(i) hMainGui.Measure(nMeasure).Y(i+1)-hMainGui.Measure(nMeasure).Y(i)]);            
                            if len>0.99
                                XI=[XI hMainGui.Measure(nMeasure).X(i)];
                                YI=[YI hMainGui.Measure(nMeasure).Y(i)];
                                len=0;
                            end
                        end
                        ZI = interp2(double(Stack{idx(1)}(:,:,idx(2))),XI,YI);
                        hMainGui.Measure(nMeasure).Mean=mean(ZI);
                        hMainGui.Measure(nMeasure).STD=std(ZI);
                        hMainGui.Measure(nMeasure).Integral=sum(ZI);
                        hMainGui.Measure(nMeasure).Dim=1;
                        fRightPanel('UpdateMeasure',hMainGui);
                    end
                end
                
                if ~isempty(hMainGui.Scan)
                    %create freehand scan if freehandscan tool is selected
                    if strcmp(hMainGui.CursorMode,'FreehandScan')==1 && length(hMainGui.Scan.X)>5
                        hMainGui.Values.CursorDownPos(:)=0;
                        if ~isempty(findobj('Parent',hMainGui.MidPanel.aView,'-and','Tag','plotScan'))
                            delete(findobj('Parent',hMainGui.MidPanel.aView,'-and','Tag','plotScan'));
                        end             
                        setappdata(0,'hMainGui',hMainGui);
                        fRightPanel('NewScan',hMainGui);
                    end
                end
                
                %create rectangle measure if rectangle tool is selected
                if strcmp(hMainGui.CursorMode,'Rectangle')==1 && max(round(cp/10)~=round(hMainGui.Values.CursorDownPos/10))  
                    hMainGui.Measure(nMeasure).X=[hMainGui.Measure(nMeasure).X hMainGui.Values.CursorDownPos(1)];
                    hMainGui.Measure(nMeasure).Y=[hMainGui.Measure(nMeasure).Y hMainGui.Values.CursorDownPos(2)];    
                    color=hMainGui.RegionColor(mod(nMeasure-1,24)+1,:);
                    set(hMainGui.Plots.Measure(nMeasure),'Color',color,'UserData',nMeasure,'UIContextMenu',hMainGui.Menu.ctMeasure);
                    hMainGui.Values.CursorDownPos(:)=0;
                    hMainGui.Measure(nMeasure).Dim=2;   
                    Measure2D=1;
                end

                %create ellipse measure if rectangle tool is selected
                if strcmp(hMainGui.CursorMode,'Ellipse')==1 && max(round(cp/10)~=round(hMainGui.Values.CursorDownPos/10))  
                    t=0:.01:2*pi;
                    hMainGui.Measure(nMeasure).X=(hMainGui.Measure(nMeasure).X+cp(1))/2+abs(hMainGui.Measure(nMeasure).X-cp(1))/2*cos(t);
                    hMainGui.Measure(nMeasure).Y=(hMainGui.Measure(nMeasure).Y+cp(2))/2+abs(hMainGui.Measure(nMeasure).Y-cp(2))/2*sin(t);
                    hMainGui.Measure(nMeasure).X=[hMainGui.Measure(nMeasure).X hMainGui.Measure(nMeasure).X(1)];
                    hMainGui.Measure(nMeasure).Y=[hMainGui.Measure(nMeasure).Y hMainGui.Measure(nMeasure).Y(1)];
                    color=hMainGui.RegionColor(mod(nMeasure-1,24)+1,:);
                    set(hMainGui.Plots.Measure(nMeasure),'Color',color,'UserData',nMeasure,'UIContextMenu',hMainGui.Menu.ctMeasure);                    hMainGui.Values.CursorDownPos(:)=0;
                    hMainGui.Measure(nMeasure).Dim=2;  
                    Measure2D=1;
                end
            end
        end

    %check for middle button or shift click
    elseif strcmp(get(hMainGui.fig,'SelectionType'),'extend')

        %if cursor pan then exit pan mode
        if strcmp(hMainGui.CursorMode,'Pan')==1
            hMainGui.Values.CursorDownPos(:)=0;  
            if strcmp(get(hMainGui.ToolBar.ToolCursor,'State'),'on')
                hMainGui.CursorMode='Normal';
                set(hMainGui.fig,'pointer','arrow');
            elseif strcmp(get(hMainGui.ToolBar.ToolRegion,'State'),'on')
                hMainGui.CursorMode='Region';
                CData=[NaN,NaN,NaN,NaN,NaN,NaN,NaN,2,2,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,2,2,2,2,2,2,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,2,2,2,2,2,2,2,2,2,2,NaN,NaN,NaN;NaN,NaN,2,2,2,NaN,NaN,2,2,NaN,NaN,2,2,2,NaN,NaN;NaN,NaN,2,2,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,2,2,NaN,NaN;NaN,2,2,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,2,2,NaN;NaN,2,2,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,2,2,NaN;2,2,2,2,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,2,2,2,2;2,2,2,2,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,2,2,2,2;NaN,2,2,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,2,2,NaN;NaN,2,2,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,2,2,NaN;NaN,NaN,2,2,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,2,2,NaN,NaN;NaN,NaN,2,2,2,NaN,NaN,2,2,NaN,NaN,2,2,2,NaN,NaN;NaN,NaN,NaN,2,2,2,2,2,2,2,2,2,2,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,2,2,2,2,2,2,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,2,2,NaN,NaN,NaN,NaN,NaN,NaN,NaN;];
                set(hMainGui.fig,'Pointer','custom','PointerShapeCData',CData,'PointerShapeHotSpot',[8 8])
            else
                hMainGui.CursorMode='RectRegion';
                set(hMainGui.fig,'pointer','crosshair');
            end 
            setappdata(0,'hMainGui',hMainGui);
        end

        %check if mouse click is on right panel
        if ~isempty(hMainGui.CurrentKey) 
             tag=get(get(gco,'Parent'),'Tag');            
             if strcmp(tag,'MoleculePan') && strcmp(hMainGui.SelectMode,'Molecule') && ~isempty(Molecule)
                 SelectObject(hMainGui,'Molecule',get(gco,'UserData')*1i,'extend');
             elseif strcmp(tag,'FilamentPan') && strcmp(hMainGui.SelectMode,'Filament') && ~isempty(Filament)
                 SelectObject(hMainGui,'Filament',get(gco,'UserData')*1i,'extend');
             elseif strcmp(tag,'LocalPan') && strcmp(hMainGui.SelectMode,'LocalQueue') && ~isempty(Queue)
                 SelectQueue(hMainGui,get(gco,'UserData'),'extend');                         
             end
        end    

    %check for right button or control click
    elseif strcmp(get(hMainGui.fig,'SelectionType'),'alt')
        
        %check if mouse click is on right panel
        if ~isempty(hMainGui.CurrentKey)  
            tag=get(get(gco,'Parent'),'Tag');
            if strcmp(tag,'MoleculePan') && ~isempty(Molecule)
                SelectObject(hMainGui,'Molecule',get(gco,'UserData')*1i,'alt');
            elseif strcmp(tag,'FilamentPan') && ~isempty(Filament)
                SelectObject(hMainGui,'Filament',get(gco,'UserData')*1i,'alt');
            elseif strcmp(tag,'LocalPan') && ~isempty(Queue)
                SelectQueue(hMainGui,get(gco,'UserData'),'alt');                         
            end
        end
        
        if strcmp(hMainGui.CursorMode,'Normal')&&~isempty(hMainGui.CurrentKey)
            delete(findobj('Tag','pSelectedPoints'));
            hMainGui.SelectedPoints = [];
            if all(hMainGui.Values.CursorDownPos==0)
                %if cursor normal and track info is shown then select object
                if ~isempty(TrackInfo.Mode)
                    SelectObject(hMainGui,TrackInfo.Mode,n,'alt');
                end
            else
                hMainGui.SelectRegion.X=[hMainGui.SelectRegion.X hMainGui.Values.CursorDownPos(1)];
                hMainGui.SelectRegion.Y=[hMainGui.SelectRegion.Y hMainGui.Values.CursorDownPos(2)];   
                delete(hMainGui.Plots.SelectRegion);
                delete(findobj('Tag','pSelectRegion'));
                hMainGui.Values.CursorDownPos(:)=0;                
                SelectRegionObject(hMainGui,'control');
                setappdata(0,'hMainGui',hMainGui);     
            end
        end

    %check for double click    
    else
       
        tag=get(get(gco,'Parent'),'Tag');
        if strcmp(tag,'MoleculePan') && ~isempty(Molecule)
            RenameObject(hMainGui,'Molecule',get(gco,'UserData'));
        elseif strcmp(tag,'FilamentPan') && ~isempty(Filament)
            RenameObject(hMainGui,'Filament',get(gco,'UserData'));
        end
       
        %if cursor normal and track info is shown then open object DataGui
        if strcmp(hMainGui.CursorMode,'Normal')==1&&~isempty(TrackInfo.Mode)
            OpenObject(hMainGui,TrackInfo.Mode,n)
        else
            %check if molecule or filament pan
           
        end
        %check if view window is active axis 
        if strcmp(hMainGui.CurrentAxes,'View')
            cp=get(hMainGui.MidPanel.aView,'currentpoint');
            cp=round(cp(1,[1 2]));
            
            %check if click happend
            if all(hMainGui.Values.CursorDownPos>0)&&~isempty(Stack)
                y=size(Stack{1},1);
                x=size(Stack{1},2);            
                %create segmented line measure if segmented line is selected
                if strcmp(hMainGui.CursorMode,'SegLine')==1&&length(hMainGui.Measure(nMeasure).X)>1
                    color=hMainGui.RegionColor(mod(nMeasure-1,24)+1,:);
                    set(hMainGui.Plots.Measure(nMeasure),'Color',color,'UserData',nMeasure,'UIContextMenu',hMainGui.Menu.ctMeasure);
                    hMainGui.Values.CursorDownPos(:)=0;
                    hMainGui.Measure(nMeasure).LenArea=0;
                    XI=[];
                    YI=[];
                    for i=1:length(hMainGui.Measure(nMeasure).X)-1;
                        len=norm([hMainGui.Measure(nMeasure).X(i+1)-hMainGui.Measure(nMeasure).X(i) hMainGui.Measure(nMeasure).Y(i+1)-hMainGui.Measure(nMeasure).Y(i)]);
                        hMainGui.Measure(nMeasure).LenArea=hMainGui.Measure(nMeasure).LenArea+hMainGui.Values.PixSize/1000*norm([hMainGui.Measure(nMeasure).X(i+1)-hMainGui.Measure(nMeasure).X(i) hMainGui.Measure(nMeasure).Y(i+1)-hMainGui.Measure(nMeasure).Y(i)]);
                        XI=[XI linspace(hMainGui.Measure(nMeasure).X(i),hMainGui.Measure(nMeasure).X(i+1),ceil(len))];
                        YI=[YI linspace(hMainGui.Measure(nMeasure).Y(1),hMainGui.Measure(nMeasure).Y(i+1),ceil(len))];
                    end
                    ZI = interp2(double(Stack{idx(1)}(:,:,idx(2))),XI,YI);
                    hMainGui.Measure(nMeasure).Mean=mean(ZI);
                    hMainGui.Measure(nMeasure).STD=std(ZI);
                    hMainGui.Measure(nMeasure).Integral=sum(ZI);
                    hMainGui.Measure(nMeasure).Dim=1;
                    fRightPanel('UpdateMeasure',hMainGui);
                end

                 %create segmented line scan if segmented line scan is selected
                if (strcmp(hMainGui.CursorMode,'SegLineScan')==1)
                    hMainGui.Values.CursorDownPos(:)=0;
                    if ~isempty(findobj('Parent',hMainGui.MidPanel.aView,'-and','Tag','plotScan'))
                        delete(findobj('Parent',hMainGui.MidPanel.aView,'-and','Tag','plotScan'));
                    end             
                    setappdata(0,'hMainGui',hMainGui);
                    fRightPanel('NewScan',hMainGui);
                end

                %create polygon measure if polygon tool is selected
                if (strcmp(hMainGui.CursorMode,'Polygon')==1)
                    hMainGui.Measure(nMeasure).X=[hMainGui.Measure(nMeasure).X cp(1) hMainGui.Measure(nMeasure).X(1)];
                    hMainGui.Measure(nMeasure).Y=[hMainGui.Measure(nMeasure).Y cp(2) hMainGui.Measure(nMeasure).Y(1)];
                    color=hMainGui.RegionColor(mod(nMeasure-1,24)+1,:);
                    set(hMainGui.Plots.Measure(nMeasure),'Color',color,'UserData',nMeasure,'UIContextMenu',hMainGui.Menu.ctMeasure);
                    hMainGui.Values.CursorDownPos(:)=0;
                    hMainGui.Measure(nMeasure).Dim=2;  
                    Measure2D=1;
                end
            end
        end
    end
    if Measure2D
        Area=roipoly(y,x,hMainGui.Measure(nMeasure).X,hMainGui.Measure(nMeasure).Y);
        hMainGui.Measure(nMeasure).LenArea=sum(sum(Area))*hMainGui.Values.PixSize^2/1000^2;
        Image=double(Stack{idx(1)}(:,:,idx(2)));        
        hMainGui.Measure(nMeasure).Integral=sum(sum(double(Area).*double(Image)));
        hMainGui.Measure(nMeasure).Mean=mean2(Image(Area));
        hMainGui.Measure(nMeasure).STD=std2(Image(Area));
        fRightPanel('UpdateMeasure',hMainGui);
    end
end


function keypress(src,evnt) %#ok<INUSL>
global Queue;
hMainGui=getappdata(0,'hMainGui');
if ~strcmp(get(hMainGui.fig,'Pointer'),'watch')
    key = double(evnt.Character);
    xy=get(hMainGui.MidPanel.aView,{'xlim','ylim'});
    dx=xy{1}(2)-xy{1}(1);
    dy=xy{1}(2)-xy{1}(1);
    if xy{1}(2)~=1&&xy{2}(2)~=1&&~isempty(key)&&isempty(evnt.Modifier)
        switch(key)
            case 28
                xy{1}=xy{1}-dx*0.1;
            case 29
                xy{1}=xy{1}+dx*0.1;
            case 30
                xy{2}=xy{2}-dy*0.1;
            case 31
                xy{2}=xy{2}+dy*0.1;
            case 115
                hMainGui.CurrentKey = 's';  
            case {110,120}
                if length(hMainGui.Values.FrameIdx)>2
                    n = hMainGui.Values.FrameIdx(1)+1;
                else
                    n = 2;
                end
                idx = hMainGui.Values.FrameIdx(n)-(key-115)/5;
                if idx<1
                    hMainGui.Values.FrameIdx(n)=1;
                elseif idx>hMainGui.Values.MaxIdx(n)
                    hMainGui.Values.FrameIdx(n)=hMainGui.Values.MaxIdx(n);
                else
                    hMainGui.Values.FrameIdx(n)=idx;
                end
                set(hMainGui.MidPanel.eFrame,'String',int2str(hMainGui.Values.FrameIdx(n)));
                set(hMainGui.MidPanel.sFrame,'Value',hMainGui.Values.FrameIdx(n));
                setappdata(0,'hMainGui',hMainGui);
                fMidPanel('Update',hMainGui);            
        end
        Zoom=hMainGui.ZoomView;
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
        set(hMainGui.MidPanel.aView,{'xlim','ylim'},xy);
        hMainGui.ZoomView.currentXY=xy;

    end   
    if strcmp(evnt.Key,'shift')&&strcmp(hMainGui.CursorMode,'Normal')&&~strcmp(hMainGui.CurrentAxes,'none')
        CData=[NaN,NaN,NaN,NaN,NaN,NaN,NaN,1,1,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,1,1,NaN,1,2,2,1,1,1,NaN,NaN,NaN,NaN;NaN,NaN,1,2,2,1,1,2,2,1,2,2,1,NaN,NaN,NaN;NaN,NaN,1,2,2,1,1,2,2,1,2,2,1,NaN,1,NaN;NaN,NaN,NaN,1,2,2,1,2,2,1,2,2,1,1,2,1;NaN,NaN,NaN,1,2,2,1,2,2,1,2,2,1,2,2,1;NaN,1,1,NaN,1,2,2,2,2,2,2,2,1,2,2,1;1,2,2,1,1,2,2,2,2,2,2,2,2,2,2,1;1,2,2,2,1,2,2,2,2,2,2,2,2,2,1,NaN;NaN,1,2,2,2,2,2,2,2,2,2,2,2,2,1,NaN;NaN,NaN,1,2,2,2,2,2,2,2,2,2,2,2,1,NaN;NaN,NaN,1,2,2,2,2,2,2,2,2,2,2,1,NaN,NaN;NaN,NaN,NaN,1,2,2,2,2,2,2,2,2,2,1,NaN,NaN;NaN,NaN,NaN,NaN,1,2,2,2,2,2,2,2,1,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,1,2,2,2,2,2,2,1,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,1,2,2,2,2,2,2,1,NaN,NaN,NaN;];
        set(hMainGui.fig,'Pointer','custom','PointerShapeCData',CData,'PointerShapeHotSpot',[10 9]);   
        hMainGui.CursorMode='Pan';   
        hMainGui=DeleteSelectRegion(hMainGui);
    end
    if ~isempty(key)
        if key==127 || key==8
            if strcmp(get(hMainGui.RightPanel.pData.panel,'Visible'),'on') || strcmp(get(hMainGui.RightPanel.pTools.panel,'Visible'),'on')
                fShared('DeleteTracks',hMainGui,[],[]);
            elseif strcmp(get(hMainGui.RightPanel.pQueue.panel,'Visible'),'on')
                if ~isempty(Queue)
                    Selected=[Queue.Selected];
                    Queue(Selected==1)=[];
                    fRightPanel('UpdateQueue',hMainGui.RightPanel.pQueue.LocList,Queue,hMainGui.RightPanel.pQueue.sLocList,'Local');
                end
            end
        end
    end
    hMainGui.CurrentKey=get(hMainGui.fig,'CurrentKey');
    if ~isempty(evnt.Modifier)
        if ismac && ischar(evnt.Modifier{1})
            if strcmp(evnt.Modifier,'command')
                hMainGui.CurrentKey='control';
            elseif strcmp(evnt.Modifier,'control')
                fMsgDlg({'Control+Click functionality is disabled for the MAC,','use the command key to select tracks'},'warn');
                hMainGui.CurrentKey=[];
            end

        end
    end
    setappdata(0,'hMainGui',hMainGui);
end

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

function hMainGui=DeleteTrackInfo(hMainGui)
if ~isempty(hMainGui.Plots.TrackInfo)
    try
        delete(hMainGui.Plots.TrackInfo);
    catch
        delete(findobj(hMainGui.MidPanel.aView,'Tag','TrackInfo'));       
    end
    hMainGui.Plots.TrackInfo=[];
end
    
function keyrelease(src,evnt) %#ok<INUSL>
hMainGui=getappdata(0,'hMainGui');
if strcmp(evnt.Key,'shift')&&strcmp(hMainGui.CursorMode,'Pan')&&~strcmp(get(hMainGui.fig,'Pointer'),'watch')
    hMainGui.Values.CursorDownPos(:)=0;    
    hMainGui.CursorMode='Normal';
    set(hMainGui.fig,'pointer','arrow');
end
hMainGui.CurrentKey=[];
setappdata(0,'hMainGui',hMainGui);

function ResizeGUI(src,evnt) %#ok<INUSD>
global Stack;
if isempty(findobj('Tag','hExportViewGui'))
    hMainGui=getappdata(0,'hMainGui');
    try
        hMainGui.ZoomView.aspect = GetAxesAspectRatio(hMainGui.MidPanel.aView);
        hMainGui.ZoomKymo.aspect = GetAxesAspectRatio(hMainGui.MidPanel.aKymoGraph);
    catch
        return;
    end
    if ~isempty(Stack)
        y=size(Stack{1},1);
        x=size(Stack{1},2);
        if y/x >= hMainGui.ZoomView.aspect
            borders = ((y/hMainGui.ZoomView.aspect)-x)/2;
            hMainGui.ZoomView.globalXY = {[0.5-borders x+0.5+borders],[0.5 y+0.5]};
        else
            borders = ((x*hMainGui.ZoomView.aspect)-y)/2;
            hMainGui.ZoomView.globalXY = {[0.5 x+0.5],[0.5-borders y+0.5+borders]}; 
        end
        set(hMainGui.MidPanel.aView,{'xlim','ylim'},hMainGui.ZoomView.globalXY,'Visible','off'); 
        hMainGui.ZoomView.currentXY=hMainGui.ZoomView.globalXY;
        hMainGui.ZoomView.level=0;
        if ~isempty(hMainGui.KymoImage)
            [y,x,~]=size(hMainGui.KymoImage);
            if y/x >= hMainGui.ZoomKymo.aspect
                borders = ((y/hMainGui.ZoomKymo.aspect)-x)/2;
                hMainGui.ZoomKymo.globalXY = {[0.5-borders x+0.5+borders],[0.5 y+0.5]};
            else
                borders = ((x*hMainGui.ZoomKymo.aspect)-y)/2;
                hMainGui.ZoomKymo.globalXY = {[0.5 x+0.5],[0.5-borders y+0.5+borders]};
            end
            set(hMainGui.MidPanel.aKymoGraph,{'xlim','ylim'},hMainGui.ZoomKymo.globalXY,'Visible','off'); 
            hMainGui.ZoomKymo.currentXY=hMainGui.ZoomKymo.globalXY;
            hMainGui.ZoomKymo.level=0;
        end
    end
    setappdata(0,'hMainGui',hMainGui);
end

%{
function CheckKeyPress(src,evnt)
key = double(evnt.Character);
if isempty(key)
    keypress(src, evnt)
else
    if key~=13
         keypress(src, evnt)
    end
end

function CheckKeyRelease(src,evnt)
key = double(evnt.Character);
if isempty(key)
    keyrelease(src, evnt)
end

function UpdateSelectionType(hMainGui)
if strcmp(hMainGui.CurrentKey,'control')
    set(hMainGui.fig,'SelectionType','alt');
elseif strcmp(hMainGui.CurrentKey,'shift')
    set(hMainGui.fig,'SelectionType','extend');
else
    set(hMainGui.fig,'SelectionType','normal');
end
    %}
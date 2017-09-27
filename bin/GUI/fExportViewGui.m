function fExportViewGui(func,varargin)
switch func
    case 'Create'
        Create;
    case 'UpdateMoviePanel'
        UpdateMoviePanel(varargin{1});
    case 'UpdateView'
        UpdateView(varargin{1});
    case 'FirstFrame'
        FirstFrame(varargin{1});
    case 'LastFrame'
        LastFrame(varargin{1});        
    case 'BarSize'
        BarSize(varargin{1});        
    case 'Close'
        Close(varargin{1});               
    case 'Export'
        Export(varargin{1});   
    case 'SetRes'
        SetRes(varargin{1});           
end

function Create
global TimeInfo;
h=findobj('Tag','hExportViewGui');
close(h)

hMainGui = getappdata(0,'hMainGui');
if strcmp(get(hMainGui.ToolBar.ToolKymoGraph,'State'),'on')
    Image = get(hMainGui.KymoGraph,'CData');
    PixSize = get(hMainGui.KymoGraph,'UserData')*hMainGui.Values.PixSize;
    xy = hMainGui.ZoomKymo.currentXY;
    enable = 'off';
    hExportViewGui.PlotAxis = hMainGui.MidPanel.aKymoGraph;
    if size(Image,3)>1
        [~,k] = max(hMainGui.Values.MaxIdx);
        T = TimeInfo{k(1)-1}; 
    else
        T = TimeInfo{hMainGui.Values.FrameIdx(1)};   
    end
    T =  mean(T(2:end)-T(1:end-1))/1000;
    if T>0.01
        if T*size(Image,1)>=1000
            T = T/60;
            hExportViewGui.time_format = '%0.0fmin';
        else
            hExportViewGui.time_format = '%0.0fs';
        end
    else
        hExportViewGui.time_format = '%0.3fs';
    end
    hExportViewGui.PixTime = T;
else
    Image = get(hMainGui.Image,'CData');
    PixSize = hMainGui.Values.PixSize;
    xy = hMainGui.ZoomView.currentXY;
    enable = 'on';
    hExportViewGui.PlotAxis = hMainGui.MidPanel.aView;
    hExportViewGui.PixTime =[];
end
hExportViewGui.ImageXY = {[0.5 size(Image,2)],[0.5 size(Image,1)]};
x_total = xy{1}(2)-xy{1}(1);
if x_total > size(Image,2)
    x_total = size(Image,2);
end
y_total=xy{2}(2)-xy{2}(1); 
if y_total > size(Image,1)
    y_total = size(Image,1);
end 
hExportViewGui.currentXY = xy;
hExportViewGui.PixSize = PixSize;

hExportViewGui.fig = figure('Units','normalized','WindowStyle','normal','DockControls','off','IntegerHandle','off','MenuBar','none','Name','Export',...
                      'NumberTitle','off','Position',[0.65 0.15 0.35 0.7],'HandleVisibility','callback','Tag','hExportViewGui',...
                      'Visible','off','Resize','off');
                  
fPlaceFig(hExportViewGui.fig ,'export');

if ispc
    set(hExportViewGui.fig,'Color',[236 233 216]/255);
end

c = get(hExportViewGui.fig ,'Color');
                  
hExportViewGui.pRange = uibuttongroup('Parent',hExportViewGui.fig,'Units','normalized','Position',[0.05 0.81 0.9 0.175],...
                                  'Title','Range','Tag','tRange','FontSize',10,'SelectionChangeFcn',@RangeSelect,'BackgroundColor',c);                  
                                  
hExportViewGui.rCurrentView = uicontrol('Parent',hExportViewGui.pRange,'Units','normalized','Position',[0.05 0.65 0.6 0.25],'Enable','on','FontSize',10,...
                                   'String','Current View (TIFF/JPG)','Style','radiobutton','Tag','rCurrentView','HorizontalAlignment','left','BackgroundColor',c);
  

hExportViewGui.rWholeStack = uicontrol('Parent',hExportViewGui.pRange,'Units','normalized','Position',[0.05 0.35 0.6 0.25],'Enable',enable,'FontSize',10,...
                                    'String','Whole Stack (AVI)','Style','radiobutton','Tag','rWholeStack','HorizontalAlignment','left','BackgroundColor',c);  
                                
hExportViewGui.rSelection = uicontrol('Parent',hExportViewGui.pRange,'Units','normalized','Position',[0.05 0.05 0.5 0.25],'Enable',enable,'FontSize',10,...
                                    'String','Selection (AVI)','Style','radiobutton','Tag','rWholeStack','HorizontalAlignment','left','BackgroundColor',c);  

hExportViewGui.tResolution = uicontrol('Parent',hExportViewGui.pRange,'Units','normalized','Position',[0.61 0.825 0.29 0.15],'Enable','on','FontSize',10,...
                                'String','Resolution','Style','text','Tag','tResolution ','HorizontalAlignment','center','BackgroundColor',c);                 
                            
XRes=1280;
YRes=1280;
if x_total/y_total<1
    XRes=(1280*x_total/y_total);
end
if y_total/x_total<1
    YRes=(1280*y_total/x_total);
end

hExportViewGui.eXRes = uicontrol('Parent',hExportViewGui.pRange,'Units','normalized','Position',[0.56 0.55 0.15 0.275],'Enable','on','FontSize',10,...
                                'String',num2str(round(XRes)),'Style','edit','Tag','eXRes','HorizontalAlignment','center','BackgroundColor','white',...
                                'Callback','fExportViewGui(''SetRes'',getappdata(0,''hExportViewGui''));','UserData',y_total^2/x_total^2);         

hExportViewGui.tX = uicontrol('Parent',hExportViewGui.pRange,'Units','normalized','Position',[0.73 0.55 0.05 0.15],'Enable','on','FontSize',10,...
                                'String','x','Style','text','Tag','tX','HorizontalAlignment','center','BackgroundColor',c);                                                                                         
                            
hExportViewGui.eYRes = uicontrol('Parent',hExportViewGui.pRange,'Units','normalized','Position',[0.8 0.55 0.15 0.275],'Enable','on','FontSize',10,...
                                'String',num2str(round(YRes)),'Style','edit','Tag','eYRes','HorizontalAlignment','center',...
                                'BackgroundColor','white','Callback','fExportViewGui(''SetRes'',getappdata(0,''hExportViewGui''));','UserData',x_total^2/y_total^2);        
                            
hExportViewGui.tFrames = uicontrol('Parent',hExportViewGui.pRange,'Units','normalized','Position',[0.61 0.325 0.29 0.15],'Enable','off','FontSize',10,...
                                'String','Frames','Style','text','Tag','tFrames','HorizontalAlignment','center','BackgroundColor',c);                 
                            
hExportViewGui.eFirst = uicontrol('Parent',hExportViewGui.pRange,'Units','normalized','Position',[0.56 0.05 0.15 0.275],'Enable','off','FontSize',10,...
                                'String','1','Style','edit','Tag','eFirst','HorizontalAlignment','center','BackgroundColor','white',...
                                'Callback','fExportViewGui(''FirstFrame'',getappdata(0,''hExportViewGui''));');         

hExportViewGui.tTo = uicontrol('Parent',hExportViewGui.pRange,'Units','normalized','Position',[0.73 0.05 0.05 0.275],'Enable','off','FontSize',10,...
                                'String','-','Style','text','Tag','tTo','HorizontalAlignment','center','BackgroundColor',c);                                                                                         
  
idx = hMainGui.Values.FrameIdx(1);
if length(hMainGui.Values.MaxIdx)>2
    idx(2) = hMainGui.Values.MaxIdx(idx+1);
else
    idx(2) = hMainGui.Values.MaxIdx(2);
end
if strcmp(get(hMainGui.ToolBar.ToolChannels(5),'State'),'off')
    last=idx(2);
else
    last=max(hMainGui.Values.MaxIdx(2:end));
end

hExportViewGui.eLast = uicontrol('Parent',hExportViewGui.pRange,'Units','normalized','Position',[0.8 0.05 0.15 0.275],'Enable','off','FontSize',10,...
                                'String',num2str(last),'Style','edit','Tag','eLast','HorizontalAlignment','center',...
                                'BackgroundColor','white','Callback','fExportViewGui(''LastFrame'',getappdata(0,''hExportViewGui''));');                         
   
hExportViewGui.cRegion = uicontrol('Parent',hExportViewGui.fig,'Units','normalized','Position',[0.05 0.76 0.9 0.04],'Enable','off','FontSize',10,...
                                    'String','Use current region (last selected)','Style','checkbox','Tag','cRegion','HorizontalAlignment','left','BackgroundColor',c,...
                                    'Callback','fExportViewGui(''UpdateView'',getappdata(0,''hExportViewGui''));');  
                                
hExportViewGui.cScale = uicontrol('Parent',hExportViewGui.fig,'Units','normalized','Position',[0.05 0.71 0.2 0.04],'Enable','on','FontSize',10,...
                                    'String','Scale Bar','Style','checkbox','Tag','cScale','HorizontalAlignment','left','BackgroundColor',c,...
                                    'Callback','fExportViewGui(''UpdateView'',getappdata(0,''hExportViewGui''));');        

hExportViewGui.tPosBar = uicontrol('Parent',hExportViewGui.fig,'Units','normalized','Position',[0.45 0.7075 0.2 0.04],'Enable','off','FontSize',10,...
                                    'String','Position:','Style','text','Tag','tPosBar','HorizontalAlignment','left','BackgroundColor',c);                                      
                                
hExportViewGui.mPosBar = uicontrol('Parent',hExportViewGui.fig,'Units','normalized','Position',[0.65 0.71 0.3 0.04],'Enable','off','FontSize',10,...
                                    'String',{'top left','top right','bottom left','bottom right'},'Value',4,'Style','popupmenu','Tag','mPosBar',...
                                    'BackgroundColor','white','Callback','fExportViewGui(''UpdateView'',getappdata(0,''hExportViewGui''));');                
                                
hExportViewGui.tBarSize = uicontrol('Parent',hExportViewGui.fig,'Units','normalized','Position',[0.15 0.66 0.1 0.04],'Enable','off','FontSize',10,...
                                    'String','Size:','Style','text','Tag','tBarSize','BackgroundColor',c);     

BarSize=x_total*0.2*PixSize/1000;

if BarSize>5
   BarSize=round(BarSize/5)*5;
elseif BarSize>0.5
   BarSize=ceil(BarSize);
else
   BarSize=ceil(BarSize*10)/10;
end

hExportViewGui.eBarSize = uicontrol('Parent',hExportViewGui.fig,'Units','normalized','Position',[0.3 0.67 0.14 0.04],'Enable','off','FontSize',10,...
                                'String',num2str(BarSize),'Style','edit','Tag','eBarSize','BackgroundColor','white',...
                                'Callback','fExportViewGui(''BarSize'',getappdata(0,''hExportViewGui''));');     
                            
hExportViewGui.tUm = uicontrol('Parent',hExportViewGui.fig,'Units','normalized','Position',[0.45 0.66 0.05 0.04],'Enable','off','FontSize',10,...
                                    'String',[char(181) 'm'],'Style','text','Tag','tUm','HorizontalAlignment','left','BackgroundColor',c);                               
                                
hExportViewGui.cTime = uicontrol('Parent',hExportViewGui.fig,'Units','normalized','Position',[0.05 0.62 0.3 0.04],'Enable','off','FontSize',10,...
                                    'String','Time Stamp','Style','checkbox','Tag','cTime','HorizontalAlignment','left','BackgroundColor',c,...
                                    'Callback','fExportViewGui(''UpdateView'',getappdata(0,''hExportViewGui''));');        
                                
hExportViewGui.tPosTime = uicontrol('Parent',hExportViewGui.fig,'Units','normalized','Position',[0.45 0.6175 0.2 0.04],'Enable','off','FontSize',10,...
                                    'String','Position:','Style','text','Tag','tPosBar','HorizontalAlignment','left','BackgroundColor',c);                                      
                                
hExportViewGui.mPosTime = uicontrol('Parent',hExportViewGui.fig,'Units','normalized','Position',[0.65 0.62 0.3 0.04],'Enable','off','FontSize',10,...
                                    'String',{'top left','top right','bottom left','bottom right'},'Value',3,'Style','popupmenu','Tag','mPosBar',...
                                    'Callback','fExportViewGui(''UpdateView'',getappdata(0,''hExportViewGui''));','BackgroundColor','white');                                        
                                
hExportViewGui.cShowVisible = uicontrol('Parent',hExportViewGui.fig,'Units','normalized','Position',[0.05 0.56 0.5 0.04],'Enable','on','FontSize',10,...
                                    'String','Show Visible Tracks','Style','checkbox','Tag','cShowVisible','HorizontalAlignment','left','Value',1,'BackgroundColor',c,...
                                     'Callback','fExportViewGui(''UpdateView'',getappdata(0,''hExportViewGui''));');        
                                 
hExportViewGui.tLineWidthTracks = uicontrol('Parent',hExportViewGui.fig,'Units','normalized','Position',[0.6 0.55 0.2 0.04],'Enable','off','FontSize',10,...
                                    'String','Width (1-20):','Style','text','Tag','tLineWidthTracks','HorizontalAlignment','left','BackgroundColor',c);                                    

hExportViewGui.eLineWidthTracks = uicontrol('Parent',hExportViewGui.fig,'Units','normalized','Position',[0.8 0.56 0.15 0.04],'Enable','off','FontSize',10,...
                                'String','1','Style','edit','Tag','eLineWidthTracks','BackgroundColor','white',...
                                'Callback','fExportViewGui(''UpdateView'',getappdata(0,''hExportViewGui''));');  
                            
hExportViewGui.cMolMarker = uicontrol('Parent',hExportViewGui.fig,'Units','normalized','Position',[0.05 0.51 0.5 0.04],'Enable','on','FontSize',10,...
                                    'String','Show all Molecules ( + marker)','Style','checkbox','Tag','cMolMarker','HorizontalAlignment','left','BackgroundColor',c,...
                                    'Callback','fExportViewGui(''UpdateView'',getappdata(0,''hExportViewGui''));');        
                         
hExportViewGui.tMolMarkerSize = uicontrol('Parent',hExportViewGui.fig,'Units','normalized','Position',[0.6 0.50 0.2 0.04],'Enable','off','FontSize',10,...
                                    'String','Size (6-100):','Style','text','Tag','tMolMarkerSize','HorizontalAlignment','left','BackgroundColor',c);                                    

hExportViewGui.eMolMarkerSize = uicontrol('Parent',hExportViewGui.fig,'Units','normalized','Position',[0.8 0.51 0.15 0.04],'Enable','off','FontSize',10,...
                                'String','6','Style','edit','Tag','eMolMarkerSize','BackgroundColor','white',...
                                'Callback','fExportViewGui(''UpdateView'',getappdata(0,''hExportViewGui''));');  
                            
hExportViewGui.cFilMarker = uicontrol('Parent',hExportViewGui.fig,'Units','normalized','Position',[0.05 0.46 0.5 0.04],'Enable','on','FontSize',10,...
                                    'String','Show all Filaments ( x marker)','Style','checkbox','Tag','cFilMarker','HorizontalAlignment','left','BackgroundColor',c,...
                                    'Callback','fExportViewGui(''UpdateView'',getappdata(0,''hExportViewGui''));');    
                                
hExportViewGui.tFilMarkerSize = uicontrol('Parent',hExportViewGui.fig,'Units','normalized','Position',[0.6 0.4525 0.2 0.04],'Enable','off','FontSize',10,...
                                    'String','Size (6-100):','Style','text','Tag','tFilMarkerSize','HorizontalAlignment','left','BackgroundColor',c);                                    

hExportViewGui.eFilMarkerSize = uicontrol('Parent',hExportViewGui.fig,'Units','normalized','Position',[0.8 0.46 0.15 0.04],'Enable','off','FontSize',10,...
                                'String','6','Style','edit','Tag','eFilMarkerSize','BackgroundColor','white',...
                                'Callback','fExportViewGui(''UpdateView'',getappdata(0,''hExportViewGui''));');  
                                
hExportViewGui.cWholeFil = uicontrol('Parent',hExportViewGui.fig,'Units','normalized','Position',[0.05 0.41 0.5 0.04],'Enable','off','FontSize',10,...
                                    'String','Show Filament Positions','Style','checkbox','Tag','cWholeFil','HorizontalAlignment','left','BackgroundColor',c,...
                                    'Callback','fExportViewGui(''UpdateView'',getappdata(0,''hExportViewGui''));');
  
hExportViewGui.tLineWidthFil = uicontrol('Parent',hExportViewGui.fig,'Units','normalized','Position',[0.6 0.4 0.2 0.04],'Enable','off','FontSize',10,...
                                    'String','Width (1-20):','Style','text','Tag','tLineWidthFil','HorizontalAlignment','left','BackgroundColor',c);                                    

hExportViewGui.eLineWidthFil = uicontrol('Parent',hExportViewGui.fig,'Units','normalized','Position',[0.8 0.41 0.15 0.04],'Enable','off','FontSize',10,...
                                'String','1','Style','edit','Tag','eLineWidthFil','BackgroundColor','white',...
                                'Callback','fExportViewGui(''UpdateView'',getappdata(0,''hExportViewGui''));');  
                            
hExportViewGui.cAddArrow = uicontrol('Parent',hExportViewGui.fig,'Units','normalized','Position',[0.05 0.35 0.8 0.04],'Enable','on','FontSize',10,...
                                 'String','Add Arrow for Selected Tracks','Style','checkbox','Tag','cAddArrow ','HorizontalAlignment','left','BackgroundColor',c,...
                                 'Callback','fExportViewGui(''UpdateView'',getappdata(0,''hExportViewGui''));');   
                             
hExportViewGui.tArrowSize = uicontrol('Parent',hExportViewGui.fig,'Units','normalized','Position',[0.6 0.34 0.2 0.04],'Enable','off','FontSize',10,...
                                    'String','Size (1-10):','Style','text','Tag','tArrowSize','HorizontalAlignment','left','BackgroundColor',c);                                    

hExportViewGui.eArrowSize = uicontrol('Parent',hExportViewGui.fig,'Units','normalized','Position',[0.8 0.35 0.15 0.04],'Enable','off','FontSize',10,...
                                'String','2','Style','edit','Tag','eArrowSize','BackgroundColor','white',...
                                'Callback','fExportViewGui(''UpdateView'',getappdata(0,''hExportViewGui''));');                               
                                
hExportViewGui.cAddName = uicontrol('Parent',hExportViewGui.fig,'Units','normalized','Position',[0.1 0.3 0.7 0.04],'Enable','off','FontSize',10,...
                                'String','Add Name for Selected Tracks','Style','checkbox','Tag','cAddName','HorizontalAlignment','left','BackgroundColor',c,...
                                'Callback','fExportViewGui(''UpdateView'',getappdata(0,''hExportViewGui''));');    
                            
hExportViewGui.tNameSize = uicontrol('Parent',hExportViewGui.fig,'Units','normalized','Position',[0.6 0.29 0.2 0.04],'Enable','off','FontSize',10,...
                                    'String','Size (1-10):','Style','text','Tag','tArrowSize','HorizontalAlignment','left','BackgroundColor',c);                                    

hExportViewGui.eNameSize = uicontrol('Parent',hExportViewGui.fig,'Units','normalized','Position',[0.8 0.3 0.15 0.04],'Enable','off','FontSize',10,...
                                'String','2','Style','edit','Tag','eArrowSize','BackgroundColor','white',...
                                'Callback','fExportViewGui(''UpdateView'',getappdata(0,''hExportViewGui''));'); 
                       
hExportViewGui.pMovie = uipanel('Parent',hExportViewGui.fig,'Units','normalized','Position',[0.05 0.08 0.9 0.21],...
                            'Title','Movie','Tag','tMovie','FontSize',10,'BackgroundColor',c);          
  
hExportViewGui.tCompression = uicontrol('Parent',hExportViewGui.pMovie,'Units','normalized','Position',[0.05 0.705 0.3 0.2],'Enable','off','FontSize',10,...
                                    'String','Compression:','Style','text','Tag','tPosBar','HorizontalAlignment','left','BackgroundColor',c);                                      
                                
hExportViewGui.mCompression = uicontrol('Parent',hExportViewGui.pMovie,'Units','normalized','Position',[0.375 0.70 0.5 0.2],'Enable','off','FontSize',10,...
                                    'String',{'Uncompressed AVI','Motion JPEG AVI'},'Value',2,'Style','popupmenu','Tag','mPosBar',...
                                    'BackgroundColor','white','Callback','fExportViewGui(''UpdateMoviePanel'',getappdata(0,''hExportViewGui''));');         
                              
hExportViewGui.tFPS = uicontrol('Parent',hExportViewGui.pMovie,'Units','normalized','Position',[0.05 0.38 0.2 0.22],'Enable','off','FontSize',10,...
                                    'String','frames/s:','Style','text','Tag','tFPS','HorizontalAlignment','left','BackgroundColor',c);                                 

hExportViewGui.eFPS = uicontrol('Parent',hExportViewGui.pMovie,'Units','normalized','Position',[0.275 0.4 0.15 0.22],'Enable','off','FontSize',10,...
                                    'String','15','Style','edit','Tag','eFPS','BackgroundColor','white');                                                                         
                                
hExportViewGui.tQuality = uicontrol('Parent',hExportViewGui.pMovie,'Units','normalized','Position',[0.05 0.05 0.2 0.22],'Enable','on','FontSize',10,...
                                    'String','Quality:','Style','text','Tag','tQuality','HorizontalAlignment','left','BackgroundColor',c); 
    
hExportViewGui.sQuality = uicontrol('Parent',hExportViewGui.pMovie,'Units','normalized','Position',[0.275 0.05 0.5 0.22],'Enable','on',...
                                'min',1,'max',100,'Value',100,'SliderStep',[0.01 0.1],'Style','slider','Tag','sQuality','Callback','fExportViewGui(''UpdateMoviePanel'',getappdata(0,''hExportViewGui''));'); 
                                
hExportViewGui.eQuality = uicontrol('Parent',hExportViewGui.pMovie,'Units','normalized','Position',[0.8 0.05 0.15 0.22],'Enable','on','FontSize',10,...
                                    'String','100','Style','edit','Tag','eQuality ','BackgroundColor','white','Callback','fExportViewGui(''UpdateMoviePanel'',getappdata(0,''hExportViewGui''));');                                    
                              
hExportViewGui.bOK = uicontrol('Parent',hExportViewGui.fig,'Units','normalized','Position',[0.05 0.015 0.4 0.05],'Enable','on','FontSize',10,...
                                    'String','OK','Style','pushbutton','Tag','bOK','Callback','fExportViewGui(''Export'',getappdata(0,''hExportViewGui''));');

hExportViewGui.bCancel= uicontrol('Parent',hExportViewGui.fig,'Units','normalized','Position',[0.55 0.015 0.4 0.05],'Enable','on','FontSize',10,...
                              'String','Cancel','Style','pushbutton','Tag','bCancel','Callback','fExportViewGui(''Close'',getappdata(0,''hExportViewGui''));');                

set(hExportViewGui.fig,'CloseRequestFcn',@CloseExportGui);

hExportViewGui.Region = [];

hExportViewGui.Bar=rectangle('Parent',hMainGui.MidPanel.aView,'Position',CalcBar(hExportViewGui),'EdgeColor','none','FaceColor','white','Visible','off');

hExportViewGui.BarLabel=text('Parent',hMainGui.MidPanel.aView,'Position',CalcBarLabel(hExportViewGui),'HorizontalAlignment','center','Color','white',...
                         'String','','Visible','off','FontUnits','normalized','FontSize',0.04,'FontWeight','bold');
                     
hExportViewGui.TimeStamp=text('Parent',hMainGui.MidPanel.aView,'Position',CalcTimeStamp(hExportViewGui),'HorizontalAlignment','center','Color','white',...
                         'String',sprintf('%4.0f s',0),'Visible','off','FontUnits','normalized','FontSize',0.04,'FontWeight','bold');

hBackup=hMainGui;
hShow.cMolMarker=get(hMainGui.RightPanel.pData.cShowAllMol,'Value');
hShow.cFilMarker=get(hMainGui.RightPanel.pData.cShowAllFil,'Value');
hShow.cWholeFil=get(hMainGui.RightPanel.pData.cShowWholeFil,'Value');
set(hExportViewGui.cMolMarker,'Value',hShow.cMolMarker);
set(hExportViewGui.cFilMarker,'Value',hShow.cFilMarker);
set(hExportViewGui.cWholeFil,'Value',hShow.cWholeFil);
hExportViewGui.Arrows=[];
hExportViewGui.Names=[];
hExportViewGui.ResFactor=1;
if hShow.cFilMarker
    set(hExportViewGui.cWholeFil,'Enable','on');
end
setappdata(0,'hExportViewGui',hExportViewGui);
setappdata(hExportViewGui.fig,'hBackup',hBackup);
setappdata(hExportViewGui.fig,'hShow',hShow);
UpdateView(hExportViewGui);
drawnow;
delete(findobj('Tag','TrackInfo'));

function Close(hExportViewGui)
close(hExportViewGui.fig);

function CloseExportGui(hObject,evnt) %#ok<INUSD>
hExportViewGui=getappdata(0,'hExportViewGui');
hBackup=getappdata(hExportViewGui.fig,'hBackup');
hMainGui=getappdata(0,'hMainGui');
hShow=getappdata(hExportViewGui.fig,'hShow');
set(hMainGui.RightPanel.pData.cShowAllMol,'Value',hShow.cMolMarker);
set(hMainGui.RightPanel.pData.cShowAllFil,'Value',hShow.cFilMarker);
set(hMainGui.RightPanel.pData.cShowWholeFil,'Value',hShow.cWholeFil);
set(hMainGui.MidPanel.aView,'Units','normalized','Position',[0 0 1 1]);
set(findobj('Tag','pKymoTracks','-and','Type','line'),'LineWidth',1);
hMainGui=hBackup;
delete(hExportViewGui.fig);
delete(hExportViewGui.Bar);
delete(hExportViewGui.BarLabel);
delete(hExportViewGui.TimeStamp);
delete(hExportViewGui.Arrows);
delete(hExportViewGui.Names);
setappdata(0,'hMainGui',hMainGui);
fShow('Image');
fShow('Tracks');
                      
function RangeSelect(hObject,evnt)      %#ok<INUSD>
hExportViewGui=getappdata(0,'hExportViewGui');
hMainGui=getappdata(0,'hMainGui');
enable='off';
if get(hExportViewGui.rSelection,'Value')
    enable='on';
end
set(hExportViewGui.tFrames,'Enable',enable);
set(hExportViewGui.eFirst,'Enable',enable);
set(hExportViewGui.tTo,'Enable',enable);
set(hExportViewGui.eLast,'Enable',enable);
if get(hExportViewGui.rCurrentView,'Value')
    set(get(hExportViewGui.pMovie,'Children'),'Enable','off');
    set(get(hExportViewGui.pMovie,'Children'),'Enable','off');
    set(get(hExportViewGui.pMovie,'Children'),'Enable','off');
    hBackup=getappdata(hExportViewGui.fig,'hBackup');
    hMainGui.Values.FrameIdx=hBackup.Values.FrameIdx;
    enable='off';
else
    n = getChIdx;
    if get(hExportViewGui.rSelection,'Value')
        hMainGui.Values.FrameIdx(n)=str2double(get(hExportViewGui.eFirst,'String'));
    else
        hMainGui.Values.FrameIdx(n)=1;
    end
    UpdateMoviePanel(hExportViewGui);
    enable='on';
end
set(hExportViewGui.cTime,'Enable',enable);
setappdata(0,'hMainGui',hMainGui);
fShow('Image');
UpdateView(hExportViewGui);

function FirstFrame(hExportViewGui)
hMainGui=getappdata(0,'hMainGui');
idx=str2double(get(hExportViewGui.eFirst,'String'));
if ~isnan(idx)
    n = getChIdx;
    if idx>0&&idx<=hMainGui.Values.MaxIdx(n)
        hMainGui.Values.FrameIdx(n)=str2double(get(hExportViewGui.eFirst,'String'));
        setappdata(0,'hMainGui',hMainGui);
        fShow('Image');
        UpdateView(hExportViewGui);
    else
        set(hExportViewGui.eFirst,'String',1);
    end
else
    set(hExportViewGui.eFirst,'String',1);
end

function LastFrame(hExportViewGui) 
hMainGui=getappdata(0,'hMainGui');
idx=str2double(get(hExportViewGui.eLast,'String'));
n = getChIdx;
if ~isnan(idx)
    if idx<=0||idx>hMainGui.Values.MaxIdx(n)
        set(hExportViewGui.eLast,'String',hMainGui.Values.MaxIdx(n));
    end
else
    set(hExportViewGui.eLast,'String',hMainGui.Values.MaxIdx(n));
end

function SetRes(hExportViewGui) 
XRes=str2double(get(hExportViewGui.eXRes,'String'));
XFactor=get(hExportViewGui.eXRes,'UserData');
YRes=str2double(get(hExportViewGui.eYRes,'String'));
YFactor=get(hExportViewGui.eYRes,'UserData');
if gcbo==hExportViewGui.eXRes
    if ~isnan(XRes)
        if XRes<1
            set(hExportViewGui.eXRes,'String',num2str(round(YRes*YFactor)));
        end
    else
        set(hExportViewGui.eXRes,'String',num2str(round(YRes*YFactor)));
    end
    XRes=str2double(get(hExportViewGui.eXRes,'String'));
    set(hExportViewGui.eYRes,'String',num2str(round(XRes*XFactor)));
else
    if ~isnan(YRes)
        if YRes<1
            set(hExportViewGui.eYRes,'String',num2str(round(XRes*XFactor)));
        end
    else
        set(hExportViewGui.eYRes,'String',num2str(round(XRes*XFactor)));
    end
    YRes=str2double(get(hExportViewGui.eYRes,'String'));
    set(hExportViewGui.eXRes,'String',num2str(round(YRes*YFactor)));    
end
        
function UpdateMoviePanel(hExportViewGui)
set(hExportViewGui.tCompression,'Enable','on');
set(hExportViewGui.mCompression,'Enable','on');
set(hExportViewGui.tFPS,'Enable','on');
set(hExportViewGui.eFPS,'Enable','on');
if gcbo==hExportViewGui.mCompression
    index=get(gcbo,'Value');
    if index==1
        set(hExportViewGui.tQuality,'Enable','off');
        set(hExportViewGui.sQuality,'Enable','off');
        set(hExportViewGui.eQuality,'Enable','off');
    else
        set(hExportViewGui.tQuality,'Enable','on');
        set(hExportViewGui.sQuality,'Enable','on');
        set(hExportViewGui.eQuality,'Enable','on');
    end
elseif gcbo==hExportViewGui.sQuality
    set(hExportViewGui.eQuality,'String',num2str(round(get(gcbo,'Value'))));
    set(hExportViewGui.sQuality,'Value',round(get(gcbo,'Value')));
elseif gcbo==hExportViewGui.eQuality
    v = str2double(get(gcbo,'String'));
    if isnan(v) || v>100
        v=100;
    elseif v<1
        v=1;
    end
    set(hExportViewGui.eQuality,'String',num2str(round(v)));
    set(hExportViewGui.sQuality,'Value',round(v));           
end

function ShowVisible(Object,Visible)
if ~isempty(Object)
    Track=[Object.PlotHandles];
    set(Track(1,Visible==1),'Visible','on','LineStyle','-');
    set(Track(1,Visible==0),'Visible','off');
end

function UpdateView(hExportViewGui)
global Molecule;
global Filament;
global Objects;
global TimeInfo;
hMainGui=getappdata(0,'hMainGui');
set(hExportViewGui.cAddArrow,'Enable','off');    
if ~isempty(Molecule)
    if max([Molecule.Visible])==1
        set(hExportViewGui.cShowVisible,'Enable','on');    
    end
     if max([Molecule.Selected])==1
        set(hExportViewGui.cAddArrow,'Enable','on');             
     end
end
if ~isempty(Filament)
    if max([Filament.Visible])==1
        set(hExportViewGui.cShowVisible,'Enable','on');    
    end
     if max([Filament.Selected])==1
        set(hExportViewGui.cAddArrow,'Enable','on');                      
     end
end
if isempty(Molecule)&&isempty(Filament)
    set(hExportViewGui.cShowVisible,'Enable','off','Value',0);        
end
if isempty(Objects)
    set(hExportViewGui.cMolMarker,'Enable','off','Value',0);    
    set(hExportViewGui.cFilMarker,'Enable','off','Value',0);    
else
    set(hMainGui.RightPanel.pData.cShowAllMol,'Value',get(hExportViewGui.cMolMarker,'Value'));
    set(hMainGui.RightPanel.pData.cShowAllFil,'Value',get(hExportViewGui.cFilMarker,'Value'));
end
setappdata(0,'hMainGui',hMainGui);
fShow('Image');
hExportViewGui.Region = [];
if ~isempty(hMainGui.Region)
    set(hExportViewGui.cRegion,'Enable','on');
    if get(hExportViewGui.cRegion,'Value')
        hExportViewGui.Region = hMainGui.Region(end);
    end
end
if get(hExportViewGui.cShowVisible,'Value')
    ShowVisible(Molecule,[Molecule.Visible]);
    ShowVisible(Filament,[Filament.Visible]);    
    set(hExportViewGui.tLineWidthTracks,'Enable','on');
    set(hExportViewGui.eLineWidthTracks,'Enable','on');
    w = str2double(get(hExportViewGui.eLineWidthTracks,'String'));
    if ~isnan(w) && w>0 && w<21
        set(findobj('Tag','pTracks','-and','Type','line'),'LineWidth',w);
        set(findobj('Tag','pKymoTracks','-and','Type','line'),'LineWidth',w);
        set(findobj('Tag','pObjects','-and','Marker','.'),'MarkerSize',w*10);
    end
else
    ShowVisible(Molecule,zeros(1,length(Molecule)));
    ShowVisible(Filament,zeros(1,length(Filament)));
    delete(findobj('Tag','pObjects','-and','Marker','.'));
    delete(findobj('Tag','pObjects','-and','Marker','o'));    
    set(hExportViewGui.tLineWidthTracks,'Enable','off');
    set(hExportViewGui.eLineWidthTracks,'Enable','off');
end
if get(hExportViewGui.cMolMarker,'Value')
    set(hExportViewGui.tMolMarkerSize ,'Enable','on');
    set(hExportViewGui.eMolMarkerSize ,'Enable','on'); 
    w = str2double(get(hExportViewGui.eMolMarkerSize,'String'));
    if ~isnan(w) && w>5 && w<101
        set(findobj('Tag','pObjects','-and','Marker','+'),'MarkerSize',w,'LineWidth',ceil(w/20));
    end
else
    set(hExportViewGui.tMolMarkerSize ,'Enable','off');
    set(hExportViewGui.eMolMarkerSize ,'Enable','off');  
end
if get(hExportViewGui.cFilMarker,'Value')
    set(hExportViewGui.cWholeFil,'Enable','on');
    set(hMainGui.RightPanel.pData.cShowWholeFil,'Value',get(hExportViewGui.cWholeFil,'Value'));
    set(hExportViewGui.tFilMarkerSize ,'Enable','on');
    set(hExportViewGui.eFilMarkerSize ,'Enable','on');  
    w = str2double(get(hExportViewGui.eFilMarkerSize,'String'));
    if ~isnan(w) && w>5 && w<101
        set(findobj('Tag','pObjects','-and','Marker','x'),'MarkerSize',w,'LineWidth',0.5+w/12,'Visible','off');
    end
else 
    set(hExportViewGui.tFilMarkerSize ,'Enable','off');
    set(hExportViewGui.eFilMarkerSize ,'Enable','off');  
end
if get(hExportViewGui.cWholeFil,'Value')
    set(hExportViewGui.tLineWidthFil,'Enable','on');
    set(hExportViewGui.eLineWidthFil,'Enable','on');  
    w = str2double(get(hExportViewGui.eLineWidthFil,'String'));
    if ~isnan(w) && w>0 && w<21
        set(findobj('Tag','pObjects','-and','Type','line','-and','Color','red'),'LineWidth',w);
    end
else
    set(hExportViewGui.tLineWidthFil,'Enable','off');
    set(hExportViewGui.eLineWidthFil,'Enable','off');
end
if get(hExportViewGui.cScale,'Value')
    delete(hExportViewGui.Bar);
    delete(hExportViewGui.BarLabel);
    BarSize = str2double(get(hExportViewGui.eBarSize,'String'));
    
    
    hExportViewGui.Bar=rectangle('Parent',hExportViewGui.PlotAxis,'Position',CalcBar(hExportViewGui),'EdgeColor','none','FaceColor','white','Visible','on');
    
    pos = CalcBarLabel(hExportViewGui);
    if pos(2)>0
        align = 'cap';
    else
        align = 'baseline';
    end
    hExportViewGui.BarLabel=text('Parent',hExportViewGui.PlotAxis,'Position',abs(pos(1:2)),'HorizontalAlignment','center','VerticalAlignment',align,'Color','white',...
                                 'String',[num2str(BarSize)  char(181) 'm'],'Visible','on','FontWeight','bold','FontUnits','points','FontSize',pos(3)*40,'FontName','Arial');                  
    if ~isempty(hExportViewGui.PixTime)
        TimeBar = str2double(sprintf(hExportViewGui.time_format(1:5),BarSize*1000/hExportViewGui.PixSize*hExportViewGui.PixTime));
        hExportViewGui.Bar(2)=rectangle('Parent',hExportViewGui.PlotAxis,'Position',CalcBar(hExportViewGui,TimeBar),'EdgeColor','none','FaceColor','white','Visible','on');
        pos = CalcBarLabel(hExportViewGui,TimeBar);
        if pos(1)>0
            align = 'cap';
        else
            align = 'baseline';
        end
        hExportViewGui.BarLabel(2)=text('Parent',hExportViewGui.PlotAxis,'Position',abs(pos),'HorizontalAlignment','center','VerticalAlignment',align,'Color','white','Rotation',90,...
                                        'String',sprintf(hExportViewGui.time_format,TimeBar),'Visible','on','FontWeight','bold','FontUnits','points','FontSize',pos(3)*40,'FontName','Arial');                 
    end
    set(hExportViewGui.tPosBar,'Enable','on');
    set(hExportViewGui.mPosBar,'Enable','on');
    set(hExportViewGui.tBarSize,'Enable','on');
    set(hExportViewGui.eBarSize,'Enable','on');    
    set(hExportViewGui.tUm,'Enable','on');    
else
    set(hExportViewGui.Bar,'Visible','off');
    set(hExportViewGui.BarLabel,'Visible','off');    
    set(hExportViewGui.tPosBar,'Enable','off');
    set(hExportViewGui.mPosBar,'Enable','off');
    set(hExportViewGui.tBarSize,'Enable','off');
    set(hExportViewGui.eBarSize,'Enable','off');        
    set(hExportViewGui.tUm,'Enable','off');      
end
if get(hExportViewGui.cTime,'Value')&&strcmp(get(hExportViewGui.cTime,'Enable'),'on')&&~get(hExportViewGui.rCurrentView,'Value')
    if get(hExportViewGui.mPosTime,'Value')==get(hExportViewGui.mPosBar,'Value')
        if get(hExportViewGui.mPosTime,'Value')==1||get(hExportViewGui.mPosTime,'Value')==3
            set(hExportViewGui.mPosTime,'Value',get(hExportViewGui.mPosTime,'Value')+1);
        else
            set(hExportViewGui.mPosTime,'Value',get(hExportViewGui.mPosTime,'Value')-1);            
        end
    end
    first=1;
    if get(hExportViewGui.rSelection,'Value')    
        first=str2double(get(hExportViewGui.eFirst,'String'));
    end
    idx = getFrameIdx(hMainGui);
    idx(1) = min([idx(1) length(TimeInfo)]);
    time=(TimeInfo{idx(1)}(idx(2))-TimeInfo{idx(1)}(first))/1000;
    if mean(TimeInfo{idx(1)}(2:end)-TimeInfo{idx(1)}(1:end-1))>10
        if TimeInfo{idx(1)}(end)-TimeInfo{idx(1)}(1)>=1000000
            time=time/60;
            time_format = '%4.0f min';
        else
            time_format = '%4.0f s';
        end
    else
        time_format = '%5.3f s';
    end
    delete(hExportViewGui.TimeStamp);
    pos = CalcTimeStamp(hExportViewGui);
    
    hExportViewGui.TimeStamp=text('Parent',hMainGui.MidPanel.aView,'Position',pos(1:2),'HorizontalAlignment','center','Color','white',...
                            'String',sprintf(time_format,time),'Visible','on','FontWeight','bold','FontUnits','points','FontSize',pos(3)*50,'FontName','Arial');
    set(hExportViewGui.tPosTime,'Enable','on');
    set(hExportViewGui.mPosTime,'Enable','on');    
else
    set(hExportViewGui.TimeStamp,'Visible','off');
    set(hExportViewGui.tPosTime,'Enable','off');
    set(hExportViewGui.mPosTime,'Enable','off');        
end
if get(hExportViewGui.cAddArrow,'Value')
    set(hExportViewGui.cAddName,'Enable','on');     
    set(hExportViewGui.tArrowSize,'Enable','on');
    set(hExportViewGui.eArrowSize,'Enable','on');
    AddArrow(hExportViewGui,hMainGui);
    hExportViewGui=getappdata(0,'hExportViewGui');
    if get(hExportViewGui.cAddName,'Value')
        set(hExportViewGui.tNameSize,'Enable','on');
        set(hExportViewGui.eNameSize,'Enable','on');
    else
        set(hExportViewGui.tNameSize,'Enable','off');
        set(hExportViewGui.eNameSize,'Enable','off');    
    end
else
    set(hExportViewGui.cAddName,'Enable','off');  
    set(hExportViewGui.tArrowSize,'Enable','off');
    set(hExportViewGui.eArrowSize,'Enable','off');
    set(hExportViewGui.tNameSize,'Enable','off');
    set(hExportViewGui.eNameSize,'Enable','off');
    delete(hExportViewGui.Arrows);
    hExportViewGui.Arrows=[];
    delete(hExportViewGui.Names);
    hExportViewGui.Names=[];
end
setappdata(0,'hExportViewGui',hExportViewGui);

function BarSize(hExportViewGui)
value = str2double(get(hExportViewGui.eBarSize,'String'));
PixSize = hExportViewGui.PixSize;
xy = hExportViewGui.currentXY;
x_total = xy{1}(2)-xy{1}(1);
if value <= 0 || value > x_total * 0.5 * PixSize / 1000
    value = x_total*0.2*PixSize/1000;
    if value>5
        value = round(value/5)*5;
    else
        value = ceil(value);
    end        
end
set(hExportViewGui.eBarSize,'String',num2str(value));
UpdateView(hExportViewGui);

function position=CalcBar(varargin)          
hExportViewGui = varargin{1};
PixSize = hExportViewGui.PixSize;
xy = hExportViewGui.currentXY;
if ~isempty(hExportViewGui.Region)&&nargin==1
    ImageXY{1} = [min(hExportViewGui.Region.X) max(hExportViewGui.Region.X)];
    ImageXY{2} = [min(hExportViewGui.Region.Y) max(hExportViewGui.Region.Y)];
else
    ImageXY = hExportViewGui.ImageXY;
end
borders = {[max([xy{1}(1) ImageXY{1}(1)]) min([xy{1}(2) ImageXY{1}(2)])],[max([xy{2}(1) ImageXY{2}(1)]) min([xy{2}(2) ImageXY{2}(2)])]};
x_total=borders{1}(2)-borders{1}(1);
y_total=borders{2}(2)-borders{2}(1); 
s = max([x_total y_total]);
if nargin==1
    width=str2double(get(hExportViewGui.eBarSize,'String'))*1000/PixSize;
    height=0.025*s;
    if get(hExportViewGui.mPosBar,'Value')==1||get(hExportViewGui.mPosBar,'Value')==3
        x=borders{1}(1)+0.05*s;
    else
        x=borders{1}(2)-0.05*s-width;
    end
    if get(hExportViewGui.mPosBar,'Value')==1||get(hExportViewGui.mPosBar,'Value')==2
        y=borders{2}(1)+0.05*s;
    else
        y=borders{2}(2)-0.05*s-height;
    end          
    position=[x y width height];
else
    width=0.025*s;
    height=varargin{2}/hExportViewGui.PixTime;
    if get(hExportViewGui.mPosBar,'Value')==1||get(hExportViewGui.mPosBar,'Value')==3
        x=borders{1}(1)+0.05*s;
    else
        x=borders{1}(2)-0.05*s-width;
    end
    if get(hExportViewGui.mPosBar,'Value')==1||get(hExportViewGui.mPosBar,'Value')==2
        y=borders{2}(1)+0.05*s;
    else
        y=borders{2}(2)-0.05*s-height;
    end          
    position=[x y width height];
end

function pos = CalcBarLabel(varargin)     
hExportViewGui = varargin{1};
PixSize = hExportViewGui.PixSize;
xy = hExportViewGui.currentXY;
x_total=xy{1}(2)-xy{1}(1);
y_total=xy{2}(2)-xy{2}(1); 
st = max([x_total y_total]);
if ~isempty(hExportViewGui.Region)&&nargin==1
    ImageXY{1} = [min(hExportViewGui.Region.X) max(hExportViewGui.Region.X)];
    ImageXY{2} = [min(hExportViewGui.Region.Y) max(hExportViewGui.Region.Y)];
else
    ImageXY = hExportViewGui.ImageXY;
end
borders = {[max([xy{1}(1) ImageXY{1}(1)]) min([xy{1}(2) ImageXY{1}(2)])],[max([xy{2}(1) ImageXY{2}(1)]) min([xy{2}(2) ImageXY{2}(2)])]};
x_total=borders{1}(2)-borders{1}(1);
y_total=borders{2}(2)-borders{2}(1); 
s = max([x_total y_total]);
if nargin==1
    width = str2double(get(hExportViewGui.eBarSize,'String'))*1000/PixSize;
    height = 0.04*s;
    if get(hExportViewGui.mPosBar,'Value')==1||get(hExportViewGui.mPosBar,'Value')==3
        x=borders{1}(1)+0.05*s+width/2;
    else
        x=borders{1}(2)-0.05*s-width/2;
    end
    if get(hExportViewGui.mPosBar,'Value')==1||get(hExportViewGui.mPosBar,'Value')==2
        y=borders{2}(1)+0.05*s+height;
    else
        y=-(borders{2}(2)-0.05*s-height);
    end          
    pos=[x y s/st];
else
    width=0.04*s;
    height=varargin{2}/hExportViewGui.PixTime;
    if get(hExportViewGui.mPosBar,'Value')==1||get(hExportViewGui.mPosBar,'Value')==3
        x = borders{1}(1)+0.05*s+width;
    else
        x = -(borders{1}(2)-0.05*s-width);
    end
    if get(hExportViewGui.mPosBar,'Value')==1||get(hExportViewGui.mPosBar,'Value')==2
        y=borders{2}(1)+0.06*s+height/2;
    else
        y=borders{2}(2)-0.06*s-height/2;
    end          
    pos=[x y s/st];
end

function position=CalcTimeStamp(hExportViewGui)  
xy = hExportViewGui.currentXY;
x_total=xy{1}(2)-xy{1}(1);
y_total=xy{2}(2)-xy{2}(1); 
st = max([x_total y_total]);
if ~isempty(hExportViewGui.Region)
    ImageXY{1} = [min(hExportViewGui.Region.X) max(hExportViewGui.Region.X)];
    ImageXY{2} = [min(hExportViewGui.Region.Y) max(hExportViewGui.Region.Y)];
else
    ImageXY = hExportViewGui.ImageXY;
end
borders = {[max([xy{1}(1) ImageXY{1}(1)]) min([xy{1}(2) ImageXY{1}(2)])],[max([xy{2}(1) ImageXY{2}(1)]) min([xy{2}(2) ImageXY{2}(2)])]};
x_total=borders{1}(2)-borders{1}(1);
y_total=borders{2}(2)-borders{2}(1); 
s = max([x_total y_total]);

if get(hExportViewGui.mPosTime,'Value')==1||get(hExportViewGui.mPosTime,'Value')==3
    x=borders{1}(1)+0.10*s;
else
    x=borders{1}(2)-0.10*s;
end
if get(hExportViewGui.mPosTime,'Value')==1||get(hExportViewGui.mPosTime,'Value')==2
    y=borders{2}(1)+0.075*s;
else
    y=borders{2}(2)-0.075*s;
end          
position=[x y s/st];

function AddArrow(hExportViewGui,hMainGui)
global Molecule;
global Filament;
xy=get(hMainGui.MidPanel.aView,{'XLim','YLim'});
pos=get(hMainGui.MidPanel.aView,'Position');
x_total=xy{1}(2)-xy{1}(1);
y_total=xy{2}(2)-xy{2}(1);
if ~isempty(hExportViewGui.Arrows)
    delete(hExportViewGui.Arrows);
    hExportViewGui.Arrows=[];
end
MapMol=struct('Name',{},'PosX',{},'PosY',{},'OrientationX',{},'OrientationY',{});
MapFil=struct('Name',{},'PosX',{},'PosY',{},'OrientationX',{},'OrientationY',{});
if ~isempty(Molecule)
    k=find([Molecule.Selected]==1);
    if ~isempty(k)
        MapMol=CreateMap(Molecule(k),hMainGui);
    end
end
if  ~isempty(Filament)
    k=find([Filament.Selected]==1);
    if ~isempty(k)
        MapFil=CreateMap(Filament(k),hMainGui);
    end
end
Map=[MapMol MapFil];
X=[Map.PosX];
Y=[Map.PosY];
U=mean([Map.OrientationX])*ones(size(X));
V=mean([Map.OrientationY])*ones(size(Y));
O=x_total*0.005/pos(3)+y_total*0.005/pos(4);
S=x_total*0.02/pos(3)+y_total*0.02/pos(4);
X1 = X + U*(O+S);
Y1 = Y + V*(O+S);
X2 = X - U*(O+S);
Y2 = Y - V*(O+S);
for n=1:length(Map)
    if (X1(n)-xy{1}(1))<0.2*x_total || (xy{1}(2)-X1(n))<0.2*x_total || (X2(n)-xy{1}(1))<0.2*x_total || (xy{1}(2)-X2(n))<0.2*x_total
        [~,c]=min([X1(n)-xy{1}(1) xy{1}(2)-X1(n) X2(n)-xy{1}(1) xy{1}(2)-X2(n)]); 
        if c<3
            U(n)=-U(n);
            V(n)=-V(n);
        end
    elseif (Y1(n)-xy{2}(1))<0.1*y_total || (xy{2}(2)-Y1(n))<0.1*y_total || (Y2(n)-xy{2}(1))<0.1*y_total || (xy{2}(2)-Y2(n))<0.1*y_total
        [~,c]=min([Y1(n)-xy{2}(1) xy{2}(2)-Y1(n) Y2(n)-xy{2}(1) xy{2}(2)-Y2(n)]); 
        if c<3
            U(n)=-U(n);
            V(n)=-V(n);
        end
    else
        t=1:length(Map);
        t(n)=[];
        m1=min(sqrt( (X(t)-X1(n)).^2 + (Y(t)-Y1(n)).^2));
        m2=min(sqrt( (X(t)-X2(n)).^2 + (Y(t)-Y2(n)).^2));
        if m2>m1
            U(n)=-U(n);
            V(n)=-V(n);
        end
    end
    
end
w = str2double(get(hExportViewGui.eArrowSize,'String'));
if isnan(w) || w<1  || w>10
    w = 2;
end 
hExportViewGui.Arrows=PlotArrows(hMainGui.MidPanel.aView,X,Y,U,V,O,S,w);
if ~isempty(hExportViewGui.Names)
    delete(hExportViewGui.Names);
    hExportViewGui.Names=[];
end
if get(hExportViewGui.cAddName,'Value')
    f = str2double(get(hExportViewGui.eNameSize,'String'));
    if isnan(f) || f<1  || f>10
        f = 2;
    end 
    hExportViewGui.Names=PlotNames(hMainGui.MidPanel.aView,Map,X,Y,U,V,O,S,w,f);
end
setappdata(0,'hExportViewGui',hExportViewGui);
    
function Map=CreateMap(Object,hMainGui)
PixSize=hMainGui.Values.PixSize;
Map=struct('Name',{},'PosX',{},'PosY',{},'OrientationX',{},'OrientationY',{});
t=1;
for n=1:length(Object)
    idx = min([Object(n).Channel+1 length(hMainGui.Values.FrameIdx)]);
    if hMainGui.Values.FrameIdx(idx)<0
        k=ceil(size(Object(n).Results,1)/2);
    else
        k=find(Object(n).Results(:,1)==hMainGui.Values.FrameIdx(idx));
    end
    if ~isempty(k)
        Map(t).Name=Object(n).Name;
        Map(t).PosX=Object(n).Results(k,3)/PixSize;
        Map(t).PosY=Object(n).Results(k,4)/PixSize;
        if size(Object(n).Results,1)>1000
            first=k-50;
            last=k+50;
            if first<1
                first=1;
                last=51;
            end
            if last>size(Object(n).Results,1);
                first=size(Object(n).Results,1)-50;
                last=size(Object(n).Results,1);
            end
        end
        if hMainGui.Values.FrameIdx(idx)<0 || size(Object(n).Results,1)<1001
            first=1;
            last=size(Object(n).Results,1);
        end
        p=1;
        v=[];
        for m=first:last
            if m~=k
                v(p,:)=(m-k)*[(Object(n).Results(m,4)-Object(n).Results(k,4)) -(Object(n).Results(m,3)-Object(n).Results(k,3))];
                p=p+1;
            end
        end
        U=mean(v(:,1));
        V=mean(v(:,2));
        Map(t).OrientationX=U/norm([U V]);
        Map(t).OrientationY=V/norm([U V]);
        
        t=t+1;
    end
end
   
function h = PlotArrows(parent,xi,yi,u,v,o,s,w)
h=[];
xf = xi + u*(o+w*s/2);
yf = yi + v*(o+w*s/2);
xi = xi + u*o;
yi = yi + v*o;
for n=1:length(xi)
    h(n) = arrow(parent,xf(n),yf(n),xi(n),yi(n),w);
end

function h = arrow(parent,x1,y1,x2,y2,w)
alpha       = 0.6;   % head length
beta        = 0.4;   % head width
den         = x2 - x1 + eps;                                
teta        = atan( (y2-y1)/den ) + pi*(x2<x1) - pi/2;      
cs          = cos(teta);                                    
ss          = sin(teta);
R           = [cs -ss;ss cs];
line_length = sqrt( (y2-y1)^2 + (x2-x1)^2 );               
head_length = line_length*alpha;
head_width  = line_length*beta;
x0          = x2*cs + y2*ss;                                
y0          = -x2*ss + y2*cs;
coords      = R*[x0+head_width/2 x0 x0-head_width/2; y0-head_length y0-head_length y0-head_length];
x_coords    = [x2 coords(1,1:2) x1 coords(1,2:3)];
y_coords    = [y2 coords(2,1:2) y1 coords(2,2:3)];
h           = patch( x_coords,y_coords,zeros(1,6),'Parent',parent,'EdgeColor','white','Facecolor','white','LineWidth',w);

function h = PlotNames(parent,Map,xi,yi,u,v,o,s,w,f)
h=[];
xf = xi + u*(o+w*s/2);
yf = yi + v*(o+w*s/2);
for n=1:length(Map)
    if v(n)<-0.4
        vert='bottom';
    elseif v(n)>0.4
        vert='top';
    else
        vert='middle';
    end
    if u(n)<-0.4
        horz='right';
    elseif u(n)>0.4
        horz='left';
        if v(n)>=-0.4&&v(n)<=0.4
            xf(n)=xf(n)+0.1*o;
        end
    else
        horz='center';
    end
    h(n) = text(double(xf(n)),double(yf(n)),Map(n).Name,'Parent',parent,'VerticalAlignment',vert,'HorizontalAlignment',horz,'Color','white',...
                                                                      'FontUnits','normalized','FontSize',0.01+f*0.004,'FontWeight','bold');
end

function Export(hExportViewGui)
hMainGui=getappdata(0,'hMainGui');
set(hMainGui.fig,'Pointer','watch');
XRes=str2double(get(hExportViewGui.eXRes,'String'));            
YRes=str2double(get(hExportViewGui.eYRes,'String'));            
R=max([XRes YRes]);
if get(hExportViewGui.rCurrentView,'Value')
    [FileName,PathName,FilterIndex] = uiputfile({'*.tif','TIFF-File (*.tif)';'*.jpg','JPEG-File (*.jpg)'},'Export Image',fShared('GetSaveDir'));
    if FileName~=0
        fShared('SetSaveDir',PathName);
        fShow('Image');
        UpdateView(hExportViewGui);
        hExportViewGui=getappdata(0,'hExportViewGui');
        I = GetImage(hMainGui);
        [y,x,~] = size(I);
        if y<x
            YRes = XRes*y/x;
        else
            XRes = YRes*x/y;
        end
        I = imresize(I, [YRes XRes], 'bilinear');
        file = [PathName FileName];
        if FilterIndex==2
            if isempty(findstr('.jpg',FileName))
                file = [file '.jpg'];
            end
            imwrite(I,file,'Quality',100);
        elseif FilterIndex==1
            if isempty(findstr('.tif',FileName))
                file = [file '.tif'];
            end
            imwrite(I,file,'Compression','none');
        end
        close(hExportViewGui.fig);
    end
else
    [FileName,PathName] = uiputfile({'*.avi','AVI-File (*.avi)'},'Export Movie',fShared('GetSaveDir'));
    if FileName~=0
        fShared('SetSaveDir',PathName);
        file = [PathName FileName];
        if isempty(findstr('.avi',FileName))
            file = [file '.avi'];
        end
        if get(hExportViewGui.rWholeStack,'Value')
            first=1;
            idx = hMainGui.Values.FrameIdx(1);
            if length(hMainGui.Values.MaxIdx)>2
                idx(2) = hMainGui.Values.MaxIdx(idx+1);
            else
                idx(2) = hMainGui.Values.MaxIdx(2);
            end
            if strcmp(get(hMainGui.ToolBar.ToolChannels(5),'State'),'off')
                last=idx(2);
            else
                last=max(hMainGui.Values.MaxIdx(2:end));
            end
        else
            first=str2double(get(hExportViewGui.eFirst,'String'));
            last=str2double(get(hExportViewGui.eLast,'String'));            
        end
        fps=str2double(get(hExportViewGui.eFPS,'String'));            
        if ~isnan(first)&&~isnan(last)&&~isnan(fps)
            if fps>15
                step=round(fps/15);
                fps=round(fps/step);
            else
                step=1;
            end
            p=1;
            progressdlg('String','Exporting Stack to Movie','Min',0,'Max',last,'Parent',hMainGui.fig,'windowstyle','modal');
            if get(hExportViewGui.mCompression,'Value')==1
                vidObj = VideoWriter(file,'Uncompressed AVI'); 
            else    
                vidObj = VideoWriter(file,'Motion JPEG AVI'); 
                vidObj.Quality = get(hExportViewGui.sQuality,'Value');
            end
            vidObj.FrameRate = fps;
            open(vidObj);
            nCh = getChIdx;
            for n=first:step:last
                hMainGui.Values.FrameIdx(nCh)=n;
                setappdata(0,'hMainGui',hMainGui);
                fShow('Image');
                UpdateView(hExportViewGui);
                hExportViewGui = getappdata(0,'hExportViewGui');
                I = GetImage(hMainGui);
                [y,x,~] = size(I);
                if y<x
                    YRes = XRes*y/x;
                else
                    XRes = YRes*x/y;
                end
                I = imresize(I, [YRes XRes], 'bilinear');
                writeVideo(vidObj,I);
                p=p+1;
                progressdlg(n);
            end
            close(vidObj);
            close(hExportViewGui.fig);
            set(hMainGui.fig,'Pointer','arrow');
        end
    end
end
progressdlg('close');
set(hMainGui.fig,'Pointer','arrow');

function I = GetImage(hMainGui)
hExportViewGui = getappdata(0,'hExportViewGui');
set(hMainGui.fig, 'PaperPositionMode', 'auto');
Frame = getframe(hExportViewGui.PlotAxis);
I = Frame.cdata;
[y,x,~] = size(I);
xy = hExportViewGui.currentXY;
if ~isempty(hExportViewGui.Region)
    ImageXY{1} = [min(hExportViewGui.Region.X) max(hExportViewGui.Region.X)];
    ImageXY{2} = [min(hExportViewGui.Region.Y) max(hExportViewGui.Region.Y)];
else
    ImageXY = hExportViewGui.ImageXY;
end
lx = xy{1}(2)-xy{1}(1);
ly = xy{2}(2)-xy{2}(1);
if xy{1}(1)<ImageXY{1}(1)
    xpos(1) = ceil((ImageXY{1}(1)-xy{1}(1))/lx*x);
else
    xpos(1) = 1;
end
if xy{1}(2)>ImageXY{1}(2)
    xpos(2) = fix(x-(xy{1}(2)-ImageXY{1}(2))/lx*x);
else
    xpos(2) = x;
end
if xy{2}(1)<ImageXY{2}(1)
    ypos(1) = ceil((ImageXY{2}(1)-xy{2}(1))/ly*y);
else
    ypos(1) = 1;
end
if xy{2}(2)>ImageXY{2}(2)
    ypos(2) = fix(y-(xy{2}(2)-ImageXY{2}(2))/ly*y);
else
    ypos(2) = y;
end
I = I(ypos(1)+4:ypos(2)-1,xpos(1)+1:xpos(2)-4,:);
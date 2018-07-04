function fExportDataGui(func,varargin)
switch func
    case 'Create'
        Create(varargin{1},varargin{2});
    case 'UpdateDataPanel'
        UpdateDataPanel(varargin{1});
    case 'SelectFormat'
        SelectFormat(varargin{1});           
    case 'SelectFolder'
        SelectFolder(varargin{1});                   
    case 'AddPlot'
        AddPlot(varargin{1});        
    case 'RemovePlot'
        RemovePlot(varargin{1});        
    case 'Preview'
        Preview(varargin{1});           
    case 'Export'
        Export(varargin{1});           
    case 'Cancel'
        Close(varargin{1});               
    case 'XAxisList'
        XAxisList(varargin{1});        
    case 'CheckYAxis2'
        CheckYAxis2(varargin{1});          
end

function Create(Type,idx)

[lXaxis,lYaxis]=CreatePlotList(Type);

hExportDataGui.idx=idx;
hExportDataGui.Type=Type;

h=findobj('Tag','hExportDataGui');
close(h)

hExportDataGui.fig = figure('Units','normalized','WindowStyle','modal','DockControls','off','IntegerHandle','off','MenuBar','none','Name','Export Data',...
                      'NumberTitle','off','Position',[0.7 0.25 0.25 0.5],'HandleVisibility','callback','Tag','hExportDataGui',...
                      'Visible','off','Resize','off','CloseRequestFcn',@CloseFcn);
                  
fPlaceFig(hExportDataGui.fig ,'export');

if ispc
    set(hExportDataGui.fig,'Color',[236 233 216]/255);
end

c = get(hExportDataGui.fig ,'Color');
                                             
hExportDataGui.pPlotSelection = uibuttongroup('Parent',hExportDataGui.fig,'Units','normalized','Position',[0.05 0.7 0.425 0.25],'BackgroundColor',c);

hExportDataGui.rCurrentView = uicontrol('Parent',hExportDataGui.pPlotSelection,'Units','normalized','Position',[0.05 0.675 0.9 0.3],'Enable','on','FontSize',10,...
                                       'String','Current View','Style','radiobutton','BackgroundColor',c,'Tag','rCurrentView','HorizontalAlignment','left');                                    
                                   
hExportDataGui.rCurrentPlot = uicontrol('Parent',hExportDataGui.pPlotSelection,'Units','normalized','Position',[0.05 0.35 0.9 0.3],'Enable','on','FontSize',10,...
                                       'String','Current Plot','Style','radiobutton','BackgroundColor',c,'Tag','rCurrentPlot','HorizontalAlignment','left');                                      
                                   
hExportDataGui.rMultiplePlots = uicontrol('Parent',hExportDataGui.pPlotSelection,'Units','normalized','Position',[0.05 0.025 0.9 0.3],'Enable','on','FontSize',10,...
                                       'String','Select Plots','Style','radiobutton','BackgroundColor',c,'Tag','rMultiplePlots','HorizontalAlignment','left');                                                                      
                         
set(hExportDataGui.pPlotSelection,'SelectionChangeFcn',@PlotSelection);

hExportDataGui.pObjectSelection = uibuttongroup('Parent',hExportDataGui.fig,'Units','normalized','Position',[0.525 0.7 0.425 0.25],'BackgroundColor',c);

hExportDataGui.rCurrentObject = uicontrol('Parent',hExportDataGui.pObjectSelection,'Units','normalized','Position',[0.05 0.675 0.9 0.3],'Enable','on','FontSize',10,...
                                       'String',['Current ' Type],'Style','radiobutton','BackgroundColor',c,'Tag','rCurrentObject','HorizontalAlignment','left');                                 
                                   
hExportDataGui.rAllObjects = uicontrol('Parent',hExportDataGui.pObjectSelection,'Units','normalized','Position',[0.05 0.35 0.9 0.3],'Enable','on','FontSize',10,...
                                       'String',['All ' Type 's'],'Style','radiobutton','BackgroundColor',c,'Tag','rAllObjects','HorizontalAlignment','left');          
                                   
hExportDataGui.rSelection = uicontrol('Parent',hExportDataGui.pObjectSelection,'Units','normalized','Position',[0.05 0.025 0.9 0.3],'Enable','on','FontSize',10,...
                                       'String','Selection','Style','radiobutton','BackgroundColor',c,'Tag','rSelection','HorizontalAlignment','left');        

hExportDataGui.tXaxis = uicontrol('Parent',hExportDataGui.fig,'Units','normalized','Style','text','FontSize',10,'Position',[0.05 0.6 0.24 0.05],...
                                  'HorizontalAlignment','left','String','X Axis:','Tag','lXaxis','BackgroundColor',c);

hExportDataGui.lXaxis = uicontrol('Parent',hExportDataGui.fig,'Units','normalized','Callback','fExportDataGui(''XAxisList'',getappdata(0,''hExportDataGui''));',...
                                  'Style','popupmenu','FontSize',10,'Position',[0.2 0.6 0.35 0.05],'String',lXaxis.list,'Tag','lXaxis','UserData',lXaxis,'BackgroundColor','white');

hExportDataGui.tYaxis = uicontrol('Parent',hExportDataGui.fig,'Units','normalized','Style','text','FontSize',10,'Position',[0.05 0.51 0.24 0.05],...
                                  'HorizontalAlignment','left','String','Y Axis (left):','Tag','lYaxis','BackgroundColor',c);

hExportDataGui.lYaxis = uicontrol('Parent',hExportDataGui.fig,'Units','normalized','Style','popupmenu','FontSize',10,'Position',[0.2 0.51 0.35 0.05],...
                                  'String',lYaxis(1).list,'Tag','lYaxis','UserData',lYaxis,'BackgroundColor','white');                        

hExportDataGui.cYaxis2 = uicontrol('Parent',hExportDataGui.fig,'Units','normalized','Callback','fExportDataGui(''CheckYAxis2'',getappdata(0,''hExportDataGui''));',...
                                  'Position',[0.05 0.42 0.3 0.05],'String','Add second plot','Style','checkbox','BackgroundColor',c,'Tag','cYaxis2','Value',0,'Enable','off');

hExportDataGui.tYaxis2 = uicontrol('Parent',hExportDataGui.fig,'Units','normalized','Style','text','FontSize',10,'Position',[0.05 0.33 0.28 0.05],...
                                   'HorizontalAlignment','left','String','Y Axis (right):','Tag','lYaxis','Enable','off','BackgroundColor',c);

hExportDataGui.lYaxis2 = uicontrol('Parent',hExportDataGui.fig,'Units','normalized','Style','popupmenu','FontSize',10,'Position',[0.2 0.33 0.35 0.05],'String',lYaxis(1).list,...
                                   'Tag','lYaxis2','UserData',lYaxis,'Enable','off','BackgroundColor','white'); 
                                          
hExportDataGui.lPlotList = uicontrol('Parent',hExportDataGui.fig,'Units','normalized','Position',[0.55 0.3 0.4 0.35],'Enable','on','FontSize',8,...
                                     'String','','Style','listbox','Tag','lPlotList','BackgroundColor','white','Max',10,'Min',1);               
                                 
hExportDataGui.bAddPlot = uicontrol('Parent',hExportDataGui.fig,'Units','normalized','Position',[0.05 0.2 0.49 0.075],'Enable','on','FontSize',8,...
                                   'String','Add plot','Style','pushbutton','Tag','bAddPLot','HorizontalAlignment','center','Callback','fExportDataGui(''AddPlot'',getappdata(0,''hExportDataGui''));');                     
 
hExportDataGui.bRemovePlot = uicontrol('Parent',hExportDataGui.fig,'Units','normalized','Position',[0.55 0.2 0.4 0.075],'Enable','on','FontSize',8,...
                                   'String','Remove selected plots','Style','pushbutton','Tag','bAddPLot','HorizontalAlignment','center','Callback','fExportDataGui(''RemovePlot'',getappdata(0,''hExportDataGui''));');                              
                           
hExportDataGui.cOnePlotPerPage = uicontrol('Parent',hExportDataGui.fig,'Units','normalized','Style','checkbox','FontSize',10,'Position',[0.1 0.135 0.525 0.065],...
                                         'HorizontalAlignment','left','String','Show only one plot per page','Tag','cOnePlotPerPage','Enable','off');
                           
hExportDataGui.bPreview = uicontrol('Parent',hExportDataGui.fig,'Units','normalized','Position',[0.05 0.025 0.425 0.1],'Enable','on','FontSize',12,...
                                    'String','Preview','Style','pushbutton','Tag','bPreview','HorizontalAlignment','center','Callback','fExportDataGui(''Preview'',getappdata(0,''hExportDataGui''));');  
                                
hExportDataGui.bOK = uicontrol('Parent',hExportDataGui.fig,'Units','normalized','Position',[0.525 0.025 0.2 0.1],'Enable','on','FontSize',12,...
                                    'String','OK','Style','pushbutton','Tag','bOK','HorizontalAlignment','center','Callback','fExportDataGui(''Export'',getappdata(0,''hExportDataGui''));'); 
                                
hExportDataGui.bCancel = uicontrol('Parent',hExportDataGui.fig,'Units','normalized','Position',[0.75 0.025 0.2 0.1],'Enable','on','FontSize',12,...
                                    'String','Cancel','Style','pushbutton','Tag','bCancel','HorizontalAlignment','center','Callback','fExportDataGui(''Cancel'',getappdata(0,''hExportDataGui''));');                                 
                                 
if isempty(idx)
    set(hExportDataGui.pPlotSelection,'SelectedObject',hExportDataGui.rMultiplePlots);
    set(hExportDataGui.pObjectSelection,'SelectedObject',hExportDataGui.rAllObjects);    
    set(hExportDataGui.rCurrentView,'Enable','off');
    set(hExportDataGui.rCurrentPlot,'Enable','off');    
    set(hExportDataGui.rCurrentObject,'Enable','off');
else
    set(hExportDataGui.pPlotSelection,'SelectedObject',hExportDataGui.rCurrentView);
    set(hExportDataGui.pObjectSelection,'SelectedObject',hExportDataGui.rCurrentObject);    
end
UpdateDataPanel(hExportDataGui)
setappdata(0,'hExportDataGui',hExportDataGui);

function PlotSelection(source,eventdata) %#ok<INUSD>
UpdateDataPanel(getappdata(0,'hExportDataGui'));

function UpdateDataPanel(hExportDataGui)
enable = 'off';
if get(hExportDataGui.rMultiplePlots,'Value')
    enable = 'on';          
end
set(hExportDataGui.tXaxis,'Enable',enable);
set(hExportDataGui.lXaxis,'Enable',enable);
set(hExportDataGui.tYaxis,'Enable',enable);
set(hExportDataGui.lYaxis,'Enable',enable);
set(hExportDataGui.cYaxis2,'Enable',enable);
set(hExportDataGui.tYaxis2,'Enable',enable);
set(hExportDataGui.lYaxis2,'Enable',enable);
set(hExportDataGui.lPlotList,'Enable',enable);
set(hExportDataGui.bAddPlot,'Enable',enable);
set(hExportDataGui.bRemovePlot,'Enable',enable);
set(hExportDataGui.cOnePlotPerPage,'Enable',enable);
enable = 'on';
if get(hExportDataGui.rCurrentView,'Value')
    enable = 'off';     
    set(hExportDataGui.pObjectSelection,'SelectedObject',hExportDataGui.rCurrentObject);        
end
set(hExportDataGui.rAllObjects,'Enable',enable);
set(hExportDataGui.rSelection,'Enable',enable);
if get(hExportDataGui.rMultiplePlots,'Value')
    XAxisList(hExportDataGui)
    CheckYAxis2(hExportDataGui)
end

function Close(hExportDataGui)
delete(findobj('Tag','fExportPreview'));
close(hExportDataGui.fig);

function CloseFcn(fig,~)
delete(findobj('Tag','fExportPreview'));
delete(fig);

function AddPlot(hExportDataGui)
x = get(hExportDataGui.lXaxis,'Value');
y = get(hExportDataGui.lYaxis,'Value');
y2 = get(hExportDataGui.lYaxis2,'Value');
Xaxis = get(hExportDataGui.lXaxis,'UserData');
Yaxis = get(hExportDataGui.lYaxis,'UserData');
data = get(hExportDataGui.lPlotList,'UserData');
str = get(hExportDataGui.lPlotList,'String');
n = length(data);
if get(hExportDataGui.cYaxis2,'Value') && strcmp(get(hExportDataGui.cYaxis2,'Enable'),'on')
    for i=1:n
        if length(data{i})==3
            if all(data{i}==[x y y2])
                fMsgDlg('Plot already selected','warn');
                return;
            end
        end
    end
    data{n+1} = [x y y2];
    str{n+1} = [Yaxis(x).list{y} ' & ' Yaxis(x).list{y2} ' vs. ' Xaxis.list{x}];
else
    for i=1:n
        if length(data{i})==2
            if all(data{i}==[x y])
                fMsgDlg('Plot already selected','warn');
                return;
            end
        end
    end
    data{n+1} = [x y];
    str{n+1} = [Yaxis(x).list{y} ' vs. ' Xaxis.list{x}];    
end
set(hExportDataGui.lPlotList,'UserData',data);
set(hExportDataGui.lPlotList,'String',str);

function Preview(hExportDataGui)
global Molecule;
global Filament;
if strcmp(hExportDataGui.Type,'Molecule')
    Objects=Molecule;
else
    Objects=Filament;
end
if get(hExportDataGui.rCurrentObject,'Value')
    CreatePage(hExportDataGui,Objects(hExportDataGui.idx));
elseif get(hExportDataGui.rAllObjects,'Value')
    CreatePage(hExportDataGui,Objects(1));
elseif get(hExportDataGui.rSelection ,'Value')
    Selected=[Objects.Selected];
    k = find(Selected==1,1,'first');
    CreatePage(hExportDataGui,Objects(k));
end

function Export(hExportDataGui)
global Molecule;
global Filament;
[FileName, PathName, FilterIndex] = uiputfile({'*.pdf','PDF-file (*.pdf)';'*.png','PNG-file (*.png)';'*.jpg','JPEG-file (*.jpg)';'*.fig','MATLAB figure (*.fig)';},'Save FIESTA Data Export',fShared('GetSaveDir'));
if FileName ~= 0
    fShared('SetSaveDir',PathName);
    [file, ~] = strtok(FileName, '.');
    if strcmp(hExportDataGui.Type,'Molecule')
        Objects=Molecule;
    else
        Objects=Filament;
    end
    if get(hExportDataGui.rCurrentObject,'Value')
        k = hExportDataGui.idx;
    elseif get(hExportDataGui.rAllObjects,'Value')
        k = 1:length(Objects);
    elseif get(hExportDataGui.rSelection ,'Value')
        k = find(Selected==1);
    end
    for idx = k
        data = get(hExportDataGui.lPlotList,'UserData');    
        if get(hExportDataGui.cOnePlotPerPage,'Value')
            nPlots = length(data);
        else
            nPlots = 1;
        end
        for n = 1:length(nPlots)
            filestr = [file ' - ' Objects(idx).Name];
            if ~isempty(data) && nPlots>1 
                set(hExportDataGui.lPlotList,'Value',n);    
                filestr = [filestr ' - ' data(n)];
            end
            fig = CreatePage(hExportDataGui,Objects(idx));
            switch(FilterIndex)
                case 1
                    saveas(fig,[PathName filestr '.pdf'],'pdf');
                case 2 
                    saveas(fig,[PathName filestr '.png'],'png');
                case 3 
                    saveas(fig,[PathName filestr '.jpg'],'jpeg');
                case 4
                    set(fig,'MenuBar','figure','ToolBar','figure');
                    savefig(fig,[PathName filestr '.fig']);
            end 
            delete(fig);
        end          
    end
end
close(hExportDataGui.fig);

function fig = CreatePage(hExportDataGui,Object)
delete(findobj('Tag','fExportPreview'));
if get(hExportDataGui.rCurrentView,'Value') || get(hExportDataGui.rCurrentPlot,'Value')
    XFig = 16;
    YFig = 10;
    PosAxes{1} = [2 1.5 12 7.75];
else
    data = get(hExportDataGui.lPlotList,'UserData');    
    nPlots = length(data);
    if nPlots == 0
        fMsgDlg('No plots selected, please add plots to the list','warn');
        return;
    end
    PosAxes = cell(1,nPlots);
    if nPlots == 1 || get(hExportDataGui.cOnePlotPerPage,'Value')
        XFig = 16;
        YFig = 10;
        PosAxes{1} = [2 1.5 12 7.75];
    elseif nPlots == 2
        XFig = 16;
        YFig = 20;
        PosAxes{1} = [2 11.5 12 7.75];
        PosAxes{2} = [2 1.5 12 7.75];
    else
        XFig = 32;
        YFig = 10*ceil(nPlots/2);  
        for n = 1:nPlots
            PosAxes{n} = [2+16*(1-mod(n,2)) 1.5+10*ceil((nPlots-n-1)/2) 12 7.75];
        end
    end
end
fig = figure('Units','centimeters','Position',[2 2 XFig YFig],'Toolbar','none','MenuBar','none','Name','FIESTA Export Data Preview','DockControls','off','Tag','fExportPreview',...
             'PaperUnits','centimeters','PaperSize',[XFig YFig],'Color','w','PaperPositionMode','manual','PaperPosition',[0 0 XFig YFig]);
if get(hExportDataGui.rCurrentView,'Value') || get(hExportDataGui.rCurrentPlot,'Value')
    hDataGui =getappdata(0,'hDataGui'); 
    data(1) = 0;
    data(2) = 0;
    if strcmp(get(hDataGui.cYaxis2,'Enable'),'on') && get(hDataGui.cYaxis2,'Value')
        data(3) = 0;
    end
    data={data};
else
    data = get(hExportDataGui.lPlotList,'UserData');    
    if get(hExportDataGui.cOnePlotPerPage,'Value')
        idx = get(hExportDataGui.lPlotList,'Value');    
        data = data(idx);
    end
end
for n = 1:length(PosAxes)
    a = axes('Parent',fig,'Units','centimeters','Position',PosAxes{n});
    Draw(hExportDataGui,Object,a,data{n});
    set(a,'Unit','normalized');
    axes('Parent',fig,'Units','normalized','Position',get(a,'Position'),'Color','none','Box','on','xtick',[],'ytick',[],{'xlim','ylim'},get(a,{'xlim','ylim'}));
end        
            
function RemovePlot(hExportDataGui)
data = get(hExportDataGui.lPlotList,'UserData');
str = get(hExportDataGui.lPlotList,'String');
index = get(hExportDataGui.lPlotList,'Value');
data(index) = [];
str(index) = [];
set(hExportDataGui.lPlotList,'Value',[]);
set(hExportDataGui.lPlotList,'UserData',data);
set(hExportDataGui.lPlotList,'String',str);

function [lXaxis,lYaxis]=CreatePlotList(Type)
%create list for X-Axis
lXaxis.list{1}='x-position';
lXaxis.units{1}='[nm]';
lXaxis.list{2}='time';
lXaxis.units{2}='[s]';
lXaxis.list{3}='distance(to origin)';
lXaxis.units{3}='[nm]';
lXaxis.list{4}='distance(along path)';
lXaxis.units{4}='[nm]';
lXaxis.list{5}='histogram';

%create Y-Axis list for xy-plot
lYaxis(1).list{1}='y-position';
lYaxis(1).units{1}='[nm]';

lYaxis(2).list{1}='distance(to origin)';
lYaxis(2).units{1}='[nm]';
lYaxis(2).list{2}='distance(along path)';
lYaxis(2).units{2}='[nm]';
lYaxis(2).list{3}='sideways(to path)';
lYaxis(2).units{3}='[nm]';
lYaxis(2).list{4}='height (above path)';
lYaxis(2).units{4}='[nm]';
lYaxis(2).list{5}='velocity';
lYaxis(2).units{5}='[nm/s]';
n=6;
if strcmp(Type,'Molecule')==1
    lYaxis(2).list{n}='width(FWHM)';
    lYaxis(2).units{n}='[nm]';
    lYaxis(2).list{n+1}='amplitude';
    lYaxis(2).units{n+1}='[ABU]';    
    lYaxis(2).list{n+2}='intensity(volume)';
    lYaxis(2).units{n+2}='[ABU]';        
    n=n+3;
else
    lYaxis(2).list{n}='length';
    lYaxis(2).units{n}='[nm]';        
    lYaxis(2).list{n+1}='average amplitude';
    lYaxis(2).units{n+1}='[ABU]'; 
    lYaxis(2).list{n+2}='orientation(angle to x-axis)';
    lYaxis(2).units{n+2}='[rad]';  
    n=n+3;
end

lYaxis(2).list{n}='x-position';
lYaxis(2).units{n}='[nm]';
lYaxis(2).list{n+1}='y-position';
lYaxis(2).units{n+1}='[nm]';
lYaxis(2).list{n+2}='z-position';
lYaxis(2).units{n+2}='[nm]';
n=n+3;

if strcmp(Type,'Molecule')==1
    lYaxis(2).list{n}='fit error of center';
    lYaxis(2).units{n}='[nm]'; 
    lYaxis(2).list{n+1}='width of major axis(FWHM)';
    lYaxis(2).units{n+1}='[nm]';        
    lYaxis(2).list{n+2}='width of minor axis(FWHM)';
    lYaxis(2).units{n+2}='[nm]';              
    lYaxis(2).list{n+3}='orientation(angle to x-axis)';    
    lYaxis(2).units{n+3}='rad';      
    lYaxis(2).list{n+4}='radius ring';
    lYaxis(2).units{n+4}='[nm]';        
    lYaxis(2).list{n+5}='amplitude ring';
    lYaxis(2).units{n+5}='[ABU]';              
    lYaxis(2).list{n+6}='width (FWHM) ring';    
    lYaxis(2).units{n+6}='[nm]';                           
end

%create Y-Axis list for distance plot
lYaxis(3)=lYaxis(2);
lYaxis(3).list(1:2)=[];
lYaxis(3).units(1:2)=[];

lYaxis(4)=lYaxis(3);

%create list for histograms
lYaxis(5).list{1}='velocity';
lYaxis(5).units{1}='[nm/s]';
lYaxis(5).list{2}='pairwise-distance';
lYaxis(5).units{2}='[nm]';
lYaxis(5).list{3}='pairwise-distance (path)';
lYaxis(5).units{3}='[nm]';
lYaxis(5).list{4}='amplitude';
lYaxis(5).units{4}='[ABU]';
if strcmp(Type,'Molecule')==1
    lYaxis(5).list{5}='intensity (volume)';
    lYaxis(5).units{5}='[ABU]';
else
    lYaxis(5).list{5}='length';
    lYaxis(5).units{5}='[nm]';
end
lYaxis(5).list{6}='z-position';
lYaxis(5).units{6}='[nanometer]';

function XAxisList(hExportDataGui)
x=get(hExportDataGui.lXaxis,'Value');
y=get(hExportDataGui.lYaxis,'Value');
y2=get(hExportDataGui.lYaxis2,'Value');
s=get(hExportDataGui.lXaxis,'UserData');
a=get(hExportDataGui.lYaxis,'UserData');
enable='off';
enable2='off';
if x>1 && x<length(s.list)
    enable='on';
    if get(hExportDataGui.cYaxis2,'Value')==1
        enable2='on';
    end
end
if length(a(x).list)<y
    set(hExportDataGui.lYaxis,'Value',1);
end
if length(a(x).list)<y2
    set(hExportDataGui.lYaxis2,'Value',1);
end    
set(hExportDataGui.lYaxis,'String',a(x).list);
set(hExportDataGui.lYaxis2,'String',a(x).list);
set(hExportDataGui.cYaxis2,'Enable',enable);
set(hExportDataGui.tYaxis2,'Enable',enable2);
set(hExportDataGui.lYaxis2,'Enable',enable2);

function CheckYAxis2(hExportDataGui)
enable='off';
if get(hExportDataGui.cYaxis2,'Value')
    enable='on';
end
set(hExportDataGui.tYaxis2,'Enable',enable);
set(hExportDataGui.lYaxis2,'Enable',enable);

function Draw(hExportDataGui,Object,a,data)

x = data(1);
y = data(2);

%get plot colums
XList = get(hExportDataGui.lXaxis,'UserData');
YList = get(hExportDataGui.lYaxis,'UserData');
Xaxis = get(hExportDataGui.lXaxis,'UserData');
Yaxis = get(hExportDataGui.lYaxis,'UserData');
if x==0
    hDataGui = getappdata(0,'hDataGui');
    %get plot colums
    xData = get(hDataGui.lXaxis,'Value');
    XDataList = get(hDataGui.lXaxis,'UserData');
    XStr = XDataList.list{xData};
    x  = find(~cellfun(@isempty,strfind(XList.list,XStr)));


    yData = get(hDataGui.lYaxis,'Value');
    YDataList = get(hDataGui.lYaxis,'UserData');
    YStr = YDataList(x).list{yData};
    y  = find(~cellfun(@isempty,strfind(YList(x).list,YStr)));
    
    if length(data)>2
        yData2=get(hDataGui.lYaxis2,'Value');
        YDataList2=get(hDataGui.lYaxis2,'UserData');    
        YStr = YDataList2(x).list{yData2};
        y2  = find(~cellfun(@isempty,strfind(YList(x).list,YStr)));    
    end

end
if x < 5
    XPlot = GetXData(Object,x);
    YPlot{1} = GetYData(Object,x,y,hExportDataGui.Type);
else
    XPlot = [];
    YPlot{1} = GetHistogram(Object,y,hExportDataGui.Type);
end

if ~isempty(YPlot{1})
    set(a,'NextPlot','add','TickDir','out'); 

    hold on     
    xscale=1;
    yscale=1;
    if strcmp(YList(x).units{y},'[nm]') 
        if x==1 
            if (max(YPlot{1})-max(YPlot{1}))>5000
                yscale=1000;
                YList(x).units{y}=['[' char(956) 'm]'];
                xscale=1000;
                XList.units{x}=['[' char(956) 'm]']; 
            end
        else
            if max(YPlot{1})>5000 || min(YPlot{1})>1000
                yscale=1000;
                YList(x).units{y}=['[' char(956) 'm]'];   
            end
        end
    end
    if strcmp(YList(x).units{y},'[nm/s]') && max(YPlot{1})>5000
        yscale=1000;
        YList(x).units{y}=['[' char(956) 'm/s]'];
    end
    if ~isempty(XPlot)
        FilXY = [];
        if x==1
            Dis=norm([Object.Results(1,3)-Object.Results(end,3) Object.Results(1,4)-Object.Results(end,4)]);
            if strcmp(hExportDataGui.Type,'Filament')
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
                        line((Object.Data{i}(:,1)-min(XPlot))/xscale,(Object.Data{i}(:,2)-min(YPlot{1}))/yscale,'Color','red','LineStyle','-','Marker','none');
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
                    fill([VecX(1)+Length/20*U(1) VecX(1)+Length/40*V(1) VecX(1)-Length/40*V(1)]/xscale,[VecY(1)+Length/20*V(1) VecY(1)-Length/40*U(1) VecY(1)+Length/40*U(1)]/yscale,'r','EdgeColor','none');
                    if lData>1
                        fill([VecX(2)+Length/20*U(2) VecX(2)+Length/40*V(2) VecX(2)-Length/40*V(2)]/xscale,[VecY(2)+Length/20*V(2) VecY(2)-Length/40*U(2) VecY(2)+Length/40*U(2)]/yscale,'r','EdgeColor','none');
                    end
                end
            end
            if Dis>2*Object.PixelSize
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
                    fill([VecX(m)+Dis/15*U(m) VecX(m)+Dis/30*V(m) VecX(m)-Dis/30*V(m)]/xscale,[VecY(m)+Dis/15*V(m) VecY(m)-Dis/30*U(m) VecY(m)+Dis/30*U(m)]/yscale,[0.8 0.8 0.8],'EdgeColor','none');
                end
            end
            
            XPlot=XPlot-min(XPlot);
            YPlot{1}=YPlot{1}-min(YPlot{1});
        end  
        if length(data)>2
            yscale(2) = 1;
            YList2 = YList;
            YPlot{2} = GetYData(Object,x,y2,hExportDataGui.Type);
            if isempty(YPlot{2})
                text(.5,.5,'No data available','Parent',a,'HorizontalAlignment','center','FontSize',14);
                return;
            end
            if strcmp(YList2(x).units{y2},'[nm]') && max(YPlot{2})-min(YPlot{2})>5000
                yscale(2)=1000;
                YList2(x).units{y2}=['[' char(956) 'm]'];
            end
            title(a,[Object.Name ' - ' Yaxis(x).list{y} ' & ' Yaxis(x).list{y2} ' vs. ' Xaxis.list{x}]);
        else
            YList2 = [];
            y2=[];
            title(a,[Object.Name ' - ' Yaxis(x).list{y} ' vs. ' Xaxis.list{x}]);
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
                yyaxis(a,astr);
            else
                astr = [];
                c = [0 0.4470 0.7410];
            end
            DataPlot(n) = plot(a,XPlot/xscale,YPlot{n}/yscale(n),'Color',c);
            tags = fliplr(dec2bin(Object.Results(:,end))=='1');
            if any(any(tags))
                line(a,XPlot(tags(:,1))/xscale,YPlot{n}(tags(:,1))/yscale(n),'Color','blue','LineStyle','none','Marker','+','MarkerSize',4);
                c=[1 0.5 0.5; 1 0.5 0; 0.8 0.1 0.56; 0.8 1 0.3; 1 1 1; 0 0.5 1; 0.5 0.5 1];
                c = repmat(c,9,1);
                s = {'s','^','*','<','d','>','p','v','h'};
                for m = 2:size(tags,2)
                    line(a,XPlot(tags(:,m))/xscale,YPlot{n}(tags(:,m))/yscale(n),'Color',c(m-1,:),'MarkerFaceColor',c(m-1,:),'LineStyle','none','Marker',s{ceil((m-1)/7)},'MarkerSize',6);
                end
            end
            set(a,'TickDir','out','YTickMode','auto');
            SetLabels(a,XList,YList,YList2,x,y,y2);
            if ~isempty(FilXY)
                XPlot=[FilXY{1} FilXY{2}];
                YPlot{n}=[FilXY{3} FilXY{4}];
            end
            if length(XPlot)>1
                SetAxis(a,XPlot/xscale,YPlot{n}/yscale(n),x,astr);
            else
                axis auto;
            end
            set(DataPlot(n),'Marker','.','MarkerSize',12);
        end
    else
        hDataGui.DataPlot = histogram(a,YPlot{1}/yscale,'BinMethod','sturges');
        xticks(a,hDataGui.DataPlot.BinEdges);
        xticklabels(a,num2str(hDataGui.DataPlot.BinEdges',4));
        xlim(a,[min(hDataGui.DataPlot.BinEdges) max(hDataGui.DataPlot.BinEdges)]);
        ylim(a,[0 1.05*max(hDataGui.DataPlot.Values)]);
        yticks(a,0:max([1 round(max(hDataGui.DataPlot.Values)/5)]):1.05*max(hDataGui.DataPlot.Values));
        xlabel(a,[YList(x).list{y} '  ' YList(x).units{y}]);
        ylabel(a,'number of data points');
        title(a,[Object.Name ' - Histogram ' YList(x).list{y}]);
    end
else
    text(.5,.5,'No data available','Parent',a,'HorizontalAlignment','center','FontSize',14);
end
hold off;

if get(hExportDataGui.rCurrentView,'Value')
    hDataGui=getappdata(0,'hDataGui'); 
    if length(data)>2
        yyaxis(a,'left');
        yyaxis(hDataGui.aPlot,'left');
        set(a,{'xlim','ylim'},get(hDataGui.aPlot,{'xlim','ylim'}));
        yyaxis(a,'right');
        yyaxis(hDataGui.aPlot,'right');
        set(a,{'xlim','ylim'},get(hDataGui.aPlot,{'xlim','ylim'}));        
    else
        set(a,{'xlim','ylim'},get(hDataGui.aPlot,{'xlim','ylim'}));        
    end
end

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

function SetLabels(a,XList,YList,YList2,x,y,y2)
if ~isempty(y2)
    yyaxis(a,'left');
end
xlabel(a,[XList(1).list{x} '  ' XList.units{x}]);
ylabel(a,[YList(x).list{y} '  ' YList(x).units{y}]);
if ~isempty(y2)
    yyaxis(a,'right');
    ylabel(a,[YList2(x).list{y2} '  ' YList2(x).units{y2}]);
end

function HistData = GetHistogram(Object,y,Type)
switch(y)
    case 1
        HistData = CalcVelocity(Object);        
    case 2
        XPos = Object.Results(:,3);
        YPos = Object.Results(:,4);
        ZPos = Object.Results(:,5);
        if any(isnan(ZPos))
            ZPos(:) = 0;
        end
        pairwise = zeros(length(XPos));
        for i = 1:length(XPos)
            pairwise(:,i) = sqrt((XPos-XPos(i)).^2 + (YPos-YPos(i)).^2 + (ZPos-ZPos(i)).^2);
        end
        p = tril(pairwise,-1);
        pairwise = p(p>1);
        HistData = pairwise;
    case 3
        if ~isempty(Object.PathData)
            Dis=real(Object.PathData(:,4));
            pairwise=zeros(length(Dis));
            for i=1:length(Dis)
                pairwise(:,i)=Dis-Dis(i);
            end
            p=tril(pairwise,-1);
            pairwise=p(p>1);
            HistData = pairwise;
        else
            HistData = [];
        end
    case 4
        Amp=Object.Results(:,8);
        HistData = Amp;
    case 5        
        if strcmp(Type,'Molecule')
            Int=2*pi*Object.Results(:,7).^2.*Object.Results(:,8);
            HistData = Int;
        else
            Len=Object.Results(:,7);
            HistData = Len;
        end
    case 6
        ZPos = Object.Results(:,5);
        if ~all(isnan(ZPos))
            HistData = ZPos;
        else
            HistData = [];
        end
end

function XPlot = GetXData(Object,x)
switch(x)
    case 1
        XPlot = Object.Results(:,3);        
    case 2
        XPlot = Object.Results(:,2);                
    case 3
        XPlot = Object.Results(:,6);        
    case 4
        if ~isempty(Object.PathData)
            XPlot = real(Object.PathData(:,4));
        else
            XPlot = [];
        end
    case 5
end

function YPlot = GetYData(Object,x,y,Type) 
if x == 1
    YPlot = Object.Results(:,4);    
else
    YPlot = [];
    switch(y)
        case 1
            YPlot = Object.Results(:,6);
        case 2
            if ~isempty(Object.PathData)
                YPlot = real(Object.PathData(:,4));
            end
        case 3
            if ~isempty(Object.PathData)
                YPlot = Object.PathData(:,5);
            end
        case 4
            if ~isempty(Object.PathData)
                YPlot = Object.PathData(:,6);
            end
        case 5
            YPlot = CalcVelocity(Object);
        case 6
            YPlot = Object.Results(:,7);
        case 7
            YPlot = Object.Results(:,8);            
        case 8
            if strcmp(Type,'Molecule')
                YPlot = 2*pi*(Object.Results(:,7)/Object.PixelSize/(2*sqrt(2*log(2)))).^2.*Object.Results(:,8);       
            else
                YPlot = Object.Results(:,9);   
            end
        case 9
            YPlot = Object.Results(:,3);
        case 10
            YPlot = Object.Results(:,4);       
        case 11
            YPlot = Object.Results(:,5);   
        otherwise
            y = y - 3;
            if y < size(Object.Results,2)
                YPlot = Object.Results(:,y);
            else
                y = y - 3;
                YPlot = Object.Results(:,y);
            end
    end
end

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
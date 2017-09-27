function fConfigGui(func,varargin)
switch(func)
    case 'Create'
        ConfigGuiCreate;
    case 'OK'
        ConfigGuiOK(varargin{1});
    case 'cancel'
        close(findobj(0,'Tag','hConfigGui'));
    case 'MolPanel'
        MolPanel(varargin{1});
    case 'FilPanel'
        FilPanel(varargin{1});
    case 'OnlyTrack'
        OnlyTrack(varargin{1});
    case 'UseIntensity'
        UseIntensity(varargin{1});        
    case 'UseServer'
        UseServer(varargin{1});  
    case 'SetThreshold'
        SetThreshold(varargin{1});         
    case 'SetFilter'
        SetFilter(varargin{1});             
    case 'SetRefPoint'
        SetRefPoint(varargin{1});             
    case 'ShowModel'
        ShowModel(varargin{1});            
    case 'UpdateParams'
        UpdateParams(varargin{1});          
    case 'ParallelProcessing'
        ParallelProcessing(varargin{1});   
    case 'Help'
        Help;              
end

function ConfigGuiCreate
global Config;
global Stack;
h=findobj('Tag','hConfigGui');
close(h)

hConfigGui.fig = figure('Units','normalized','DockControls','off','IntegerHandle','off','MenuBar','none','Name','FIESTA - Configuration',...
                     'NumberTitle','off','HandleVisibility','callback','Tag','hConfigGui','Renderer', 'painters',...
                     'Visible','off','WindowStyle','normal');

fPlaceFig(hConfigGui.fig,'big');

if ispc
    set(hConfigGui.fig,'Color',[236 233 216]/255);
end

c = get(hConfigGui.fig,'Color');
hMainGui=getappdata(0,'hMainGui');
n = getChIdx;

hConfigGui.mHelpContext = uicontextmenu('Parent',hConfigGui.fig);

hConfigGui.mHelp = uimenu('Parent',hConfigGui.mHelpContext,'Callback','fConfigGui(''Help'');',...
                          'Label','Help','Tag','mHelp');

hConfigGui.pGeneral.panel = uipanel('Parent',hConfigGui.fig,'Units','normalized','Fontsize',12,'Bordertype','none',...
                                    'Position',[0 0.6 1 0.4],'Tag','pGeneral','Visible','on','BackgroundColor',c);          
                                 
hConfigGui.pGeneral.tGeneralOptions = uicontrol('Parent',hConfigGui.pGeneral.panel,'Style','text','Units','normalized',...
                                                'Position',[.0 .94 1 .06],'Tag','tGeneralOptions','Fontsize',12,...
                                                'String','General options','HorizontalAlignment','center','FontWeight','bold','Enable','on',...
                                                'BackgroundColor',[0 0 1],'ForegroundColor','white');                                 

hConfigGui.pGeneral.tStackT = uicontrol('Parent',hConfigGui.pGeneral.panel,'Style','text','Units','normalized',...
                                                'Position',[.01 .85 .09 .06],'Tag','tStackT','Fontsize',12,...
                                                'String','Stack:','HorizontalAlignment','left','BackgroundColor',c);     
                                            
hConfigGui.pGeneral.tStack = uicontrol('Parent',hConfigGui.pGeneral.panel,'Style','text','Units','normalized',...
                                                'Position',[.10 .85 .35  .06],'Tag','tStack ','Fontsize',12,...
                                                'String',Config.StackName{n-1},'HorizontalAlignment','left','BackgroundColor',c);     
                                            
hConfigGui.pGeneral.tStackTypeT = uicontrol('Parent',hConfigGui.pGeneral.panel,'Style','text','Units','normalized',...
                                                'Position',[.51 .85 .14 .06],'Tag','tStackTypeT','Fontsize',12,...
                                                'String','StackType:','HorizontalAlignment','left','BackgroundColor',c);     
                                            
hConfigGui.pGeneral.tStackType = uicontrol('Parent',hConfigGui.pGeneral.panel,'Style','text','Units','normalized',...
                                           'Position',[.65 .85 .3 .06],'Tag','tStackType','Fontsize',12,...
                                           'String',Config.StackType{n-1},'HorizontalAlignment','left','BackgroundColor',c);                      

hConfigGui.pGeneral.pOptions = uipanel('Parent',hConfigGui.pGeneral.panel,'Units','normalized','Fontsize',10,'BackgroundColor',c,...
                                       'Position',[0.025 0.58 .95 .25],'Tag','pOptions','Visible','on','Title','Stack Options');          
                                   
hConfigGui.pGeneral.tPixSize = uicontrol('Parent',hConfigGui.pGeneral.pOptions,'Style','text','Units','normalized',...
                                         'Position',[.025 .45 .125  .4],'Tag','tPixSize','Fontsize',12,...
                                         'String','Pixel size:','HorizontalAlignment','left','BackgroundColor',c);     
                                     
hConfigGui.pGeneral.ePixSize = uicontrol('Parent',hConfigGui.pGeneral.pOptions,'Style','edit','Units','normalized',...
                                         'Position',[.175 .55 .075 .4],'Tag','ePixSize','Fontsize',10,'UserData','General options.htm#pixel_size',...
                                         'String',num2str(Config.PixSize),'BackgroundColor','white','HorizontalAlignment','center',...
                                         'TooltipString','Right click for Help','UIContextMenu',hConfigGui.mHelpContext);                             
if isempty(Stack)
    set(hConfigGui.pGeneral.ePixSize,'Enable','off');
end

hConfigGui.pGeneral.tNM(1) = uicontrol('Parent',hConfigGui.pGeneral.pOptions,'Style','text','Units','normalized',...
                                    'Position',[.26 .45 .04  .4],'Tag','tNM','Fontsize',12,'BackgroundColor',c,...
                                    'String','nm','HorizontalAlignment','left','TooltipString','Right click for Help');    

hConfigGui.pGeneral.tTimeDiff = uicontrol('Parent',hConfigGui.pGeneral.pOptions,'Style','text','Units','normalized',...
                                         'Position',[.325 .45 .145  .4],'Tag','TimeDiff','Fontsize',12,'Enable','off',...
                                         'String','Time difference:','HorizontalAlignment','left','BackgroundColor',c);                             

hConfigGui.pGeneral.eTimeDiff = uicontrol('Parent',hConfigGui.pGeneral.pOptions,'Style','edit','Units','normalized',...
                                         'Position',[.475 .55 .075 .4],'Tag','eTimeDiff','Fontsize',10,'Enable','off',...
                                         'String','','BackgroundColor','white','HorizontalAlignment','center',...
                                         'TooltipString','Right click for Help','UIContextMenu',hConfigGui.mHelpContext,'UserData','General options.htm#time_difference');                             
                                     
hConfigGui.pGeneral.tMS = uicontrol('Parent',hConfigGui.pGeneral.pOptions,'Style','text','Units','normalized',...
                                    'Position',[.56 .45 .06  .4],'Tag','tS','Fontsize',12,'Enable','off',...
                                    'String','ms','HorizontalAlignment','left','BackgroundColor',c);    
                                
if strcmp(Config.StackType,'TIFF')==1
    set(hConfigGui.pGeneral.eTimeDiff,'String',num2str(Config.Time(n-1)),'Enable','on');
    set(hConfigGui.pGeneral.tTimeDiff,'Enable','on');
    set(hConfigGui.pGeneral.tMS,'Enable','on');
end
                                  
hConfigGui.pGeneral.tFirstFrame = uicontrol('Parent',hConfigGui.pGeneral.pOptions,'Style','text','Units','normalized',...
                                         'Position',[.025 .01 .125 .4],'Tag','tFirstFrame','Fontsize',12,...
                                         'String','First Frame:','HorizontalAlignment','left','BackgroundColor',c);                             

hConfigGui.pGeneral.eFirstFrame = uicontrol('Parent',hConfigGui.pGeneral.pOptions,'Style','edit','Units','normalized',...
                                         'Position',[.175 .1 .075 .4],'Tag','eFirstFrame','Fontsize',10,...
                                         'String',num2str(Config.FirstTFrame),'BackgroundColor','white','HorizontalAlignment','center',...
                                         'TooltipString','Right click for Help','UIContextMenu',hConfigGui.mHelpContext,'UserData','General options.htm#frame');                                               
                                
hConfigGui.pGeneral.tLastFrame = uicontrol('Parent',hConfigGui.pGeneral.pOptions,'Style','text','Units','normalized',...
                                           'Position',[.325 .01 .125  .4],'Tag','tLastFrame','Fontsize',12,...
                                           'String','Last Frame:','HorizontalAlignment','left','BackgroundColor',c);                             

hConfigGui.pGeneral.eLastFrame = uicontrol('Parent',hConfigGui.pGeneral.pOptions,'Style','edit','Units','normalized',...
                                         'Position',[.475 .1 .075 .4],'Tag','eLastFrame','Fontsize',10,...
                                         'String',num2str(Config.LastFrame),'BackgroundColor','white','HorizontalAlignment','center',...
                                         'TooltipString','Right click for Help','UIContextMenu',hConfigGui.mHelpContext,'UserData','General options.htm#frame');                             
                                     
hConfigGui.pGeneral.tParallelProcessing = uicontrol('Parent',hConfigGui.pGeneral.pOptions,'Style','text','BackgroundColor',c,'Units','normalized',...
                                         'Position',[.65 .525 .15 .4],'String','Parallel Processing:','Fontsize',12,'Tag','tParallelProcessing','HorizontalAlignment','left',...
                                         'TooltipString','Right click for Help','UIContextMenu',hConfigGui.mHelpContext,'UserData','General options.htm#parallel');   
                                     
                                     
%define available models
str={'none',...
     'local',...
     'server'};
 
if isempty(Config.TrackingServer)
    value = 1;
elseif strncmp(Config.TrackingServer,'local',5)
    value = 2;
else
    value = 3;
end

hConfigGui.pGeneral.mParallelProcessing = uicontrol('Parent',hConfigGui.pGeneral.pOptions,'Style','popupmenu','Units','normalized',...
                                          'Position',[.82 .525 .15 .4],'Tag','mParallelProcessing','Fontsize',12,'String',str,...
                                          'Callback','fConfigGui(''ParallelProcessing'',getappdata(0,''hConfigGui''));','Value',value,...
                                          'TooltipString','Right click for Help','UIContextMenu',hConfigGui.mHelpContext,...
                                          'UserData','Tracking options.htm#parallel','BackgroundColor','white');    
                                      
hConfigGui.pGeneral.tField = uicontrol('Parent',hConfigGui.pGeneral.pOptions,'Style','text','Units','normalized',...
                                           'Position',[.65 .01 .15  .4],'Tag','tServerName','Fontsize',12,...
                                           'String','','HorizontalAlignment','left','BackgroundColor',c);     
                                     
hConfigGui.pGeneral.eField = uicontrol('Parent',hConfigGui.pGeneral.pOptions,'Style','edit','Units','normalized',...
                                         'Position',[.82 .1 .15 .4],'Tag','eField','Fontsize',10,...
                                         'String','','BackgroundColor','white','HorizontalAlignment','center',...
                                         'TooltipString','Right click for Help','UIContextMenu',hConfigGui.mHelpContext,'UserData','General options.htm#parallel');     
                                     
fConfigGui('ParallelProcessing',hConfigGui);      
                                     
hConfigGui.pGeneral.pTrack = uipanel('Parent',hConfigGui.pGeneral.panel,'Units','normalized','Fontsize',10,'BackgroundColor',c,...
                                       'Position',[0.025 0.21 .45 .35],'Tag','pTrack','Visible','on','Title','Tracking');   
                                              
                                     
hConfigGui.pGeneral.tOnlyMol = uicontrol('Parent',hConfigGui.pGeneral.pTrack,'Style','text','Units','normalized',...
                                         'Position',[.05 .6 .3  .2],'Tag','tOnlyMol','Fontsize',12,'BackgroundColor',c,...
                                         'String','Only Molecules:','HorizontalAlignment','left');        
                                     
hConfigGui.pGeneral.cMolFull = uicontrol('Parent',hConfigGui.pGeneral.pTrack,'Style','checkbox','BackgroundColor',c,'Units','normalized','Callback','fConfigGui(''OnlyTrack'',getappdata(0,''hConfigGui''));',...
                                         'Position',[.375 .6 .1 .2],'Tag','cMolFull','HorizontalAlignment','left','Value',Config.OnlyTrack.MolFull,...
                                         'TooltipString','Right click for Help','UIContextMenu',hConfigGui.mHelpContext,'UserData','General options.htm#tracking');                                                                    
                                     
hConfigGui.pGeneral.tOnlyFil = uicontrol('Parent',hConfigGui.pGeneral.pTrack,'Style','text','Units','normalized',...
                                         'Position',[.55 .6 .3  .2],'Tag','tOnlyFil ','Fontsize',12,...
                                         'String','Only Filaments:','HorizontalAlignment','left','BackgroundColor',c);                    
                                     
hConfigGui.pGeneral.cFilFull = uicontrol('Parent',hConfigGui.pGeneral.pTrack,'Style','checkbox','BackgroundColor',c,'Units','normalized','Callback','fConfigGui(''OnlyTrack'',getappdata(0,''hConfigGui''));',...
                                         'Position',[.875 .6 .1 .2],'Tag','cFilFull','HorizontalAlignment','left','Value',Config.OnlyTrack.FilFull,...
                                         'TooltipString','Right click for Help','UIContextMenu',hConfigGui.mHelpContext,'UserData','General options.htm#tracking');  
                                     
hConfigGui.pGeneral.cIncludeFitData = uicontrol('Parent',hConfigGui.pGeneral.pTrack,'Style','checkbox','BackgroundColor',c,'Units','normalized',...
                                                'Position',[.05 .2 .9 .2],'Fontsize',12,'String','Include fit data (Warning: aprox. 50x-100x data size)','Tag','cIncludeFitData','HorizontalAlignment','left','Value',Config.OnlyTrack.IncludeData,...
                                                'TooltipString','Right click for Help','UIContextMenu',hConfigGui.mHelpContext,'UserData','General options.htm#tracking');                                      
                                     
hConfigGui.pGeneral.pThreshold = uipanel('Parent',hConfigGui.pGeneral.panel,'Units','normalized','Fontsize',10,'BackgroundColor',c,...
                                       'Position',[.525 .21 .45 .35],'Tag','pThreshold','Visible','on','Title','Threshold');   

hConfigGui.pGeneral.tAreaThreshold = uicontrol('Parent',hConfigGui.pGeneral.pThreshold,'Style','text','Units','normalized',...
                                              'Position',[.025 .7 .15  .2],'Tag','tAreaThreshold','Fontsize',12,...
                                              'String','Area:','HorizontalAlignment','left','BackgroundColor',c);              

hConfigGui.pGeneral.eAreaThreshold = uicontrol('Parent',hConfigGui.pGeneral.pThreshold,'Style','edit','Units','normalized',...
                                              'Position',[.18 .7 .12  .2],'Tag','eAreaThreshold','Fontsize',10,...
                                              'String',num2str(Config.Threshold.Area),'BackgroundColor','white','HorizontalAlignment','center',...
                                              'TooltipString','Right click for Help','UIContextMenu',hConfigGui.mHelpContext,'UserData','General options.htm#area'); 
                                          
hConfigGui.pGeneral.tPix = uicontrol('Parent',hConfigGui.pGeneral.pThreshold,'Style','text','Units','normalized',...
                                              'Position',[.32 .68 .1 .2],'Tag','tPix','Fontsize',10,...
                                              'String','pixel','HorizontalAlignment','left','BackgroundColor',c);              

Value=0;                   
if strcmp(Config.Threshold.Mode,'constant')
    Value=1;
end

hConfigGui.pGeneral.rConstant = uicontrol('Parent',hConfigGui.pGeneral.pThreshold,'Style','radiobutton','BackgroundColor',c,'Units','normalized',...
                                          'Position',[.02 .45 .5  .2],'Tag','rVariable','Fontsize',12,...
                                          'String','Constant Intensity','HorizontalAlignment','left','Value',Value,...
                                          'Callback','fConfigGui(''SetThreshold'',getappdata(0,''hConfigGui''));',...
                                          'TooltipString','Right click for Help','UIContextMenu',hConfigGui.mHelpContext,'UserData','General options.htm#intensity');  
                                      

                                      
Value=0;                   
if strcmp(Config.Threshold.Mode,'relative')
    Value=1;
end

hConfigGui.pGeneral.rRelative = uicontrol('Parent',hConfigGui.pGeneral.pThreshold,'Style','radiobutton','BackgroundColor',c,'Units','normalized',...
                                          'Position',[.02 .25 .5  .2],'Tag','rRelative','Fontsize',12,'Enable','on',...
                                          'String','Relative Intensity','HorizontalAlignment','left','Value',Value,...
                                          'Callback','fConfigGui(''SetThreshold'',getappdata(0,''hConfigGui''));',...
                                         'TooltipString','Right click for Help','UIContextMenu',hConfigGui.mHelpContext,'UserData','General options.htm#intensity');    

Value=0;                   
if strcmp(Config.Threshold.Mode,'variable')
    Value=1;
end

hConfigGui.pGeneral.rVariable = uicontrol('Parent',hConfigGui.pGeneral.pThreshold,'Style','radiobutton','BackgroundColor',c,'Units','normalized',...
                                          'Position',[.02 .05 .5  .2],'Tag','rVariable','Fontsize',12,...
                                          'String','Variable Intensity','HorizontalAlignment','left','Value',Value,...
                                          'Callback','fConfigGui(''SetThreshold'',getappdata(0,''hConfigGui''));',...
                                         'TooltipString','Right click for Help','UIContextMenu',hConfigGui.mHelpContext,'UserData','General options.htm#intensity');          
                                     
hConfigGui.pGeneral.tHeightThreshold = uicontrol('Parent',hConfigGui.pGeneral.pThreshold,'Style','text','Units','normalized',...
                                              'Position',[.5 .755 .22 .2],'Tag','tHeightThreshold','Fontsize',10,...
                                              'String','Height:','HorizontalAlignment','left','BackgroundColor',c);           
                                                            
hConfigGui.pGeneral.eHeightThreshold = uicontrol('Parent',hConfigGui.pGeneral.pThreshold,'Style','edit','Units','normalized',...
                                              'Position',[.76 .765 .15  .2],'Tag','eHeightThreshold','Fontsize',10,...
                                              'String',num2str(Config.Threshold.Height),'BackgroundColor','white','HorizontalAlignment','center',...
                                              'TooltipString','Right click for Help','UIContextMenu',hConfigGui.mHelpContext,'UserData','General options.htm#cod');    
                                          
hConfigGui.pGeneral.tFitThreshold = uicontrol('Parent',hConfigGui.pGeneral.pThreshold,'Style','text','Units','normalized',...
                                              'Position',[.5 .52 .22 .2],'Tag','tFitThreshold','Fontsize',10,...
                                              'String','Fit(CoD):','HorizontalAlignment','left','BackgroundColor',c);           
                                          
hConfigGui.pGeneral.eFitThreshold = uicontrol('Parent',hConfigGui.pGeneral.pThreshold,'Style','edit','Units','normalized',...
                                              'Position',[.76 .53 .15  .2],'Tag','eFitThreshold','Fontsize',10,...
                                              'String',num2str(Config.Threshold.Fit),'BackgroundColor','white','HorizontalAlignment','center',...
                                              'TooltipString','Right click for Help','UIContextMenu',hConfigGui.mHelpContext,'UserData','General options.htm#cod');      
                                          
hConfigGui.pGeneral.tFWHM = uicontrol('Parent',hConfigGui.pGeneral.pThreshold,'Style','text','Units','normalized',...
                                              'Position',[.5 .285 .25 .2],'Tag','tCurvatureThreshold','Fontsize',10,...
                                              'String','FWHM(Est.):','HorizontalAlignment','left','BackgroundColor',c);                                                     
                                          
hConfigGui.pGeneral.eFWHM = uicontrol('Parent',hConfigGui.pGeneral.pThreshold,'Style','edit','Units','normalized',...
                                              'Position',[.76 .295 .15  .2],'Tag','eCurvatureThreshold','Fontsize',10,...
                                              'String',num2str(Config.Threshold.FWHM),'BackgroundColor','white','HorizontalAlignment','center',...
                                              'TooltipString','Right click for Help','UIContextMenu',hConfigGui.mHelpContext,'UserData','General options.htm#fwhm');                                          
                                          
hConfigGui.pGeneral.tNM(2) = uicontrol('Parent',hConfigGui.pGeneral.pThreshold,'Style','text','Units','normalized',...
                                              'Position',[.9125 .285 .08 .2],'Tag','tNM','Fontsize',10,...
                                              'String','nm','HorizontalAlignment','left','BackgroundColor',c);              
                                     
hConfigGui.pGeneral.tBorderMargin = uicontrol('Parent',hConfigGui.pGeneral.pThreshold,'Style','text','Units','normalized',...
                                              'Position',[.5 .04 .25 .2],'Tag','tBorderMargin','Fontsize',10,...
                                              'String','Border Margin:','HorizontalAlignment','left','BackgroundColor',c);                                                     
                                          
hConfigGui.pGeneral.eBorderMargin = uicontrol('Parent',hConfigGui.pGeneral.pThreshold,'Style','edit','Units','normalized',...
                                              'Position',[.76 .05 .15  .2],'Tag','eBorderMargin','Fontsize',10,...
                                              'String',num2str(Config.BorderMargin),'BackgroundColor','white','HorizontalAlignment','center',...
                                              'TooltipString','Right click for Help','UIContextMenu',hConfigGui.mHelpContext,'UserData','General options.htm#border_margin');                                          
                                          
hConfigGui.pGeneral.tPixel = uicontrol('Parent',hConfigGui.pGeneral.pThreshold,'Style','text','Units','normalized',...
                                              'Position',[.9125 .04 .08 .2],'Tag','tPixel','Fontsize',10,...
                                              'String','pixel','HorizontalAlignment','left','BackgroundColor',c);              

                                          
hConfigGui.pGeneral.pFilter = uipanel('Parent',hConfigGui.pGeneral.panel,'Units','normalized','Fontsize',10,'BackgroundColor',c,...
                                      'Position',[.025 .03 .95 .16],'Tag','pThreshold','Visible','on','Title','Filter for thresholding (will be used for relative/constant intensity thresholding)'); 
 
Filter=0;
Value=0;                   
if strncmp(Config.Threshold.Filter(1:4),'none',4)
    Value=1;
    if length(Config.Threshold.Filter)>4
        Filter=1;
    end
end

hConfigGui.pGeneral.rFilterNone = uicontrol('Parent',hConfigGui.pGeneral.pFilter,'Style','radiobutton','BackgroundColor',c,'Units','normalized',...
                                          'Position',[.025 .1 .2  .8],'Tag','rFilterNone','Fontsize',12,...
                                          'String','none','HorizontalAlignment','left','Value',Value,...
                                          'Callback','fConfigGui(''SetFilter'',getappdata(0,''hConfigGui''));',...
                                         'TooltipString','Right click for Help','UIContextMenu',hConfigGui.mHelpContext,'UserData','General options.htm#intensity');          
                                      
Value=0;                   
if strncmp(Config.Threshold.Filter,'average',7)
    Value=1;
    if length(Config.Threshold.Filter)>7
        Filter=1;
    end
end

hConfigGui.pGeneral.rFilterAverage = uicontrol('Parent',hConfigGui.pGeneral.pFilter,'Style','radiobutton','BackgroundColor',c,'Units','normalized',...
                                          'Position',[.25 .1 .2  .8],'Tag','rFilterAverage','Fontsize',12,'Enable','on',...
                                          'String','average before','HorizontalAlignment','left','Value',Value,...
                                          'Callback','fConfigGui(''SetFilter'',getappdata(0,''hConfigGui''));',...
                                          'TooltipString','Right click for Help','UIContextMenu',hConfigGui.mHelpContext,'UserData','General options.htm#intensity');    
Value=0;                   
if strncmp(Config.Threshold.Filter,'smooth',6)
    Value=1;
    if length(Config.Threshold.Filter)>6
        Filter=1;
    end
end

hConfigGui.pGeneral.rFilterSmooth = uicontrol('Parent',hConfigGui.pGeneral.pFilter,'Style','radiobutton','BackgroundColor',c,'Units','normalized',...
                                          'Position',[.475 .1 .2  .8],'Tag','rFilterSmooth','Fontsize',12,...
                                          'String','smooth after','HorizontalAlignment','left','Value',Value,...
                                          'Callback','fConfigGui(''SetFilter'',getappdata(0,''hConfigGui''));',...
                                          'TooltipString','Right click for Help','UIContextMenu',hConfigGui.mHelpContext,'UserData','General options.htm#intensity');    
                                      
hConfigGui.pGeneral.cFilterBackground = uicontrol('Parent',hConfigGui.pGeneral.pFilter,'Style','checkbox','BackgroundColor',c,'Units','normalized',...
                                          'Position',[.7 .1 .2  .8],'Tag','rFilterBackground','Fontsize',12,...
                                          'String','filter background','HorizontalAlignment','left','Value',Filter,...
                                          'TooltipString','Right click for Help','UIContextMenu',hConfigGui.mHelpContext,'UserData','General options.htm#intensity');                                       
                                      
hConfigGui.pMolecules.panel = uipanel('Parent',hConfigGui.fig,'Units','normalized','Fontsize',12,'Bordertype','none',...
                                     'Position',[0 .06 1 0.54],'Tag','pNorm','Visible','on','BackgroundColor',c);

hConfigGui.pMolecules.tTrackingOptions = uicontrol('Parent',hConfigGui.pMolecules.panel,'Style','text','Units','normalized',...
                                   'Position',[.0 .955 1 .045],'Tag','ConfigGui.TrackingOptions','Fontsize',12,...
                                   'String','Tracking options','HorizontalAlignment','center','FontWeight','bold','Enable','on',...
                                   'BackgroundColor',[0 0 1],'ForegroundColor','white');                                 
                                 
hConfigGui.pMolecules.tMoleculesM = uicontrol('Parent',hConfigGui.pMolecules.panel,'Style','text','Units','normalized',...
                                   'Position',[.0 .91 .5 .045],'Tag','ConfigGui.tMoleculesM','Fontsize',12,...
                                   'String','Molecules','HorizontalAlignment','center','FontWeight','bold','Enable','on',...
                                   'BackgroundColor',[.5 .5 1],'ForegroundColor','white');
                                   
hConfigGui.pMolecules.tFilamentsM = uicontrol('Parent',hConfigGui.pMolecules.panel,'Style','text','Units','normalized',...
                                      'Position',[.5 .91 .5 .045],'Tag','ConfigGui.tFilamentsM','Fontsize',12,...
                                      'String','Filaments','HorizontalAlignment','center','BackgroundColor',[.5 .5 .5],...
                                      'FontWeight','bold','Enable','off',...
                                      'ButtonDownFcn','fConfigGui(''FilPanel'',getappdata(0,''hConfigGui''));');

hConfigGui.pMolecules.pConnect = uipanel('Parent',hConfigGui.pMolecules.panel,'Units','normalized','Fontsize',10,'BackgroundColor',c,...
                                       'Position',[0.025 0.65 .575 .25],'Tag','pConnect','Visible','on','Title','Connecting');                                            

hConfigGui.pMolecules.tMaxVelocity = uicontrol('Parent',hConfigGui.pMolecules.pConnect,'Style','text','Units','normalized',...
                                         'Position',[.025 .7 .25  .2],'Tag','tMaxVelocity','Fontsize',12,...
                                         'String','max. Velocity:','HorizontalAlignment','left','BackgroundColor',c);                             

hConfigGui.pMolecules.eMaxVelocity = uicontrol('Parent',hConfigGui.pMolecules.pConnect,'Style','edit','Units','normalized',...
                                         'Position',[.275 .7 .1  .2],'Tag','eMaxVelocity','Fontsize',10,...
                                         'String',num2str(Config.ConnectMol.MaxVelocity),'BackgroundColor','white','HorizontalAlignment','center',...
                                         'TooltipString','Right click for Help','UIContextMenu',hConfigGui.mHelpContext,'UserData','Tracking options.htm#max_velocity');                             

hConfigGui.pMolecules.tNMpS = uicontrol('Parent',hConfigGui.pMolecules.pConnect,'Style','text','Units','normalized',...
                                    'Position',[.380 .7 .1  .2],'Tag','tNMpS','Fontsize',10,...
                                    'String','nm/s','HorizontalAlignment','left','BackgroundColor',c);           

hConfigGui.pMolecules.tNumVerification = uicontrol('Parent',hConfigGui.pMolecules.pConnect,'Style','text','Units','normalized',...
                                         'Position',[.5 .7 .325  .2],'Tag','tNumVerification','Fontsize',12,...
                                         'String','Verification Steps:','HorizontalAlignment','left','BackgroundColor',c);                             

hConfigGui.pMolecules.eNumVerification = uicontrol('Parent',hConfigGui.pMolecules.pConnect,'Style','edit','Units','normalized',...
                                         'Position',[.85 .7 .1  .2],'Tag','eNumVerification','Fontsize',10,...
                                         'String',num2str(Config.ConnectMol.NumberVerification),'BackgroundColor','white','HorizontalAlignment','center',...
                                         'TooltipString','Right click for Help','UIContextMenu',hConfigGui.mHelpContext,'UserData','Tracking options.htm#num_verification');                                   
 
hConfigGui.pMolecules.tWeightPosition = uicontrol('Parent',hConfigGui.pMolecules.pConnect,'Style','text','Units','normalized',...
                                                    'Position',[.225 .45 .2  .15],'Tag','tWeightMolecule','Fontsize',10,...
                                                    'String','Position','HorizontalAlignment','center','BackgroundColor',c); 
                                                
hConfigGui.pMolecules.tWeightDirection = uicontrol('Parent',hConfigGui.pMolecules.pConnect,'Style','text','Units','normalized',...
                                                    'Position',[.415 .45 .2  .15],'Tag','tWeightDirection','Fontsize',10,...
                                                    'String','Direction','HorizontalAlignment','center','BackgroundColor',c);  
                                                
hConfigGui.pMolecules.tWeightSpeed = uicontrol('Parent',hConfigGui.pMolecules.pConnect,'Style','text','Units','normalized',...
                                                    'Position',[.605 .45 .2  .15],'Tag','tWeightSpeed','Fontsize',10,...
                                                    'String','Speed','HorizontalAlignment','center','BackgroundColor',c);  
                                                
hConfigGui.pMolecules.tWeightIntensity  = uicontrol('Parent',hConfigGui.pMolecules.pConnect,'Style','text','Units','normalized',...
                                                    'Position',[.8 .45 .2  .15],'Tag','tWeightLength','Fontsize',10,...
                                                    'String','Intensity','HorizontalAlignment','center','BackgroundColor',c);   
                                                
hConfigGui.pMolecules.tWeights = uicontrol('Parent',hConfigGui.pMolecules.pConnect,'Style','text','Units','normalized',...
                                                    'Position',[.025 .25 .2  .2],'Tag','tWeightMolecule','Fontsize',12,...
                                                    'String','Weights:','HorizontalAlignment','left','BackgroundColor',c);    
                                                
hConfigGui.pMolecules.eWeightPos = uicontrol('Parent',hConfigGui.pMolecules.pConnect,'Style','edit','Units','normalized',...
                                              'Position',[.275 .27 .1  .18],'Tag','eWeightMolPos','Fontsize',8,...
                                              'String',num2str(Config.ConnectMol.Position*100),'BackgroundColor','white','HorizontalAlignment','center',...
                                              'TooltipString','Right click for Help','UIContextMenu',hConfigGui.mHelpContext,'UserData','Tracking options.htm#weights');             
                                          
hConfigGui.pMolecules.tPercent(1) = uicontrol('Parent',hConfigGui.pMolecules.pConnect,'Style','text','Units','normalized',...
                                              'Position',[.375 .25 .04  .18],'Tag','tPercent','Fontsize',10,'BackgroundColor',c,...
                                              'String','%','HorizontalAlignment','center');                                              
                                          
hConfigGui.pMolecules.eWeightDir = uicontrol('Parent',hConfigGui.pMolecules.pConnect,'Style','edit','Units','normalized',...
                                              'Position',[.465 .27 .1  .18],'Tag','eWeightMolDir','Fontsize',8,...
                                              'String',num2str(Config.ConnectMol.Direction*100),'BackgroundColor','white','HorizontalAlignment','center',...
                                              'TooltipString','Right click for Help','UIContextMenu',hConfigGui.mHelpContext,'UserData','Tracking options.htm#weights');      
                                          
hConfigGui.pMolecules.tPercent(2) = uicontrol('Parent',hConfigGui.pMolecules.pConnect,'Style','text','Units','normalized',...
                                              'Position',[.565 .25 .04  .18],'Tag','tPercent','Fontsize',10,...
                                              'String','%','HorizontalAlignment','center','BackgroundColor',c);                                              

hConfigGui.pMolecules.eWeightSpd = uicontrol('Parent',hConfigGui.pMolecules.pConnect,'Style','edit','Units','normalized',...
                                              'Position',[.655 .27 .1  .18],'Tag','eWeightMolSpd','Fontsize',8,...
                                              'String',num2str(Config.ConnectMol.Speed*100),'BackgroundColor','white','HorizontalAlignment','center',...
                                              'TooltipString','Right click for Help','UIContextMenu',hConfigGui.mHelpContext,'UserData','Tracking options.htm#weights');       
                                          
hConfigGui.pMolecules.tPercent(3) = uicontrol('Parent',hConfigGui.pMolecules.pConnect,'Style','text','Units','normalized',...
                                              'Position',[.755 .25 .04  .18],'Tag','tPercent','Fontsize',10,...
                                              'String','%','HorizontalAlignment','center','BackgroundColor',c);                                              
if Config.ConnectMol.UseIntensity==1
    enable='on';
else
    enable='off';
end

hConfigGui.pMolecules.eWeightInt = uicontrol('Parent',hConfigGui.pMolecules.pConnect,'Style','edit','Units','normalized',...
                                              'Position',[.85 .27 .1  .18],'Tag','eWeightMolSpd','Fontsize',8,...
                                              'String',num2str(Config.ConnectMol.IntensityOrLength*100),'BackgroundColor','white','HorizontalAlignment','center','Enable',enable,...
                                              'TooltipString','Right click for Help','UIContextMenu',hConfigGui.mHelpContext,'UserData','Tracking options.htm#weights');      
                                          
hConfigGui.pMolecules.tPercent(4) = uicontrol('Parent',hConfigGui.pMolecules.pConnect,'Style','text','Units','normalized',...
                                              'Position',[.95 .25 .04  .18],'Tag','tPercent','Fontsize',10,'BackgroundColor',c,...
                                              'String','%','HorizontalAlignment','center','Enable',enable);  
                                          
hConfigGui.pMolecules.cActivateInt = uicontrol('Parent',hConfigGui.pMolecules.pConnect,'Style','checkbox','BackgroundColor',c,'Units','normalized',...
                                              'Position',[.275 .05 .6  .18],'Tag','cActivateInt','Fontsize',10,'Value',Config.ConnectMol.UseIntensity,...
                                              'String','Use Intensity for connecting molecules','HorizontalAlignment','left',...
                                              'Callback','fConfigGui(''UseIntensity'',getappdata(0,''hConfigGui''));',...
                                              'TooltipString','Right click for Help','UIContextMenu',hConfigGui.mHelpContext,'UserData','Tracking options.htm#use_intensity');       
                                          
hConfigGui.pMolecules.pTracks = uipanel('Parent',hConfigGui.pMolecules.panel,'Units','normalized','Fontsize',10,'BackgroundColor',c,...
                                        'Position',[0.65 0.65 .325 .25],'Tag','pConnect','Visible','on','Title','Tracks');      
                                    
hConfigGui.pMolecules.tMinLength = uicontrol('Parent',hConfigGui.pMolecules.pTracks,'Style','text','Units','normalized',...
                                         'Position',[.025 .7 .55  .2],'Tag','tMinLength','Fontsize',12,'BackgroundColor',c,...
                                         'String','Minimum Length:','HorizontalAlignment','left');                             

hConfigGui.pMolecules.eMinLength = uicontrol('Parent',hConfigGui.pMolecules.pTracks,'Style','edit','Units','normalized',...
                                         'Position',[.6 .7 .2  .2],'Tag','eMinLength','Fontsize',10,...
                                         'String',num2str(Config.ConnectMol.MinLength),'BackgroundColor','white','HorizontalAlignment','center',...
                                         'TooltipString','Right click for Help','UIContextMenu',hConfigGui.mHelpContext,'UserData','Tracking options.htm#min_length');              
                                     
hConfigGui.pMolecules.tFramesMin = uicontrol('Parent',hConfigGui.pMolecules.pTracks,'Style','text','Units','normalized',...
                                         'Position',[.815 .69 .18  .2],'Tag','tFrames','Fontsize',10,'BackgroundColor',c,...
                                         'String','frames','HorizontalAlignment','left');                                                                             

hConfigGui.pMolecules.tMaxBreak = uicontrol('Parent',hConfigGui.pMolecules.pTracks,'Style','text','Units','normalized',...
                                         'Position',[.025 .4 .55  .2],'Tag','tMaxBreak','Fontsize',12,...
                                         'String','Maximum Break:','HorizontalAlignment','left','BackgroundColor',c);                             

hConfigGui.pMolecules.eMaxBreak = uicontrol('Parent',hConfigGui.pMolecules.pTracks,'Style','edit','Units','normalized',...
                                         'Position',[.6 .4 .2  .2],'Tag','eMaxBreak','Fontsize',10,...
                                         'String',num2str(Config.ConnectMol.MaxBreak),'BackgroundColor','white','HorizontalAlignment','center',...
                                         'TooltipString','Right click for Help','UIContextMenu',hConfigGui.mHelpContext,'UserData','Tracking options.htm#max_break');  
                                     
hConfigGui.pMolecules.tFramesMax = uicontrol('Parent',hConfigGui.pMolecules.pTracks,'Style','text','Units','normalized',...
                                         'Position',[.815 .39 .18  .2],'Tag','tFrames','Fontsize',10,'BackgroundColor',c,...
                                         'String','frames','HorizontalAlignment','left');                                        
                                     
hConfigGui.pMolecules.tMaxAngle = uicontrol('Parent',hConfigGui.pMolecules.pTracks,'Style','text','Units','normalized',...
                                         'Position',[.025 .1 .55  .2],'Tag','tMaxAngle','Fontsize',12,...
                                         'String','Maximum Angle:','HorizontalAlignment','left','BackgroundColor',c);                             

hConfigGui.pMolecules.eMaxAngle = uicontrol('Parent',hConfigGui.pMolecules.pTracks,'Style','edit','Units','normalized',...
                                         'Position',[.6 .1 .2  .2],'Tag','eMaxAngle','Fontsize',10,...
                                         'String',num2str(Config.ConnectMol.MaxAngle),'BackgroundColor','white','HorizontalAlignment','center',...
                                         'TooltipString','Right click for Help','UIContextMenu',hConfigGui.mHelpContext,'UserData','Tracking options.htm#max_angle');                   
                                     
hConfigGui.pMolecules.tDeg = uicontrol('Parent',hConfigGui.pMolecules.pTracks,'Style','text','Units','normalized',...
                                         'Position',[.815 .11 .1  .2],'Tag','tDeg','Fontsize',14,...
                                         'String',char(176),'HorizontalAlignment','left','BackgroundColor',c);                                  
                                     
hConfigGui.pMolecules.pModel = uipanel('Parent',hConfigGui.pMolecules.panel,'Units','normalized','Fontsize',10,'BackgroundColor',c,...
                                       'Position',[0.025 0.025 .95 .6],'Tag','pModel','Visible','on','Title','Model');      
                                      
hConfigGui.pMolecules.tMaxFunc = uicontrol('Parent',hConfigGui.pMolecules.pModel,'Style','text','Units','normalized',...
                                         'Position',[.025 .9 .3 .075],'Tag','tMaxFunc','Fontsize',12,'BackgroundColor',c,...
                                         'String','Maximum Number of functions:','HorizontalAlignment','left');                                 

hConfigGui.pMolecules.eMaxFunc = uicontrol('Parent',hConfigGui.pMolecules.pModel,'Style','edit','Units','normalized',...
                                         'Position',[.325 .9 .05 .075],'Tag','eMaxFunc','Fontsize',10,...
                                         'String',num2str(Config.MaxFunc),'BackgroundColor','white',...
                                         'TooltipString','Right click for Help','UIContextMenu',hConfigGui.mHelpContext,...
                                         'UserData','Tracking options.htm#model',...
                                         'Callback','fConfigGui(''UpdateParams'',getappdata(0,''hConfigGui''));'); 

hConfigGui.pMolecules.tParams = uicontrol('Parent',hConfigGui.pMolecules.pModel,'Style','text','Units','normalized',...
                                         'Position',[.4 .9 .1 .075],'Tag','tMaxFunc','Fontsize',12,...
                                         'String','Parameter:','HorizontalAlignment','left','BackgroundColor',c);                                 

hConfigGui.pMolecules.eParams = uicontrol('Parent',hConfigGui.pMolecules.pModel,'Style','text','Units','normalized',...
                                         'Position',[.525 .9 .05 .075],'Tag','eMaxFunc','Fontsize',12,...
                                         'String','','Enable','inactive',...
                                         'TooltipString','Right click for Help','UIContextMenu',hConfigGui.mHelpContext,'UserData','Tracking options.htm#model');                                      

%define available models
str={'Symmetric 2D-Gaussian',...
     'Stretched 2D-Gaussian',...
     'Symmetric 2D-Gaussian plus Gaussian Ring'}; %,...
%     'Symmetric 2D-Gaussian plus two opposing Gaussian Rings'};

hConfigGui.pMolecules.mModel = uicontrol('Parent',hConfigGui.pMolecules.pModel,'Style','popupmenu','Units','normalized',...
                                          'Position',[.025 .8 .55 .075],'Tag','rSymmetricGauss','Fontsize',12,'String',str,...
                                          'Callback','fConfigGui(''ShowModel'',getappdata(0,''hConfigGui''));','Value',0,...
                                          'TooltipString','Right click for Help','UIContextMenu',hConfigGui.mHelpContext,...
                                          'UserData','Tracking options.htm#model','BackgroundColor','white');    
                                      
if strcmp(Config.Model,'GaussSymmetric')
    set(hConfigGui.pMolecules.mModel,'Value',1);
elseif strcmp(Config.Model,'GaussStretched')
    set(hConfigGui.pMolecules.mModel,'Value',2);
elseif strcmp(Config.Model,'GaussPlusRing')
    set(hConfigGui.pMolecules.mModel,'Value',3);    
else
    set(hConfigGui.pMolecules.mModel,'Value',4);
end

hConfigGui.pMolecules.aModelLabel = axes('Parent',hConfigGui.pMolecules.pModel,'Units','normalized',....
                                            'Position',[0.025 .325 .55 .4],'Tag','aModelLabel','Visible','off');  

hConfigGui.pMolecules.aModelPreview = axes('Parent',hConfigGui.pMolecules.pModel,'Units','normalized',....
                                            'Position',[.55 .325 .45 .55],'Tag','aModelPreview','Visible','off');     
                                        
hConfigGui.pMolecules.aModelEquation = axes('Parent',hConfigGui.pMolecules.pModel,'Units','normalized',....
                                            'Position',[0.025 .025 .95 .225],'Tag','aModelEquation','Visible','off');         

ShowModel(hConfigGui);

hConfigGui.pFilaments.panel = uipanel('Parent',hConfigGui.fig,'Units','normalized','Fontsize',12,'Bordertype','none',...
                                     'Position',[0 .06 1 0.54],'Tag','pNorm','Visible','off','BackgroundColor',c);

hConfigGui.pFilaments.tTrackingOptions = uicontrol('Parent',hConfigGui.pFilaments.panel,'Style','text','Units','normalized',...
                                   'Position',[.0 .955 1 .045],'Tag','ConfigGui.tTrackingOptions','Fontsize',12,...
                                   'String','Tracking options','HorizontalAlignment','center','FontWeight','bold','Enable','on',...
                                   'BackgroundColor',[0 0 1],'ForegroundColor','white');                                 
                               
hConfigGui.pFilaments.tMoleculesM = uicontrol('Parent',hConfigGui.pFilaments.panel,'Style','text','Units','normalized',...
                                     'Position',[.0 .91 .5 .045],'Tag','ConfigGui.tMoleculesM','Fontsize',12,...
                                     'String','Molecules','HorizontalAlignment','center','BackgroundColor',[.5 .5 .5],...
                                     'FontWeight','bold','Enable','off',...
                                     'ButtonDownFcn','fConfigGui(''MolPanel'',getappdata(0,''hConfigGui''));');
  
                                   
hConfigGui.pFilaments.tFilamentsM = uicontrol('Parent',hConfigGui.pFilaments.panel,'Style','text','Units','normalized',...
                                      'Position',[.5 .91 .5 .045],'Tag','ConfigGui.tFilamentsM','Fontsize',12,...
                                      'String','Filaments','HorizontalAlignment','center','FontWeight','bold','Enable','on',...
                                      'BackgroundColor',[.5 .5 1],'ForegroundColor','white');

hConfigGui.pFilaments.pConnect = uipanel('Parent',hConfigGui.pFilaments.panel,'Units','normalized','Fontsize',10,'BackgroundColor',c,...
                                       'Position',[0.025 0.65 .575 .25],'Tag','pConnect','Visible','on','Title','Connecting');                                            

hConfigGui.pFilaments.tMaxVelocity = uicontrol('Parent',hConfigGui.pFilaments.pConnect,'Style','text','Units','normalized',...
                                         'Position',[.025 .7 .25  .2],'Tag','tMaxVelocity','Fontsize',12,...
                                         'String','max. Velocity:','HorizontalAlignment','left','BackgroundColor',c);                             

hConfigGui.pFilaments.eMaxVelocity = uicontrol('Parent',hConfigGui.pFilaments.pConnect,'Style','edit','Units','normalized',...
                                         'Position',[.275 .7 .1  .2],'Tag','eMaxVelocity','Fontsize',10,...
                                         'String',num2str(Config.ConnectFil.MaxVelocity),'BackgroundColor','white','HorizontalAlignment','center',...
                                         'TooltipString','Right click for Help','UIContextMenu',hConfigGui.mHelpContext,'UserData','Tracking options.htm#max_velocity');                                   

hConfigGui.pFilaments.tNMpS = uicontrol('Parent',hConfigGui.pFilaments.pConnect,'Style','text','Units','normalized',...
                                    'Position',[.380 .7 .1  .2],'Tag','tNMpS','Fontsize',10,'BackgroundColor',c,...
                                    'String','nm/s','HorizontalAlignment','left');        
                                
hConfigGui.pFilaments.tNumVerification = uicontrol('Parent',hConfigGui.pFilaments.pConnect,'Style','text','Units','normalized',...
                                         'Position',[.5 .7 .325  .2],'Tag','tNumVerification','Fontsize',12,'BackgroundColor',c,...
                                         'String','Verification Steps:','HorizontalAlignment','left');                             

hConfigGui.pFilaments.eNumVerification = uicontrol('Parent',hConfigGui.pFilaments.pConnect,'Style','edit','Units','normalized',...
                                         'Position',[.85 .7 .1  .2],'Tag','eNumVerification','Fontsize',10,...
                                         'String',num2str(Config.ConnectFil.NumberVerification),'BackgroundColor','white','HorizontalAlignment','center',...
                                         'TooltipString','Right click for Help','UIContextMenu',hConfigGui.mHelpContext,'UserData','Tracking options.htm#num_verification');                                 
 
hConfigGui.pFilaments.tWeightPosition = uicontrol('Parent',hConfigGui.pFilaments.pConnect,'Style','text','Units','normalized',...
                                                    'Position',[.225 .45 .2  .15],'Tag','tWeightMolecule','Fontsize',10,...
                                                    'String','Position','HorizontalAlignment','center','BackgroundColor',c); 
                                                
hConfigGui.pFilaments.tWeightDirection = uicontrol('Parent',hConfigGui.pFilaments.pConnect,'Style','text','Units','normalized',...
                                                    'Position',[.415 .45 .2  .15],'Tag','tWeightDirection','Fontsize',10,...
                                                    'String','Direction','HorizontalAlignment','center','BackgroundColor',c);  
                                                
hConfigGui.pFilaments.tWeightSpeed = uicontrol('Parent',hConfigGui.pFilaments.pConnect,'Style','text','Units','normalized',...
                                                    'Position',[.605 .45 .2  .15],'Tag','tWeightSpeed','Fontsize',10,...
                                                    'String','Speed','HorizontalAlignment','center','BackgroundColor',c);  
                                                
hConfigGui.pFilaments.tWeightLength  = uicontrol('Parent',hConfigGui.pFilaments.pConnect,'Style','text','Units','normalized',...
                                                    'Position',[.8 .45 .2  .15],'Tag','tWeightLength','Fontsize',10,...
                                                    'String','Length','HorizontalAlignment','center','BackgroundColor',c);   
                                                
hConfigGui.pFilaments.tWeights = uicontrol('Parent',hConfigGui.pFilaments.pConnect,'Style','text','Units','normalized',...
                                                    'Position',[.025 .25 .2  .2],'Tag','tWeightFilament','Fontsize',12,...
                                                    'String','Weights:','HorizontalAlignment','left','BackgroundColor',c);    
                                                
hConfigGui.pFilaments.eWeightPos = uicontrol('Parent',hConfigGui.pFilaments.pConnect,'Style','edit','Units','normalized',...
                                                'Position',[.275 .27 .1  .18],'Tag','eWeightFilPos','Fontsize',8,...
                                                'String',num2str(Config.ConnectFil.Position*100),'BackgroundColor','white','HorizontalAlignment','center',...
                                                'TooltipString','Right click for Help','UIContextMenu',hConfigGui.mHelpContext,'UserData','Tracking options.htm#weights');                                                          

hConfigGui.pFilaments.tPercent(1) = uicontrol('Parent',hConfigGui.pFilaments.pConnect,'Style','text','Units','normalized',...
                                              'Position',[.375 .25 .04  .18],'Tag','tPercent','Fontsize',10,...
                                              'String','%','HorizontalAlignment','center','BackgroundColor',c);                     
                                          
hConfigGui.pFilaments.eWeightDir = uicontrol('Parent',hConfigGui.pFilaments.pConnect,'Style','edit','Units','normalized',...
                                              'Position',[.465 .27 .1  .18],'Tag','eWeightFilDir','Fontsize',8,...
                                              'String',num2str(Config.ConnectFil.Direction*100),'BackgroundColor','white','HorizontalAlignment','center',...
                                              'TooltipString','Right click for Help','UIContextMenu',hConfigGui.mHelpContext,'UserData','Tracking options.htm#weights');  
                                          
hConfigGui.pFilaments.tPercent(2) = uicontrol('Parent',hConfigGui.pFilaments.pConnect,'Style','text','Units','normalized',...
                                              'Position',[.565 .25 .04  .18],'Tag','tPercent','Fontsize',10,...
                                              'String','%','HorizontalAlignment','center','BackgroundColor',c);                                                
                                          
hConfigGui.pFilaments.eWeightSpd = uicontrol('Parent',hConfigGui.pFilaments.pConnect,'Style','edit','Units','normalized',...
                                              'Position',[.655 .27 .1  .18],'Tag','eWeightFilSpd','Fontsize',8,...
                                              'String',num2str(Config.ConnectFil.Speed*100),'BackgroundColor','white','HorizontalAlignment','center',...
                                              'TooltipString','Right click for Help','UIContextMenu',hConfigGui.mHelpContext,'UserData','Tracking options.htm#weights');  
                                          
hConfigGui.pFilaments.tPercent(3) = uicontrol('Parent',hConfigGui.pFilaments.pConnect,'Style','text','Units','normalized',...
                                              'Position',[.755 .25 .04  .18],'Tag','tPercent','Fontsize',10,...
                                              'String','%','HorizontalAlignment','center','BackgroundColor',c);                                                
                                          
hConfigGui.pFilaments.eWeightLen = uicontrol('Parent',hConfigGui.pFilaments.pConnect,'Style','edit','Units','normalized',...
                                              'Position',[.85 .27 .1  .18],'Tag','eWeightFilLen','Fontsize',8,...
                                              'String',num2str(Config.ConnectFil.IntensityOrLength*100),'BackgroundColor','white','HorizontalAlignment','center',...
                                              'TooltipString','Right click for Help','UIContextMenu',hConfigGui.mHelpContext,'UserData','Tracking options.htm#weights');          
                                          
hConfigGui.pFilaments.tPercent(4) = uicontrol('Parent',hConfigGui.pFilaments.pConnect,'Style','text','Units','normalized',...
                                              'Position',[.95 .25 .04  .18],'Tag','tPercent','Fontsize',10,...
                                              'String','%','HorizontalAlignment','center','BackgroundColor',c);            
                                       
hConfigGui.pFilaments.cDisregardEdge = uicontrol('Parent',hConfigGui.pFilaments.pConnect,'Style','checkbox','BackgroundColor',c,'Units','normalized',...
                                              'Position',[.275 .05 .6  .18],'Tag','cDisregardEdge','Fontsize',10,'Value',Config.ConnectFil.DisregardEdge,...
                                              'String','Disregard filaments at the edge of the field of view','HorizontalAlignment','left',...
                                              'TooltipString','Right click for Help','UIContextMenu',hConfigGui.mHelpContext,'UserData','Tracking options.htm#disregard_edge');      
                                          
hConfigGui.pFilaments.pTracks = uipanel('Parent',hConfigGui.pFilaments.panel,'Units','normalized','Fontsize',10,'BackgroundColor',c,...
                                        'Position',[0.65 0.65 .325 .25],'Tag','pConnect','Visible','on','Title','Tracks');      
                                    
hConfigGui.pFilaments.tMinLength = uicontrol('Parent',hConfigGui.pFilaments.pTracks,'Style','text','Units','normalized',...
                                         'Position',[.025 .7 .55  .2],'Tag','tMinLength','Fontsize',12,...
                                         'String','Minimum Length:','HorizontalAlignment','left','BackgroundColor',c);                             

hConfigGui.pFilaments.eMinLength = uicontrol('Parent',hConfigGui.pFilaments.pTracks,'Style','edit','Units','normalized',...
                                         'Position',[.6 .7 .2  .2],'Tag','eMinLength','Fontsize',10,...
                                         'String',num2str(Config.ConnectFil.MinLength),'BackgroundColor','white','HorizontalAlignment','center',...
                                                'TooltipString','Right click for Help','UIContextMenu',hConfigGui.mHelpContext,'UserData','Tracking options.htm#min_length');     
                                            
hConfigGui.pFilaments.tFramesMin = uicontrol('Parent',hConfigGui.pFilaments.pTracks,'Style','text','Units','normalized',...
                                         'Position',[.815 .69 .18  .2],'Tag','tFrames','Fontsize',10,...
                                         'String','frames','HorizontalAlignment','left','BackgroundColor',c);                                                                                                                                     

hConfigGui.pFilaments.tMaxBreak = uicontrol('Parent',hConfigGui.pFilaments.pTracks,'Style','text','Units','normalized',...
                                         'Position',[.025 .4 .6  .2],'Tag','tMaxBreak','Fontsize',12,...
                                         'String','Maximum Break:','HorizontalAlignment','left','BackgroundColor',c);                             

hConfigGui.pFilaments.eMaxBreak = uicontrol('Parent',hConfigGui.pFilaments.pTracks,'Style','edit','Units','normalized',...
                                         'Position',[.6 .4 .2  .2],'Tag','eMaxBreak','Fontsize',10,...
                                         'String',num2str(Config.ConnectFil.MaxBreak),'BackgroundColor','white','HorizontalAlignment','center',...
                                                'TooltipString','Right click for Help','UIContextMenu',hConfigGui.mHelpContext,'UserData','Tracking options.htm#max_break');       
                                            
hConfigGui.pFilaments.tFramesMax = uicontrol('Parent',hConfigGui.pFilaments.pTracks,'Style','text','Units','normalized',...
                                         'Position',[.815 .39 .18  .2],'Tag','tFrames','Fontsize',10,...
                                         'String','frames','HorizontalAlignment','left','BackgroundColor',c);                                                                                         
                                            
hConfigGui.pFilaments.tMaxAngle = uicontrol('Parent',hConfigGui.pFilaments.pTracks,'Style','text','Units','normalized',...
                                         'Position',[.025 .1 .55  .2],'Tag','tMaxAngle','Fontsize',12,...
                                         'String','Maximum Angle:','HorizontalAlignment','left','BackgroundColor',c);                             

hConfigGui.pFilaments.eMaxAngle = uicontrol('Parent',hConfigGui.pFilaments.pTracks,'Style','edit','Units','normalized',...
                                         'Position',[.6 .1 .2  .2],'Tag','eMaxAngle','Fontsize',10,...
                                         'String',num2str(Config.ConnectFil.MaxAngle),'BackgroundColor','white','HorizontalAlignment','center',...
                                         'TooltipString','Right click for Help','UIContextMenu',hConfigGui.mHelpContext,'UserData','Tracking options.htm#max_angle');                   
                                     
hConfigGui.pFilaments.tDeg = uicontrol('Parent',hConfigGui.pFilaments.pTracks,'Style','text','Units','normalized',...
                                         'Position',[.815 .11 .1  .2],'Tag','tDeg','Fontsize',14,...
                                         'String',char(176),'HorizontalAlignment','left','BackgroundColor',c);                                             
                                                                           
hConfigGui.pFilaments.pRefPoint = uipanel('Parent',hConfigGui.pFilaments.panel,'Units','normalized','Fontsize',10,'BackgroundColor',c,...
                                             'Position',[0.025 0.475 .95 .15],'Tag','pConnect','Visible','on','Title','Reference Point');       

Value=0;                   
if strcmp(Config.RefPoint,'start')==1
    Value=1;
end

hConfigGui.pRefPoint.rStart = uicontrol('Parent',hConfigGui.pFilaments.pRefPoint,'Style','radiobutton','BackgroundColor',c,'Units','normalized',...
                                        'Position',[.025 .2 .3  .6],'Tag','rStart','Fontsize',12,...
                                        'String','Start Point','HorizontalAlignment','left','Value',Value,...
                                        'Callback','fConfigGui(''SetRefPoint'',getappdata(0,''hConfigGui''));',...
                                        'TooltipString','Right click for Help','UIContextMenu',hConfigGui.mHelpContext,'UserData','Tracking options.htm#reference_point');               
                                      
Value=0;                   
if strcmp(Config.RefPoint,'center')==1
    Value=1;
end

hConfigGui.pRefPoint.rCenter = uicontrol('Parent',hConfigGui.pFilaments.pRefPoint,'Style','radiobutton','BackgroundColor',c,'Units','normalized',...
                                        'Position',[.35 .2 .3  .6],'Tag','rCenter','Fontsize',12,...
                                        'String','Center Point','HorizontalAlignment','left','Value',Value,...
                                        'Callback','fConfigGui(''SetRefPoint'',getappdata(0,''hConfigGui''));',...
                                        'TooltipString','Right click for Help','UIContextMenu',hConfigGui.mHelpContext,'UserData','Tracking options.htm#reference_point');                  
Value=0;                   
if strcmp(Config.RefPoint,'end')==1
    Value=1;
end

hConfigGui.pRefPoint.rEnd = uicontrol('Parent',hConfigGui.pFilaments.pRefPoint,'Style','radiobutton','BackgroundColor',c,'Units','normalized',...
                                        'Position',[.675 .2 .3  .6],'Tag','rEnd','Fontsize',12,...
                                        'String','End Point','HorizontalAlignment','left','Value',Value,...
                                        'Callback','fConfigGui(''SetRefPoint'',getappdata(0,''hConfigGui''));',...
                                        'TooltipString','Right click for Help','UIContextMenu',hConfigGui.mHelpContext,'UserData','Tracking options.htm#reference_point');     

hConfigGui.pFilaments.pExperimental = uipanel('Parent',hConfigGui.pFilaments.panel,'Units','normalized','Fontsize',10,'BackgroundColor',c,...
                                             'Position',[0.025 0.100 .95 .35],'Tag','pExperimental','Visible','on','Title','Experimental Options'); 
                                         
hConfigGui.pFilaments.tExperimental = uicontrol('Parent',hConfigGui.pFilaments.pExperimental,'Style','text','Units','normalized',...
                                         'Position',[.025 .8 .9  .15],'Tag','tExperimental','Fontsize',10,...
                                         'String','The following options are experimental and require more testing!','HorizontalAlignment','left','BackgroundColor',c); 
                                         
hConfigGui.pExperimental.cFocus = uicontrol('Parent',hConfigGui.pFilaments.pExperimental,'Style','checkbox','BackgroundColor',c,'Units','normalized',...
                                        'Position',[.025 .55 .9  .2],'Tag','cFocus','Fontsize',10,...
                                        'String','Correct for focus drift - different reference points for filament tips','HorizontalAlignment','left','Value',Config.FilFocus,...
                                        'TooltipString','Right click for Help','UIContextMenu',hConfigGui.mHelpContext,'UserData','Tracking options.htm#reference_point');   
                                    
hConfigGui.pExperimental.cCurvedFil = uicontrol('Parent',hConfigGui.pFilaments.pExperimental,'Style','checkbox','BackgroundColor',c,'Units','normalized',...
                                                'Position',[.025 .3 .55  .2],'Tag','cCurvedFil','Fontsize',10,...
                                                'String','Track especially curved filaments - reduce fit box size by:','HorizontalAlignment','left','Value',Config.ReduceFitBox<1,...
                                                'TooltipString','Right click for Help','UIContextMenu',hConfigGui.mHelpContext,'UserData','Tracking options.htm#reference_point');    
                                            
hConfigGui.pExperimental.eReduceFitBox = uicontrol('Parent',hConfigGui.pFilaments.pExperimental,'Style','edit','BackgroundColor','white','Units','normalized',...
                                                    'Position',[.6 .3 .1  .2],'Tag','eReduceFitBox','Fontsize',10,...
                                                    'String',num2str(Config.ReduceFitBox*100),'HorizontalAlignment','center','Enable','on',....
                                                    'TooltipString','Right click for Help','UIContextMenu',hConfigGui.mHelpContext,'UserData','Tracking options.htm#reference_point');     
 
uicontrol('Parent',hConfigGui.pFilaments.pExperimental,'Style','text','BackgroundColor',c,'Units','normalized',...
          'Position',[.71 .26 .25  .2],'Tag','percent','Fontsize',12,'Enable','on',...
          'String','%   (25% - 100%)','HorizontalAlignment','left');
      
if ~isfield(Config,'DynamicFil')   
    Config.DynamicFil = 0;
end
hConfigGui.pExperimental.cDynamicFil = uicontrol('Parent',hConfigGui.pFilaments.pExperimental,'Style','checkbox','BackgroundColor',c,'Units','normalized',...
                                                'Position',[.025 .05 .55  .2],'Tag','cDynamicFil','Fontsize',10,...
                                                'String','Track dynamic filaments','HorizontalAlignment','left','Value',Config.DynamicFil,...
                                                'TooltipString','Right click for Help','UIContextMenu',hConfigGui.mHelpContext,'UserData','Tracking options.htm#reference_point');                                                  
                                                                                                                                                                                                            
hConfigGui.pButtons = uipanel('Parent',hConfigGui.fig,'Units','normalized','Fontsize',12,'Bordertype','none',...
                                     'Position',[0 0 1 0.06],'Tag','pNorm','Visible','on','BackgroundColor',c);
                                 
hConfigGui.bApply = uicontrol('Parent',hConfigGui.pButtons,'Style','pushbutton','Units','normalized',...
                              'Position',[.5 .2 .2 .7],'Tag','bOkay','Fontsize',12,...
                              'String','Apply','Callback','fConfigGui(''OK'',getappdata(0,''hConfigGui''));');                       
                          
hConfigGui.bCancel= uicontrol('Parent',hConfigGui.pButtons,'Style','pushbutton','Units','normalized',...
                              'Position',[.75 .2 .2 .7],'Tag','bCancel','Fontsize',12,...
                              'String','Cancel','Callback','close(findobj(0,''Tag'',''hConfigGui''));');                          
                                  
set(hConfigGui.fig, 'CloseRequestFcn',@Close);                          
setappdata(0,'hConfigGui',hConfigGui);

function Close(hObject,eventdata)
delete(findobj('Tag','hConfigGui'));
fShared('ReturnFocus');

function MolPanel(hConfigGui)
set(hConfigGui.pMolecules.panel,'Visible','on');
set(hConfigGui.pFilaments.panel,'Visible','off');

function FilPanel(hConfigGui)
set(hConfigGui.pMolecules.panel,'Visible','off');
set(hConfigGui.pFilaments.panel,'Visible','on');

function OnlyTrack(hConfigGui)
if get(gcbo,'Value')==1
    if gcbo==hConfigGui.pGeneral.cMolFull
        set(hConfigGui.pGeneral.cFilFull,'Value',0);
    elseif gcbo==hConfigGui.pGeneral.cFilFull
        set(hConfigGui.pGeneral.cMolFull,'Value',0);
    end
end
choice = cell2mat(get(get(hConfigGui.pGeneral.pTrack,'Children'),'Value'));
if choice(2) || choice(4)
    set(hConfigGui.pGeneral.tAreaThreshold,'Enable','off');
    set(hConfigGui.pGeneral.eAreaThreshold,'Enable','off');
    set(hConfigGui.pGeneral.tPix,'Enable','off');
else
    set(hConfigGui.pGeneral.tAreaThreshold,'Enable','on');
    set(hConfigGui.pGeneral.eAreaThreshold,'Enable','on');
    set(hConfigGui.pGeneral.tPix,'Enable','on');
end
    

function UseIntensity(hConfigGui)
if get(gcbo,'Value')==1
    set(hConfigGui.pMolecules.eWeightInt,'Enable','on');
else
    set(hConfigGui.pMolecules.eWeightInt,'Enable','off');
end


function UseServer(hConfigGui)
if get(gcbo,'Value')==1
    set(hConfigGui.pGeneral.tServerName,'Enable','on');
    set(hConfigGui.pGeneral.eServerName,'Enable','on');
else
    set(hConfigGui.pGeneral.tServerName,'Enable','off');
    set(hConfigGui.pGeneral.eServerName,'Enable','off');
end

function SetThreshold(hConfigGui)
if gcbo==hConfigGui.pGeneral.rVariable
    set(hConfigGui.pGeneral.rVariable,'Value',1);
    set(hConfigGui.pGeneral.rConstant,'Value',0);
    set(hConfigGui.pGeneral.rRelative,'Value',0);
elseif gcbo==hConfigGui.pGeneral.rConstant
    set(hConfigGui.pGeneral.rVariable,'Value',0);
    set(hConfigGui.pGeneral.rConstant,'Value',1);
    set(hConfigGui.pGeneral.rRelative,'Value',0);
else
    set(hConfigGui.pGeneral.rVariable,'Value',0);
    set(hConfigGui.pGeneral.rConstant,'Value',0);
    set(hConfigGui.pGeneral.rRelative,'Value',1);
end
 
function SetFilter(hConfigGui)
if gcbo==hConfigGui.pGeneral.rFilterNone
    set(hConfigGui.pGeneral.rFilterNone,'Value',1);
    set(hConfigGui.pGeneral.rFilterAverage,'Value',0);
    set(hConfigGui.pGeneral.rFilterSmooth,'Value',0);
elseif gcbo==hConfigGui.pGeneral.rFilterAverage
    set(hConfigGui.pGeneral.rFilterNone,'Value',0);
    set(hConfigGui.pGeneral.rFilterAverage,'Value',1);
    set(hConfigGui.pGeneral.rFilterSmooth,'Value',0);
else
    set(hConfigGui.pGeneral.rFilterNone,'Value',0);
    set(hConfigGui.pGeneral.rFilterAverage,'Value',0);
    set(hConfigGui.pGeneral.rFilterSmooth,'Value',1);
end

function ParallelProcessing(hConfigGui)
global Config;
value = get(hConfigGui.pGeneral.mParallelProcessing,'Value');
if value == 1
    str = '';
    server = '';
    visible = 'off';
elseif value == 2
    str = ['Num Cores (max. ' num2str(feature('numCores')) '):'];
    if isempty(Config.TrackingServer)
        server = num2str(feature('numCores'));
    elseif strncmp(Config.TrackingServer,'local',5)
        server = Config.TrackingServer(6:end);
    else
        server = num2str(feature('numCores'));
    end
    visible = 'on';
else
    str = 'Computer Name:';
    if strncmp(Config.TrackingServer,'local',5)
        server = '';
    else
        server = Config.TrackingServer;
    end
    visible = 'on';
end
set(hConfigGui.pGeneral.tField,'String',str);
set(hConfigGui.pGeneral.eField,'String',server,'Visible',visible);

function SetRefPoint(hConfigGui)
if gcbo==hConfigGui.pRefPoint.rStart
    set(hConfigGui.pRefPoint.rStart,'Value',1);
    set(hConfigGui.pRefPoint.rCenter,'Value',0);
    set(hConfigGui.pRefPoint.rEnd,'Value',0);
elseif gcbo==hConfigGui.pRefPoint.rCenter
    set(hConfigGui.pRefPoint.rStart,'Value',0);
    set(hConfigGui.pRefPoint.rCenter,'Value',1);
    set(hConfigGui.pRefPoint.rEnd,'Value',0);
else
    set(hConfigGui.pRefPoint.rStart,'Value',0);
    set(hConfigGui.pRefPoint.rCenter,'Value',0);
    set(hConfigGui.pRefPoint.rEnd,'Value',1);
end    

function ConfigGuiOK(hConfigGui)
global Config;
global Filament;
global TimeInfo;
hMainGui=getappdata(0,'hMainGui');
nCh = getChIdx;
err=[];
tempConfig = Config;
tempConfig.PixSize=str2double(get(hConfigGui.pGeneral.ePixSize,'String'));
if tempConfig.PixSize<=0||isnan(tempConfig.PixSize)
    err{length(err)+1}='Wrong pixel size input';
else
    hMainGui.Values.PixSize=tempConfig.PixSize;
end

if strcmp(tempConfig.StackType{nCh-1},'TIFF')==1&&hMainGui.Values.MaxIdx(nCh)>1
    tempConfig.Time(nCh-1) = str2double(get(hConfigGui.pGeneral.eTimeDiff,'String'));
    if tempConfig.Time(nCh-1)<=0||isnan(tempConfig.Time(nCh-1))
        err{length(err)+1}='Wrong time difference input for TIFF file';
    end
end

tempConfig.FirstTFrame=round(str2double(get(hConfigGui.pGeneral.eFirstFrame,'String')));
if tempConfig.FirstTFrame<0||isnan(tempConfig.FirstTFrame)||tempConfig.FirstTFrame>max(hMainGui.Values.MaxIdx)
    err{length(err)+1}='First frame input wrong or out of range';
else
    tempConfig.FirstCFrame=tempConfig.FirstTFrame;
end

tempConfig.LastFrame=str2double(get(hConfigGui.pGeneral.eLastFrame,'String'));
if tempConfig.LastFrame<0||isnan(tempConfig.LastFrame)||tempConfig.LastFrame>max(hMainGui.Values.MaxIdx)
    err{length(err)+1}='Last frame input wrong or out of range';
elseif tempConfig.FirstTFrame<0||isnan(tempConfig.FirstTFrame)
    err{length(err)+1}='First frame input wrong or out of range';    
end

if get(hConfigGui.pGeneral.mParallelProcessing,'Value')==1
    tempConfig.TrackingServer = '';
elseif get(hConfigGui.pGeneral.mParallelProcessing,'Value')==2
    cores = str2double(get(hConfigGui.pGeneral.eField,'String'));
    if cores>feature('numCores')
        err{length(err)+1}='Maximum number of cores exceeded';
    end
    tempConfig.TrackingServer = ['local' num2str(cores)];
else 
    tempConfig.TrackingServer = get(hConfigGui.pGeneral.eField,'String');
    if ~isempty(tempConfig.TrackingServer)
        CheckServer(tempConfig);
    end
end

tempConfig.OnlyTrack.MolFull=get(hConfigGui.pGeneral.cMolFull,'Value');
tempConfig.OnlyTrack.FilFull=get(hConfigGui.pGeneral.cFilFull,'Value');
tempConfig.OnlyTrack.IncludeData=get(hConfigGui.pGeneral.cIncludeFitData,'Value');

tempConfig.Threshold.Area=str2double(get(hConfigGui.pGeneral.eAreaThreshold,'String'));
if tempConfig.Threshold.Area<=0||isnan(tempConfig.Threshold.Area)
    err{length(err)+1}='Wrong area threshold input';
end

tempConfig.Threshold.Height=str2double(get(hConfigGui.pGeneral.eHeightThreshold,'String'));
if tempConfig.Threshold.Height<=0||isnan(tempConfig.Threshold.Height)
    err{length(err)+1}='Wrong height threshold input';
end

tempConfig.Threshold.Fit=str2double(get(hConfigGui.pGeneral.eFitThreshold,'String'));
if tempConfig.Threshold.Fit<-1||isnan(tempConfig.Threshold.Area)||tempConfig.Threshold.Fit>1
    err{length(err)+1}='Coefficient of determination must be between -1 and 1';
end

tempConfig.Threshold.FWHM=str2double(get(hConfigGui.pGeneral.eFWHM,'String'));
if tempConfig.Threshold.FWHM<=0||isnan(tempConfig.Threshold.FWHM)
     err{length(err)+1}='Wrong FWHM estimate input';
end

if tempConfig.Threshold.FWHM<2*tempConfig.PixSize
     err{length(err)+1}='FWHM estimate is smaller than 2 pixels';
end

tempConfig.BorderMargin=str2double(get(hConfigGui.pGeneral.eBorderMargin,'String'));
if tempConfig.BorderMargin<0||isnan(tempConfig.BorderMargin)
     err{length(err)+1}='Wrong border margin input';
end

if get(hConfigGui.pGeneral.rConstant,'Value')==1
    tempConfig.Threshold.Mode='constant';
end
if get(hConfigGui.pGeneral.rRelative,'Value')==1
    tempConfig.Threshold.Mode='relative';
end
if get(hConfigGui.pGeneral.rVariable,'Value')==1
    tempConfig.Threshold.Mode='variable';
end
   
r=get(hConfigGui.pGeneral.pFilter,'Children');
val = cell2mat(get(r,'Value'));
k=find(val(2:4)==1,1);
tag=get(r(k+1),'Tag');
if strcmp( tag, 'rFilterAverage' )
  tempConfig.Threshold.Filter='average';
elseif strcmp( tag, 'rFilterSmooth' )
  tempConfig.Threshold.Filter='smooth';  
elseif strcmp( tag, 'rFilterNone' )
  tempConfig.Threshold.Filter='none';
end
if get(hConfigGui.pGeneral.cFilterBackground,'Value')==1
    tempConfig.Threshold.Filter = [tempConfig.Threshold.Filter '+background'];
end

tempConfig.ConnectMol.MaxVelocity=str2double(get(hConfigGui.pMolecules.eMaxVelocity,'String'));
if tempConfig.ConnectMol.MaxVelocity<=0||isnan(tempConfig.ConnectMol.MaxVelocity)
     err{length(err)+1}='Wrong maximum velocity input for molecules';
end

tempConfig.ConnectMol.NumberVerification=str2double(get(hConfigGui.pMolecules.eNumVerification,'String'));
if tempConfig.ConnectMol.NumberVerification<0||isnan(tempConfig.ConnectMol.NumberVerification)
     err{length(err)+1}='Wrong number fo verification input for molecules';
end

tempConfig.ConnectMol.Position=str2double(get(hConfigGui.pMolecules.eWeightPos,'String'))/100;
if tempConfig.ConnectMol.Position<0||isnan(tempConfig.ConnectMol.Position)
     err{length(err)+1}='Wrong position weight input for molecules';
end

tempConfig.ConnectMol.Direction=str2double(get(hConfigGui.pMolecules.eWeightDir,'String'))/100;
if tempConfig.ConnectMol.Direction<0||isnan(tempConfig.ConnectMol.Direction)
     err{length(err)+1}='Wrong direction weight input for molecules';
end

tempConfig.ConnectMol.Speed=str2double(get(hConfigGui.pMolecules.eWeightSpd,'String'))/100;
if tempConfig.ConnectMol.Speed<0||isnan(tempConfig.ConnectMol.Speed)
    err{length(err)+1}='Wrong speed weight input for molecules';
end

tempConfig.ConnectMol.UseIntensity=get(hConfigGui.pMolecules.cActivateInt,'Value');

if tempConfig.ConnectMol.UseIntensity==1
    tempConfig.ConnectMol.IntensityOrLength=str2double(get(hConfigGui.pMolecules.eWeightInt,'String'))/100;
    if tempConfig.ConnectMol.IntensityOrLength<0||isnan(tempConfig.ConnectMol.IntensityOrLength)
        err{length(err)+1}='Wrong intensity weight input for molecules';
    end
else
    tempConfig.ConnectMol.IntensityOrLength=0;
end

if abs(tempConfig.ConnectMol.Position+tempConfig.ConnectMol.Direction+tempConfig.ConnectMol.Speed+tempConfig.ConnectMol.IntensityOrLength-1.0)>1e-8
    err{length(err)+1}='Connecting weights for molecules do not equal 100%';
end

tempConfig.ConnectMol.MinLength=str2double(get(hConfigGui.pMolecules.eMinLength,'String'));
if tempConfig.ConnectMol.MinLength<=0||isnan(tempConfig.ConnectMol.MinLength)
    err{length(err)+1}='Wrong minimum length input for molecules';
end

tempConfig.ConnectMol.MaxBreak=str2double(get(hConfigGui.pMolecules.eMaxBreak,'String'));
if tempConfig.ConnectMol.MaxBreak<0||isnan(tempConfig.ConnectMol.MaxBreak)
    err{length(err)+1}='Wrong maximum break input for molecules';
end

tempConfig.ConnectMol.MaxAngle=str2double(get(hConfigGui.pMolecules.eMaxAngle,'String'));
if tempConfig.ConnectMol.MaxAngle<=0||isnan(tempConfig.ConnectMol.MaxAngle)
    err{length(err)+1}='Wrong maximum angle input for molecules';
end

tempConfig.MaxFunc=str2double(get(hConfigGui.pMolecules.eMaxFunc,'String'));
if tempConfig.MaxFunc<=0||isnan(tempConfig.MaxFunc)
    err{length(err)+1}='Wrong maximum function input for molecules';
end

warn='continue';
if str2double(get(hConfigGui.pMolecules.eParams,'String'))>20
    warn = fQuestDlg({'Number of fitting parameters exceeds 20,','fitting might take very long time!'} ,'FIESTA Warning',{'change','continue'},'change');
end

switch(get(hConfigGui.pMolecules.mModel,'Value'))
    case 1
        tempConfig.Model='GaussSymmetric';
    case 2 
        tempConfig.Model='GaussStretched';
    case 3
        tempConfig.Model='GaussPlusRing';
    case 4
        tempConfig.Model='GaussPlus2Rings';
end

tempConfig.ConnectFil.MaxVelocity=str2double(get(hConfigGui.pFilaments.eMaxVelocity,'String'));
if tempConfig.ConnectFil.MaxVelocity<=0||isnan(tempConfig.ConnectFil.MaxVelocity)
     err{length(err)+1}='Wrong maximum velocity input for filaments';
end

tempConfig.ConnectFil.NumberVerification=str2double(get(hConfigGui.pFilaments.eNumVerification,'String'));
if tempConfig.ConnectFil.NumberVerification<=0||isnan(tempConfig.ConnectFil.NumberVerification)
     err{length(err)+1}='Wrong number fo verification input for filaments';
end

tempConfig.ConnectFil.Position=str2double(get(hConfigGui.pFilaments.eWeightPos,'String'))/100;
if tempConfig.ConnectFil.Position<0||isnan(tempConfig.ConnectFil.Position)
     err{length(err)+1}='Wrong position weight input for filaments';
end

tempConfig.ConnectFil.Direction=str2double(get(hConfigGui.pFilaments.eWeightDir,'String'))/100;
if tempConfig.ConnectFil.Direction<0||isnan(tempConfig.ConnectFil.Direction)
     err{length(err)+1}='Wrong direction weight input for filaments';
end

tempConfig.ConnectFil.Speed=str2double(get(hConfigGui.pFilaments.eWeightSpd,'String'))/100;
if tempConfig.ConnectFil.Speed<0||isnan(tempConfig.ConnectFil.Speed)
    err{length(err)+1}='Wrong speed weight input for filaments';
end

tempConfig.ConnectFil.IntensityOrLength=str2double(get(hConfigGui.pFilaments.eWeightLen,'String'))/100;
if tempConfig.ConnectFil.IntensityOrLength<0||isnan(tempConfig.ConnectFil.IntensityOrLength)
    err{length(err)+1}='Wrong length weight input for filaments';
end

if abs(tempConfig.ConnectFil.Position+tempConfig.ConnectFil.Direction+tempConfig.ConnectFil.Speed+tempConfig.ConnectFil.IntensityOrLength-1.0)>1e-8
    err{length(err)+1}='Connecting weights for filaments do not equal 100%';
end

tempConfig.ConnectFil.DisregardEdge=get(hConfigGui.pFilaments.cDisregardEdge,'Value');

tempConfig.ConnectFil.MinLength=str2double(get(hConfigGui.pFilaments.eMinLength,'String'));
if tempConfig.ConnectFil.MinLength<=0||isnan(tempConfig.ConnectFil.MinLength)
    err{length(err)+1}='Wrong minimum length input for filaments';
end

tempConfig.ConnectFil.MaxBreak=str2double(get(hConfigGui.pFilaments.eMaxBreak,'String'));
if tempConfig.ConnectFil.MaxBreak<0||isnan(tempConfig.ConnectFil.MaxBreak)
    err{length(err)+1}='Wrong maximum break input for filaments';
end

tempConfig.ConnectFil.MaxAngle=str2double(get(hConfigGui.pFilaments.eMaxAngle,'String'));
if tempConfig.ConnectFil.MaxAngle<=0||isnan(tempConfig.ConnectFil.MaxAngle)
    err{length(err)+1}='Wrong maximum angle input for filaments';
end

if get(hConfigGui.pRefPoint.rStart,'Value')==1&&strcmp(tempConfig.RefPoint,'start')==0
    tempConfig.RefPoint='start';
    nFil=length(Filament);
    for i=1:nFil
        Filament(i).Results(:,3:5) = Filament(i).PosStart;
        Filament(i).Results(:,5) = fDis( Filament(i).PosStart );
    end
end    

if get(hConfigGui.pRefPoint.rCenter,'Value')==1&&strcmp(tempConfig.RefPoint,'center')==0
    tempConfig.RefPoint='center';
    nFil=length(Filament);
    for i=1:nFil
        Filament(i).Results(:,3:5) = Filament(i).PosCenter;
        Filament(i).Results(:,5) = fDis( Filament(i).PosCenter );
    end
end  

if get(hConfigGui.pRefPoint.rEnd,'Value')==1&&strcmp(tempConfig.RefPoint,'end')==0
    tempConfig.RefPoint='end';
    nFil=length(Filament);
    for i=1:nFil
        Filament(i).Results(:,3:5) = Filament(i).PosEnd;
        Filament(i).Results(:,5) = fDis( Filament(i).PosEnd );
    end
end  

tempConfig.FilFocus=get(hConfigGui.pExperimental.cFocus,'Value');

if get(hConfigGui.pExperimental.cCurvedFil,'Value');
    tempConfig.ReduceFitBox=str2double(get(hConfigGui.pExperimental.eReduceFitBox,'String'))/100;
    if tempConfig.ReduceFitBox<0.25||tempConfig.ReduceFitBox>1||isnan(tempConfig.ReduceFitBox)
        err{length(err)+1}='Wrong fit box reduction for curved filaments';
        set(hConfigGui.pExperimental.eReduceFitBox,'String','100');
    end
else
    tempConfig.ReduceFitBox=1;
end

tempConfig.DynamicFil = get(hConfigGui.pExperimental.cDynamicFil,'Value');

if isempty(err)&&strcmp(warn,'continue')
    Config = tempConfig;
    if all(isreal(hMainGui.Values.FrameIdx))
        if strcmp(tempConfig.StackType{nCh-1},'TIFF')==1
            for i=0:length(TimeInfo{nCh-1})-1
                TimeInfo{nCh-1}(i+1) = (i*tempConfig.Time(nCh-1));
            end
        end
        if hMainGui.Values.FrameIdx>0
            set(hMainGui.MidPanel.tInfoTime,'String',sprintf('Time: %0.3f s',(TimeInfo{nCh-1}(hMainGui.Values.FrameIdx(nCh))-TimeInfo{nCh-1}(1))/1000));
        end
    end
    setappdata(0,'hMainGui',hMainGui);    
    close(findobj('Tag','hConfigGui'));
    fLeftPanel('SetThresh',hMainGui,Config.Threshold.Mode);    
    fShared('UpdateMenu',hMainGui); 
    fShow('Image');
    fShow('Tracks');
else
    if ~isempty(err);
        fMsgDlg(err,'error');
    end
end

function CheckServer(Config)
%check if FIESTA tracking server is available
if ispc 
    %for PC just access the tracking server directory
    DirServer = ['\\' Config.TrackingServer '\FIESTASERVER\'];
elseif ismac 
    %for MAC ask user if he wants to connect to tracking server
    DirServer = '/Volumes/FIESTASERVER/';  
elseif isunix
    %Linux users need to state the full path of where share is mounted (because there is a difference between "real mounting" and
    %"connect to server" via the file browser, and on top of that, these mounting points are different for the different distributions
    DirServer = [Config.TrackingServer '/']; % works both if user entered path ending with or without the last slash
else
    %error message for users of Linux version of MatLab        
    errordlg('Your Operating System is not yet supported','FIESTA Installation Error','modal');
    return;
end

%try to access tracking server
if isempty(dir(DirServer))
    if ispc
        fMsgDlg({'Could not connect to the server','Make sure that you permission to access the server'},'error');
    elseif ismac
        fMsgDlg({'Could not connect to the server','Make sure that you are connected to',['smb://' Config.TrackingServer '/FIESTASERVER/']},'warning');
    elseif isunix
        fMsgDlg({'Could not connect to the server','Make sure that you state the full path','of where the FIESTASERVER-share is mounted'},'warning');
    end
end

function Help
openhelp(sprintf('content\\GUI\\Configuration\\%s',get(gco,'UserData')));

function UpdateParams(hConfigGui)
n=round(str2double(get(hConfigGui.pMolecules.eMaxFunc,'String')));
set(hConfigGui.pMolecules.eMaxFunc,'String',num2str(n));
if n>0
    switch(get(hConfigGui.pMolecules.mModel,'Value'))
        case 1
            params=n*4;
        case 2
            params=n*6;            
        case 3
            params=n*7;                 
        case 4
            params=n*10;            
    end
    set(hConfigGui.pMolecules.eParams,'String',num2str(params));
    if params>20
        set(hConfigGui.pMolecules.eParams,'BackgroundColor','red');
    else
        set(hConfigGui.pMolecules.eParams,'BackgroundColor',get(hConfigGui.pMolecules.pModel,'BackgroundColor'));
    end
else
   set(hConfigGui.pMolecules.eParams,'String','','BackgroundColor','red');    
   set(hConfigGui.pMolecules.eMaxFunc,'String','');       
end

function ShowModel(hConfigGui)
set(gcf, 'Renderer', 'painters')
n=str2double(get(hConfigGui.pMolecules.eMaxFunc,'String'));
[X,Y] = meshgrid(-10:1:10);
if n>0
    label=[];
    label2=[];
    label{1}='\(h\) ... Height of Peak';                        
    label{2}='\(\hat{x}\) ... X Position of Center';
    label{3}='\(\hat{y}\) ... Y Position of Center';
    switch(get(hConfigGui.pMolecules.mModel,'Value'))
        case 1
            equation='\(I(x,y) = \frac{h}{2\pi\sigma^2} \cdot \exp \left[ -\frac{\left(x-\hat{x}\right)^2+\left(y-\hat{y}\right)^2 }{2\sigma^2} \right]\)';
            label{4}='\(\sigma\) ... Width of Peak';
            Z=Calc2DPeakCircle(X,Y);
        case 2
            label{4}='\(\sigma_x\) ... Width in X Direction';
            label{5}='\(\sigma_y\) ... Width in Y Direction';
            label{6}='\(\rho\) ... Orientation';
            equation='\(I(x,y) = \frac{h}{2\pi\sigma_x\sigma_x\sqrt{1-\rho^2}} \cdot \exp \left[-\frac{1}{(1-\rho^2)} \left( \frac{\left(x-\hat{x}\right)^2}{2\sigma^2_x} -\rho\,\frac{\left(x-\hat{x}\right)}{\sigma_x}\,\frac{\left(y-\hat{y}\right)}{\sigma_y}+ \frac{\left(y-\hat{y}\right)^2}{2\sigma^2_y}\right) \right]\)';
            Z=Calc2DPeakEllipses(X,Y);
        case 3
            label{4}='\(\sigma\) ... Width of Peak';
            label2{1}='\(h_r\) ... Height of Ring';
            label2{2}='\(r\) ... Radius of Ring';            
            label2{3}='\(\sigma_r\) ... Width of Ring';
            equation='\(I(x,y) = \frac{h}{2\pi\sigma^2} \cdot \exp \left[-\frac{\left(x-\hat{x}\right)^2+\left(y-\hat{y}\right)^2}{2\sigma^2}  \right]+\frac{h_r}{2\pi\sigma^2} \cdot \exp\left[ -\frac{\left(\sqrt{ \left(x-\hat{x}\right)^2+\left(y-\hat{y}\right)^2}-r\right)^2}{2\sigma^2_r} \right]\)';
            Z=Calc2DPeakRing(X,Y);         
        case 4
            label{4}='\(\sigma\) ... Width of Peak';
            label2{1}='\(h_{r,1}\) ... Height of first Ring';
            label2{2}='\(r_1\) ... Radius of first Ring';            
            label2{3}='\(\sigma_{r,1}\) ... Width of first Ring';            
            label2{4}='\(h_{r,2}\) ... Height of second Ring';
            label2{5}='\(r_2\) ... Radius of second Ring';            
            label2{6}='\(\sigma_{r,2}\) ... Width of second Ring';                  
            equation='\(I(x,y) = \frac{h}{2\pi\sigma^2} \cdot \exp \left[-\frac{(x-\hat{x})^2+(y-\hat{y})^2}{2\sigma^2}  \right]+\sum_{n=1}^{2}\frac{(-1)^n h_{r,n}}{2\pi\sigma^2_{r,n}} \cdot \exp\left[-\frac{\left (\sqrt{(x-\hat{x})^2+(y-\hat{y})^2}-r_n  \right )^2}{2\sigma^2_{r,n}} \right]\)';
            Z=Calc2DPeak2Rings(X,Y);                     
    end
    
    cla(hConfigGui.pMolecules.aModelLabel);
    text('Parent',hConfigGui.pMolecules.aModelLabel,'Interpreter','latex','Position',[0.01 0.99],...
         'FontSize',14,'BackgroundColor',get(hConfigGui.pMolecules.pModel,'BackgroundColor'),'String',label,'VerticalAlignment','top');
    if ~isempty(label2) 
        text('Parent',hConfigGui.pMolecules.aModelLabel,'Interpreter','latex','Position',[0.6 0.99],...
             'FontSize',14,'BackgroundColor',get(hConfigGui.pMolecules.pModel,'BackgroundColor'),'String',label2,'VerticalAlignment','top');     
    end
    set(hConfigGui.pMolecules.aModelLabel,'Visible','off');
    
    cla(hConfigGui.pMolecules.aModelPreview);
    surf(X,Y,Z,'Parent',hConfigGui.pMolecules.aModelPreview);
    set(hConfigGui.pMolecules.aModelPreview,{'XLim','YLim','ZLim'},{[-10 10],[-10 10],[0 1]},'CameraViewAngle',22,'CameraPosition',[-10 -30 2],'CameraTarget',[0 0 0])
    set(hConfigGui.pMolecules.aModelPreview,'Visible','off');
    
    cla(hConfigGui.pMolecules.aModelEquation);
    text('Parent',hConfigGui.pMolecules.aModelEquation,'Interpreter','latex','Position',[0.01 0.6],...
         'FontSize',16,'BackgroundColor',get(hConfigGui.pMolecules.pModel,'BackgroundColor'),'String',equation);
     
    set(hConfigGui.pMolecules.aModelEquation,'Visible','off');
    UpdateParams(hConfigGui)
end

function Z=Calc2DPeakCircle(X,Y)
x=[-0.3 0.2 8 1];
Z = x(4) * exp( -( (X-x(1)).^2 + (Y-x(2)).^2 ) / x(3) );

function Z=Calc2DPeakEllipses(X,Y)
x=[0.3 0.2 3.9 2.8 0.08 1];
Z = x(6) * exp( - ( (X-x(1)) ./ x(3) ).^2  - ( (Y-x(2)) ./ x(4) ).^2 + x(5) .* (X-x(1)) .* (Y-x(2)));

function Z=Calc2DPeakRing(X,Y)
x=[0.3 0.2 8 1 4 0.3 7];
Z = x(4) * exp( -( (X-x(1)).^2 + (Y-x(2)).^2 ) / x(3) ) + x(6) .* exp( -( ( sqrt( (X-x(1)).^2 + (Y-x(2)).^2) - x(7) ).^2 ) / x(5) );

function Z=Calc2DPeak2Rings(X,Y)
x=[0.3 0.2 8 0.6 4 0.3 4 4 0.2 8];
Z = x(4) * exp( -( (X-x(1)).^2 + (Y-x(2)).^2 ) / x(3) ) - x(6) .* exp( -( (sqrt( (X-x(1)).^2 + (Y-x(2)).^2) - x(7)).^2) / x(5) ) + x(9) .* exp( -( ( sqrt( (X-x(1)).^2 + (Y-x(2)).^2) - x(10) ).^2) / x(8) );
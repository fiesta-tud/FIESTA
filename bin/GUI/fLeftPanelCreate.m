function hLeftPanel=fLeftPanelCreate(hMainGui)
%create Scale Panel
c = get(hMainGui.fig,'Color');
hLeftPanel.pNorm.panel = uipanel('Parent',hMainGui.fig,'Units','normalized','Fontsize',12,'Bordertype','beveledout',...
                                 'Position',[0 .3 .1 .7],'Tag','pNorm','Visible','on','BackgroundColor',c);
                             
hLeftPanel.pNorm.tIntensity = uicontrol('Parent',hLeftPanel.pNorm.panel,'Style','text','Units','normalized',...
                                        'Position',[.0 .965 1 .035],'Tag','pNorm.tIntensity','Fontsize',12,...
                                        'String','Intensity','HorizontalAlignment','center','BackgroundColor','blue',...
                                        'ForegroundColor','white','FontWeight','bold');
                                 
hLeftPanel.pNorm.aScaleBar = axes('Parent',hLeftPanel.pNorm.panel,'Units','normalized','Visible','off',...
                                  'Position',[.25 .075 .5 .825],'Tag','pNorm.aScaleBar');

hLeftPanel.pNorm.tScaleMin = uicontrol('Parent',hLeftPanel.pNorm.panel,'Style','text','Units','normalized',...
                                       'Position',[.025 .92 .3 .03],'Tag','pNorm.tScaleMin','Fontsize',12,...
                                       'String','min','HorizontalAlignment','left','Enable','off','BackgroundColor',c);
                                   
hLeftPanel.pNorm.tScaleMax = uicontrol('Parent',hLeftPanel.pNorm.panel,'Style','text','Units','normalized',...
                                       'Position',[.7 .92 .3 .03],'Tag','pNorm.tScaleMax','Fontsize',12,...
                                       'String','max','HorizontalAlignment','center','Enable','off','BackgroundColor',c);
                                   
hLeftPanel.pNorm.sScaleMin = uicontrol('Parent',hLeftPanel.pNorm.panel,'Style','slider','Units','normalized',...
                                       'Position',[.05 .075 .15 .825],'Tag','pNorm.sScaleMin','Enable','off',...
                                       'Callback','fLeftPanel(''sScaleMin'',getappdata(0,''hMainGui''));'); 
                                   
hLeftPanel.pNorm.sScaleMax = uicontrol('Parent',hLeftPanel.pNorm.panel,'Style','slider','Units','normalized',...
                                       'Position',[.8 .075 .15 .825],'Tag','pNorm.sScaleMax','Enable','off',...
                                        'Callback','fLeftPanel(''sScaleMax'',getappdata(0,''hMainGui''));'); 

hLeftPanel.pNorm.eScaleMin = uicontrol('Parent',hLeftPanel.pNorm.panel,'Style','edit','Units','normalized',...
                                       'Position',[.05 .02 .4 .04],'Tag','pNorm.eScaleMin','Fontsize',12,...
                                       'BackgroundColor','white','Enable','off',...
                                       'Callback','fLeftPanel(''eScaleMin'',getappdata(0,''hMainGui''));');                                
                                 
hLeftPanel.pNorm.eScaleMax = uicontrol('Parent',hLeftPanel.pNorm.panel,'Style','edit','Units','normalized',...
                                       'Position',[.55 .02 .4 .04],'Tag','pNorm.eScaleMax','Fontsize',12,...
                                       'BackgroundColor','white','Enable','off',...
                                       'Callback','fLeftPanel(''eScaleMax'',getappdata(0,''hMainGui''));'); 

%create Thresh Panel
hLeftPanel.pThresh.panel = uipanel('Parent',hMainGui.fig,'Units','normalized','Fontsize',12,'Bordertype','beveledout',...
                                   'Position',[0 .3 .1 .7],'Tag','pThresh','Visible','off','BackgroundColor',c);

hLeftPanel.pThresh.tThreshold = uicontrol('Parent',hLeftPanel.pThresh.panel,'Style','text','Units','normalized',...
                                        'Position',[.0 .965 1 .035],'Tag','pThresh.tThreshold','Fontsize',12,...
                                        'String','Threshold','HorizontalAlignment','center','BackgroundColor','blue',...
                                        'ForegroundColor','white','FontWeight','bold');

hLeftPanel.pThresh.aScaleBar = axes('Parent',hLeftPanel.pThresh.panel,'Units','normalized','Visible','off',...
                                    'Position',[.25 .075 .5 .825],'Tag','pThresh.aScaleBar');
                                   
hLeftPanel.pThresh.sScale = uicontrol('Parent',hLeftPanel.pThresh.panel,'Style','slider','Units','normalized',...
                                      'Position',[.8 .075 .15 .825],'Tag','pThresh.sScale','Enable','off',...
                                      'Callback','fLeftPanel(''sScale'',getappdata(0,''hMainGui''));');
                                   
hLeftPanel.pThresh.eScale = uicontrol('Parent',hLeftPanel.pThresh.panel,'Style','edit','Units','normalized',...
                                      'Position',[.3 .02 .4 .04],'Tag','pThresh.eScale','Fontsize',12,...
                                      'BackgroundColor','white','Enable','off',...
                                      'Callback','fLeftPanel(''eScale'',getappdata(0,''hMainGui''));');
                                  
hLeftPanel.pThresh.tPercent = uicontrol('Parent',hLeftPanel.pThresh.panel,'Style','text','Units','normalized','Visible','off',...
                                      'Position',[.7 .01 .1 .04],'Tag','pThresh.tPercent','Fontsize',12,'String','%','BackgroundColor',c);
                                     
%create RedNorm Panel
hLeftPanel.pRedNorm.panel = uipanel('Parent',hMainGui.fig,'Units','normalized','Fontsize',12,'Bordertype','beveledout',...
                                    'Position',[0 .3 .1 .7],'Tag','pRedNorm','Visible','off');
                          
hLeftPanel.pRedNorm.tRed = uicontrol('Parent',hLeftPanel.pRedNorm.panel,'Style','text','Units','normalized',...
                                     'Position',[.0 .97 .5 .03],'Tag','pRedNorm.tRed','Fontsize',12,...
                                     'String','Red','HorizontalAlignment','center','BackgroundColor','red',...
                                     'ForegroundColor','white','FontWeight','bold');
                                   
hLeftPanel.pRedNorm.tGreen = uicontrol('Parent',hLeftPanel.pRedNorm.panel,'Style','text','Units','normalized',...
                                       'Position',[.5 .97 .5 .03],'Tag','pRedNorm.tGreen','Fontsize',12,...
                                       'String','Green','HorizontalAlignment','center','FontWeight','bold','Enable','off',...
                                       'BackgroundColor',[.8 .8 .8],'ButtonDownFcn','fLeftPanel(''GreenNormPanel'',getappdata(0,''hMainGui''));');                          
                                   
hLeftPanel.pRedNorm.aScaleBar = axes('Parent',hLeftPanel.pRedNorm.panel,'Units','normalized','Visible','off',...
                                     'Position',[.25 .075 .5 .825],'Tag','pRedNorm.aScaleBar');

hLeftPanel.pRedNorm.tScaleMin = uicontrol('Parent',hLeftPanel.pRedNorm.panel,'Style','text','Units','normalized',...
                                          'Position',[.025 .92 .3 .03],'Tag','pRedNorm.tScaleMin','Fontsize',12,...
                                         'String','min','HorizontalAlignment','left','Enable','off','BackgroundColor',c);
                                   
hLeftPanel.pRedNorm.tScaleMax = uicontrol('Parent',hLeftPanel.pRedNorm.panel,'Style','text','Units','normalized',...
                                          'Position',[.7 .92 .3 .03],'Tag','pRedNorm.tScaleMax','Fontsize',12,...
                                          'String','max','HorizontalAlignment','center','Enable','off','BackgroundColor',c);
                                   
hLeftPanel.pRedNorm.sScaleMin = uicontrol('Parent',hLeftPanel.pRedNorm.panel,'Style','slider','Units','normalized',...
                                          'Position',[.05 .075 .15 .825],'Tag','pRedNorm.sScaleMin','Enable','off',...
                                          'Callback','fLeftPanel(''sScaleMin'',getappdata(0,''hMainGui''));');
                                   
hLeftPanel.pRedNorm.sScaleMax = uicontrol('Parent',hLeftPanel.pRedNorm.panel,'Style','slider','Units','normalized',...
                                          'Position',[.8 .075 .15 .825],'Tag','pRedNorm.sScaleMax','Enable','off',...
                                          'Callback','fLeftPanel(''sScaleMax'',getappdata(0,''hMainGui''));');
 
hLeftPanel.pRedNorm.eScaleMin = uicontrol('Parent',hLeftPanel.pRedNorm.panel,'Style','edit','Units','normalized',...
                                          'Position',[.05 .02 .4 .04],'Tag','pRedNorm.eScaleMin','Fontsize',12,...
                                          'BackgroundColor','white','Enable','off',...
                                          'Callback','fLeftPanel(''eScaleMin'',getappdata(0,''hMainGui''));');
                                   
hLeftPanel.pRedNorm.eScaleMax = uicontrol('Parent',hLeftPanel.pRedNorm.panel,'Style','edit','Units','normalized',...
                                          'Position',[.55 .02 .4 .04],'Tag','pRedNorm.eScaleMax','Fontsize',12,...
                                          'BackgroundColor','white','Enable','off',...
                                          'Callback','fLeftPanel(''eScaleMax'',getappdata(0,''hMainGui''));');
                          
%create GreenNorm Panel
hLeftPanel.pGreenNorm.panel = uipanel('Parent',hMainGui.fig,'Units','normalized','Fontsize',12,'Bordertype','beveledout',...
                                'Position',[0 .3 .1 .7],'Tag','pGreenNorm','Visible','off');
                            
hLeftPanel.pGreenNorm.tRed = uicontrol('Parent',hLeftPanel.pGreenNorm.panel,'Style','text','Units','normalized',...
                                     'Position',[.0 .97 .5 .03],'Tag','pGreenNorm.tRed','Fontsize',12,...
                                     'String','Red','HorizontalAlignment','center','FontWeight','bold','Enable','off',...
                                     'BackgroundColor',[.8 .8 .8],'ButtonDownFcn','fLeftPanel(''RedNormPanel'',getappdata(0,''hMainGui''));');
                                   
hLeftPanel.pGreenNorm.tGreen = uicontrol('Parent',hLeftPanel.pGreenNorm.panel,'Style','text','Units','normalized',...
                                       'Position',[.5 .97 .5 .03],'Tag','pGreenNorm.tGreen','Fontsize',12,...
                                       'String','Green','HorizontalAlignment','center','BackgroundColor','green',...
                                       'ForegroundColor','white','FontWeight','bold');                          
                                   
hLeftPanel.pGreenNorm.aScaleBar = axes('Parent',hLeftPanel.pGreenNorm.panel,'Units','normalized','Visible','on',...
                                     'Position',[.25 .075 .5 .825],'Tag','pGreenNorm.aScaleBar');

hLeftPanel.pGreenNorm.tScaleMin = uicontrol('Parent',hLeftPanel.pGreenNorm.panel,'Style','text','Units','normalized',...
                                          'Position',[.025 .92 .3 .03],'Tag','pGreenNorm.tScaleMin','Fontsize',12,...
                                         'String','min','HorizontalAlignment','left','Enable','off','BackgroundColor',c);
                                   
hLeftPanel.pGreenNorm.tScaleMax = uicontrol('Parent',hLeftPanel.pGreenNorm.panel,'Style','text','Units','normalized',...
                                          'Position',[.7 .92 .3 .03],'Tag','pGreenNorm.tScaleMax','Fontsize',12,...
                                          'String','max','HorizontalAlignment','center','Enable','off','BackgroundColor',c);
                                   
hLeftPanel.pGreenNorm.sScaleMin = uicontrol('Parent',hLeftPanel.pGreenNorm.panel,'Style','slider','Units','normalized',...
                                          'Position',[.05 .075 .15 .825],'Tag','pGreenNorm.sScaleMin','Enable','off',...
                                       'Callback','fLeftPanel(''sScaleMin'',getappdata(0,''hMainGui''));');
                                   
hLeftPanel.pGreenNorm.sScaleMax = uicontrol('Parent',hLeftPanel.pGreenNorm.panel,'Style','slider','Units','normalized',...
                                          'Position',[.8 .075 .15 .825],'Tag','pGreenNorm.sScaleMax','Enable','off',...
                                        'Callback','fLeftPanel(''sScaleMax'',getappdata(0,''hMainGui''));');
 
hLeftPanel.pGreenNorm.eScaleMin = uicontrol('Parent',hLeftPanel.pGreenNorm.panel,'Style','edit','Units','normalized',...
                                          'Position',[.05 .02 .4 .04],'Tag','pGreenNorm.eScaleMin','Fontsize',12,...
                                          'BackgroundColor','white','Enable','off',...
                                          'Callback','fLeftPanel(''eScaleMin'',getappdata(0,''hMainGui''));');
                                   
hLeftPanel.pGreenNorm.eScaleMax = uicontrol('Parent',hLeftPanel.pGreenNorm.panel,'Style','edit','Units','normalized',...
                                          'Position',[.55 .02 .4 .04],'Tag','pGreenNorm.eScaleMax','Fontsize',12,...
                                          'BackgroundColor','white','Enable','off',...
                                          'Callback','fLeftPanel(''eScaleMax'',getappdata(0,''hMainGui''));');
                                      
%create RedThresh Panel
hLeftPanel.pRedThresh.panel = uipanel('Parent',hMainGui.fig,'Units','normalized','Fontsize',12,'Bordertype','beveledout',...
                                'Position',[0 .3 .1 .7],'Tag','pRedThresh','Visible','off');
                            
hLeftPanel.pRedThresh.tRed = uicontrol('Parent',hLeftPanel.pRedThresh.panel,'Style','text','Units','normalized',...
                                       'Position',[.0 .97 .5 .03],'Tag','pRedThresh.tRed','Fontsize',12,...
                                       'String','Red','HorizontalAlignment','center','BackgroundColor','red',...
                                       'ForegroundColor','white','FontWeight','bold');
                                   
hLeftPanel.pRedThresh.tGreen = uicontrol('Parent',hLeftPanel.pRedThresh.panel,'Style','text','Units','normalized',...
                                         'Position',[.5 .97 .5 .03],'Tag','pRedThresh.tGreen','Fontsize',12,...
                                         'String','Green','HorizontalAlignment','center','FontWeight','bold','Enable','off',...
                                         'BackgroundColor',[.8 .8 .8],'ButtonDownFcn','fLeftPanel(''GreenThreshPanel'',getappdata(0,''hMainGui''));');                          
                            
hLeftPanel.pRedThresh.aScaleBar = axes('Parent',hLeftPanel.pRedThresh.panel,'Units','normalized','Visible','off',...
                                       'Position',[.25 .075 .5 .825],'Tag','pRedThresh.aScaleBar');

hLeftPanel.pRedThresh.sScale = uicontrol('Parent',hLeftPanel.pRedThresh.panel,'Style','slider','Units','normalized',...
                                         'Position',[.8 .075 .15 .825],'Tag','pRedThresh.sScale','Enable','off',...
                                      'Callback','fLeftPanel(''sScale'',getappdata(0,''hMainGui''));');
                                   
hLeftPanel.pRedThresh.eScale = uicontrol('Parent',hLeftPanel.pRedThresh.panel,'Style','edit','Units','normalized',...
                                         'Position',[.3 .02 .4 .04],'Tag','pRedThresh.eScale','Fontsize',12,...
                                         'BackgroundColor','white','Enable','off',...
                                         'Callback','fLeftPanel(''eScale'',getappdata(0,''hMainGui''));');
                                     
hLeftPanel.pRedThresh.tPercent = uicontrol('Parent',hLeftPanel.pRedThresh.panel,'Style','text','Units','normalized','Visible','off',...
                                      'Position',[.7 .01 .1 .04],'Tag','pThresh.tPercent','Fontsize',12,'String','%','BackgroundColor',c);                                     
                           
%create GreenThresh Panel
hLeftPanel.pGreenThresh.panel = uipanel('Parent',hMainGui.fig,'Units','normalized','Fontsize',12,'Bordertype','beveledout',...
                                  'Position',[0 .3 .1 .7],'Tag','pGreenThresh','Visible','off');

hLeftPanel.pGreenThresh.tRed = uicontrol('Parent',hLeftPanel.pGreenThresh.panel,'Style','text','Units','normalized',...
                                         'Position',[.0 .97 .5 .03],'Tag','pGreenThresh.tRed','Fontsize',12,...
                                         'String','Red','HorizontalAlignment','center','FontWeight','bold','Enable','off',...
                                         'BackgroundColor',[.8 .8 .8],'ButtonDownFcn','fLeftPanel(''RedThreshPanel'',getappdata(0,''hMainGui''));');
                                   
hLeftPanel.pGreenThresh.tGreen = uicontrol('Parent',hLeftPanel.pGreenThresh.panel,'Style','text','Units','normalized',...
                                           'Position',[.5 .97 .5 .03],'Tag','pGreenThresh.tGreen','Fontsize',12,...
                                           'String','Green','HorizontalAlignment','center','BackgroundColor','green',...
                                           'ForegroundColor','white','FontWeight','bold');   
                              
hLeftPanel.pGreenThresh.aScaleBar = axes('Parent',hLeftPanel.pGreenThresh.panel,'Units','normalized','Visible','off',...
                                         'Position',[.25 .075 .5 .825],'Tag','pGreenThresh.aScaleBar');

hLeftPanel.pGreenThresh.sScale = uicontrol('Parent',hLeftPanel.pGreenThresh.panel,'Style','slider','Units','normalized',...
                                           'Position',[.8 .075 .15 .825],'Tag','pGreenThresh.sScale','Enable','off',...
                                           'Callback','fLeftPanel(''sScale'',getappdata(0,''hMainGui''));');
                                   
hLeftPanel.pGreenThresh.eScale = uicontrol('Parent',hLeftPanel.pGreenThresh.panel,'Style','edit','Units','normalized',...
                                           'Position',[.3 .02 .4 .04],'Tag','pGreenThresh.eScale','Fontsize',12,...
                                           'BackgroundColor','white','Enable','off',...
                                           'Callback','fLeftPanel(''eScale'',getappdata(0,''hMainGui''));');            
                                       
hLeftPanel.pGreenThresh.tPercent = uicontrol('Parent',hLeftPanel.pGreenThresh.panel,'Style','text','Units','normalized','Visible','off',...
                                      'Position',[.7 .01 .1 .04],'Tag','pThresh.tPercent','Fontsize',12,'String','%','BackgroundColor',c);  
                                  
%create Region Panel                      
hLeftPanel.pRegions.panel = uipanel('Parent',hMainGui.fig,'Units','normalized','Fontsize',12,'Bordertype','beveledout',...
                                    'Position',[0 0 .1 .3],'Tag','pRegions','BackgroundColor',c);
                          
hLeftPanel.pRegions.tRegions = uicontrol('Parent',hLeftPanel.pRegions.panel,'Style','text','Units','normalized',...
                                         'Position',[0 0.92 1 0.08],'String','Regions','Tag','tRegions',...
                                         'Fontsize',12,'FontWeight','bold','ForegroundColor','white','BackgroundColor','blue');
                                     
hLeftPanel.pRegions.pRegListPan = uipanel('Parent',hLeftPanel.pRegions.panel,'Units','normalized','Bordertype','beveledin',...
                                        'Position',[.05 .22 .9 .68],'Tag','pRegListPan','Visible','on','UIContextMenu',hMainGui.Menu.ctRegion,'BackgroundColor',c);
                                    
for i=1:8
    
    hLeftPanel.pRegions.RegList.Pan(i) = uipanel('Parent',hLeftPanel.pRegions.pRegListPan,'Units','normalized','Bordertype','beveledout',...
                                                'Position',[.0 (8-i)*0.125 .925 .125],'Tag','RegionsPan','UserData',i,...
                                                'UIContextMenu',hMainGui.Menu.ctRegion,'Visible','off','BackgroundColor',c);
                                            
    hLeftPanel.pRegions.RegList.Region(i) = uicontrol('Parent',hLeftPanel.pRegions.RegList.Pan(i) ,'Style','text','Units','normalized',...
                                                      'Fontsize',10,'FontWeight','bold','HorizontalAlignment','left','Userdata',i,...
                                                      'Position',[.05 .05 .9 .9],'Tag','tRegion','Enable','inactive','BackgroundColor',c,...
                                                      'UIContextMenu',hMainGui.Menu.ctRegion);
end
   
hLeftPanel.pRegions.sRegList = uicontrol('Parent',hLeftPanel.pRegions.pRegListPan,'Style','slider','Units','normalized',...
                                       'Position',[.85 0 .15 1],'Tag','sRegList','SliderStep',[1 1],'Value',1,'Enable','off',...
                                       'Callback','fLeftPanel(''RegListSlider'',getappdata(0,''hMainGui''));');   
                                   
hLeftPanel.pRegions.cExcludeReg = uicontrol('Parent',hLeftPanel.pRegions.panel ,'Style','checkbox','Units','normalized',...
                                          'String','Exclude regions','FontSize',10,'BackgroundColor',c,...
                                          'TooltipString','FIESTA will only find objects outside of the selected regions',...
                                          'Position',[.05 .12 .9 .08],'Tag','cIgnoreFil','Enable','off',...
                                          'Callback','fLeftPanel(''ExcludeRegions'',getappdata(0,''hMainGui''));','BackgroundColor',c); 
                                      
hLeftPanel.pRegions.Load = uicontrol('Parent',hLeftPanel.pRegions.panel,'Callback','fLeftPanel(''LoadRegion'',getappdata(0,''hMainGui''));',...
                                       'Units','normalized','Style','pushbutton','Tag','pRegionsLoad',...
                                       'FontSize',10,'FontWeight','normal',...                                             
                                       'Position',[.05 .02 .4 .08],'String','Load');   
                                   
hLeftPanel.pRegions.Save = uicontrol('Parent',hLeftPanel.pRegions.panel,'Callback','fLeftPanel(''SaveRegion'',getappdata(0,''hMainGui''));',...
                                       'Units','normalized','Style','pushbutton','Tag','pRegionsSave',...
                                       'FontSize',10,'FontWeight','normal',...                                             
                                       'Position',[.55 .02 .4 .08],'String','Save');                                            


                                       
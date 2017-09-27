function hMidPanel=fMidPanelCreate(hMainGui)
%create Scale Panel
c = get(hMainGui.fig,'Color');
hMidPanel.pNoData = uipanel('Parent',hMainGui.fig,'Units','normalized','Bordertype','none',...
                            'Position',[.1 .026 .68 .948],'Tag','pNoData','Visible','on','BackgroundColor',c);
                        
hMidPanel.tNoData = uicontrol('Parent',hMidPanel.pNoData,'Units','normalized','Style','text',...
                              'Position',[0 .45 1 .04],'Tag','tNoData','FontSize',14,'FontWeight','bold',...
                              'String','No Stack or Data present','BackgroundColor',c);                        
                        
hMidPanel.pView = uipanel('Parent',hMainGui.fig,'Units','normalized','Bordertype','none',...
                          'Position',[.1 .026 .68 .948],'Tag','pView','Visible','off','BackgroundColor','white');
                        
hMidPanel.aView = axes('Parent',hMidPanel.pView,'Units','normalized','Visible','off','ActivePositionProperty','position',...
                       'Position',[0 0 1 1],'Tag','aView','NextPlot','add','YDir','reverse','SortMethod','childorder');
                   
hMidPanel.pKymoGraph = uipanel('Parent',hMainGui.fig,'Units','normalized','Bordertype','none',...
                               'Position',[.1 .026 .68 .948],'Tag','pKymoGraph','Visible','off','BackgroundColor','white');
                                    
hMidPanel.aKymoGraph = axes('Parent',hMidPanel.pKymoGraph,'Units','normalized','UIContextMenu',hMainGui.Menu.ctKymoGraph,...
                                     'Position',[0 0 1 1],'Tag','aKymoGraph','NextPlot','add','Visible','off');       

hMidPanel.pFrame = uipanel('Parent',hMainGui.fig,'Units','normalized','Bordertype','beveledout',...
                           'Position',[.1 .974 .68 .026],'Tag','pFrame','Visible','on','BackgroundColor',c);
                      
hMidPanel.eFrame = uicontrol('Parent',hMidPanel.pFrame,'Style','edit','Units','normalized',...
                             'Position',[.93 .05 .06 .9],'Tag','eFrame','Fontsize',10,...
                             'BackgroundColor','white','Enable','off',...
                             'Callback','fMidPanel(''eFrame'',getappdata(0,''hMainGui''));');
                                   
hMidPanel.sFrame = uicontrol('Parent',hMidPanel.pFrame,'Style','slider','Units','normalized',...
                             'Position',[.01 .05 .91 .9],'Tag','sFrame','Enable','off','ButtonDownFcn',@sFrameDrag);

addlistener(hMidPanel.sFrame, 'Value', 'PostSet',@sFrameDrag);

% jScrollBar = findjobj(hMidPanel.sFrame);
% jScrollBar.AdjustmentValueChangedCallback = @sJFrameDrag;
                       
hMidPanel.pInfo = uipanel('Parent',hMainGui.fig,'Units','normalized','Bordertype','beveledout',...
                          'Position',[.1 0 .68 .026],'Tag','pInfo','Visible','on','BackgroundColor',c); 
                      
hMidPanel.tInfoTime = uicontrol('Parent',hMidPanel.pInfo,'Units','normalized','Style','text','Fontsize',12,...
                                'Position',[0.01 0 0.18 0.95],'Tag','tInfoTime','String','','HorizontalAlignment','left','BackgroundColor',c);                       

hMidPanel.tInfoImage = uicontrol('Parent',hMidPanel.pInfo,'Units','normalized','Style','text','Fontsize',12,...
                                'Position',[0.2 0 0.35 0.95],'Tag','tInfoImage','String','','HorizontalAlignment','left','BackgroundColor',c);                       
                       
hMidPanel.tInfoCoord = uicontrol('Parent',hMidPanel.pInfo,'Units','normalized','Style','text','Fontsize',12,...
                                'Position',[0.55 0 0.4 0.95],'Tag','tInfoCoord','String','','HorizontalAlignment','left','BackgroundColor',c);         
                                              
function sFrameDrag(~,event)
if strcmp(event.EventName,'PostSet')
    hMainGui = getappdata(0,'hMainGui');
    idx = round(get(event.AffectedObject,'Value'));
    if length(hMainGui.Values.FrameIdx)>2
        n = hMainGui.Values.FrameIdx(1)+1;
    else
        n = 2;
    end
    if idx~=hMainGui.Values.FrameIdx(n)
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
        fMidPanel('Update',hMainGui);
    end
end
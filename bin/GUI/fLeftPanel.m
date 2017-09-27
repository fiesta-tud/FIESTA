function varargout=fLeftPanel(func,varargin)
varargout={};
switch func
    case 'NormPanel'
        NormPanel(varargin{1});        
    case 'ThreshPanel'
        ThreshPanel(varargin{1});
    case 'RedNormPanel'
        RedNormPanel(varargin{1});
    case 'GreenNormPanel'
        GreenNormPanel(varargin{1});        
    case 'RedThreshPanel'
        RedThreshPanel(varargin{1});
    case 'GreenThreshPanel'
        GreenThreshPanel(varargin{1});                
    case 'sScaleMin'
        sScaleMin(varargin{1});
    case 'sScaleMax'
        sScaleMax(varargin{1});
    case 'sScale'
        sScale(varargin{1});
    case 'eScaleMin'
        eScaleMin(varargin{1});
    case 'eScaleMax'
        eScaleMax(varargin{1});
    case 'eScale'
        eScale(varargin{1});
    case 'LoadRegion'
        LoadRegion(varargin{1});
    case 'SaveRegion'
        SaveRegion(varargin{1});
    case 'CheckRegion'
        CheckRegion(varargin{1});       
    case 'SetThresh'
        SetThresh(varargin{1},varargin{2});       
    case 'DisableAllPanels'
        DisableAllPanels(varargin{1});           
    case 'RegUpdateList'
        RegUpdateList(varargin{1});
    case 'RegListSlider'
        RegListSlider(varargin{1}); 
    case 'Update'
        Update(varargin{1});
    case 'UpdateKymo'
        UpdateKymo(varargin{1});
end

function SetThresh(hMainGui,Mode)
global Stack;
nCh = hMainGui.Values.FrameIdx(1);
if isempty(Stack)||strcmp(Mode,'variable')
    enable='off';
    Max=2;
    Thresh=1;
    sStep=1;
    visible='off';
    strThresh='';
else
    enable='on';
    if strcmp(Mode,'constant')
        Max=hMainGui.Values.PixMax(nCh);
        Thresh=hMainGui.Values.Thresh(nCh);
        sStep=100;
        visible='off';
    else
        Max=hMainGui.Values.MaxRelThresh(nCh);
        Thresh=hMainGui.Values.RelThresh(nCh);
        sStep=10;    
        visible='on';        
    end
    strThresh=int2str(Thresh);
end
slider_step(1) = 1/double(Max);
slider_step(2) = sStep/double(Max);
if (max(slider_step)>=1)||(min(slider_step)<=0)
    slider_step=[0.1 0.1];
end
set(hMainGui.LeftPanel.pThresh.sScale,'Enable',enable,'sliderstep',slider_step,'max',Max,'min',1,'Value',Thresh);
set(hMainGui.LeftPanel.pThresh.eScale,'Enable',enable,'String',strThresh);
set(hMainGui.LeftPanel.pThresh.tPercent,'Visible',visible);


function UpdateKymo(hMainGui)
if ~isempty(hMainGui.KymoImage)
    KymoGraph = hMainGui.KymoImage;
    if strcmp(get(hMainGui.ToolBar.ToolChannels(5),'State'),'off')
        n = hMainGui.Values.FrameIdx(1);
        Image=(KymoGraph-hMainGui.Values.ScaleMin(n))/(hMainGui.Values.ScaleMax(n)-hMainGui.Values.ScaleMin(n)+1);
    else
        IRGB = zeros(size(KymoGraph,1),size(KymoGraph,2),3);
        for n = 1:length(hMainGui.Values.StackColor)
            c = get(hMainGui.ToolBar.ToolColors(hMainGui.Values.StackColor(n)),'CData');
            c = squeeze(c(1,1,1:3));
            KymoGraph(:,:,n) = (KymoGraph(:,:,n)-hMainGui.Values.ScaleMin(n))/(hMainGui.Values.ScaleMax(n)-hMainGui.Values.ScaleMin(n)+1);
            IRGB(:,:,1) = IRGB(:,:,1)+KymoGraph(:,:,n)*c(1);
            IRGB(:,:,2) = IRGB(:,:,2)+KymoGraph(:,:,n)*c(2);
            IRGB(:,:,3) = IRGB(:,:,3)+KymoGraph(:,:,n)*c(3);
        end
        Image = IRGB;
    end
    Image(Image<0)=0;
    Image(Image>1)=1;
    if size(Image,3)==1
       Image=Image*2^16;
    end
    set(hMainGui.KymoGraph,'CData',Image);
end

function sScaleMin(hMainGui)
h=gcbo;
value=round(get(h,'Value'));
nCh = hMainGui.Values.FrameIdx(1);

if value<hMainGui.Values.ScaleMax(nCh)
    hMainGui.Values.ScaleMin(nCh)=value;
else
    hMainGui.Values.ScaleMin(nCh)=hMainGui.Values.ScaleMax(nCh);
end
UpdateKymo(hMainGui);
setappdata(0,'hMainGui',hMainGui);
Update(hMainGui);

function sScaleMax(hMainGui)
h=gcbo;
value=round(get(h,'Value'));
nCh = hMainGui.Values.FrameIdx(1);
if value>hMainGui.Values.ScaleMin(nCh)  
    hMainGui.Values.ScaleMax(nCh)=value;
else
    hMainGui.Values.ScaleMax(nCh)=hMainGui.Values.ScaleMin(nCh);        
end
UpdateKymo(hMainGui);
setappdata(0,'hMainGui',hMainGui);
Update(hMainGui);

function sScale(hMainGui)
global Config
h=gcbo;
value=round(get(h,'Value'));
nCh = hMainGui.Values.FrameIdx(1);
if strcmp(Config.Threshold.Mode,'constant')==1
    hMainGui.Values.Thresh(nCh)=value;
elseif strcmp(Config.Threshold.Mode,'relative')==1
   hMainGui.Values.RelThresh(nCh)=value;
end
setappdata(0,'hMainGui',hMainGui);
Update(hMainGui);

function eScaleMin(hMainGui)
h=gcbo;
value=round(str2double(get(h,'String')));
nCh = hMainGui.Values.FrameIdx(1);
if value<1
    value=1;
end
if ~isnan(value)
    if value<hMainGui.Values.ScaleMax(nCh)
        hMainGui.Values.ScaleMin(nCh)=value;
    else
        hMainGui.Values.ScaleMin(nCh)=hMainGui.Values.ScaleMax(nCh);
    end
    UpdateKymo(hMainGui);
end
setappdata(0,'hMainGui',hMainGui);
Update(hMainGui);

function eScaleMax(hMainGui)
h=gcbo;
value=round(str2double(get(h,'String')));
nCh = hMainGui.Values.FrameIdx(1);
if ~isnan(value)
    if value>hMainGui.Values.PixMax(nCh)
        value=hMainGui.Values.PixMax(nCh);
    end
    if value>hMainGui.Values.ScaleMin(nCh)    
        hMainGui.Values.ScaleMax(nCh)=value;
    else
        hMainGui.Values.ScaleMax(nCh)=hMainGui.Values.ScaleMin(nCh);        
    end
    UpdateKymo(hMainGui);
end
setappdata(0,'hMainGui',hMainGui);
Update(hMainGui);

function eScale(hMainGui)
global Config;
h=gcbo;
value=round(str2double(get(h,'String')));
nCh = hMainGui.Values.FrameIdx(1);
if ~isnan(value);
    if value<1
        value=1;
    end
    if strcmp(Config.Threshold.Mode,'constant')==1
        if value>hMainGui.Values.PixMax(nCh)
             value=hMainGui.Values.PixMax(nCh);
        end
        hMainGui.Values.Thresh(nCh)=value;     
    elseif strcmp(Config.Threshold.Mode,'relative')==1
        if value>hMainGui.Values.MaxRelThresh(nCh)
             value=hMainGui.Values.MaxRelThresh(nCh);
        end
        hMainGui.Values.RelThresh(nCh)=value;
    end
end
setappdata(0,'hMainGui',hMainGui);
Update(hMainGui);

function Update(hMainGui)
global Config;
nCh = hMainGui.Values.FrameIdx(1);
slider_step(1) = 1/double(hMainGui.Values.PixMax(nCh));
slider_step(2) = 100/double(hMainGui.Values.PixMax(nCh));
if (max(slider_step)>=1)||(min(slider_step)<=0)
    slider_step=[0.1 0.1];
end
set(hMainGui.LeftPanel.pNorm.sScaleMin,'Enable','on','sliderstep',slider_step,'max',hMainGui.Values.PixMax(nCh),'min',0,'Value',hMainGui.Values.ScaleMin(nCh));
set(hMainGui.LeftPanel.pNorm.sScaleMax,'Enable','on','sliderstep',slider_step,'max',hMainGui.Values.PixMax(nCh),'min',0,'Value',hMainGui.Values.ScaleMax(nCh));
set(hMainGui.LeftPanel.pNorm.eScaleMin,'Enable','on','String',int2str(hMainGui.Values.ScaleMin(nCh)));
set(hMainGui.LeftPanel.pNorm.eScaleMax,'Enable','on','String',int2str(hMainGui.Values.ScaleMax(nCh)));
SetThresh(hMainGui,Config.Threshold.Mode);
fShared('ReturnFocus');
fShow('Image');

function SetAllPanelsOff(hMainGui)
global Config;
set(hMainGui.LeftPanel.pNorm.panel,'Visible','off');
set(hMainGui.LeftPanel.pThresh.panel,'Visible','off');
set(hMainGui.LeftPanel.pRedNorm.panel,'Visible','off');
set(hMainGui.LeftPanel.pGreenNorm.panel,'Visible','off');
set(hMainGui.LeftPanel.pRedThresh.panel,'Visible','off');
set(hMainGui.LeftPanel.pGreenThresh.panel,'Visible','off');
SetThresh(hMainGui,Config.Threshold.Mode);

function DisableAllPanels(hMainGui)
sPanels{1}='';
sPanels{2}='Red';
sPanels{3}='Green';
for n=1:3
    set(findobj('Parent',hMainGui.LeftPanel.(sprintf('p%sNorm',sPanels{n})).panel,'-and','Style','edit'),'Enable','off');
    set(findobj('Parent',hMainGui.LeftPanel.(sprintf('p%sThresh',sPanels{n})).panel,'-and','Style','edit'),'Enable','off');    
    set(findobj('Parent',hMainGui.LeftPanel.(sprintf('p%sNorm',sPanels{n})).panel,'-and','Type','slider'),'Enable','off');
    set(findobj('Parent',hMainGui.LeftPanel.(sprintf('p%sThresh',sPanels{n})).panel,'-and','Style','slider'),'Enable','off');    
    cla(hMainGui.LeftPanel.(sprintf('p%sNorm',sPanels{n})).aScaleBar);
    cla(hMainGui.LeftPanel.(sprintf('p%sThresh',sPanels{n})).aScaleBar);        
end

function NormPanel(hMainGui)
SetAllPanelsOff(hMainGui);
set(hMainGui.LeftPanel.pNorm.panel,'Visible','on');
if isfield(hMainGui,'Values')
    fShow('Image');
    fShow('Tracks');
end

function ThreshPanel(hMainGui)
SetAllPanelsOff(hMainGui);
set(hMainGui.LeftPanel.pThresh.panel,'Visible','on');
if isfield(hMainGui,'Values')
    Update(hMainGui);
    fShow('Image');
    fShow('Tracks');    
end

function RegUpdateList(hMainGui)
l = length(hMainGui.Region);
slider = hMainGui.LeftPanel.pRegions.sRegList;
if l>8
    slider_step(1) = 1/(l-8);
    slider_step(2) = 8/(l-8);
    if strcmp(get(slider,'Enable'),'on')==1
        v=get(slider,'Value');
        if v>l-7
            v=l-7;
        end
        set(slider,'sliderstep',slider_step,...
         'max',l-7,'min',1,'Value',v)
    else
        set(slider,'sliderstep',slider_step,...
         'max',l-7,'min',1,'Value',l-8,'Enable','on')
    end
    ListBegin=(l-7)-round(get(slider,'Value'));
    ListLength=8;
else
    slider_step(1) = 0.1;
    slider_step(2) = 0.1;
    set(slider,'sliderstep',slider_step,...
         'max',2,'min',1,'Value',1,'Enable','off')
     ListLength=l;
     ListBegin=0;
end
for i=1:ListLength
    set(hMainGui.LeftPanel.pRegions.RegList.Pan(i),'Visible','on','UIContextMenu',hMainGui.Menu.ctRegion);    
    set(hMainGui.LeftPanel.pRegions.RegList.Region(i),'Enable','inactive','ForegroundColor',hMainGui.Region(i+ListBegin).color,'UIContextMenu',hMainGui.Menu.ctRegion,'String',['Region ' num2str(i+ListBegin)],'UserData',i+ListBegin);
end
for i=ListLength+1:8
    set(hMainGui.LeftPanel.pRegions.RegList.Pan(i),'Visible','off');    
    set(hMainGui.LeftPanel.pRegions.RegList.Region(i),'Enable','off','String','');
end
if l>0
    set(hMainGui.LeftPanel.pRegions.cExcludeReg,'Enable','on');
else
    set(hMainGui.LeftPanel.pRegions.cExcludeReg,'Enable','off');
end

function RegListSlider(hMainGui)
RegUpdateList(hMainGui);
fShared('ReturnFocus');

function LoadRegion(hMainGui)
[FileName, PathName] = uigetfile({'*.mat','FIESTA Regions (*.mat)'},'Load FIESTA Regions',fShared('GetLoadDir'));
if FileName~=0
    fShared('SetLoadDir',PathName);
    Region=fLoad([PathName FileName],'Region');
    nRegion=length(hMainGui.Region);
    nNewRegion=length(Region);
    hMainGui.Region = [hMainGui.Region Region];
    for i=nRegion+1:nRegion+nNewRegion
        hMainGui.Region(i).color=hMainGui.RegionColor(mod(i-1,24)+1,:);        
        hMainGui.Plots.Region(i)=plot(hMainGui.Region(i).X,hMainGui.Region(i).Y,'Color',hMainGui.Region(i).color,'LineStyle','--','UserData',i,'UIContextMenu',hMainGui.Menu.ctRegion);
    end
end
setappdata(0,'hMainGui',hMainGui);
RegUpdateList(hMainGui);
fShared('ReturnFocus');

function SaveRegion(hMainGui)
[FileName, PathName] = uiputfile({'*.mat','MAT-files (*.mat)'},'Save FIESTA Regions',fShared('GetSaveDir'));
if FileName~=0
    fShared('SetSaveDir',PathName);
    Region=hMainGui.Region; %#ok<NASGU>
    file = [PathName FileName];
    if isempty(findstr('.mat',file))
        file = [file '.mat'];
    end
    save(file,'Region');
end
fShared('ReturnFocus');
function fFlowEval(varargin)
global Stack;
if ~isempty(Stack) && nargin==0
    hFlowEval.fig = figure('Units','normalized','DockControls','off','IntegerHandle','off','Name','FIESTA - Kymograph Evaluation','MenuBar','none',...
                         'NumberTitle','off','Position',[0.005 0.032 0.99 0.865],'HandleVisibility','callback',...
                         'Visible','on','NextPlot','add','WindowStyle','modal');
    fPlaceFig(hFlowEval.fig,'full');
    hFlowEval.sContrast = uicontrol('Parent',hFlowEval.fig,'Style','slider','Units','normalized','Position',[0.02 0.05 0.02 0.9],'Enable','on','Callback',@ChangeContrast);   
    hFlowEval.aImage = axes('Parent',hFlowEval.fig,'Units','normalized','Visible','off','Position',[0.05 0.05 0.775 0.9]);
    hFlowEval.hTools = uibuttongroup('Parent',hFlowEval.fig,'Units','normalized','Visible','on','Position',[0.85 0.875 0.125 0.075],'BackgroundColor',get(hFlowEval.fig,'Color'));
    
    
    CData=zeros(30,30,3);
    CData(:,:,1)=[NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,0,0,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,0,0,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,0,0,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,0,0,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,0,0,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,0,0,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;];
    CData(:,:,2)=CData(:,:,1);
    CData(:,:,3)=CData(:,:,1);
    hFlowEval.bSingle = uicontrol('Style','togglebutton','Units','normalized','String','','CData',CData,'Position',[0.1 0.1 0.3 0.8],'Parent',hFlowEval.hTools,'Enable','on','HandleVisibility','off');

    CData(:,:,1)=[NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,0,0,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,0,0,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,0,0,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,0,0,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,0,0,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,0,0,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,NaN,NaN,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,0,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,0,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,0,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;];
    CData(:,:,2)=CData(:,:,1);
    CData(:,:,3)=CData(:,:,1); 
    hFlowEval.bMulti = uicontrol('Style','togglebutton','Units','normalized','String','','CData',CData,'Position',[0.6 0.1 0.3 0.8],'Parent',hFlowEval.hTools,'Enable','on','HandleVisibility','off');
    set(hFlowEval.hTools,'SelectedObject',hFlowEval.bSingle);
    
    hFlowEval.lResults = uitable('Parent',hFlowEval.fig,'Units','normalized','Position',[0.85 0.32 0.125 0.53],'Enable','off');  
    jTable = findjobj(hFlowEval.lResults);
    jTable.setVerticalScrollBarPolicy(22);
    jTable.setHorizontalScrollBarPolicy(31);
    
    hFlowEval.tLineWidth = uicontrol('Parent',hFlowEval.fig,'Style','text','String','Line width:','Units','normalized','Position',[0.85 0.28 0.05 0.025],'BackgroundColor',get(hFlowEval.fig,'Color'),'FontSize',12,'HorizontalAlignment','left');   
    hFlowEval.eLineWidth = uicontrol('Parent',hFlowEval.fig,'Style','edit','String','2','Units','normalized','Position',[0.92 0.285 0.04 0.025]);   
    hFlowEval.tPix = uicontrol('Parent',hFlowEval.fig,'Style','text','String','pix','Units','normalized','Position',[0.965 0.28 0.01 0.025],'BackgroundColor',get(hFlowEval.fig,'Color'),'FontSize',12,'HorizontalAlignment','left');  
    hFlowEval.tZoom = uicontrol('Parent',hFlowEval.fig,'Style','text','String','Zoom factor:','Units','normalized','Position',[0.85 0.25 0.05 0.025],'BackgroundColor',get(hFlowEval.fig,'Color'),'FontSize',12,'HorizontalAlignment','left');  
    hFlowEval.eZoom = uicontrol('Parent',hFlowEval.fig,'Style','edit','String','400','Units','normalized','Position',[0.92 0.255 0.04 0.025],'Callback',@Next); 
    hFlowEval.tPercent = uicontrol('Parent',hFlowEval.fig,'Style','text','String','%','Units','normalized','Position',[0.965 0.25 0.01 0.025],'BackgroundColor',get(hFlowEval.fig,'Color'),'FontSize',12,'HorizontalAlignment','left');  
    
    hFlowEval.hButtons = uibuttongroup('Parent',hFlowEval.fig,'Units','normalized','Visible','on','Position',[0.85 0.19 0.125 0.06],'BackgroundColor',get(hFlowEval.fig,'Color'));
    hFlowEval.rAutomatic = uicontrol('Style','Radio','Units','normalized','String','Automatic','Position',[0.1 0.6 0.8 0.3],'Parent',hFlowEval.hButtons,'Enable','on','HandleVisibility','off','BackgroundColor',get(hFlowEval.fig,'Color'));
    hFlowEval.rManuell = uicontrol('Style','Radio','Units','normalized','String','Manuell','Position',[0.1 0.1 0.8 0.3],'Parent',hFlowEval.hButtons,'Enable','on','HandleVisibility','off','BackgroundColor',get(hFlowEval.fig,'Color'));
    set(hFlowEval.hButtons,'SelectedObject',[]);
    hFlowEval.bNext = uicontrol('Parent',hFlowEval.fig,'Style','pushbutton','String','Next','Units','normalized','Position',[0.85 0.14 0.125 0.04],'Enable','on','Callback',@Next);
    hFlowEval.bSave = uicontrol('Parent',hFlowEval.fig,'Style','pushbutton','String','Save','Units','normalized','Position',[0.85 0.095 0.125 0.04],'Enable','off','Callback',@Save);
    hFlowEval.bExport = uicontrol('Parent',hFlowEval.fig,'Style','pushbutton','String','Export','Units','normalized','Position',[0.85 0.05 0.125 0.04],'Enable','off','Callback',@Export);
    hFlowEval.mContext = uicontextmenu('Parent',hFlowEval.fig);       
    hFlowEval.mDelete = uimenu('Parent',hFlowEval.mContext,'Callback',@Delete,...
                                'Label','Delete','Tag','mDelete ','UserData','Selected');
    hFlowEval.mDeleteAll = uimenu('Parent',hFlowEval.mContext,'Callback',@Delete,...
                                'Label','Delete all','Tag','mDeleteAll','UserData','All');           
    
    set(hFlowEval.fig,'WindowButtonMotionFcn',@UpdateCursor,'WindowButtonUpFcn',@ButtonUp,'ResizeFcn',@Resize,'CloseRequestFcn',@Close);
    set(hFlowEval.fig,'KeyReleaseFcn',@KeyRelease);
    set(hFlowEval.aImage,'CLim',[0 65535],'YDir','reverse','NextPlot','add','TickDir','in','Visible','off'); 
    set(hFlowEval.fig,'colormap',colormap('Gray'));
    for n = 1:size(Stack)
        hFlowEval.Used{n} = zeros(size(Stack{1}(:,:,n)));
        hFlowEval.Data{n} = [];
        m(n) = mean2(Stack{n});
        s(n) = std2(Stack{n});
    end
    PixMin = min(min(Stack{1}));
    PixMax = max(max(Stack{1}));
    mContrast = round(mean(m)+6*mean(s));
    Image = imadjust(Stack{1}(:,:,1),[double(PixMin(1))/2^16 double(mContrast)/2^16],[]);
    hFlowEval.hImage = image(Image,'Parent',hFlowEval.aImage,'CDataMapping','scaled','EraseMode','normal');
    set(hFlowEval.aImage,'CLim',[0 65535],'YDir','reverse','NextPlot','add','TickDir','in','Visible','off'); 
    set(hFlowEval.fig,'colormap',colormap('Gray'));
    daspect([1 1 1]); 
    slider_step(1) = 1/double(max(PixMax)-min(PixMin));
    slider_step(2) = 100/double(max(PixMax)-min(PixMin));
    if (max(slider_step)>=1)||(min(slider_step)<=0)
        slider_step=[0.1 0.1];
    end
    hFlowEval.cp = [];
    hFlowEval.Line = {};
    set(hFlowEval.sContrast,'sliderstep',slider_step,'Min',min(PixMin),'Max',max(PixMax),'Value',mContrast);
    setappdata(0,'hFlowEval',hFlowEval);
    Next([],[]);
end

function Close(~,~)
hFlowEval = getappdata(0,'hFlowEval');
delete(hFlowEval.fig);
rmappdata(0,'hFlowEval');

function Resize(~,~)
hFlowEval = getappdata(0,'hFlowEval');
UpdateMeasure(hFlowEval);

function KeyRelease(~,evt)
if evt.Key=='n';
    Next([],[]);
end

function ChangeContrast(hObj,~)
global Stack;
hFlowEval = getappdata(0,'hFlowEval');
mContrast = round(get(hObj,'Value'));
Image = uint16(Stack{1}(:,:,hFlowEval.Current));
Image = imadjust(Image,[double(min(min(Image)))/2^16 double(mContrast)/2^16],[]);
set(hFlowEval.hImage,'CData',Image);

function UpdateCursor(~,~)
hFlowEval = getappdata(0,'hFlowEval');
CData = get(hFlowEval.hImage,'CData');
xy = {[0.5 size(CData,2)+0.5],[0.5 size(CData,1)+0.5]};
cp = get(hFlowEval.aImage,'CurrentPoint');
cp = cp(1,[1 2]);
cp(1) = round(cp(1));
if  all(cp>=[xy{1}(1) xy{2}(1)]) && all(cp<=[xy{1}(2) xy{2}(2)])
    setptr(hFlowEval.fig, 'datacursor');
    if ~isempty(hFlowEval.cp)
        set(hFlowEval.Line{end},'XData',[hFlowEval.cp(:,1); cp(1)],'YData',[hFlowEval.cp(:,2); cp(2)]);
    end
else
    set(hFlowEval.fig,'pointer','arrow');
end

function ButtonUp(~,~)
hFlowEval = getappdata(0,'hFlowEval');
if ~strcmp(get(hFlowEval.fig,'SelectionType'),'alt')
    if isempty(hFlowEval.cp) 
        if strcmp(get(hFlowEval.fig,'SelectionType'),'extend')
            set(hFlowEval.hButtons,'SelectedObject',hFlowEval.rAutomatic);
        else
            set(hFlowEval.hButtons,'SelectedObject',hFlowEval.rManuell);
        end
    end
    CData = get(hFlowEval.hImage,'CData');
    xy = {[0.5 size(CData,2)+0.5],[0.5 size(CData,1)+0.5]};
    cp = get(hFlowEval.aImage,'CurrentPoint');
    cp = cp(1,[1 2]);
    cp(1) = round(cp(1));
    if  all(cp>=[xy{1}(1) xy{2}(1)]) && all(cp<=[xy{1}(2) xy{2}(2)])
        if isempty(hFlowEval.cp)   
            measure = get(hFlowEval.hButtons,'SelectedObject');
            if isempty(measure)
                measure = 0;
            end
            if measure == hFlowEval.rManuell
                hFlowEval.cp = cp;
                hFlowEval.Line{end+1} = line([hFlowEval.cp(:,1); cp(1)],[hFlowEval.cp(:,2); cp(2)],'Color','g','LineStyle','-','Tag','temp');
            elseif measure == hFlowEval.rAutomatic
                hFlowEval = AutoMeasure(hFlowEval,cp);
            else
                fMsgDlg('Choose either manual or automatic measurements','warn');
            end
        else
            if get(hFlowEval.hTools,'SelectedObject') == hFlowEval.bSingle
                set(hFlowEval.Line{end},'XData',[hFlowEval.cp(:,1); cp(1)],'YData',[hFlowEval.cp(:,2); cp(2)],'Color','r','LineStyle','-','Tag','line','UserData',length(hFlowEval.Line),'UIContextMenu',hFlowEval.mContext);
                hFlowEval.Line{end} = sortrows([hFlowEval.cp; cp],2);
                addText(hFlowEval.Line{end},length(hFlowEval.Line));
                hFlowEval.cp = [];
                hFlowEval = Measure(hFlowEval);                
            else
                if strcmp(get(hFlowEval.fig,'SelectionType'),'normal')
                    hFlowEval.cp = [hFlowEval.cp; cp];
                elseif strcmp(get(hFlowEval.fig,'SelectionType'),'open')
                    k=0;
                    while ~isempty(k)
                        d=sqrt((hFlowEval.cp(2:end,1)-hFlowEval.cp(1:end-1,1)).^2 + (hFlowEval.cp(2:end,2)-hFlowEval.cp(1:end-1,2)).^2);
                        k = find(d<1,1,'first');
                        hFlowEval.cp(k,:)=[];
                    end
                    set(hFlowEval.Line{end},'XData',hFlowEval.cp(:,1),'YData',hFlowEval.cp(:,2),'Color','r','LineStyle','-','Tag','line','UserData',length(hFlowEval.Line),'UIContextMenu',hFlowEval.mContext);
                    hFlowEval.Line{end} = sortrows(hFlowEval.cp,2);
                    addText(hFlowEval.Line{end},length(hFlowEval.Line));
                    hFlowEval.cp = [];
                    set(hFlowEval.bCreate,'Enable','on');
                    hFlowEval = Measure(hFlowEval);
                end     
            end
        end
        setappdata(0,'hFlowEval',hFlowEval);
    end
end

function hFlowEval = Measure(hFlowEval)
hMainGui = getappdata(0,'hMainGui');
PixSize = hMainGui.Values.PixSize;
X = hFlowEval.Line{end}(:,1);
Y = hFlowEval.Line{end}(:,2);
D = abs(X(end)-X(1));
hFlowEval.Data{hFlowEval.Current} = [hFlowEval.Data{hFlowEval.Current}; length(hFlowEval.Line) hFlowEval.Current D*PixSize/1000];
UpdateMeasure(hFlowEval)

function hFlowEval = AutoMeasure(hFlowEval,cp)
global Stack;
global Config;
X=[];
hMainGui = getappdata(0,'hMainGui');
PixSize = hMainGui.Values.PixSize;
ftype = fittype('b+h*exp(-(x-x0).^2/(2*s)^2)');
fopts = fitoptions('Method','NonLinearLeastSquares','MaxFunEvals',30,'MaxIter',20,'TolX',0.1,'TolFun',0.1);
s = Config.Threshold.FWHM / PixSize / (2*sqrt(2*log(2)));
[f,c,o] = FitGauss(Stack{1}(:,:,hFlowEval.Current),cp,s,ftype,fopts);
if c(1,2)>0 && o.exitflag>0
    X(1) = cp(1);
    Y(1) = f.x0;
    H(1) = f.h;
    p=1;
    [f,c,o] = FitGauss(Stack{1}(:,:,hFlowEval.Current),round([X(end)+1 Y(end)]),s,ftype,fopts);
    while c(1,2)>0 && o.exitflag>0 
        X = [X cp(1)+p];
        Y = [Y f.x0];
        H = [H f.h];
        p = p+1;
        if Y(end)+1<=size(Stack{1},2)
            [f,c,o] = FitGauss(Stack{1}(:,:,hFlowEval.Current),round([X(end)+1 Y(end)]),s,ftype,fopts);
        else
            break;
        end
    end
    p=1;
    [f,c,o] = FitGauss(Stack{1}(:,:,hFlowEval.Current),round([X(1)-1 Y(1)]),s,ftype,fopts);
    while c(1,2)>0 && o.exitflag>0 && X(end)>1
        X = [cp(1)-p X];
        Y = [f.x0 Y];
        H = [f.h H];
        p = p+1;
        if Y(1)-1>=1
            [f,c,o] = FitGauss(Stack{1}(:,:,hFlowEval.Current),round([X(1)-1 Y(1)]),s,ftype,fopts);
        else
            break;
        end        
    end
end
if length(X)>1
    idx=H<median(H)-2*std(H);
    X(idx)=[];
    Y(idx)=[];
    if length(X) > 3
        [f,stats] = robustfit(X',Y');
        fY = (f(1)+X*f(2));
        X(stats.w==0)=[];
        Y(stats.w==0)=[];
        fY(stats.w==0)=[];
    end
    D = abs(X(end)-X(1));
    hFlowEval.Line{end+1} = [X' Y'];
    line(X,Y,'Color','b','LineStyle','-','Tag','line','UserData',length(hFlowEval.Line),'UIContextMenu',hFlowEval.mContext);
    line(X,fY,'Color','r','LineStyle','-','Tag','line','UserData',length(hFlowEval.Line),'UIContextMenu',hFlowEval.mContext);  
    addText(hFlowEval.Line{end},length(hFlowEval.Line));
    hFlowEval.Data{hFlowEval.Current} = [hFlowEval.Data{hFlowEval.Current}; length(hFlowEval.Line) hFlowEval.Current D*PixSize/1000];
    UpdateMeasure(hFlowEval)
end

function addText(XY,N)
hFlowEval = getappdata(0,'hFlowEval');
zoom = str2double(get(hFlowEval.eZoom,'String'))/100;
if sign(XY(end,1)-XY(1,1))>0
    text(XY(1,1)-1,XY(1,2),num2str(N),'HorizontalAlignment','Right','Clipping','on','Tag','line','UserData',N,'Color','r','FontSize',4+2*zoom,'UIContextMenu',hFlowEval.mContext);
else
    text(XY(1,1)+1,XY(1,2),num2str(N),'HorizontalAlignment','Left','Clipping','on','Tag','line','UserData',N,'Color','r','FontSize',4+2*zoom,'UIContextMenu',hFlowEval.mContext);
end
    
function [f,c,o]=FitGauss(I,xy,s,ftype,fopts)
sx = max([round(xy(2)-4*s) 1]);
ex = min([round(xy(2)+4*s) size(I,1)]);
line = double(I(sx:ex,xy(1)));
idx = sx:ex;
set(fopts,'StartPoint',[min(line) max(line)-min(line) s round(xy(2))]);
[f,~,o] = fit(idx',line,ftype,fopts);
c=confint(f,0.99);

function UpdateMeasure(hFlowEval)
Data = cell2mat(hFlowEval.Data');
if isempty(Data)
    set(hFlowEval.lResults,'Data',[],'Enable','off');   
    set(hFlowEval.bSave,'Enable','off');
else
    Data = sortrows(Data,1);
    set(hFlowEval.fig,'Units','pixels');
    ssizetemp = get(hFlowEval.fig,'Position');
    set(hFlowEval.fig,'Units','normalized');
    ssize = ssizetemp(3);
    ssize = ssize * 0.125;
    big = fix((ssize-19)/3);
    set(hFlowEval.lResults,'Data',Data(:,1:3),'Enable','on','ColumnFormat',{'numeric','numeric','bank'},'ColumnWidth',{big,big,big},'RowName','','ColumnName',{'Index','Frame','<html><CENTER>Distance<br><CENTER>[&mu;m]'});
    set(hFlowEval.bSave,'Enable','on');
end

function Delete(hObj,~)
hFlowEval = getappdata(0,'hFlowEval');
mode = get(hObj,'UserData');
if strcmp(mode,'All')
    mode=fQuestDlg('Delete all traces?','FIESTA - Flow Evaluation',{'Yes','No'},'No');
    if strcmp(mode,'No')
        return;
    end
    idx = 1:length(hFlowEval.Line);
    delete(findobj('Tag','line'));
else
    if gco==hFlowEval.lResults
        idx = get(gco,Value) - 1;
        idx(idx<1)=[];
    else
        idx = get(gco,'UserData');
    end
    hLine = findobj('Tag','line');
    t = cell2mat(get(hLine,'UserData')); 
    delete(hLine(t==idx));
    k = find(t>idx);
    for n=k'
        set(hLine(n),'UserData',t(n)-1);  
        if strcmp(get(hLine(n),'Type'),'text')
            set(hLine(n),'String',num2str(t(n)-1));  
        end   
    end
end
hFlowEval.Line(idx)=[];
if length(idx)==1
    for n=1:length(hFlowEval.Data)
        if ~isempty(hFlowEval.Data{n})
            nStack = hFlowEval.Data{n}(:,1);
            t = find(nStack==idx);
            k = find(nStack>idx);
            hFlowEval.Data{n}(k,1) = hFlowEval.Data{n}(k,1)-1;       
            hFlowEval.Data{n}(t,:)=[];
        end
    end
else
    for n=1:length(hFlowEval.Data)
        hFlowEval.Data{n} = [];
    end
end
UpdateMeasure(hFlowEval)
setappdata(0,'hFlowEval',hFlowEval);

function Next(~,~)
global Stack;
hFlowEval = getappdata(0,'hFlowEval');
set(hFlowEval.aImage,'Units','Pixels');
set(hFlowEval.aImage,'Units','Normalized');
zoom = str2double(get(hFlowEval.eZoom,'String'))/100;
c=0;
while c<100
   n = ceil(rand*length(Stack));
   total_x = size(Stack{1},2);
   total_y = size(Stack{1},1);
   dy = fix(total_y/zoom/2)-1;
   dx = fix(total_y/zoom/2)-1;
   x = dx+ceil(rand*(total_x-2*dx));
   y = dy+ceil(rand*(total_y-2*dy));
  
   Used = hFlowEval.Used{n}(y-dy:y+dy,x-dx:x+dx);
   if sum(sum(Used))<0.5*numel(Used)
       c = 100;
       hFlowEval.Used{n}(y-dy:y+dy,x-dx:x+dx) = ones(size(hFlowEval.Used{n}(y-dy:y+dy,x-dx:x+dx)));
   else
       c = c+1;
   end   
end
Image = uint16(Stack{1}(:,:,n));
mContrast = round(get(hFlowEval.sContrast,'Value'));
Image = imadjust(Image,[double(min(min(Image)))/2^16 double(mContrast)/2^16],[]);
set(hFlowEval.hImage,'CData',Image);
set(hFlowEval.aImage,'XLim',[x-dx x+dx],'YLim',[y-dy y+dy]);

hLine = findobj('Tag','line');
nLine = cell2mat(get(hLine,'UserData'));
if isempty(hFlowEval.Data{n})
    set(hLine,'Visible','off');
else
    idx = ismember(nLine,hFlowEval.Data{n}(:,1));
    set(hLine(idx),'Visible','on');
    set(hLine(~idx),'Visible','off');
    hText = findobj('Tag','line','-and','Type','text');
    set(hText,'FontSize',4+2*zoom);
end
hFlowEval.Current = n;
setappdata(0,'hFlowEval',hFlowEval);
warning off MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame
javaFrame = get(hFlowEval.fig,'JavaFrame');
javaFrame.getAxisComponent.requestFocus;

function Save(~,~)
hFlowEval = getappdata(0,'hFlowEval');
Data = sortrows(cell2mat(hFlowEval.Data'),1);
[FileName, PathName, FilterIndex] = uiputfile({'*.mat','MAT-file (*.mat)';'*.txt','TXT-File (*.txt)'},'Save FIESTA Mean Square Displacement',fShared('GetSaveDir'));
file = [PathName FileName];
if FilterIndex==1
    fShared('SetSaveDir',PathName);
    if ~contains(file,'.mat')
        file = [file '.mat'];
    end
    save(file,'Data');
elseif FilterIndex==2
    fShared('SetSaveDir',PathName);
    if ~contains(file,'.txt')
        file = [file '.txt'];
    end
    f = fopen(file,'w');
    fprintf(f,'Index\tFrame\tDistance[um]\n');
    fprintf(f,'%d\t%d\t%d\n',Data);
    fclose(f);

end

function Export(~,~)
global Config;
hFlowEval = getappdata(0,'hFlowEval');
PathName = uigetdir(fShared('GetSaveDir'));
file = Config.StackName(1:end-4);
format = fQuestDlg({'FIESTA will now export the reference image,','the kymographs and the data to the specified folder!','(The measurement index will be reordered consecutively)','','Which format do you want to use?'},'FIESTA - Kymograph Evaluation',{'TIFF','JPEG','PNG'},'TIFF');
if strcmp(format,'TIFF')
    f = [PathName filesep file ' - Reference.tif'];
    imwrite(hFlowEval.refImage,f,'Compression','none');
elseif strcmp(format,'JPEG') 
    f = [PathName filesep file ' - Reference.jpg'];
    imwrite(hFlowEval.refImage,f,'Quality',100);
else
    f = [PathName filesep file ' - Reference.png'];
    imwrite(hFlowEval.refImage,f);
end
mContrast = round(get(hFlowEval.sContrast,'Value'));
hLine = findobj('Tag','line');
set(hLine,'Visible','off');
nLine = cell2mat(get(hLine,'UserData'));
hText = findobj('Tag','line','-and','Type','text');    
set(hText,'FontSize',2);
delete(findobj('Tag','border'));
for n=1:length(hFlowEval.Data)
    Kymo = uint16(hFlowEval.Kymo{n});
    Image = imadjust(Kymo,[double(min(min(Kymo)))/2^16 double(mContrast)/2^16],[]);
    set(hFlowEval.hImage,'CData',Image);
    if ~isempty(hFlowEval.Data{n})
        idx = ismember(nLine,hFlowEval.Data{n}(:,1));
        set(hLine(idx),'Visible','on','LineWidth',0.2);
    end
    I = GetImage(hFlowEval,900);
    if strcmp(format,'TIFF')
        f = [PathName filesep file ' - Kymograph ' num2str(n) '.tif'];
        imwrite(I,f,'Compression','none');
    elseif strcmp(format,'JPEG') 
        f = [PathName filesep file ' - Kymograph ' num2str(n) '.jpg'];
        imwrite(I,f,'Quality',100);
    else
        f = [PathName filesep file ' - Kymograph ' num2str(n) '.png'];
        imwrite(I,f);
    end
    set(hLine,'Visible','off');
end
Data = sortrows(cell2mat(hFlowEval.Data),1);
Data(:,1) = 1:size(Data,1);
f = [PathName filesep file ' - Data.mat'];
save(f,'Data');
f = [PathName filesep file ' - Data.txt'];
fid = fopen(f,'w');
fprintf(fid,'Index\tDistance[?m]\tTime[s]\tVelocity[?m/s]\n');
fprintf(fid,'%f\t%f\t%f\t%f\n',Data(:,1:4)');
fclose(fid);
Close([],[]);

function I = GetImage(hFlowEval,dpi)
CData = get(hFlowEval.hImage,'CData');
hFig = figure('Visible','off','Units','pixels','Position',[0 0 size(CData,2) size(CData,1)]);
hAxes = copyobj(hFlowEval.aImage,hFig);
set(hAxes,'Units','normalized','Position',[0 0 1 1],{'XLim','YLim'},{[0.5 size(CData,2)+0.5],[0.5 size(CData,1)+0.5]});
set(hFig,'colormap',get(hFlowEval.fig,'colormap'));
I = hardcopy(hFig, '-Dzbuffer', ['-r' num2str(dpi)]);
c = get(hFig,'Color');
k = find(mean(I(:,:,1))==c(1)*255&mean(I(:,:,2))==c(2)*255&mean(I(:,:,3))==c(3)*255);
I(:,k,:)=[];
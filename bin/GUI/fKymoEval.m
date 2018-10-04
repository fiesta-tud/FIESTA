function fKymoEval(varargin)
global Stack;
global Filament;
global FiestaDir;
if ~isempty(Stack) && nargin==0
    hMainGui=getappdata(0,'hMainGui');
    hKymoEval.fig = figure('Units','normalized','DockControls','off','IntegerHandle','off','Name','FIESTA - Kymograph Evaluation','MenuBar','none',...
                         'NumberTitle','off','Position',[0.005 0.032 0.99 0.865],'HandleVisibility','callback',...
                         'Visible','on','NextPlot','add');
    fPlaceFig(hKymoEval.fig,'full');
    hKymoEval.sContrast = uicontrol('Parent',hKymoEval.fig,'Style','slider','Units','normalized','Position',[0.02 0.05 0.02 0.9],'Enable','on','Callback',@ChangeContrast);   
    hKymoEval.aImage = axes('Parent',hKymoEval.fig,'Units','normalized','Visible','off','Position',[0.05 0.05 0.775 0.9]);
    hKymoEval.hTools = uibuttongroup('Parent',hKymoEval.fig,'Units','normalized','Visible','on','Position',[0.85 0.875 0.125 0.075],'BackgroundColor',get(hKymoEval.fig,'Color'));
    
    
    CData=zeros(30,30,3);
    CData(:,:,1)=[NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,0,0,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,0,0,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,0,0,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,0,0,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,0,0,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,0,0,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;];
    CData(:,:,2)=CData(:,:,1);
    CData(:,:,3)=CData(:,:,1);
    hKymoEval.bSingle = uicontrol('Style','togglebutton','Units','normalized','String','','CData',CData,'Position',[0.1 0.1 0.3 0.8],'Parent',hKymoEval.hTools,'Enable','on','HandleVisibility','off');

    CData(:,:,1)=[NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,0,0,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,0,0,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,0,0,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,0,0,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,0,0,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,0,0,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,NaN,NaN,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,0,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,0,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,0,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;];
    CData(:,:,2)=CData(:,:,1);
    CData(:,:,3)=CData(:,:,1); 
    hKymoEval.bMulti = uicontrol('Style','togglebutton','Units','normalized','String','','CData',CData,'Position',[0.6 0.1 0.3 0.8],'Parent',hKymoEval.hTools,'Enable','on','HandleVisibility','off');
    set(hKymoEval.hTools,'SelectedObject',hKymoEval.bSingle);
    
    hKymoEval.lResults = uitable('Parent',hKymoEval.fig,'Units','normalized','Position',[0.85 0.32 0.125 0.53],'Enable','off');  
    jTable = findjobj(hKymoEval.lResults);
    jTable.setVerticalScrollBarPolicy(22);
    jTable.setHorizontalScrollBarPolicy(31);
    
    hKymoEval.tLineWidth = uicontrol('Parent',hKymoEval.fig,'Style','text','String','Line width:','Units','normalized','Position',[0.85 0.28 0.05 0.025],'BackgroundColor',get(hKymoEval.fig,'Color'),'FontSize',12,'HorizontalAlignment','left');   
    hKymoEval.eLineWidth = uicontrol('Parent',hKymoEval.fig,'Style','edit','String','2','Units','normalized','Position',[0.92 0.285 0.04 0.025]);   
    hKymoEval.tPix = uicontrol('Parent',hKymoEval.fig,'Style','text','String','pix','Units','normalized','Position',[0.965 0.28 0.01 0.025],'BackgroundColor',get(hKymoEval.fig,'Color'),'FontSize',12,'HorizontalAlignment','left');  
    hKymoEval.tZoom = uicontrol('Parent',hKymoEval.fig,'Style','text','String','Zoom factor:','Units','normalized','Position',[0.85 0.25 0.05 0.025],'BackgroundColor',get(hKymoEval.fig,'Color'),'FontSize',12,'HorizontalAlignment','left');  
    hKymoEval.eZoom = uicontrol('Parent',hKymoEval.fig,'Style','edit','String','800','Units','normalized','Position',[0.92 0.255 0.04 0.025],'Callback',@Next); 
    hKymoEval.tPercent = uicontrol('Parent',hKymoEval.fig,'Style','text','String','%','Units','normalized','Position',[0.965 0.25 0.01 0.025],'BackgroundColor',get(hKymoEval.fig,'Color'),'FontSize',12,'HorizontalAlignment','left');  
    
    hKymoEval.hButtons = uibuttongroup('Parent',hKymoEval.fig,'Units','normalized','Visible','on','Position',[0.85 0.19 0.125 0.06],'BackgroundColor',get(hKymoEval.fig,'Color'));
    hKymoEval.rAutomatic = uicontrol('Style','Radio','Units','normalized','String','Automatic','Position',[0.1 0.6 0.8 0.3],'Parent',hKymoEval.hButtons,'Enable','off','HandleVisibility','off','BackgroundColor',get(hKymoEval.fig,'Color'));
    hKymoEval.rManuell = uicontrol('Style','Radio','Units','normalized','String','Manuell','Position',[0.1 0.1 0.8 0.3],'Parent',hKymoEval.hButtons,'Enable','off','HandleVisibility','off','BackgroundColor',get(hKymoEval.fig,'Color'));
    set(hKymoEval.hButtons,'SelectedObject',[]);
    hKymoEval.bCreate = uicontrol('Parent',hKymoEval.fig,'Style','pushbutton','String','Create','Units','normalized','Position',[0.85 0.14 0.125 0.04],'Enable','off','Callback',@Create);
    hKymoEval.bSave = uicontrol('Parent',hKymoEval.fig,'Style','pushbutton','String','Save','Units','normalized','Position',[0.85 0.095 0.125 0.04],'Enable','off','Callback',@Save);
    hKymoEval.bExport = uicontrol('Parent',hKymoEval.fig,'Style','pushbutton','String','Export','Units','normalized','Position',[0.85 0.05 0.125 0.04],'Enable','off','Callback',@Export);
    hKymoEval.mContext = uicontextmenu('Parent',hKymoEval.fig);       
    hKymoEval.mDelete = uimenu('Parent',hKymoEval.mContext,'Callback',@Delete,...
                                'Label','Delete','Tag','mDelete ','UserData','Selected');
    hKymoEval.mDeleteAll = uimenu('Parent',hKymoEval.mContext,'Callback',@Delete,...
                                'Label','Delete all','Tag','mDeleteAll','UserData','All');           
    mode = fQuestDlg({'How do you like to select lines for the Kymograph creation?',...
                    'Maximum Projection - Displays the maximum projection',...
                    'Average Projection - Displays the average projection',...
                    'Filament Image - Displays an image of the filaments ',...
                    'Filament Positions - Uses the tracked filament positions (Objects)'},...
                    'FIESTA - Kymograph Evaluation',...
                    {'Maximum Projection','Average Projection','Filament Image','Filament Positions'},'Maximum Projection');
    if isempty(mode)
        return;
    end
    maxImage = getappdata(hMainGui.fig,'MaxImage');
    averageImage = getappdata(hMainGui.fig,'AverageImage');
    if strcmp(mode,'Filament Image')
        [filfile,filpath]=uigetfile({'*.stk;*.tif;*.tiff','Images (*.stk,*.tif,*.tiff)'},'Select Filament Image',FiestaDir.Stack);
        if filfile==0
            close(hKymoEval.fig);
            return;
        end
        [I,~,~]=fStackRead([filpath filfile]);
        hKymoEval.ref = I{1};
    elseif strcmp(mode,'Average Projection')
        hKymoEval.ref = averageImage(:,:,1);
    else
        hKymoEval.ref = maxImage(:,:,1);
    end
    hKymoEval.Line = [];
    hKymoEval.cp = [];
    hKymoEval.Data = [];
    if ~isempty(hKymoEval.ref) && ~isempty(mode)
        mContrast = round(mean2(hKymoEval.ref)+3*std2(hKymoEval.ref));
        Image = imadjust(uint16(hKymoEval.ref),[double(min(min(hKymoEval.ref)))/2^16 max([double(min(min(hKymoEval.ref))+1)/2^16 double(mContrast)/2^16])],[]);
        hKymoEval.hImage = image(Image,'Parent',hKymoEval.aImage,'CDataMapping','scaled');
        set(hKymoEval.aImage,'CLim',[0 2^16],'YDir','reverse','NextPlot','add','TickDir','in','Visible','off'); 
        set(hKymoEval.fig,'colormap',colormap('Gray'));
        daspect([1 1 1]);
        line([0.5 0.5],[0.5 1],'Color','k'); 
        PixMin = min(min(hKymoEval.ref));
        PixMax = max(max(hKymoEval.ref));
        slider_step(1) = 1/double(PixMax-PixMin);
        slider_step(2) = 100/double(PixMax-PixMin);
        if (max(slider_step)>=1)||(min(slider_step)<=0)
            slider_step=[0.1 0.1];
        end
        set(hKymoEval.sContrast,'sliderstep',slider_step,'Min',PixMin,'Max',PixMax,'Value',mContrast);
        if strcmp(mode,'Filament Positions') && ~isempty(Filament)        
            for n=1:length(Filament)
                hKymoEval.Line{n} = double([Filament(n).Data{1}(:,1) Filament(n).Data{1}(:,2)])/hMainGui.Values.PixSize;
                hKymoEval.Line{n}(hKymoEval.Line{n}(:,1)<1|hKymoEval.Line{n}(:,2)<1,:)=[];
                hKymoEval.Line{n}(hKymoEval.Line{n}(:,1)>size(hKymoEval.ref,2)|hKymoEval.Line{n}(:,2)>size(hKymoEval.ref,1),:)=[];
                line(hKymoEval.Line{n}(:,1), hKymoEval.Line{n}(:,2),'Color','r','LineStyle','-','Tag','line','UserData',n,'UIContextMenu',hKymoEval.mContext); 
                setappdata(0,'hKymoEval',hKymoEval);
                addText(hKymoEval.Line{n},n);
            end
            set(hKymoEval.bCreate,'Enable','on');
        end
    end
    hKymoEval.xy = get(hKymoEval.aImage,{'XLim','YLim'});
    set(hKymoEval.fig,'WindowButtonMotionFcn',@UpdateCursor,'WindowButtonUpFcn',@ButtonUp,'ResizeFcn',@Resize,'CloseRequestFcn',@Close);
    setappdata(0,'hKymoEval',hKymoEval);
end

function Close(~,~)
hKymoEval = getappdata(0,'hKymoEval');
delete(hKymoEval.fig);
rmappdata(0,'hKymoEval');

function Resize(~,~)
hKymoEval = getappdata(0,'hKymoEval');
UpdateMeasure(hKymoEval);


function KeyRelease(~,evt)
if evt.Key=='n';
    Next([],[]);
end

function ChangeContrast(hObj,~)
hKymoEval = getappdata(0,'hKymoEval');
mContrast = round(get(hObj,'Value'));
mode = get(hKymoEval.bCreate,'String');
if strcmp(mode,'Create')
    Image = imadjust(uint16(hKymoEval.ref),[double(min(min(hKymoEval.ref)))/2^16 max([double(min(min(hKymoEval.ref))+1)/2^16 double(mContrast)/2^16])],[]);
else
    Kymo = uint16(hKymoEval.Kymo{hKymoEval.CurrentKymo});
    Image = imadjust(Kymo,[double(min(min(Kymo)))/2^16 max([double(min(min(Kymo))+1)/2^16 double(mContrast)/2^16])],[]);
end
set(hKymoEval.hImage,'CData',Image);

function UpdateCursor(~,~)
hKymoEval = getappdata(0,'hKymoEval');
CData = get(hKymoEval.hImage,'CData');
xy = {[0.5 size(CData,2)+0.5],[0.5 size(CData,1)+0.5]};
cp = get(hKymoEval.aImage,'CurrentPoint');
cp = cp(1,[1 2]);
mode = get(hKymoEval.bCreate,'String');
if strcmp(mode,'Next')
    cp(2) = round(cp(2));
end
if  all(cp>=[xy{1}(1) xy{2}(1)]) && all(cp<=[xy{1}(2) xy{2}(2)])
    setptr(hKymoEval.fig, 'datacursor');
    if ~isempty(hKymoEval.cp)
        set(hKymoEval.Line{end},'XData',[hKymoEval.cp(:,1); cp(1)],'YData',[hKymoEval.cp(:,2); cp(2)]);
    end
else
    set(hKymoEval.fig,'pointer','arrow');
end

function ButtonUp(~,~)
hKymoEval = getappdata(0,'hKymoEval');
if ~strcmp(get(hKymoEval.fig,'SelectionType'),'alt')
    if isempty(hKymoEval.cp) 
        if strcmp(get(hKymoEval.fig,'SelectionType'),'extend')
            set(hKymoEval.hButtons,'SelectedObject',hKymoEval.rAutomatic);
        else
            set(hKymoEval.hButtons,'SelectedObject',hKymoEval.rManuell);
        end
    end
    CData = get(hKymoEval.hImage,'CData');
    xy = {[0.5 size(CData,2)+0.5],[0.5 size(CData,1)+0.5]};
    cp = get(hKymoEval.aImage,'CurrentPoint');
    cp = cp(1,[1 2]);
    mode = get(hKymoEval.bCreate,'String');
    if strcmp(mode,'Next')
        cp(2) = round(cp(2));
    end
    if  all(cp>=[xy{1}(1) xy{2}(1)]) && all(cp<=[xy{1}(2) xy{2}(2)])
        if isempty(hKymoEval.cp)   
            measure = get(hKymoEval.hButtons,'SelectedObject');
            if isempty(measure)
                measure = 0;
            end
            if strcmp(mode,'Create') || measure == hKymoEval.rManuell
                hKymoEval.cp = cp;
                hKymoEval.Line{end+1} = line([hKymoEval.cp(:,1); cp(1)],[hKymoEval.cp(:,2); cp(2)],'Color','g','LineStyle','-','Tag','temp');
            elseif measure == hKymoEval.rAutomatic
                hKymoEval = AutoMeasure(hKymoEval,cp);
            else
                fMsgDlg('Choose either manual or automatic measurements','warn');
            end
        else
            if get(hKymoEval.hTools,'SelectedObject') == hKymoEval.bSingle
                set(hKymoEval.Line{end},'XData',[hKymoEval.cp(:,1); cp(1)],'YData',[hKymoEval.cp(:,2); cp(2)],'Color','r','LineStyle','-','Tag','line','UserData',length(hKymoEval.Line),'UIContextMenu',hKymoEval.mContext);
                hKymoEval.Line{end} = sortrows([hKymoEval.cp; cp],2);
                addText(hKymoEval.Line{end},length(hKymoEval.Line));
                hKymoEval.cp = [];
                set(hKymoEval.bCreate,'Enable','on');
                if strcmp(mode,'Next')
                    hKymoEval = Measure(hKymoEval);                
                end
            else
                if strcmp(get(hKymoEval.fig,'SelectionType'),'normal')
                    hKymoEval.cp = [hKymoEval.cp; cp];
                elseif strcmp(get(hKymoEval.fig,'SelectionType'),'open')
                    k=0;
                    while ~isempty(k)
                        d=sqrt((hKymoEval.cp(2:end,1)-hKymoEval.cp(1:end-1,1)).^2 + (hKymoEval.cp(2:end,2)-hKymoEval.cp(1:end-1,2)).^2);
                        k = find(d<1,1,'first');
                        hKymoEval.cp(k,:)=[];
                    end
                    set(hKymoEval.Line{end},'XData',hKymoEval.cp(:,1),'YData',hKymoEval.cp(:,2),'Color','r','LineStyle','-','Tag','line','UserData',length(hKymoEval.Line),'UIContextMenu',hKymoEval.mContext);
                    if strcmp(mode,'Next')
                        hKymoEval.Line{end} = sortrows(hKymoEval.cp,2);
                    else
                         hKymoEval.Line{end} = hKymoEval.cp;
                    end
                    addText(hKymoEval.Line{end},length(hKymoEval.Line));
                    hKymoEval.cp = [];
                    set(hKymoEval.bCreate,'Enable','on');
                    if strcmp(mode,'Next')
                        hKymoEval = Measure(hKymoEval);
                    end
                end     
            end
        end
        setappdata(0,'hKymoEval',hKymoEval);
    end
end

function hKymoEval = Measure(hKymoEval)
global TimeInfo;
hMainGui = getappdata(0,'hMainGui');
PixSize = hMainGui.Values.PixSize*hKymoEval.KymoPix(hKymoEval.CurrentKymo);
X = hKymoEval.Line{end}(:,1);
Y = hKymoEval.Line{end}(:,2);
T = (TimeInfo{1}(Y)-TimeInfo{1}(Y(1)))*sign(TimeInfo{1}(Y(end))-TimeInfo{1}(Y(1)))/1000;
D = (X-X(1))*PixSize*sign(X(end)-X(1))/1000;
if length(T) == 2
    V=D(2)/T(2);
else
    f = fit(T',D,'poly1');
    V = f.p1; 
end
if X(end)>X(1)
    hKymoEval.Data{hKymoEval.CurrentKymo} = [hKymoEval.Data{hKymoEval.CurrentKymo}; length(hKymoEval.Line) D(end) T(end) V X(1)*PixSize/1000 (size(hKymoEval.Kymo{hKymoEval.CurrentKymo},2)-X(end))*PixSize/1000 Y(1) (size(hKymoEval.Kymo{hKymoEval.CurrentKymo},1)-Y(end))];
else
    hKymoEval.Data{hKymoEval.CurrentKymo} = [hKymoEval.Data{hKymoEval.CurrentKymo}; length(hKymoEval.Line) D(end) T(end) V (size(hKymoEval.Kymo{hKymoEval.CurrentKymo},2)-X(1))*PixSize/1000 X(end)*PixSize/1000 Y(1) (size(hKymoEval.Kymo{hKymoEval.CurrentKymo},1)-Y(end))];
end
UpdateMeasure(hKymoEval)

function hKymoEval = AutoMeasure(hKymoEval,cp)
global TimeInfo;
global Config;
X=[];
hMainGui = getappdata(0,'hMainGui');
PixSize = hMainGui.Values.PixSize*hKymoEval.KymoPix(hKymoEval.CurrentKymo);
ftype = fittype('b+h*exp(-(x-x0).^2/(2*s)^2)');
fopts = fitoptions('Method','NonLinearLeastSquares','MaxFunEvals',30,'MaxIter',20,'TolX',0.1,'TolFun',0.1);
s = Config.Threshold.FWHM / PixSize / (2*sqrt(2*log(2)));
[f,c,o] = FitGauss(hKymoEval.Kymo{hKymoEval.CurrentKymo},cp,s,ftype,fopts);
if c(1,2)>0 && o.exitflag>0
    X(1) = f.x0;
    Y(1) = cp(2);
    H(1) = f.h;
    p=1;
    [f,c,o] = FitGauss(hKymoEval.Kymo{hKymoEval.CurrentKymo},round([X(end) Y(end)+1]),s,ftype,fopts);
    while c(1,2)>0 && o.exitflag>0 
        X = [X f.x0];
        Y = [Y cp(2)+p];
        H = [H f.h];
        p = p+1;
        if Y(end)+1<=size(hKymoEval.Kymo{hKymoEval.CurrentKymo},1)
            [f,c,o] = FitGauss(hKymoEval.Kymo{hKymoEval.CurrentKymo},round([X(end) Y(end)+1]),s,ftype,fopts);
        else
            break;
        end
    end
    p=1;
    [f,c,o] = FitGauss(hKymoEval.Kymo{hKymoEval.CurrentKymo},round([X(1) Y(1)-1]),s,ftype,fopts);
    while c(1,2)>0 && o.exitflag>0 && Y(end)>1
        X = [f.x0 X];
        Y = [cp(2)-p Y];
        H = [f.h H];
        p = p+1;
        if Y(1)-1>=1
            [f,c,o] = FitGauss(hKymoEval.Kymo{hKymoEval.CurrentKymo},round([X(1) Y(1)-1]),s,ftype,fopts);
        else
            break;
        end        
    end
end
if length(X)>1
    idx=H<median(H)-2*std(H);
    X(idx)=[];
    Y(idx)=[];
    T = (TimeInfo{1}(Y)-TimeInfo{1}(Y(1)))*sign(TimeInfo{1}(Y(end))-TimeInfo{1}(Y(1)))/1000;
    D = (X-X(1))*PixSize*sign(X(end)-X(1))/1000;
    if length(T) == 2
        V=D(2)/T(2);
        fX = D*1000/PixSize*sign(X(end)-X(1));
    else
        [f,stats] = robustfit(T',D');
        V = f(2); 
        fX = (f(1)+T*f(2))*1000/PixSize*sign(X(end)-X(1))+X(1);
        T(stats.w==0)=[];
        X(stats.w==0)=[];
        Y(stats.w==0)=[];
        D(stats.w==0)=[];
        fX(stats.w==0)=[];
        T=T-T(1);
    end
    hKymoEval.Line{end+1} = [X' Y'];
    line(X,Y,'Color','b','LineStyle','-','Tag','line','UserData',length(hKymoEval.Line),'UIContextMenu',hKymoEval.mContext);
    line(fX,Y,'Color','r','LineStyle','-','Tag','line','UserData',length(hKymoEval.Line),'UIContextMenu',hKymoEval.mContext);  
    addText(hKymoEval.Line{end},length(hKymoEval.Line));
    if X(end)>X(1)
        hKymoEval.Data{hKymoEval.CurrentKymo} = [hKymoEval.Data{hKymoEval.CurrentKymo}; length(hKymoEval.Line) D(end) T(end) V X(1)*PixSize/1000 (size(hKymoEval.Kymo{hKymoEval.CurrentKymo},2)-X(end))*PixSize/1000 Y(1) (size(hKymoEval.Kymo{hKymoEval.CurrentKymo},1)-Y(end))];
    else
        hKymoEval.Data{hKymoEval.CurrentKymo} = [hKymoEval.Data{hKymoEval.CurrentKymo}; length(hKymoEval.Line) D(end) T(end) V (size(hKymoEval.Kymo{hKymoEval.CurrentKymo},2)-X(1))*PixSize/1000 X(end)*PixSize/1000 Y(1) (size(hKymoEval.Kymo{hKymoEval.CurrentKymo},1)-Y(end))];
    end
    UpdateMeasure(hKymoEval)
end

function addText(XY,N)
hKymoEval = getappdata(0,'hKymoEval');
mode = get(hKymoEval.bCreate,'String');
if strcmp(mode,'Next')
    zoom = str2double(get(hKymoEval.eZoom,'String'))/100;
else
    zoom = 4;
end
if sign(XY(end,1)-XY(1,1))>0
    text(XY(1,1)-1,XY(1,2),num2str(N),'HorizontalAlignment','Right','Clipping','on','Tag','line','UserData',N,'Color','r','FontSize',4+2*zoom,'UIContextMenu',hKymoEval.mContext);
else
    text(XY(1,1)+1,XY(1,2),num2str(N),'HorizontalAlignment','Left','Clipping','on','Tag','line','UserData',N,'Color','r','FontSize',4+2*zoom,'UIContextMenu',hKymoEval.mContext);
end
    
function [f,c,o]=FitGauss(I,xy,s,ftype,fopts)
sx = max([round(xy(1)-4*s) 1]);
ex = min([round(xy(1)+4*s) size(I,2)]);
line = I(xy(2),sx:ex);
idx = sx:ex;
set(fopts,'StartPoint',[min(line) max(line)-min(line) s round(xy(1))]);
[f,~,o] = fit(idx',line',ftype,fopts);
c=confint(f,0.99);

function UpdateMeasure(hKymoEval)
Data = cell2mat(hKymoEval.Data);
if isempty(Data)
    set(hKymoEval.lResults,'Data',[],'Enable','off');   
    set(hKymoEval.bSave,'Enable','off');
    set(hKymoEval.bExport,'Enable','off');
else
    Data = sortrows(Data,1);
    set(hKymoEval.fig,'Units','pixels');
    ssizetemp = get(hKymoEval.fig,'Position');
    set(hKymoEval.fig,'Units','normalized');
    ssize = ssizetemp(3);
    ssize = ssize * 0.125;
    big = ceil(0.26*ssize);
    small = ssize - 3*big-19;
    set(hKymoEval.lResults,'Data',Data(:,1:4),'Enable','on','ColumnFormat',{'numeric','bank','bank','bank'},'ColumnWidth',{small,big,big,big},'RowName','','ColumnName',{'Idx',['<html><CENTER>Distance<br><CENTER>[' char(181) 'm]'],'<html><CENTER>Time<br><CENTER>[s]',['<html><CENTER>Velocity<br><CENTER>[' char(181) 'm/s]']});
    set(hKymoEval.bSave,'Enable','on');
    set(hKymoEval.bExport,'Enable','on');
end

function Delete(hObj,~)
hKymoEval = getappdata(0,'hKymoEval');
mode = get(hObj,'UserData');
if strcmp(mode,'All')
    mode=fQuestDlg('Delete all traces?','FIESTA - Kymograph Evaluation',{'Yes','No'},'No');
    if strcmp(mode,'No')
        return;
    end
    idx = 1:length(hKymoEval.Line);
    delete(findobj('Tag','line'));
else
    if gco==hKymoEval.lResults
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
hKymoEval.Line(idx)=[];
mode = get(hKymoEval.bCreate,'String');    
if strcmp(mode,'Create')
    if isempty(hKymoEval.Line)
        set(hKymoEval.bCreate,'Enable','off');
    end
else
    if length(idx)==1
        for n=1:length(hKymoEval.Data)
            if ~isempty(hKymoEval.Data{n})
                nKymo = hKymoEval.Data{n}(:,1);
                t = find(nKymo==idx);
                k = find(nKymo>idx);
                hKymoEval.Data{n}(k,1) = hKymoEval.Data{n}(k,1)-1;       
                hKymoEval.Data{n}(t,:)=[];
            end
        end
    else
        for n=1:length(hKymoEval.Data)
            hKymoEval.Data{n} = [];
        end
    end
    UpdateMeasure(hKymoEval)
end
setappdata(0,'hKymoEval',hKymoEval);

function Create(~,~)
hKymoEval = getappdata(0,'hKymoEval');
hMainGui=getappdata(0,'hMainGui');
set(hKymoEval.bCreate,'String','Next','Callback',@Next);
set(hKymoEval.fig,'KeyReleaseFcn',@KeyRelease);
scansize = str2double(get(hKymoEval.eLineWidth,'String'));
if ishandle(hKymoEval.Line{end})
    hKymoEval.Line(end)=[];
end
h=progressdlg('String','Calculating KymoGraphs','Min',0,'Max',length(hKymoEval.Line),'Parent',hKymoEval.fig,'Cancel','on'); 
for n=1:length(hKymoEval.Line)
    [hKymoEval.Kymo{n},hKymoEval.KymoPix(n)] = NewKymo(hKymoEval.Line{n}(:,1),hKymoEval.Line{n}(:,2),scansize);
    if any(any(isnan(hKymoEval.Kymo{n})))
        hKymoEval.Kymo{n}(:,any(isnan(hKymoEval.Kymo{n}))) =[];
    end
    hKymoEval.Used{n} = zeros(size(hKymoEval.Kymo{n}));
    if isempty(h)
        return
    end 
    h=progressdlg(n);
end        
if length(hKymoEval.Kymo)==length(hKymoEval.Line)
    hText = findobj('Tag','line','-and','Type','text');    
    set(hText,'FontSize',6);
    hKymoEval.refImage = GetImage(hKymoEval,600);    
    delete(findobj('Tag','line'));
    set(hKymoEval.rAutomatic,'Enable','on');
    set(hKymoEval.rManuell,'Enable','on');
    hKymoEval.Data = cell(length(hKymoEval.Line),1);
    hKymoEval.Line = [];
    set(hKymoEval.hTools,'SelectedObject',hKymoEval.bSingle);
    maxImage = getappdata(hMainGui.fig,'MaxImage');
    maxImage = maxImage(:,:,1);
    mContrast = round(mean2(maxImage)+3*std2(maxImage));  
    PixMin = min(min(maxImage));
    PixMax = max(max(maxImage));
    slider_step(1) = 1/double(PixMax-PixMin);
    slider_step(2) = 100/double(PixMax-PixMin);
    if (max(slider_step)>=1)||(min(slider_step)<=0)
        slider_step=[0.1 0.1];
    end
    set(hKymoEval.sContrast,'sliderstep',slider_step,'Min',PixMin,'Max',PixMax,'Value',mContrast);
    setappdata(0,'hKymoEval',hKymoEval);
    Next([],[]);
end

function [KymoGraph,KymoPix] = NewKymo(nX,nY,ScanSize)
global Stack;
d=[0; cumsum(sqrt((nX(2:end)-nX(1:end-1)).^2 + (nY(2:end)-nY(1:end-1)).^2))];
dt=max(d)/round(max(d));
id=(0:round(max(d)))'*dt;
scan_length=length(id);
idx = nearestpoint(id,d);
X=zeros(scan_length,1);
Y=zeros(scan_length,1);
dis = id-d(idx);
dis(1)=0;
dis(end)=0;
X(dis==0) = nX(idx(dis==0));
Y(dis==0) = nY(idx(dis==0));
X(dis>0) = nX(idx(dis>0))+(nX(idx(dis>0)+1)-nX(idx(dis>0)))./(d(idx(dis>0)+1)-d(idx(dis>0))).*dis(dis>0);
Y(dis>0) = nY(idx(dis>0))+(nY(idx(dis>0)+1)-nY(idx(dis>0)))./(d(idx(dis>0)+1)-d(idx(dis>0))).*dis(dis>0);
X(dis<0) = nX(idx(dis<0))+(nX(idx(dis<0)-1)-nX(idx(dis<0)))./(d(idx(dis<0)-1)-d(idx(dis<0))).*dis(dis<0);
Y(dis<0) = nY(idx(dis<0))+(nY(idx(dis<0)-1)-nY(idx(dis<0)))./(d(idx(dis<0)-1)-d(idx(dis<0))).*dis(dis<0);
iX=zeros(2*ScanSize+1,scan_length);
iY=zeros(2*ScanSize+1,scan_length);
n=zeros(scan_length,3);
for i=1:length(X)
    if i==1   
        v=[X(i+1)-X(i) Y(i+1)-Y(i) 0];
        n(i,:)=[v(2) -v(1) 0]/norm(v); 
    elseif i==length(X)
        v=[X(i)-X(i-1) Y(i)-Y(i-1) 0];
        n(i,:)=[v(2) -v(1) 0]/norm(v);
    else
        v1=[X(i+1)-X(i) Y(i+1)-Y(i) 0];
        v2=-[X(i)-X(i-1) Y(i)-Y(i-1) 0];
        n(i,:)=v1/norm(v1)+v2/norm(v2); 
        if norm(n(i,:))==0
            n(i,:)=[v1(2) -v1(1) 0]/norm(v1);
        else
            n(i,:)=n(i,:)/norm(n(i,:));
        end
        z=cross(v1,n(i,:));
        if z(3)>0
            n(i,:)=-n(i,:);
        end
    end
    iX(:,i)=linspace(X(i)+ScanSize*n(i,1),X(i)-ScanSize*n(i,1),2*ScanSize+1)';
    iY(:,i)=linspace(Y(i)+ScanSize*n(i,2),Y(i)-ScanSize*n(i,2),2*ScanSize+1)';
end
d = sqrt((X(2:end)-X(1:end-1)).^2 + (Y(2:end)-Y(1:end-1)).^2);
KymoPix = mean(d);
KymoGraph = zeros(size(Stack{1},3),scan_length);           
for i = 1:size(Stack{1},3)
    Z = interp2(double(Stack{1}(:,:,i)),iX,iY);
    KymoGraph(i,:)=max(Z,[],1);
end

function Next(~,~)
hKymoEval = getappdata(0,'hKymoEval');
set(hKymoEval.aImage,'Units','Pixels');
xy = get(hKymoEval.aImage,'Position');
set(hKymoEval.aImage,'Units','Normalized');
zoom = str2double(get(hKymoEval.eZoom,'String'))/100;
c=0;
while c<100
   n = ceil(rand*length(hKymoEval.Kymo));
   total_x = size(hKymoEval.Kymo{n},2);
   total_y = size(hKymoEval.Kymo{n},1);
   dy = fix(total_y/zoom/2)-1;
   dx = fix(dy*xy(3)/xy(4));
   x = dx+ceil(rand*(total_x-2*dx));
   y = dy+ceil(rand*(total_y-2*dy));
   sx = max([x-dx 1]);
   ex = min([x+dx total_x]);
   Used = hKymoEval.Used{n}(y-dy:y+dy,sx:ex);
   if sum(sum(Used))<0.5*numel(Used)
       c = 100;
       hKymoEval.Used{n}(y-dy:y+dy,sx:ex) = ones(size(hKymoEval.Used{n}(y-dy:y+dy,sx:ex)));
   else
       c = c+1;
   end   
end
Kymo = uint16(hKymoEval.Kymo{n});
mContrast = round(get(hKymoEval.sContrast,'Value'));
Image = imadjust(Kymo,[double(min(min(Kymo)))/2^16 max([double(min(min(Kymo))+1)/2^16 double(mContrast)/2^16])],[]);
set(hKymoEval.hImage,'CData',Image);
set(hKymoEval.aImage,'XLim',[sx-5 ex+5],'YLim',[y-dy-10 y+dy+10]);
delete(findobj('Tag','border'));
line(hKymoEval.aImage,[0.5 total_x+0.5 total_x+0.5 0.5 0.5],[0.5 0.5 total_y+0.5 total_y+0.5 0.5],'Color','red','LineWidth',2,'Tag','border','Parent',hKymoEval.aImage);
hLine = findobj('Tag','line');
nLine = cell2mat(get(hLine,'UserData'));
if isempty(hKymoEval.Data{n})
    set(hLine,'Visible','off');
else
    idx = ismember(nLine,hKymoEval.Data{n}(:,1));
    set(hLine(idx),'Visible','on');
    set(hLine(~idx),'Visible','off');
    hText = findobj('Tag','line','-and','Type','text');
    set(hText,'FontSize',4+2*zoom);
end
hKymoEval.CurrentKymo = n;
setappdata(0,'hKymoEval',hKymoEval);
warning off MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame
javaFrame = get(hKymoEval.fig,'JavaFrame');
javaFrame.getAxisComponent.requestFocus;

function Save(~,~)
hKymoEval = getappdata(0,'hKymoEval');
Data = sortrows(cell2mat(hKymoEval.Data),1);
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
    fprintf(f,'Index\tDistance[?m]\tTime[s]\tVelocity[?m/s]\n');
    fprintf(f,'%f\t%f\t%f\t%f\n',Data(:,1:4)');
    fclose(f);
end

function Export(~,~)
global Config;
hKymoEval = getappdata(0,'hKymoEval');
PathName = uigetdir(fShared('GetSaveDir'));
file = Config.StackName{1}(1:end-4);
format = fQuestDlg({'FIESTA will now export the reference image,','the kymographs and the data to the specified folder!','(The measurement index will be reordered consecutively)','','Which format do you want to use?'},'FIESTA - Kymograph Evaluation',{'TIFF','JPEG','PNG'},'TIFF');
if strcmp(format,'TIFF')
    f = [PathName filesep file ' - Reference.tif'];
    imwrite(hKymoEval.refImage,f,'Compression','none');
elseif strcmp(format,'JPEG') 
    f = [PathName filesep file ' - Reference.jpg'];
    imwrite(hKymoEval.refImage,f,'Quality',100);
else
    f = [PathName filesep file ' - Reference.png'];
    imwrite(hKymoEval.refImage,f);
end
mContrast = round(get(hKymoEval.sContrast,'Value'));
hLine = findobj('Tag','line');
set(hLine,'Visible','off');
nLine = cell2mat(get(hLine,'UserData'));
hText = findobj('Tag','line','-and','Type','text');    
set(hText,'FontSize',2);
delete(findobj('Tag','border'));
for n=1:length(hKymoEval.Data)
    Kymo = uint16(hKymoEval.Kymo{n});
    Image = imadjust(Kymo,[double(min(min(Kymo)))/2^16 double(mContrast)/2^16],[]);
    set(hKymoEval.hImage,'CData',Image);
    if ~isempty(hKymoEval.Data{n})
        idx = ismember(nLine,hKymoEval.Data{n}(:,1));
        set(hLine(idx),'Visible','on','LineWidth',0.2);
    end
    I = GetImage(hKymoEval,900);
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
Data = sortrows(cell2mat(hKymoEval.Data),1);
Data(:,1) = 1:size(Data,1);
f = [PathName filesep file ' - Data.mat'];
save(f,'Data');
f = [PathName filesep file ' - Data.txt'];
fid = fopen(f,'w');
fprintf(fid,'Index\tDistance[?m]\tTime[s]\tVelocity[?m/s]\n');
fprintf(fid,'%f\t%f\t%f\t%f\n',Data(:,1:4)');
fclose(fid);
Close([],[]);

function I = GetImage(hKymoEval,dpi)
CData = get(hKymoEval.hImage,'CData');
hFig = figure('Visible','off','Units','pixels','Position',[0 0 size(CData,2) size(CData,1)]);
hAxes = copyobj(hKymoEval.aImage,hFig);
set(hAxes,'Units','normalized','Position',[0 0 1 1],{'XLim','YLim'},{[0.5 size(CData,2)+0.5],[0.5 size(CData,1)+0.5]});
set(hFig,'colormap',get(hKymoEval.fig,'colormap'));
I = print(hFig, '-RGBImage', ['-r' num2str(dpi)]);
c = get(hFig,'Color');
k = mean(I(:,:,1))==c(1)*255&mean(I(:,:,2))==c(2)*255&mean(I(:,:,3))==c(3)*255;
I(:,k,:)=[];
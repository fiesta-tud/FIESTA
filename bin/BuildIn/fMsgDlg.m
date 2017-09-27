function fMsgDlg(prompt,mode)
%%%%%%%%%%%%%%%%%%%%%
%%% Set Positions %%%
%%%%%%%%%%%%%%%%%%%%%
DefFigPos=get(0,'DefaultFigurePosition');
MsgOff=7;
IconWidth=38;
FigWidth=190;
MsgTxtWidth=FigWidth-2*MsgOff-IconWidth;
FigHeight=50;
DefFigPos(3:4)=[FigWidth FigHeight];
OKWidth=40;
OKHeight=17;
OKXOffset=(FigWidth-OKWidth)/2;
OKYOffset=MsgOff;
MsgTxtXOffset=MsgOff;
MsgTxtYOffset=MsgOff+OKYOffset+OKHeight;
MsgTxtHeight=FigHeight-MsgOff-MsgTxtYOffset;
IconHeight=38;
IconXOffset=MsgTxtXOffset;

hFig = dialog('Name','','Pointer','arrow','Units','points','Visible','off','KeyPressFcn',@doKeyPress, ...
              'WindowStyle','modal','Toolbar','none','HandleVisibility','on','Tag','hMsgDlg');
          
if ispc
    set(hFig,'Color',[236 233 216]/255);
end
    
c = get(hFig,'Color');

a = load('dialogicons.mat');
if strcmp(mode,'error')
    title = 'FIESTA Error';
    IconData=a.errorIconData;
    a.errorIconMap(146,:)=c;
    IconCMap=a.errorIconMap;
elseif strcmp(mode,'warn') || strcmp(mode,'warning')
    title = 'FIESTA Warning';
    IconData=a.warnIconData;
    a.warnIconMap(256,:)=c;
    IconCMap=a.warnIconMap;
else
    title = 'FIESTA';
    IconData=[];
    IconCMap=[];
end


okPos = [ OKXOffset OKYOffset OKWidth OKHeight ];
OKHandle=uicontrol('Parent',hFig,'Style','pushbutton','Units','points','Position',okPos,'CallBack','uiresume(gcbf)', ...
                  'KeyPressFcn',@doKeyPress,'String','OK','HorizontalAlignment','center','Tag','OKButton');     

msgPos = [ MsgTxtXOffset MsgTxtYOffset MsgTxtWidth MsgTxtHeight ];
MsgHandle=uicontrol('Parent',hFig,'Style','text','Units','points','Position',msgPos,'String',' ','HorizontalAlignment','left','BackgroundColor',c);

if ~iscell(prompt)
    prompt = {prompt};
end

[WrapString,NewMsgTxtPos]=textwrap(MsgHandle,prompt,75);

set(MsgHandle,'String',WrapString);

textExtent = get(MsgHandle, 'extent');

MsgTxtWidth=max([MsgTxtWidth NewMsgTxtPos(3) textExtent(3)]);
MsgTxtHeight=max([MsgTxtHeight NewMsgTxtPos(4) textExtent(4)]);

MsgTxtXOffset=IconXOffset+IconWidth+MsgOff;
FigWidth=MsgTxtXOffset+MsgTxtWidth+MsgOff;
% Center Vertically around icon
if IconHeight>MsgTxtHeight
    IconYOffset=OKYOffset+OKHeight+MsgOff;
    MsgTxtYOffset=IconYOffset+(IconHeight-MsgTxtHeight)/2;
    FigHeight=IconYOffset+IconHeight+MsgOff;
    % center around text
else
    MsgTxtYOffset=OKYOffset+OKHeight+MsgOff;
    IconYOffset=MsgTxtYOffset+(MsgTxtHeight-IconHeight)/2;
    FigHeight=MsgTxtYOffset+MsgTxtHeight+MsgOff;
end

OKXOffset=(FigWidth-OKWidth)/2;
DefFigPos(3:4)=[FigWidth FigHeight];

set(hFig,'Position',DefFigPos,'Name',title);

set(MsgHandle,'Position',[MsgTxtXOffset MsgTxtYOffset MsgTxtWidth MsgTxtHeight]);
set(OKHandle,'Position',[OKXOffset OKYOffset OKWidth OKHeight]);

iconPos = [IconXOffset IconYOffset IconWidth IconHeight];

IconAxes=axes('Parent',hFig,'Units','points','Position',iconPos);

try
    Img=image('CData',IconData,'Parent',IconAxes);
    set(hFig, 'Colormap', IconCMap);
catch ex
    delete(hhFig);
    rethrow(ex);
end
if ~isempty(get(Img,'XData')) && ~isempty(get(Img,'YData'))
    set(IconAxes,'XLim',get(Img,'XData')+[-0.5 0.5],'YLim',get(Img,'YData')+[-0.5 0.5]);
end

set(IconAxes,'Visible','off','YDir','reverse');

if ~isempty(findobj('Tag','hMainGui'))
    fPlaceFig(hFig,'reposition');
else
    set(hFig,'Visible','on');
end

uiwait(hFig);
delete(hFig);
drawnow

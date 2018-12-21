function fBleachEvaluate(func,varargin)
if nargin<1
    Create;
else
    switch (func)
        case 'Update'
            Update(varargin{1});
        case 'Skip'
            Skip;
        case 'Next'
            Next;
        case 'SaveData'
            SaveData;
            
    end 
end

function Create
cObj = fMenuStatistics('CountObjects',0);
Objects = cObj{1};
if ~isempty(Objects)
    hBleachEvaluate.fig = figure('Units','normalized','DockControls','off','IntegerHandle','off','Name','FIESTA Bleaching Evaluation',...
                  'NumberTitle','off','Position',[0.05 0.05 0.9 0.9],'HandleVisibility','callback','Tag','hBleachEvaluate',...
                  'Visible','on','Resize','off','WindowStyle','normal');
    fPlaceFig(hBleachEvaluate.fig,'full');
    hBleachEvaluate.aPlot = axes('Parent',hBleachEvaluate.fig,'Position',[0.05 0.25 0.9 0.7],'Tag','Plot');
    
    hBleachEvaluate.aVerify = axes('Parent',hBleachEvaluate.fig,'Position',[0.05 0.05 0.65 0.17],'Tag','Plot');
                             
    hBleachEvaluate.bNext = uicontrol('Parent',hBleachEvaluate.fig,'Units','normalized','FontSize',12,'HorizontalAlignment','center','Callback','fBleachEvaluate(''Next'');',...
                               'Position',[0.75 0.15 0.2 0.04],'String','Next Molecule [n]','Style','pushbutton','Tag','bNext');  
                           
    hBleachEvaluate.bSkip = uicontrol('Parent',hBleachEvaluate.fig,'Units','normalized','FontSize',12,'HorizontalAlignment','center','Callback','fBleachEvaluate(''Skip'');',...
                               'Position',[0.75 0.10 0.2 0.04],'String','Skip Molecule [s]','Style','pushbutton','Tag','bSkip');
                           
    hBleachEvaluate.bSave = uicontrol('Parent',hBleachEvaluate.fig,'Units','normalized','FontSize',12,'HorizontalAlignment','center','Callback','fBleachEvaluate(''SaveData'');',...
                               'Position',[0.75 0.05 0.2 0.04],'String','Save Data','Style','pushbutton','Tag','bSave');
                         
                           
    hBleachEvaluate.BoxSize = str2double(fInputDlg('Box size for integration in pixel (3,5):','3'));                         
    set(hBleachEvaluate.fig, 'WindowButtonMotionFcn', @UpdateCursor);
    set(hBleachEvaluate.fig, 'WindowButtonUpFcn',@ButtonUp);
    set(hBleachEvaluate.fig, 'WindowScrollWheelFcn',@Scroll);  
    set(hBleachEvaluate.fig, 'KeyPressFcn',@KeyPress);
    
    hBleachEvaluate.BleachTime = [];
    hBleachEvaluate.Objects = Objects;
    hBleachEvaluate.Zoom = 0;
    setappdata(0,'hBleachEvaluate',hBleachEvaluate);    
    Update(hBleachEvaluate);
end

function KeyPress(~,h)
if h.Key=='n'
    fBleachEvaluate('Next');
end
if h.Key=='s'
    fBleachEvaluate('Skip');
end

function Scroll(~,eventdata)
global TimeInfo;
hBleachEvaluate=getappdata(0,'hBleachEvaluate');
hBleachEvaluate.Zoom  = max([0 hBleachEvaluate.Zoom-eventdata.VerticalScrollCount]);
xy=get(hBleachEvaluate.aPlot,{'xlim','ylim'});
xy{1}(2) = max([(TimeInfo{1}(end)-TimeInfo{1}(1))/1000-hBleachEvaluate.Zoom*(TimeInfo{1}(end)-TimeInfo{1}(1))/50000 1]);
if xy{1}(2) == 1
    hBleachEvaluate.Zoom = 50;
end
set(hBleachEvaluate.aPlot,{'xlim','ylim'},xy);
m = find((TimeInfo{1}-TimeInfo{1}(1))/1000<xy{1}(2),1,'last');
xy{1}(2) = m;
set(hBleachEvaluate.aVerify,'xlim',xy{1});
setappdata(0,'hBleachEvaluate',hBleachEvaluate);  

function Skip
hBleachEvaluate=getappdata(0,'hBleachEvaluate');
hBleachEvaluate.BleachTime(end+1,1) = -1;
hBleachEvaluate.BleachTime(end,2) = -1;
hBleachEvaluate.BleachTime(end,3) = 0;    
X= round(hBleachEvaluate.Objects(hBleachEvaluate.idx,1));
Y= round(hBleachEvaluate.Objects(hBleachEvaluate.idx,2));
dx = (hBleachEvaluate.BoxSize-1)/2;
in = inpolygon(hBleachEvaluate.Objects(:,1),hBleachEvaluate.Objects(:,2),[X-dx-0.5 X-dx-0.5 X+dx+0.5 X+dx+0.5],[Y-dx-0.5 Y+dx+0.5 Y+dx+0.5 Y-dx-0.5]);
hBleachEvaluate.Objects(in,:) = [];
setappdata(0,'hBleachEvaluate',hBleachEvaluate);  
Update(hBleachEvaluate);

function Next
hBleachEvaluate=getappdata(0,'hBleachEvaluate');
if ~isempty(hBleachEvaluate.Current)
    hBleachEvaluate.BleachTime(end+1,1) = hBleachEvaluate.Current(1);
    if length(hBleachEvaluate.Current)==1
        hBleachEvaluate.BleachTime(end,2) = -1;
        hBleachEvaluate.BleachTime(end,3) = 1;    
    else
        hBleachEvaluate.BleachTime(end,2) = hBleachEvaluate.Current(2);
        hBleachEvaluate.BleachTime(end,3) = 2;      
    end
    X= round(hBleachEvaluate.Objects(hBleachEvaluate.idx,1));
    Y= round(hBleachEvaluate.Objects(hBleachEvaluate.idx,2));
    dx = (hBleachEvaluate.BoxSize-1)/2;
    in = inpolygon(hBleachEvaluate.Objects(:,1),hBleachEvaluate.Objects(:,2),[X-dx-0.5 X-dx-0.5 X+dx+0.5 X+dx+0.5],[Y-dx-0.5 Y+dx+0.5 Y+dx+0.5 Y-dx-0.5]);
    hBleachEvaluate.Objects(in,:) = [];
    setappdata(0,'hBleachEvaluate',hBleachEvaluate);  
    Update(hBleachEvaluate);
end

function Update(hBleachEvaluate)
global Stack;
global TimeInfo;
found = 0;
while ~found
    idx = ceil(rand*size(hBleachEvaluate.Objects,1));
    if idx==0
        SaveData;
        close(hBleachEvaluate.fig);
        return;
    end
    if hBleachEvaluate.Objects(idx,3)>hBleachEvaluate.BoxSize
        hBleachEvaluate.Objects(idx,:)=[];
    else
        found = 1;
    end
end
X= round(hBleachEvaluate.Objects(idx,1));
Y= round(hBleachEvaluate.Objects(idx,2));
dx = (hBleachEvaluate.BoxSize-1)/2;
if X<1+dx || Y<1+dx || X>size(Stack{1},2)-dx || Y>size(Stack{1},1)-dx
    hBleachEvaluate.Objects(idx,:) = [];
    setappdata(0,'hBleachEvaluate',hBleachEvaluate);  
    Update(hBleachEvaluate);
    return;
end
I = zeros(1,size(Stack{1},3));
kymo = [];
for n=1:length(I)
    pic = double(Stack{1}(Y-dx:Y+dx,X-dx:X+dx,n)); 
    I(n) = sum(sum(pic));
    try
        kymo(:,n) = round(mean(Stack{1}(Y-3:Y+3,X-3:X+3,n),2));
    catch
        kymo(:,n) = round(mean(pic,2));
    end
end
plot(hBleachEvaluate.aPlot,(TimeInfo{1}-TimeInfo{1}(1))/1000,I,'-*b','Tag','hBleachEvaluateCurve');
set(hBleachEvaluate.aPlot,'XLim',[0 (TimeInfo{1}(end)-TimeInfo{1}(1))/1000]);
legend(['X=' num2str(X) ', Y=' num2str(Y)],'AutoUpdate','off');
imshow(kymo,[min(min(kymo)) max(max(kymo))],'Parent',hBleachEvaluate.aVerify);
hBleachEvaluate.idx = idx;
hBleachEvaluate.Current = [];
hBleachEvaluate.Zoom = 0;
setappdata(0,'hBleachEvaluate',hBleachEvaluate);  

function UpdateCursor(~,~) 
hBleachEvaluate=getappdata(0,'hBleachEvaluate');
xy=get(hBleachEvaluate.aPlot,{'xlim','ylim'});
cp=get(hBleachEvaluate.aPlot,'currentpoint');
cp=cp(1,[1 2]);
delete(findobj('Tag','CurrentLine'));
if all(cp>=[xy{1}(1) xy{2}(1)]) && all(cp<=[xy{1}(2) xy{2}(2)])
    line(hBleachEvaluate.aPlot,[cp(1) cp(1)],xy{2},'Color','k','LineStyle','--','Tag','CurrentLine');
end    
setappdata(0,'hBleachEvaluate',hBleachEvaluate);                
       
function ButtonUp(~,~)
hBleachEvaluate=getappdata(0,'hBleachEvaluate');
xy=get(hBleachEvaluate.aPlot,{'xlim','ylim'});
cp=get(hBleachEvaluate.aPlot,'currentpoint');
cp=cp(1,[1 2]);
if strcmp(get(hBleachEvaluate.fig,'SelectionType'),'normal')
    hBleachEvaluate.Current(end+1) = cp(1);
    line(hBleachEvaluate.aPlot,[cp(1) cp(1)],xy{2},'Color','r','LineStyle','-','Tag','Selected');
    setappdata(0,'hBleachEvaluate',hBleachEvaluate);      
end
    
function SaveData
hBleachEvaluate=getappdata(0,'hBleachEvaluate');
[file,path] = uiputfile('*.mat','Save');
if ~isempty(path)
    BleachingTime = hBleachEvaluate.BleachTime; %#ok<NASGU>
    save([path file],'BleachingTime');
end

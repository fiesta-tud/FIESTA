function fMenuContext(func,varargin)
switch func
    case 'DeleteRegion'
        DeleteRegion(varargin{1});        
    case 'DeleteMeasure'
        DeleteMeasure(varargin{1});  
    case 'TransferTrackInfo'
        TransferTrackInfo(varargin{1});  
    case 'OpenTrack'
        OpenTrack(varargin{1});  
    case 'MarkTrack'
        MarkTrack(varargin{1});        
    case 'MarkSelection'
        MarkSelection;     
    case 'SelectTrack'
        SelectTrack(varargin{1});     
    case 'SelectList'
        SelectList(varargin{1});             
    case 'VisibleList'
        VisibleList(varargin{1});                     
    case 'SetCurrentTrack'
        SetCurrentTrack(varargin{1},varargin{2});                     
    case 'AddTo'
        AddTo(varargin{1});
    case 'DeleteObject'
        DeleteObject(varargin{1});        
    case 'DeleteQueue'
        DeleteQueue;           
    case 'DeleteOffset'
        DeleteOffset(varargin{1});           
    case 'DeleteOffsetMatch'
        DeleteOffsetMatch(varargin{1});    
    case 'EstimateFWHM'
        EstimateFWHM(varargin{1});    
end     

function SelectList(hMainGui)
global Molecule;
global Filament;
global KymoTrackMol;
global KymoTrackFil;
Mode=get(gcbo,'UserData');
for n=1:length(Molecule)
    if Molecule(n).Selected==0||Molecule(n).Selected==1
        v=[];
        if strcmp(Mode,'All')||strcmp(Mode,'Molecule')
            v=1;
        elseif strcmp(Mode,'Filament')
            v=0;
        end
        Molecule(n)=fShared('SelectOne',Molecule(n),KymoTrackMol,n,v);
    end
end
for n=1:length(Filament)
    if Filament(n).Selected==0||Filament(n).Selected==1
        v=[];
        if strcmp(Mode,'All')||strcmp(Mode,'Filament')
            v=1;
        elseif strcmp(Mode,'Molecule')
            v=0;
        end
        Filament(n)=fShared('SelectOne',Filament(n),KymoTrackFil,n,v);
    end
end
fRightPanel('UpdateList',hMainGui.RightPanel.pData.MolList,Molecule,hMainGui.RightPanel.pData.sMolList,hMainGui.Menu.ctListMol);
fRightPanel('UpdateList',hMainGui.RightPanel.pData.FilList,Filament,hMainGui.RightPanel.pData.sFilList,hMainGui.Menu.ctListFil);
fShow('Image');
Selected = [Molecule.Selected];
hPlot = [Molecule.PlotHandles];
uistack(hPlot(Selected==1),'top');
Selected = [Filament.Selected];
hPlot = [Filament.PlotHandles];
uistack(hPlot(Selected==1),'top');

function VisibleList(hMainGui)
global Molecule;
global Filament;
global KymoTrackMol;
global KymoTrackFil;
Mode=get(gcbo,'UserData');
for n=1:length(Molecule)
    if Molecule(n).Selected>-1
        if strcmp(Mode,'All')
            Molecule=fShared('VisibleOne',Molecule,KymoTrackMol,hMainGui.RightPanel.pData.MolList,n,1,hMainGui.RightPanel.pData.sMolList);
        else
            if Molecule(n).Selected==1
                Molecule=fShared('VisibleOne',Molecule,KymoTrackMol,hMainGui.RightPanel.pData.MolList,n,[],hMainGui.RightPanel.pData.sMolList);            
            end
        end
    end
end
for n=1:length(Filament)
    if Filament(n).Selected>-1
        if strcmp(Mode,'All')
            Filament=fShared('VisibleOne',Filament,KymoTrackFil,hMainGui.RightPanel.pData.FilList,n,1,hMainGui.RightPanel.pData.sFilList);
        else
            if Filament(n).Selected==1
                Filament=fShared('VisibleOne',Filament,KymoTrackFil,hMainGui.RightPanel.pData.FilList,n,[],hMainGui.RightPanel.pData.sFilList);
            end
        end
    end
end
fRightPanel('UpdateList',hMainGui.RightPanel.pData.MolList,Molecule,hMainGui.RightPanel.pData.sMolList,hMainGui.Menu.ctListMol);
fRightPanel('UpdateList',hMainGui.RightPanel.pData.FilList,Filament,hMainGui.RightPanel.pData.sFilList,hMainGui.Menu.ctListFil);
fShow('Image');
Selected = [Molecule.Selected];
hPlot = [Molecule.PlotHandles];
uistack(hPlot(Selected==1),'top');
Selected = [Filament.Selected];
hPlot = [Filament.PlotHandles];
uistack(hPlot(Selected==1),'top');

function DeleteQueue
global Queue;
Mode=get(gcbo,'UserData');
if ~isempty(Queue)
    if strcmp(Mode,'All')==1
        Queue=[];
    else
        Selected=[Queue.Selected];
        Queue(Selected==1)=[];
    end
    fRightPanel('UpdateQueue','Local');
end

function [Object,OtherObject]=CurrentTrack(Object,OtherObject,n)
Selected=[Object.Selected];
k=find(Selected==2,1);
if ~isempty(k)
    Object(k).Selected=0;
    if k~=n
        Object(n).Selected=2; 
    end
else
    Object(n).Selected=2;
end
Selected=[OtherObject.Selected];
k=find(Selected==2,1);
if ~isempty(k)
    OtherObject(k).Selected=0;
end

function SetCurrentTrack(hMainGui,Mode)
global Molecule;
global Filament;
TrackInfo=get(hMainGui.Menu.ctTrack(1).menu,'UserData');
n=[];
if strcmp(Mode,'Set')
    if isempty(TrackInfo)
        TrackInfo=get(gco,'UserData');
        set(gco,'UserData',[]);
    end
    if ~isempty(TrackInfo)
        n=TrackInfo.List(1);
        Mode=TrackInfo.Mode;
    end
else
    n=find([Molecule.Selected]==2,1);
    Mode='Molecule';
    if isempty(n)
        n=find([Filament.Selected]==2,1);        
        Mode='Filament';
    end
end
if ~isempty(n)
    if strcmp(Mode,'Molecule')
        [Molecule,Filament]=CurrentTrack(Molecule,Filament,n);
    else
        [Filament,Molecule]=CurrentTrack(Filament,Molecule,n);
    end
    fRightPanel('UpdateList',hMainGui.RightPanel.pData.FilList,Filament,hMainGui.RightPanel.pData.sFilList,hMainGui.Menu.ctListFil);
    fRightPanel('UpdateList',hMainGui.RightPanel.pData.MolList,Molecule,hMainGui.RightPanel.pData.sMolList,hMainGui.Menu.ctListMol);
end


function TransferTrackInfo(hMainGui)
global TrackInfo;
set(hMainGui.Menu.ctTrack(1).menu,'UserData',TrackInfo);

function OpenTrack(hMainGui)
TrackInfo=get(hMainGui.Menu.ctTrack(1).menu,'UserData');
if ~isempty(TrackInfo)
    n=TrackInfo.List(1);
    fMainGui('OpenObject',hMainGui,TrackInfo.Mode,n)
end

function Object=SetColor(Object,KymoObject,color,n)
Object(n).Color=color;
set(Object(n).PlotHandles(1),'Color',color);
k=find([KymoObject.Index]==n);
if ~isempty(k)
    set(KymoObject(k).PlotHandles(1),'Color',color);            
end

function MarkTrack(hMainGui)
global Molecule;
global Filament;
global KymoTrackMol;
global KymoTrackFil;
TrackInfo=get(hMainGui.Menu.ctTrack(1).menu,'UserData');
if ~isempty(TrackInfo)
    n=TrackInfo.List(1);
    color=get(gcbo,'UserData');
    if strcmp(TrackInfo.Mode,'Molecule')
        Molecule=SetColor(Molecule,KymoTrackMol,color,n);
    else
        Filament=SetColor(Filament,KymoTrackFil,color,n);
    end
end
fShow('Image');
drawnow

function MarkSelection
global Molecule;
global Filament;
global KymoTrackMol;
global KymoTrackFil;
MolSelect = find([Molecule.Selected]==1);
FilSelect = find([Filament.Selected]==1);
color=get(gcbo,'UserData');
for n=MolSelect
    Molecule=SetColor(Molecule,KymoTrackMol,color,n);
end
for n=FilSelect
    Filament=SetColor(Filament,KymoTrackFil,color,n);
end
fShow('Image');
drawnow

function SelectTrack(hMainGui)
TrackInfo=get(hMainGui.Menu.ctTrack(1).menu,'UserData');
if ~isempty(TrackInfo)
    n=TrackInfo.List(1);
    fMainGui('SelectObject',hMainGui,TrackInfo.Mode,n,get(gcbo,'UserData'));
end

function DeleteRegion(hMainGui)
if strcmp(get(gcbo,'UserData'),'one')==1
    sRegion=get(gco,'UserData');
    nRegion=sRegion;
else
    sRegion=1;
    nRegion=length(hMainGui.Region);
end
for i=nRegion:-1:sRegion
    hMainGui.Region(i)=[];
    try
        delete(hMainGui.Plots.Region(i));
        hMainGui.Plots.Region(i)=[];
    catch
    end
end
for i=sRegion:length(hMainGui.Region)
    set(hMainGui.Plots.Region(i),'Color',hMainGui.Region(i).color,'Linestyle','--','UserData',i,'UIContextMenu',hMainGui.Menu.ctRegion);
end
setappdata(0,'hMainGui',hMainGui);
fLeftPanel('RegUpdateList',hMainGui);

function EstimateFWHM(hMainGui)
global Config;
hPlot = findobj('Tag','plotLineScan');
D=get(hPlot,'XData')';
I=get(hPlot,'YData')';
lb = [0 0 0 0];
ub = [max(I) 3*(max(I)-mean(I)) Inf max(D)];
params0 = [mean(I) max(I)-mean(I) 0.5 D(I==max(I))];
s = fitoptions('Method','NonlinearLeastSquares','Lower',lb,'Upper',ub,'Startpoint',params0);
f = fittype('b+h*exp(-0.5*(x-x0)^2/s^2)','options',s);
g = fit(D,I,f);
FWHM = round(g.s*2*sqrt(2*log(2))*1000);
button =  fQuestDlg({'Results of the FWHM Estimation:','Function I=b+exp(-0.5*(x-x0)^2/s^2)',['b=' num2str(round(g.b)) ', h=' num2str(round(g.h)) ', x0=' num2str(round(g.x0*100)/100) ', s=' num2str(round(g.s*100)/100)],['Results in a FWHM of ' num2str(FWHM) 'nm']},'FWHM Estimate',{'Apply to configuration','Cancel'},'Apply to configuration');       
if strcmp(button,'Apply to configuration')
    Config.Threshold.FWHM = FWHM;
end

function DeleteMeasure(hMainGui)
fToolBar('Cursor',hMainGui);
hMainGui=getappdata(0,'hMainGui');
if strcmp(get(gcbo,'UserData'),'one')==1
    sMeasure=get(gco,'UserData');
    if sMeasure>0
        nMeasure=sMeasure;
        set(hMainGui.RightPanel.pTools.lMeasureTable,'Value',sMeasure,'UserData',sMeasure-1)
    else
        nMeasure=length(hMainGui.Measure);
        sMeasure=length(hMainGui.Measure)+1;
    end
else
    sMeasure=1;
    nMeasure=length(hMainGui.Measure);
end
for i=nMeasure:-1:sMeasure
    hMainGui.Measure(i)=[];
    delete(hMainGui.Plots.Measure(i));
    hMainGui.Plots.Measure(i)=[];
end
setappdata(0,'hMainGui',hMainGui);
fRightPanel('UpdateMeasure',hMainGui);

function DeleteObject(hMainGui)
global Objects;
data=get(gco,'UserData');
nCh = data(1);
n = data(2);
Obj = Objects{hMainGui.Values.FrameIdx(nCh+1)};
Obj.center_x(n)=[];
Obj.center_y(n)=[];
Obj.com_x(:,n)=[];
Obj.com_y(:,n)=[];
Obj.orientation(:,n)=[];
Obj.length(:,n)=[];
Obj.width(:,n)=[];
Obj.height(:,n)=[];
Obj.background(:,n)=[];
Obj.data(n)=[];
Objects{hMainGui.Values.FrameIdx(nCh+1)} = Obj;
fShow('Marker',hMainGui,hMainGui.Values.FrameIdx);  

function DeleteOffset(hMainGui)
OffsetMap = getappdata(hMainGui.fig,'OffsetMap');
n=get(gco,'UserData');
if isreal(n)
    if ~isempty(OffsetMap.Match)
        k = ismember(OffsetMap.Match(:,1:2),OffsetMap.RedXY(n,:));
        if max(k(:,1))==1
            OffsetMap.Match(k(:,1),:)=[];
        end
    end
    OffsetMap.RedXY(n,:)=[];
else
    n=imag(n);
    if ~isempty(OffsetMap.Match)
        k = ismember(OffsetMap.Match(:,3:4),OffsetMap.GreenXY(n,:));
        if max(k(:,1))==1
            OffsetMap.Match(k(:,1),:)=[];
        end
    end
    OffsetMap.GreenXY(n,:)=[];  
end
setappdata(hMainGui.fig,'OffsetMap',OffsetMap);
if strcmp(get(hMainGui.Menu.mShowOffsetMap,'Checked'),'on')
    fShow('OffsetMap',hMainGui);    
end
fShared('UpdateMenu',hMainGui);

function DeleteOffsetMatch(hMainGui)
OffsetMap = getappdata(hMainGui.fig,'OffsetMap');
n=get(gco,'UserData');
if ~isempty(OffsetMap.RedXY) && ~isempty(OffsetMap.GreenXY) && ~isempty(OffsetMap.Match)
    k = ismember(OffsetMap.RedXY,OffsetMap.Match(n,1:2));
    if max(k(:,1))==1
        OffsetMap.RedXY(k(:,1),:)=[];
    end
    k = ismember(OffsetMap.GreenXY,OffsetMap.Match(n,3:4));
    if max(k(:,1))==1
        OffsetMap.GreenXY(k(:,1),:)=[];
    end
    OffsetMap.Match(n,:)=[];
end
setappdata(hMainGui.fig,'OffsetMap',OffsetMap);
if strcmp(get(hMainGui.Menu.mShowOffsetMap,'Checked'),'on')
    fShow('OffsetMap',hMainGui);    
end
fShared('UpdateMenu',hMainGui);

function AddTo(hMainGui)
global Config;
global Objects;
global Molecule;
global Filament;
Mode=get(gcbo,'UserData');
data=get(gco,'UserData');
if strcmp(Mode{1},'Molecule')
    Object=Molecule;
else
    Object=Filament;
end
nObj=length(Object);
kObj=[];
kData=[];
nCh = data(1);
n = data(2);
frame_idx = hMainGui.Values.FrameIdx(nCh+1);
if strcmp(Mode{2},'New')==1
    Object(nObj+1).Selected=0;
    Object(nObj+1).Visible=1;
    Object(nObj+1).Name=sprintf('%s %d',Mode{1},nObj+1); 
    Object(nObj+1).Comments='';
    Object(nObj+1).File=Config.StackName;
    Object(nObj+1).Color=[0 0 1];
    Object(nObj+1).Drift=0;
    Object(nObj+1).Channel=nCh(1);
    Object(nObj+1).PixelSize=Config.PixSize;
    kObj=nObj+1;
    kData=1;
else
    if nObj==0
        fMsgDlg(['No ' Mode{1} ' present'],'error');
        return;
    else
        idx=find([Object.Selected]==2,1);
        if isempty(idx)
            fMsgDlg(['No Current' Mode{1} ' Track'],'error');
            return;
        else
            if ~isempty(find(Object(idx).Results(:,1)==frame_idx, 1))
                button = fQuestDlg('Overwrite current frame?','FIESTA Warning',{'OK','Cancel'},'OK');
                if strcmp(button,'OK') && ~isempty(button)
                    kData=find(Object(idx).Results(:,1)==frame_idx,1);
                else 
                    return;
                end
            end
            kObj=idx;
        end
    end
end
if ~isempty(kObj)
    if strcmp(Mode{1},'Molecule')
        Molecule=fShared('AddDataMol',Object,Objects,kObj,kData,frame_idx,n);
        Molecule(kObj).Results(:,6) = fDis(Molecule(kObj).Results(:,3:5));
    else
        Filament=fShared('AddDataFil',Object,Objects,kObj,kData,frame_idx,n);
        if strcmp(Config.RefPoint,'center')==1
            Filament(kObj).Results(:,3:5) = Filament(kObj).PosCenter;
        elseif strcmp(Config.RefPoint,'start')==1
            Filament(kObj).Results(:,3:5) = Filament(kObj).PosStart;
        else
            Filament(kObj).Results(:,3:5) = Filament(kObj).PosEnd;
        end
        Filament(kObj).Results(:,6) = fDis(Filament(kObj).Results(:,3:5));
    end
end
fShow('Image');  
fShow('Tracks');
if strcmp(Mode{1},'Molecule')&&strcmp(Mode{2},'New')
    [Molecule,Filament]=CurrentTrack(Molecule,Filament,kObj);
elseif strcmp(Mode{1},'Filament')&&strcmp(Mode{2},'New')
    [Filament,Molecule]=CurrentTrack(Filament,Molecule,kObj);
end
fRightPanel('UpdateList',hMainGui.RightPanel.pData.FilList,Filament,hMainGui.RightPanel.pData.sFilList,hMainGui.Menu.ctListFil);
fRightPanel('UpdateList',hMainGui.RightPanel.pData.MolList,Molecule,hMainGui.RightPanel.pData.sMolList,hMainGui.Menu.ctListMol);
fShared('UpdateMenu',hMainGui);




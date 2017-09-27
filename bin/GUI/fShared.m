function Object=fShared(func,varargin)
Object=[];
switch func
    case 'AddStack'
        AddStack(varargin{1});
    case 'AnalyseQueue'
        AnalyseQueue(varargin{1});
    case 'SelectOne'
        Object=SelectOne(varargin{1},varargin{2},varargin{3},varargin{4});
    case 'VisibleOne'
        Object=VisibleOne(varargin{1},varargin{2},varargin{3},varargin{4},varargin{5},varargin{6});        
    case 'DeleteTracks'
        DeleteTracks(varargin{1},varargin{2},varargin{3});
    case 'DeleteScan'
        DeleteScan(varargin{1});        
    case 'MergeTracks'
        MergeTracks;        
    case 'ClearTracks'
        ClearTracks(varargin{1});                
    case 'UpdateMenu'
        UpdateMenu(varargin{1});         
    case 'SetDrift'
        SetDrift(varargin{1});        
    case 'ReturnFocus'
        ReturnFocus;  
    case 'GetSaveDir'
        Object=GetSaveDir;
    case 'SetSaveDir'
        SetSaveDir(varargin{1});  
    case 'GetLoadDir'
        Object=GetLoadDir;
    case 'SetLoadDir'
        SetLoadDir(varargin{1});         
    case 'BackUp'
        BackUpData(varargin{1});      
    case 'CheckServer'
        Object=CheckServer;   
    case 'AddDataMol'
        Object=AddDataMol(varargin{1},varargin{2},varargin{3},varargin{4},varargin{5},varargin{6});
    case 'AddDataFil'
        Object=AddDataFil(varargin{1},varargin{2},varargin{3},varargin{4},varargin{5},varargin{6}); 
end

function SaveDir=GetSaveDir
global FiestaDir;
SaveDir=FiestaDir.Save;
if isempty(SaveDir)
    if isempty(FiestaDir.Load)
        SaveDir=FiestaDir.Stack;
    else
        SaveDir=FiestaDir.Load;
    end
end

function SetSaveDir(SaveDir)
global FiestaDir;
FiestaDir.Save=SaveDir;

function LoadDir=GetLoadDir
global FiestaDir;
LoadDir=FiestaDir.Load;
if isempty(LoadDir)
    LoadDir=FiestaDir.Stack;
end

function SetLoadDir(LoadDir)
global FiestaDir;
FiestaDir.Load=LoadDir;

function ReturnFocus
hMainGui=getappdata(0,'hMainGui');
%warning off MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame
%javaFrame = get(hMainGui.fig,'JavaFrame');
%javaFrame.getAxisComponent.requestFocus;


function MergeTracks
global Molecule;
global Filament;
hMainGui = getappdata(0,'hMainGui');
BackUpData(hMainGui);
MolSelected=[Molecule.Selected];
FilSelected=[Filament.Selected];
kMol=find(MolSelected==1);
kFil=find(FilSelected==1);
h = findobj('Tag','hMergeGui');
if ~isempty(h)
    close(h);
end
if isempty(kMol)&&~isempty(kFil)
    fMergeGui('Create','Filament',kFil);
elseif ~isempty(kMol)&&isempty(kFil)
    fMergeGui('Create','Molecule',kMol);    
elseif ~isempty(kMol)&&~isempty(kFil)
    fMsgDlg('Can not merge molecules and filaments','error');
    ReturnFocus;
end
hMainGui.CurrentKey = [];
setappdata(0,'hMainGui',hMainGui);

function BackUpData(hMainGui)
global Molecule;
global Filament;
global KymoTrackMol;
global KymoTrackFil;
global BackUp;
BackUp.Molecule = Molecule;
BackUp.Filament = Filament;
BackUp.KymoTrackMol = KymoTrackMol;
BackUp.KymoTrackFil = KymoTrackFil;
set(hMainGui.Menu.mUndo,'Enable','on');

function [Mol,Fil] = DeleteSelectedPoints(hMainGui)
global Molecule;
global Filament;
SelectedPoints = hMainGui.SelectedPoints;
Mol = [];
Fil = [];
if ~isempty(SelectedPoints)
    % find Molecules
    k = unique(real(SelectedPoints(:,1)));
    k(k==0) = [];
    if ~isempty(k)
        for n = k'
            idx = SelectedPoints(SelectedPoints(:,1)==n,2);
            sect = ones(size(Molecule(n).Results,1),1);
            sect(idx) = 0;
            sect = bwlabel(logical(sect));
            if max(sect)>1
                nMol = length(Molecule);
                for m = max(sect):-1:2
                    Molecule(nMol+m-1) = Molecule(n);
                    Molecule(nMol+m-1).Results(sect~=m,:) = [];
                    Molecule(nMol+m-1).Results(:,6) = fDis(Molecule(nMol+m-1).Results(:,3:5));
                    Molecule(nMol+m-1).TrackingResults(sect~=m) = [];
                    Molecule(nMol+m-1).PathData = [];   
                    Molecule(nMol+m-1).Name = [Molecule(nMol+m-1).Name ' - Part ' num2str(m)];
                end
            end
            if max(sect)>0
                Molecule(n).Results(sect~=1,:) = [];
                Molecule(n).Results(:,6) = fDis(Molecule(n).Results(:,3:5));
                Molecule(n).TrackingResults(sect~=1) = [];
                if ~isempty(Molecule(n).PathData)
                    Molecule(n).PathData(sect~=1,:) = [];   
                end
                Molecule(n).Name = [Molecule(n).Name ' - Part 1'];
            else
                Mol = [Mol n];
            end
        end
    end
    %find Filaments
    k = unique(imag(SelectedPoints(:,1)));
    k(k==0) = [];
    if ~isempty(k)
        for n = k'
            idx = SelectedPoints(SelectedPoints(:,1)==n*1i,2);
            sect = ones(size(Filament(n).Results,1),1);
            sect(idx) = 0;
            sect = bwlabel(logical(sect));
            if max(sect)>1
                nFil = length(Filament);
                for m = max(sect):-1:2
                    Filament(nFil+m-1) = Filament(n);
                    Filament(nFil+m-1).Results(sect~=m,:) = [];
                    Filament(nFil+m-1).Results(:,6) = fDis(Filament(nFil+m-1).Results(:,3:5));
                    Filament(nFil+m-1).TrackingResults(sect~=m) = [];
                    Filament(nFil+m-1).PosStart(sect~=m,:)=[];
                    Filament(nFil+m-1).PosCenter(sect~=m,:)=[];   
                    Filament(nFil+m-1).PosEnd(sect~=m,:)=[];
                    Filament(nFil+m-1).Data(sect~=m)=[];       
                    Filament(nFil+m-1).PathData = [];   
                    Filament(nFil+m-1).Name = [Filament(nFil+m-1).Name ' - Part ' num2str(m)];
                end
            end
            if max(sect)>0
                Filament(n).Results(sect~=1,:) = [];
                Filament(n).Results(:,6) = fDis(Filament(n).Results(:,3:5));
                Filament(n).TrackingResults(sect~=1) = [];
                Filament(n).PosStart(sect~=1,:)=[];
                Filament(n).PosCenter(sect~=1,:)=[];   
                Filament(n).PosEnd(sect~=1,:)=[];
                Filament(n).Data(sect~=1)=[];       
                if ~isempty(Filament(n).PathData)
                    Filament(n).PathData(sect~=1,:) = [];   
                end
                Filament(n).Name = [Filament(n).Name ' - Part 1'];
            else
                Fil = [Fil n];
            end
        end
    end
end

function DeleteTracks(hMainGui,MolSelect,FilSelect)
global Molecule;
global Filament;
global KymoTrackMol;
global KymoTrackFil;
global Stack;
BackUpData(hMainGui);
if ~isempty(Molecule)
    if isempty(MolSelect)
        MolSelect = [Molecule.Selected];
    end
    [Molecule,KymoTrackMol]=DeleteSelection(Molecule,KymoTrackMol,MolSelect);
end
if ~isempty(Filament)
    if isempty(FilSelect)
        FilSelect = [Filament.Selected];
    end
    [Filament,KymoTrackFil]=DeleteSelection(Filament,KymoTrackFil,FilSelect);
end
if ~any(MolSelect) && ~any(FilSelect)
    [Mol,Fil]=DeleteSelectedPoints(hMainGui);
    delete(findobj('Tag','pSelectedPoints'));
    hMainGui.SelectedPoints = [];
    if ~isempty(Molecule) && ~isempty(Mol)
        MolSelect = [Molecule.Selected];
        MolSelect(Mol) = 1;
        [Molecule,KymoTrackMol]=DeleteSelection(Molecule,KymoTrackMol,MolSelect);    
    end
    if ~isempty(Filament) && ~isempty(Fil)
        FilSelect = [Filament.Selected];
        FilSelect(Fil) = 1;
        [Filament,KymoTrackFil]=DeleteSelection(Filament,KymoTrackFil,FilSelect);
    end
    fRightPanel('UpdateKymoTracks',hMainGui);
    hMainGui = getappdata(0,'hMainGui');
end
fRightPanel('UpdateList',hMainGui.RightPanel.pData.MolList,Molecule,hMainGui.RightPanel.pData.sMolList,hMainGui.Menu.ctListMol);
fRightPanel('UpdateList',hMainGui.RightPanel.pData.FilList,Filament,hMainGui.RightPanel.pData.sFilList,hMainGui.Menu.ctListFil);
if isempty(Molecule)
    Molecule=[];
    Molecule=fDefStructure(Molecule,'Molecule');
    set(hMainGui.RightPanel.pData.cMolDrift,'Enable','off');    
    set(hMainGui.RightPanel.pData.cIgnoreMol,'Enable','off');
end
if isempty(Filament)
    Filament=[];
    Filament=fDefStructure(Filament,'Filament'); 
    set(hMainGui.RightPanel.pData.cIgnoreFil,'Enable','off');            
    set(hMainGui.RightPanel.pData.cFilDrift,'Enable','off');
end
UpdateMenu(hMainGui)
setappdata(0,'hMainGui',hMainGui);
if isempty(Stack) && isempty(Filament) && isempty(Molecule)
    set(hMainGui.MidPanel.pView,'Visible','off');
    set(hMainGui.MidPanel.pNoData,'Visible','on')
    set(hMainGui.MidPanel.tNoData,'String','No Stack or Tracks present','Visible','on');      
    drawnow expose
else
    fShow('Image',hMainGui);
    fShow('Tracks',hMainGui);
end

function ClearTracks(hMainGui)
global Molecule;
global Filament;
global Stack;
MolSelect=ones(1,length(Molecule));
FilSelect=ones(1,length(Filament));
DeleteTracks(hMainGui,MolSelect,FilSelect);
if isempty(Stack)
    set(hMainGui.MidPanel.pView,'Visible','off');
    set(hMainGui.MidPanel.pNoData,'Visible','on')
    set(hMainGui.MidPanel.tNoData,'String','No Stack or Tracks present','Visible','on');      
    drawnow
end 

function SetDrift(hMainGui)
global Molecule;
fRightPanel('CheckDrift',hMainGui);
nMol=length(Molecule);
if nMol>0
    stidx = unique([Molecule([Molecule.Selected]==1).Channel]);
    Drift = cell(1,hMainGui.Values.MaxIdx(1));
    for m = stidx
        Drift{m} =[];
        k=find([Molecule.Selected]==1 & [Molecule.Channel]==m);
        nData=zeros(length(Molecule(k)),1);
        for i = 1:length(Molecule(k))
            nData(i)=Molecule(k(i)).Results(size(Molecule(k(i)).Results,1),1);
        end
        n=max(nData);
        n=n(1);
        F=(1:n);
        if ~isempty(k)
            X=zeros(n,length(k));
            Y=zeros(n,length(k));
            Z=zeros(n,length(k));
            p=1;
            for i=k
                Drift{m} =[];
                R_Index=Molecule(i).Results(:,1);
                R_X=Molecule(i).Results(:,3);
                R_Y=Molecule(i).Results(:,4);
                R_Z=Molecule(i).Results(:,5);
                DisX=zeros(n,1);
                DisY=zeros(n,1);
                DisZ=zeros(n,1);
                for j=1:n
                    [~,k2]=min(abs(j-R_Index));
                    DisX(j)=R_X(k2(1))-R_X(1);
                    DisY(j)=R_Y(k2(1))-R_Y(1);
                    DisZ(j)=R_Z(k2(1))-R_Z(1);
                end
                X(:,p)=DisX;
                Y(:,p)=DisY;
                Z(:,p)=DisZ;
                p=p+1;
            end
            drift_x=mean(X,2);
            drift_y=mean(Y,2);
            drift_z=mean(Z,2);
            drift_dx=std(X,0,2);
            drift_dy=std(Y,0,2);
            drift_dz=std(Z,0,2);
            Drift{m}=[F' drift_x drift_y drift_z drift_dx drift_dy drift_dz];
        end
    end
    setappdata(hMainGui.fig,'Drift',Drift);
    UpdateMenu(hMainGui);
end

function [Object,KymoObject]=DeleteSelection(Object,KymoObject,Selected)
Track = [Object.PlotHandles];
Selection = (Selected==1);
if ~isempty(Track)
    h = Track(:,Selection(1:length(Track)));
    delete(h(ishandle(h)));
end
if ~isempty(KymoObject)
    KymoTrack = [KymoObject.PlotHandles];
    k = ismember([KymoObject.Index],find(Selection==1));
    if ishandle(KymoTrack(:,k))
        delete(KymoTrack(:,k));
    end
    KymoObject(k) = [];
    for n=1:length(KymoObject)
        cIndex = sum(Selection(1:KymoObject(n).Index));
        KymoObject(n).Index = KymoObject(n).Index-cIndex;
    end
end
Object(Selection) = [];

function UpdateMenu(hMainGui)
global Stack;
global Objects;
global Molecule;
global Filament;
global BackUp;
global Config;
Drift=getappdata(hMainGui.fig,'Drift');
OffsetMap=getappdata(hMainGui.fig,'OffsetMap');
enable='off';
if ~isempty(Stack)
    enable='on';
end
set(hMainGui.RightPanel.pButton.bAddLocal,'Enable',enable);
set(hMainGui.Menu.mSaveStack,'Enable',enable);
set(hMainGui.Menu.mCloseStack,'Enable',enable);
if isempty(BackUp)
    set(hMainGui.Menu.mUndo,'Enable','off');    
else
    set(hMainGui.Menu.mUndo,'Enable','on');   
end
if ~isempty(Config.TrackingServer)&&~strncmp(Config.TrackingServer,'local',5)
    set(hMainGui.Menu.mLoadServer,'Enable','on');
    set(hMainGui.Menu.mLoadObjServer,'Enable','on');
    set(hMainGui.Menu.mAddStackServer,'Enable',enable);
    set(hMainGui.Menu.mAddBatchServer,'Enable',enable);
    set(hMainGui.RightPanel.pButton.bAddServer,'Enable',enable);    
    set(hMainGui.RightPanel.pQueue.bSrvRefresh,'Enable','on');    
else
    set(hMainGui.Menu.mLoadServer,'Enable','off');
    set(hMainGui.Menu.mLoadObjServer,'Enable','off');
    set(hMainGui.Menu.mAddStackServer,'Enable','off');
    set(hMainGui.Menu.mAddBatchServer,'Enable','off');
    set(hMainGui.RightPanel.pButton.bAddServer,'Enable','off');    
    set(hMainGui.RightPanel.pQueue.bSrvRefresh,'Enable','off');    
end
set(hMainGui.Menu.mAddStackLocal,'Enable',enable);
set(hMainGui.Menu.mAddBatchLocal,'Enable',enable);
set(hMainGui.Menu.mAnalyseFrame,'Enable',enable);
set(hMainGui.Menu.mFrame,'Enable',enable);
set(hMainGui.Menu.mMaximum,'Enable',enable);
set(hMainGui.Menu.mAverage,'Enable',enable);
if strcmp(get(hMainGui.Menu.mCorrectStack,'Checked'),'on')
    set(hMainGui.Menu.mCorrectStack,'Enable','off');
    set(hMainGui.Menu.mAlignChannels,'Enable','off','Checked','on');
else  
    set(hMainGui.Menu.mCorrectStack,'Enable',enable);
end
if strcmp(get(hMainGui.ToolBar.ToolNormImage,'State'),'on')
   set(hMainGui.Menu.mZProjection,'Enable',enable);
   set(hMainGui.Menu.mObjProjection,'Enable',enable);
else
   set(hMainGui.Menu.mZProjection,'Enable','off');
   set(hMainGui.Menu.mObjProjection,'Enable','off');
end
set(hMainGui.Menu.mColorOverlay,'Enable',enable);
set(hMainGui.Menu.mExport,'Enable',enable);
set(get(hMainGui.Menu.mTools,'Children'),'Enable',enable);
enable='off';
if ~isempty(Molecule)||~isempty(Filament)
    enable='on';
end
set(hMainGui.Menu.mSaveTracks,'Enable',enable);
set(hMainGui.Menu.mSaveAs,'Enable',enable);
set(hMainGui.Menu.mSaveSelection,'Enable',enable);
set(hMainGui.Menu.mSaveSelAs,'Enable',enable);
set(hMainGui.Menu.mClearTracks,'Enable',enable);
set(hMainGui.Menu.mFind,'Enable',enable);
set(hMainGui.Menu.mSort,'Enable',enable);
set(hMainGui.Menu.mFindMoving,'Enable',enable);
set(hMainGui.Menu.mFindStatic,'Enable',enable);
set(hMainGui.Menu.mMergeTracks,'Enable',enable);
set(hMainGui.Menu.mCombineTracks,'Enable',enable);
set(hMainGui.Menu.mDeleteTracks,'Enable',enable);
if isempty(Molecule)
    set(hMainGui.Menu.mSetDrift,'Enable','off');
    set(hMainGui.Menu.mFindDrift,'Enable','off');      
    set(hMainGui.RightPanel.pData.cMolDrift,'Enable','off','Value',0);
    set(hMainGui.RightPanel.pData.cIgnoreMol,'Enable','off','Value',0);     
    set(hMainGui.Menu.mCreateOffsetMap,'Enable','off');
else
    set(hMainGui.Menu.mSetDrift,'Enable','on');
    set(hMainGui.Menu.mFindDrift,'Enable','on');                
    set(hMainGui.Menu.mCreateOffsetMap,'Enable','on');
    if ~isempty(Drift)
        set(hMainGui.RightPanel.pData.cMolDrift,'Enable','on');
    else
        set(hMainGui.RightPanel.pData.cMolDrift,'Enable','off','Value',0);
    end
    set(hMainGui.RightPanel.pData.cIgnoreMol,'Enable','on');
end
if isempty(Filament)
    set(hMainGui.RightPanel.pData.cFilDrift,'Enable','off','Value',0);   
    set(hMainGui.RightPanel.pData.cIgnoreFil,'Enable','off','Value',0);            
else
    if ~isempty(Drift)
        set(hMainGui.RightPanel.pData.cFilDrift,'Enable','on');
    else
        set(hMainGui.RightPanel.pData.cFilDrift,'Enable','off','Value',0);
    end
    set(hMainGui.RightPanel.pData.cIgnoreFil,'Enable','on');
    set(hMainGui.RightPanel.pData.cShowWholeFil,'Enable','on');
end

if isempty(Drift)
    set(hMainGui.Menu.mSaveDrift,'Enable','off');
else
    set(hMainGui.Menu.mSaveDrift,'Enable','on');
end
enable='off';
if ~isempty(Objects)
    enable='on';
    if get(hMainGui.RightPanel.pData.cShowAllFil,'Value')
        set(hMainGui.RightPanel.pData.cShowWholeFil,'Enable','on');
    else
        if isempty(Filament)
            set(hMainGui.RightPanel.pData.cShowWholeFil,'Enable','off'); 
        end
    end
else
    set(hMainGui.RightPanel.pData.cShowAllMol,'Value',0);
    if isempty(Filament)
       set(hMainGui.RightPanel.pData.cShowWholeFil,'Enable','off'); 
    end
end
set(hMainGui.Menu.mSaveObjects,'Enable',enable);
set(hMainGui.Menu.mClearObjects,'Enable',enable);
set(hMainGui.Menu.mReconnect,'Enable',enable);
set(hMainGui.Menu.mReconnectStatic,'Enable',enable);
set(hMainGui.RightPanel.pData.cShowAllMol,'Enable',enable);
set(hMainGui.RightPanel.pData.cShowAllFil,'Enable',enable);

enable='off';
if ~isempty(OffsetMap)
    enable='on';
end
set(hMainGui.Menu.mShowOffsetMap,'Enable',enable);
set(hMainGui.Menu.mSaveOffsetMap,'Enable',enable);
set(hMainGui.Menu.mApplyOffsetMap,'Enable',enable);
set(hMainGui.Menu.mClearOffsetMap,'Enable',enable);

function Object=SelectOne(Object,KymoObject,n,v)
if numel(Object.Selected)==1
    if Object.Selected==0||Object.Selected==1
        if isempty(v)
            Object.Selected=1-Object.Selected;
        else
            Object.Selected=v;
        end
        if Object.Selected==1
            marker='s';
            line = '-.';
        else
            marker='none';  
            line = '-';
        end
        if Object.Visible==0
            marker = 'none';
            line = '-';
        end
        if ishandle(Object.PlotHandles(1))
            set(Object.PlotHandles(1),'Marker',marker,'MarkerIndices',1:5:length(get(Object.PlotHandles(1),'YData')),'LineStyle',line,'MarkerEdgeColor',[0 0.34 0.59],'MarkerFaceColor',[0.75 0.91 1]);
            if ~isempty(KymoObject)
                k=find([KymoObject.Index]==n);
                if ~isempty(k)
                    if ishandle(KymoObject(k).PlotHandles(1))
                        set(KymoObject(k).PlotHandles(1),'Marker',marker,'MarkerIndices',1:5:length(get(KymoObject(k).PlotHandles(1),'YData')),'LineStyle',line,'MarkerEdgeColor',[0 0.34 0.59],'MarkerFaceColor',[0.75 0.91 1]); 
                    end
                end   
            end
        end
    end
end

function Object=VisibleOne(Object,KymoObject,List,n,v,slider)
hMainGui=getappdata(0,'hMainGui');
nObj=length(Object);
value=round(get(slider,'Value'));
if imag(n)>0
    if nObj>8
        idx=imag(n);
        n=nObj-7-value+imag(n);
    else
        idx=imag(n);
        n=imag(n);
    end
else
   idx=n+value+7-nObj;
end
if Object(n).Selected>-1
    if isempty(v)
        Object(n).Visible=~Object(n).Visible;
    else
        Object(n).Visible=logical(v);
    end
    marker='none';
    line='-';
    if Object(n).Visible
        CDataVisible(:,:,1)=[NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0.964705882352941,0.886274509803922,0.811764705882353,0.721568627450980,0.650980392156863,0.635294117647059,0.721568627450980,0.862745098039216,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,0.858823529411765,0.596078431372549,0.462745098039216,0.356862745098039,0.262745098039216,0.196078431372549,0.176470588235294,0.262745098039216,0.431372549019608,0.709803921568628,NaN,NaN,NaN;NaN,NaN,NaN,NaN,0.992156862745098,0.600000000000000,0.168627450980392,0,0,0,0,0,0,0,0,0,0,0.258823529411765,0.905882352941177,NaN;NaN,NaN,NaN,0.843137254901961,0.227450980392157,0,0,0,0,0,0,0,0,0,0,0,0,0,0.372549019607843,NaN;NaN,NaN,0.729411764705882,0.0509803921568627,0,0,0,0,0,0,0,0,0.0274509803921569,0.211764705882353,0.00392156862745098,0,0,0.0745098039215686,0.874509803921569,NaN;NaN,0.650980392156863,0,0,0,0,0.0392156862745098,0.168627450980392,0,0,0,0,0.0666666666666667,0.968627450980392,0.827450980392157,0.325490196078431,0,0,0.329411764705882,0.886274509803922;0.682352941176471,0.239215686274510,0.235294117647059,0,0.462745098039216,0.352941176470588,0.231372549019608,NaN,0.156862745098039,0,0,0,0.125490196078431,0.976470588235294,NaN,0.913725490196078,0.0117647058823529,0.129411764705882,0.129411764705882,0.800000000000000;0.937254901960784,0.674509803921569,0.0431372549019608,0.247058823529412,NaN,0.882352941176471,0.0941176470588235,0.976470588235294,0.403921568627451,0,0,0,0.376470588235294,NaN,NaN,0.603921568627451,0,0.317647058823529,0.960784313725490,0.960784313725490;0.984313725490196,0.121568627450980,0,0.447058823529412,NaN,NaN,0.407843137254902,0.266666666666667,0.258823529411765,0,0,0.0549019607843137,0.858823529411765,NaN,0.854901960784314,0.0627450980392157,0.0156862745098039,0.298039215686275,0.996078431372549,NaN;NaN,0.345098039215686,0,0.0313725490196078,0.717647058823529,NaN,NaN,0.305882352941177,0,0,0.164705882352941,0.784313725490196,NaN,0.858823529411765,0.109803921568627,0,0.384313725490196,0.890196078431373,NaN,NaN;NaN,0.862745098039216,0.0431372549019608,0,0,0.368627450980392,0.827450980392157,NaN,0.945098039215686,0.894117647058824,NaN,NaN,0.592156862745098,0.00784313725490196,0.0117647058823529,0.203921568627451,0.662745098039216,NaN,NaN,NaN;NaN,NaN,0.698039215686275,0,0,0,0,0.188235294117647,0.329411764705882,0.392156862745098,0.317647058823529,0.0823529411764706,0.0274509803921569,0.431372549019608,0.615686274509804,0.682352941176471,0.937254901960784,NaN,NaN,NaN;NaN,NaN,NaN,0.709803921568628,0.341176470588235,0,0,0,0.0313725490196078,0,0.266666666666667,0.372549019607843,0.537254901960784,0.690196078431373,0.937254901960784,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,0.972549019607843,0.592156862745098,0.109803921568627,0.0745098039215686,0.501960784313726,0.631372549019608,0.400000000000000,0.721568627450980,0.819607843137255,0.952941176470588,0.964705882352941,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,0.972549019607843,0.913725490196078,0.843137254901961,NaN,0.929411764705882,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;];
        CDataVisible(:,:,2)=[NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0.964705882352941,0.886274509803922,0.811764705882353,0.721568627450980,0.650980392156863,0.635294117647059,0.721568627450980,0.862745098039216,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,0.858823529411765,0.596078431372549,0.462745098039216,0.356862745098039,0.262745098039216,0.196078431372549,0.176470588235294,0.262745098039216,0.431372549019608,0.709803921568628,NaN,NaN,NaN;NaN,NaN,NaN,NaN,0.992156862745098,0.600000000000000,0.168627450980392,0,0,0,0,0,0,0,0,0,0,0.258823529411765,0.905882352941177,NaN;NaN,NaN,NaN,0.843137254901961,0.227450980392157,0,0,0,0,0,0,0,0,0,0,0,0,0,0.372549019607843,NaN;NaN,NaN,0.729411764705882,0.0509803921568627,0,0,0,0,0,0,0,0,0.0274509803921569,0.211764705882353,0.00392156862745098,0,0,0.0745098039215686,0.874509803921569,NaN;NaN,0.650980392156863,0,0,0,0,0.0392156862745098,0.168627450980392,0,0,0,0,0.0666666666666667,0.968627450980392,0.827450980392157,0.325490196078431,0,0,0.329411764705882,0.886274509803922;0.682352941176471,0.239215686274510,0.235294117647059,0,0.462745098039216,0.352941176470588,0.231372549019608,NaN,0.156862745098039,0,0,0,0.125490196078431,0.976470588235294,NaN,0.913725490196078,0.0117647058823529,0.129411764705882,0.129411764705882,0.800000000000000;0.937254901960784,0.674509803921569,0.0431372549019608,0.247058823529412,NaN,0.882352941176471,0.0941176470588235,0.976470588235294,0.403921568627451,0,0,0,0.376470588235294,NaN,NaN,0.603921568627451,0,0.317647058823529,0.960784313725490,0.960784313725490;0.984313725490196,0.121568627450980,0,0.447058823529412,NaN,NaN,0.407843137254902,0.266666666666667,0.258823529411765,0,0,0.0549019607843137,0.858823529411765,NaN,0.854901960784314,0.0627450980392157,0.0156862745098039,0.298039215686275,0.996078431372549,NaN;NaN,0.345098039215686,0,0.0313725490196078,0.717647058823529,NaN,NaN,0.305882352941177,0,0,0.164705882352941,0.784313725490196,NaN,0.858823529411765,0.109803921568627,0,0.384313725490196,0.890196078431373,NaN,NaN;NaN,0.862745098039216,0.0431372549019608,0,0,0.368627450980392,0.827450980392157,NaN,0.945098039215686,0.894117647058824,NaN,NaN,0.592156862745098,0.00784313725490196,0.0117647058823529,0.203921568627451,0.662745098039216,NaN,NaN,NaN;NaN,NaN,0.698039215686275,0,0,0,0,0.188235294117647,0.329411764705882,0.392156862745098,0.317647058823529,0.0823529411764706,0.0274509803921569,0.431372549019608,0.615686274509804,0.682352941176471,0.937254901960784,NaN,NaN,NaN;NaN,NaN,NaN,0.709803921568628,0.341176470588235,0,0,0,0.0313725490196078,0,0.266666666666667,0.372549019607843,0.537254901960784,0.690196078431373,0.937254901960784,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,0.972549019607843,0.592156862745098,0.109803921568627,0.0745098039215686,0.501960784313726,0.631372549019608,0.400000000000000,0.721568627450980,0.819607843137255,0.952941176470588,0.964705882352941,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,0.972549019607843,0.913725490196078,0.843137254901961,NaN,0.929411764705882,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;];
        CDataVisible(:,:,3)=[NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0.964705882352941,0.886274509803922,0.811764705882353,0.721568627450980,0.650980392156863,0.635294117647059,0.721568627450980,0.862745098039216,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,0.858823529411765,0.596078431372549,0.462745098039216,0.356862745098039,0.262745098039216,0.196078431372549,0.176470588235294,0.262745098039216,0.431372549019608,0.709803921568628,NaN,NaN,NaN;NaN,NaN,NaN,NaN,0.992156862745098,0.600000000000000,0.168627450980392,0,0,0,0,0,0,0,0,0,0,0.258823529411765,0.905882352941177,NaN;NaN,NaN,NaN,0.843137254901961,0.227450980392157,0,0,0,0,0,0,0,0,0,0,0,0,0,0.372549019607843,NaN;NaN,NaN,0.729411764705882,0.0509803921568627,0,0,0,0,0,0,0,0,0.0274509803921569,0.211764705882353,0.00392156862745098,0,0,0.0745098039215686,0.874509803921569,NaN;NaN,0.650980392156863,0,0,0,0,0.0392156862745098,0.168627450980392,0,0,0,0,0.0666666666666667,0.968627450980392,0.827450980392157,0.325490196078431,0,0,0.329411764705882,0.886274509803922;0.682352941176471,0.239215686274510,0.235294117647059,0,0.462745098039216,0.352941176470588,0.231372549019608,NaN,0.156862745098039,0,0,0,0.125490196078431,0.976470588235294,NaN,0.913725490196078,0.0117647058823529,0.129411764705882,0.129411764705882,0.800000000000000;0.937254901960784,0.674509803921569,0.0431372549019608,0.247058823529412,NaN,0.882352941176471,0.0941176470588235,0.976470588235294,0.403921568627451,0,0,0,0.376470588235294,NaN,NaN,0.603921568627451,0,0.317647058823529,0.960784313725490,0.960784313725490;0.984313725490196,0.121568627450980,0,0.447058823529412,NaN,NaN,0.407843137254902,0.266666666666667,0.258823529411765,0,0,0.0549019607843137,0.858823529411765,NaN,0.854901960784314,0.0627450980392157,0.0156862745098039,0.298039215686275,0.996078431372549,NaN;NaN,0.345098039215686,0,0.0313725490196078,0.717647058823529,NaN,NaN,0.305882352941177,0,0,0.164705882352941,0.784313725490196,NaN,0.858823529411765,0.109803921568627,0,0.384313725490196,0.890196078431373,NaN,NaN;NaN,0.862745098039216,0.0431372549019608,0,0,0.368627450980392,0.827450980392157,NaN,0.945098039215686,0.894117647058824,NaN,NaN,0.592156862745098,0.00784313725490196,0.0117647058823529,0.203921568627451,0.662745098039216,NaN,NaN,NaN;NaN,NaN,0.698039215686275,0,0,0,0,0.188235294117647,0.329411764705882,0.392156862745098,0.317647058823529,0.0823529411764706,0.0274509803921569,0.431372549019608,0.615686274509804,0.682352941176471,0.937254901960784,NaN,NaN,NaN;NaN,NaN,NaN,0.709803921568628,0.341176470588235,0,0,0,0.0313725490196078,0,0.266666666666667,0.372549019607843,0.537254901960784,0.690196078431373,0.937254901960784,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,0.972549019607843,0.592156862745098,0.109803921568627,0.0745098039215686,0.501960784313726,0.631372549019608,0.400000000000000,0.721568627450980,0.819607843137255,0.952941176470588,0.964705882352941,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,0.972549019607843,0.913725490196078,0.843137254901961,NaN,0.929411764705882,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;];
        visible='on';
        if Object(n).Selected
            marker='s';
            line = '-.';
        end
    else
        CDataVisible=[];
        visible='off';   
        if Object(n).Selected
            marker='none';
            line = '-';
        end
    end
    if idx>0&&idx<9
        set(List.Visible(idx),'CData',CDataVisible);
        hMainGui.CurrentKey=[];
        setappdata(0,'hMainGui',hMainGui);
    end
    set(Object(n).PlotHandles(1),'Marker',marker,'MarkerIndices',1:5:length(get(Object(n).PlotHandles(1),'YData')),'LineStyle',line,'MarkerEdgeColor',[0 0.34 0.59],'MarkerFaceColor',[0.75 0.91 1],'Visible',visible);
    k=find([KymoObject.Index]==n);
    if ~isempty(k)
        set(KymoObject(k).PlotHandles(1),'Marker',marker,'MarkerIndices',1:5:length(get(KymoObject(k).PlotHandles(1),'YData')),'LineStyle',line,'MarkerEdgeColor',[0 0.34 0.59],'MarkerFaceColor',[0.75 0.91 1],'Visible',visible); 
    end  
end

function DeleteScan(hMainGui)
%fToolBar('Cursor',hMainGui);
%hMainGui=getappdata(0,'hMainGui');
if ~isempty(hMainGui.Scan)
    fRightPanel('DeleteScan',hMainGui);
    set(get(hMainGui.RightPanel.pTools.pKymoGraph,'Children'),'Enable','off');                                                                             
    set(hMainGui.RightPanel.pTools.aLineScan,'Visible','off');        
    set(hMainGui.RightPanel.pTools.pLineScan,'Visible','off');         
    set(hMainGui.MidPanel.aKymoGraph,'Visible','off');    
    set(hMainGui.MidPanel.pKymoGraph,'Visible','off');   
end


function DirServer=CheckServer
global Config;
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
    DirServer = '';
    if ispc
        fMsgDlg({'Could not connect to the server','Make sure that you permission to access the server'},'error');
    elseif ismac
        fMsgDlg({'Could not connect to the server','Make sure that you are connected to',['smb://' Config.TrackingServer '/FIESTASERVER/']},'warning');
     elseif isunix
        fMsgDlg({'Could not connect to the server','Make sure that you state the full path','of where the FIESTASERVER-share is mounted'},'warning');   
    end
end

function disregard=CheckConfig(Config,Mode,Stack)
if strcmp(Mode,'Reconnect')
    disregard = 0;
else
    nObjects = 0;
    hMainGui=getappdata(0,'hMainGui');
    set(hMainGui.MidPanel.pView,'Visible','off');
    set(hMainGui.MidPanel.pNoData,'Visible','on');
    set(hMainGui.MidPanel.tNoData,'String','Checking configuration  - Please wait...','Visible','on');   
    set(hMainGui.fig,'Pointer','watch');
    drawnow expose update
    disregard = 0;
    
    params.bw_region = Config.Region;
    if isfield(Config,'TformChannel')
        params.transform = Config.TformChannel;
    end

    params.bead_model=Config.Model;
    params.max_beads_per_region=Config.MaxFunc;
    params.scale=Config.PixSize;
    params.ridge_model = 'quadratic';

    params.find_molecules=1;
    params.find_beads=1;

    if Config.OnlyTrackMol==1
        params.find_molecules=0;
    end
    if Config.OnlyTrackFil==1
        params.find_beads=0;
    end
    params.include_data = Config.OnlyTrack.IncludeData;
    params.area_threshold=Config.Threshold.Area;
    params.height_threshold=Config.Threshold.Height;   
    params.fwhm_estimate=Config.Threshold.FWHM;
    if isempty(Config.BorderMargin)
        params.border_margin = 2 * Config.Threshold.FWHM / params.scale / (2*sqrt(2*log(2)));
    else
        params.border_margin = Config.BorderMargin;
    end

    if isempty(Config.ReduceFitBox)
        params.reduce_fit_box = 1;
    else
        params.reduce_fit_box = Config.ReduceFitBox;
    end

    params.focus_correction = Config.FilFocus;
    params.min_cod=Config.Threshold.Fit;
    params.threshold = Config.Threshold.Value;
    if length(Config.Threshold.Filter)==1
        [params.binary_image_processing,params.background_filter] = strtok(Config.Threshold.Filter{1},'+');
    else
        params.binary_image_processing = [];
        params.background_filter=Config.Threshold.Filter;
    end
    params.display = 0;
    
    if isinf(Config.LastFrame)
        Config.LastFrame = size(Stack,2);
    end
   
    params.options = optimset( 'Display', 'off','UseParallel','never');
    params.options.MaxFunEvals = []; 
    params.options.MaxIter = [];
    params.options.TolFun = [];
    params.options.TolX = [];
    params.creation_time_vector = 1:size(Stack{1},3);
    if Config.FirstTFrame>0
        Objects=ScanImage(fGetStackFrame(Stack,Config.FirstTFrame),params,Config.FirstTFrame+1i);
        nObjects=length(Objects);
        if Config.FirstTFrame~=Config.LastFrame
            Objects=ScanImage(fGetStackFrame(Stack,Config.LastFrame),params,min(Config.LastFrame+1i));
            nObjects=round((nObjects+length(Objects))/2);
        end
    end
    if nObjects>100
        button =  fQuestDlg('FIESTA found more than 100 objects with the current configuration. Make sure that the threshold is set correctly. Do you want to continue? (Note: Tracking of more than 100 objects per frame might requires a lot of time and resources)','FIESTA Warning',{'Add anyway','Disregard Stack'},'Disregard Stack');       
        if isempty(button) || strcmp(button,'Disregard Stack')
            disregard = 1;
        end
    end
    set(hMainGui.MidPanel.pView,'Visible','on');
    set(hMainGui.MidPanel.pNoData,'Visible','off');    
    set(hMainGui.MidPanel.tNoData,'String','No Stack or Data present','Visible','off');  
    set(hMainGui.fig,'Pointer','arrow');        
end

function AddStack(hMainGui)
global Config;
global Stack;
global Objects;
global Queue;
global FiestaDir;
global DirRoot;
global DirCurrent;
addConfig=Config;
Mode=get(gcbo,'UserData');
if strcmp(Mode,'Server')
    %check if FIESTA tracking server available
    DirServer = CheckServer;
    if ~isempty(DirServer);
        %get local version of FIESTA
        if ispc
            f_id = fopen([DirCurrent 'readme.txt'], 'r'); 
        else
            f_id = fopen([DirRoot 'readme.txt'], 'r'); 
        end
        if f_id ~= -1
            index = fgetl(f_id);
            local_version = index(66:74);
            fclose(f_id); 
        else
            local_version = '';
        end
        %get server version of FIESTA
        f_id = fopen([DirServer 'FIESTA' filesep 'readme.txt'], 'r'); 
        if f_id ~= -1
            index = fgetl(f_id);
            server_version = index(66:74);
            fclose(f_id); 
        else
            server_version = '';
        end
        %compare server version with local version
        if ~strcmp( local_version , server_version )
            fMsgDlg({'Detected a different version on the server!';'Restart server for newest version'},'error');
            DirServer='';
        end
    end
    if ~isempty(DirServer)
        set(hMainGui.MidPanel.pView,'Visible','off');
        set(hMainGui.MidPanel.pNoData,'Visible','on');
        set(hMainGui.MidPanel.tNoData,'String','Copying Stack to Server - Please wait...','Visible','on');   
        set(hMainGui.fig,'Pointer','watch');
        drawnow expose update
    else
        return;
    end
end
nRegion=length(hMainGui.Region);
if nRegion==0
    Region=ones(size(Stack{1}(:,:,1)));
else
    Region=zeros(size(Stack{1}(:,:,1)));
    for i=1:nRegion
        Region(hMainGui.Region(i).Area==1)=1;
    end
    if get(hMainGui.LeftPanel.pRegions.cExcludeReg,'Value')
        Region=ones(size(Stack{1}(:,:,1)))-Region;
    end
end
if isfield(Config,'DynamicFil')
    if Config.DynamicFil
        Fil = double(getappdata(hMainGui.fig,'AverageImage'));
        [filter,background] = strtok(Config.Threshold.Filter,'+'); 
        params = struct('scale',Config.PixSize,'fwhm_estimate',Config.Threshold.FWHM/Config.PixSize,'binary_image_processing',filter,'background_filter',background);
        if strcmp(Config.Threshold.Mode,'variable')==1
            Fil = Image2Binary(Fil,params);
        elseif strcmp(Config.Threshold.Mode,'relative')==1
            params.threshold = hMainGui.Values.RelThresh(1)*1i;
            hMainGui.Values.RelThresh(1) = 0;
            Fil=Image2Binary(Fil,params);
        else
            params.threshold = hMainGui.Values.Thresh(1);
            hMainGui.Values.Thresh(1) = 0;
            Fil=Image2Binary(Fil,params);
        end
        Region = Region.*Fil;    
    end
else
    Config.DynamicFil = 0;
end
if ~contains(get(gcbo,'Tag'),'Batch')
    if isempty(hMainGui.Values.PostSpecial)
        batch = hMainGui.Values.FrameIdx(1);
    else
        batch = 1:hMainGui.Values.MaxIdx(1);
    end
    FileName = Config.StackName;
    PathName = Config.Directory;
    if length(FileName)<hMainGui.Values.MaxIdx(1)
        FileName = repmat(FileName,1,hMainGui.Values.MaxIdx(1));
        PathName = repmat(PathName,1,hMainGui.Values.MaxIdx(1));
    end
    Time = Config.Time;
    TformChannel = hMainGui.Values.TformChannel;
    RelThresh = hMainGui.Values.RelThresh;
else
    [FileName, PathName] = uigetfile({'*.stk','FIESTA Data(*.stk)';'*.tif','Multilayer TIFF-Files (*.tif)'},'Select multiple stacks for analysis',FiestaDir.Stack,'MultiSelect','on');
    if ~iscell(FileName)
        FileName = {FileName};
    end   
    PathName = repmat({PathName},1,length(FileName));
    if FileName{1}==0
       FileName=0; 
    end
    batch = 1:length(FileName);
    if addConfig.LastFrame == size(Stack)
        addConfig.LastFrame = Inf;
    end
    Time = repmat(Config.Time,1,length(FileName));
    TformChannel = repmat(hMainGui.Values.TformChannel,1,length(FileName));
    RelThresh = repmat(hMainGui.Values.RelThresh,1,length(FileName));
end
if isempty(FileName) || iscell(FileName)
    addRegion = logical(Region);
    for n = batch
        addConfig.StackName = FileName{n};
        addConfig.Directory = PathName{n};
        if (~isempty(Stack)||strcmp(Mode,'Reconnect'))   
            addConfig.Selected=0;
            if strcmp(Mode,'Reconnect')
                addConfig.FirstTFrame=0;
                hMainGui.Values.Thresh=0;
                addConfig.FirstCFrame=1;
                addConfig.LastFrame=length(Objects);
                addConfig.StackName=[strrep(hMainGui.File,'.mat','') ' - Reconnect'];
                addConfig.Directory=fShared('GetLoadDir');
            elseif strcmp(Mode,'One')==1
                t = getChIdx;
                addConfig.FirstTFrame=hMainGui.Values.FrameIdx(t);
                addConfig.FirstCFrame=0;
                addConfig.LastFrame=hMainGui.Values.FrameIdx(t);
            else
                t = getChIdx;
                if hMainGui.Values.MaxIdx(t) == 1
                    addConfig.FirstTFrame=1;
                    addConfig.FirstCFrame=0;
                    addConfig.LastFrame=1;
                elseif hMainGui.Values.MaxIdx(t) < addConfig.LastFrame
                    addConfig.LastFrame = hMainGui.Values.MaxIdx(t);
                elseif Config.LastFrame<Config.FirstTFrame+4
                    fMsgDlg({'There must be at least 5 frames for tracking','Try analyzing current frame'},'error');
                    return;
                end
            end
            if strcmp(Mode,'Server')
                file_id{1} = [addConfig.Directory addConfig.StackName];
                file_id{2} = [DirServer 'Data' filesep 'Stacks' filesep addConfig.StackName];
                df1=dir(file_id{1});
                df2=dir(file_id{2}); 
                status = 1;
                if isempty(df2)
                    [status,message]=copyfile(file_id{1},file_id{2},'f');          
                else
                    if df1.bytes~=df2.bytes
                        [status,message]=copyfile(file_id{1},file_id{2},'f');          
                    end
                end
                if ~status
                    fMsgDlg(message,'error');
                end
            end
            addConfig.Time = Time(n);
            addConfig.OnlyTrackMol=0;
            addConfig.OnlyTrackFil=0;
            if addConfig.OnlyTrack.MolFull==1
                addConfig.OnlyTrackMol=1;
            end
            if addConfig.OnlyTrack.FilFull==1
                addConfig.OnlyTrackFil=1;
            end
            if isempty(hMainGui.Values.PostSpecial)
                k = n;
                addConfig.TformChannel{1} = TformChannel{n};
            else
                k = 1:length(hMainGui.Values.TformChannel);
                Config.BorderMargin = 0;
                addConfig.TformChannel = hMainGui.Values.TformChannel;
                addConfig.TformChannel{1}(3,3) = n;
            end
            addConfig.StackReadOptions = Config.StackReadOptions;
            if strcmp(addConfig.Threshold.Mode,'relative')==1
                addConfig.Threshold.Value = RelThresh(k)*1i;
            elseif strcmp(addConfig.Threshold.Mode,'variable')==1
                addConfig.Threshold.Value = [];
            else
                addConfig.Threshold.Value = hMainGui.Values.Thresh(k);
            end
            addConfig.Threshold.Filter = [];
            for p = 1:length(k)
                addConfig.Threshold.Filter{p} = Config.Threshold.Filter;
            end
            addConfig.Region = addRegion;
            k = min([length(Stack)*ones(size(k)); k]);
            if ~CheckConfig(addConfig,Mode,Stack(k))
                if strcmp(Mode,'Server')==1
                    ServerQueue = addConfig;                  
                    save([DirServer 'Queue' filesep 'FiestaQueue(' datestr(clock,'yyyymmddTHHMMSS') '-' num2str(fix(rand*1000),'%04.0f') ').mat'],'ServerQueue');
                    fRightPanel('UpdateQueue','Server');    
                    fRightPanel('QueueServerPanel',hMainGui);   
                    set(hMainGui.RightPanel.pQueue.bSrvRefresh,'String','Refresh SERVER Queue');
                elseif strcmp(Mode,'Local')==1||strcmp(Mode,'Reconnect')==1||strcmp(Mode,'One')==1
                    if isempty(Queue)
                        Queue=addConfig;
                    else
                        Queue=[Queue addConfig];
                    end
                    fRightPanel('UpdateQueue','Local');
                    fRightPanel('QueueLocalPanel',hMainGui);
                end
            end
        end
    end
end
if strcmp(Mode,'Server')
    set(hMainGui.MidPanel.pView,'Visible','on');
    set(hMainGui.MidPanel.pNoData,'Visible','off');    
    set(hMainGui.MidPanel.tNoData,'String','No Stack or Data present','Visible','off');  
    set(hMainGui.fig,'Pointer','arrow');   
end
ReturnFocus;

%/////////////////////////////////////////////////////////////////////////%
%                           Menu - Analyse all Stacks in Queue            %
%/////////////////////////////////////////////////////////////////////////%
function AnalyseQueue(hMainGui)
global Config;
global Queue;
global Objects;
global Stack;
global TimeInfo;
try
    nQueue=length(Queue);
    abort=0;
    while nQueue>0&&abort==0
        if Queue(1).FirstTFrame==0 && isempty(Objects)
            abort=1;
        else
            aObjects = Objects;
        end
        if isempty(strfind(Queue(1).StackName,'Reconnect'))
            if ~strcmp(Queue(1).StackName,Config.StackName)
                try
                    if strcmp(Queue(1).StackType,'ND2')
                        [aStack,aTimeInfo]=fReadND2([Queue(1).Directory Queue(1).StackName],Queue(1).StackReadOptions); 
                    else 
                        [aStack,aTimeInfo]=fStackRead([Queue(1).Directory Queue(1).StackName],Queue(1).StackReadOptions); 
                    end
                catch ME   
                    fMsgDlg(ME.message,'error');
                    abort=1;
                end
                if ~isempty(Queue(1).Time) && ~isnan(Queue(1).Time)
                    for n = 1:length(aStack)
                        nFrames=size(aStack,3);
                        aTimeInfo{n}=(0:nFrames-1)*Queue(1).Time;
                    end
                end
            else
                aTimeInfo = TimeInfo;
                aStack = Stack;
            end
            if length(Queue(1).TformChannel)==1
                k = Queue(1).TformChannel{1}(3,3);    
            else
                k = 1:length(Queue(1).TformChannel);
            end 
            aObjects = [];
        else
            k = Queue(1).TformChannel{1}(3,3);
            aTimeInfo = TimeInfo;
            aStack = Stack;
        end
        if abort==0
            abort=fAnalyseStack(aStack(k),aTimeInfo(k),Queue(1),0,aObjects);
        end
        if abort==0
            Queue(1)=[];
            fRightPanel('UpdateQueue','Local');
        end
        nQueue=length(Queue);
    end
    ReturnFocus;
catch ME   
    fMsgDlg({'FIESTA detected a problem during analysis','','Error message:','',getReport(ME,'extended','hyperlinks','off')},'error');
    delete(gcp);
end

function Molecule=AddDataMol(Molecule,Objects,nMol,nData,idx,k)
global Config;
if ~isempty(Molecule(nMol).Results) && isempty(nData)
    f=find(idx<Molecule(nMol).Results(:,1),1,'first');
    if ~isempty(f)
        n=size(Molecule(nMol).Results,1);
        nData=f;
        Molecule(nMol).Results(f+1:n+1,:)=Molecule(nMol).Results(f:n,:);
        Molecule(nMol).TrackingResults(f+1:n+1)=Molecule(nMol).TrackingResults(f:n);
    else
        nData=size(Molecule(nMol).Results,1)+1;
    end
end

Molecule(nMol).Results(nData,1) = single(idx);
Molecule(nMol).Results(nData,2) = Objects{idx}.time;
Molecule(nMol).Results(nData,3) = Objects{idx}.center_x(k);
Molecule(nMol).Results(nData,4) = Objects{idx}.center_y(k);
Molecule(nMol).Results(nData,5) = NaN;
Molecule(nMol).Results(nData,7) = Objects{idx}.width(1,k);
Molecule(nMol).Results(nData,8) = Objects{idx}.height(1,k);                
Molecule(nMol).Results(nData,9) = single(sqrt((Objects{idx}.com_x(2,k))^2+(Objects{idx}.com_y(2,k))^2));
Molecule(nMol).TrackingResults{nData} = [];
if size(Objects{idx}.data{k},2)==1
    Molecule(nMol).Results(nData,9:10) = Objects{idx}.data{k}';                
    Molecule(nMol).Results(nData,11) = single(mod(Objects{idx}.orientation(1,k),2*pi));                
    Molecule(nMol).Type = 'stretched';
    Molecule(nMol).Results(nData,12) = 0; 
elseif size(Objects{idx}.data{k},2)==3
    Molecule(nMol).Results(nData,9:11) = Objects{idx}.data{k}(1,:);                
    Molecule(nMol).Type = 'ring1';
    Molecule(nMol).Results(nData,12) = 0; 
else
    Molecule(nMol).Type = 'symmetric';
    Molecule(nMol).Results(nData,10) = 0; 
end
if Config.OnlyTrack.IncludeData == 1
    Molecule(nMol).TrackingResults{nData} = Objects{idx}.points{k};
else
    Molecule(nMol).TrackingResults{nData} = [];
end      

function Filament=AddDataFil(Filament,Objects,nFil,nData,idx,k)
global Config;
if ~isempty(Filament(nFil).Results) && isempty(nData)
    f=find(idx<Filament(nFil).Results(:,1),1);
    if ~isempty(f)
        n=size(Filament(nFil).Results,1);
        nData=f;
        Filament(nFil).Results(f+1:n+1,:) = Filament(nFil).Results(f:n,:);
        Filament(nFil).PosStart(f+1:n+1,:) = Filament(nFil).PosStart(f:n,:);
        Filament(nFil).PosCenter(f+1:n+1,:) = Filament(nFil).PosCenter(f:n,:);
        Filament(nFil).PosEnd(f+1:n+1,:) = Filament(nFil).PosEnd(f:n,:);
        Filament(nFil).Data(f+1:n+1) = Filament(nFil).Data(f:n);     
        Filament(nFil).TrackingResults(f+1:n+1)=Filament(nFil).TrackingResults(f:n);
    else
        nData = size(Filament(nFil).Results,1) + 1;
    end
end

Filament(nFil).Results(nData,1) = single(idx);
Filament(nFil).Results(nData,2) = Objects{idx}.time;
Filament(nFil).Results(nData,3) = Objects{idx}.center_x(k);
Filament(nFil).Results(nData,4) = Objects{idx}.center_y(k);
Filament(nFil).Results(nData,5) = NaN;
Filament(nFil).Results(nData,7) = Objects{idx}.length(1,k);
Filament(nFil).Results(nData,8) = Objects{idx}.height(1,k);                
Filament(nFil).Results(nData,9) = single( mod(Objects{idx}.orientation(1,k),2*pi) );
Filament(nFil).Results(nData,10) = 0;
Filament(nFil).Data{nData} = [Objects{idx}.data{k}(:,1:2) ones(size(Objects{idx}.data{k},1),1)*NaN Objects{idx}.data{k}(:,3:end)];
if Config.OnlyTrack.IncludeData == 1
    Filament(nFil).TrackingResults{nData} = Objects{idx}.points{k};
else
    Filament(nFil).TrackingResults{nData} = [];
end
if nData > 1
    if abs(Filament(nFil).Results(nData,8)-Filament(nFil).Results(nData-1,8)) > pi/2
       Filament(nFil).Data{nData} = flipud(Filament(nFil).Data{nData});
       Filament(nFil).Results(nData,8) = single( mod(Filament(nFil).Results(nData,8)+pi,2*pi) );
    end
elseif nData == 1 && size(Filament(nFil).Results,1) > 1
    if abs(Filament(nFil).Results(nData,8)-Filament(nFil).Results(nData+1,8))>pi/2
       Filament(nFil).Data{nData} = flipud(Filament(nFil).Data{nData});
       Filament(nFil).Results(nData,8) = single( mod(Filament(nFil).Results(nData,8)+pi,2*pi) );
    end
end

Filament(nFil).PosStart(nData,1:3) = Filament(nFil).Data{nData}(1,1:3);
Filament(nFil).PosCenter(nData,1:3) = Filament(nFil).Results(nData,3:5);
Filament(nFil).PosEnd(nData,1:3) = Filament(nFil).Data{nData}(end,1:3);
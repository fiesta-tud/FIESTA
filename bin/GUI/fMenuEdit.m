function fMenuEdit(func,varargin)
switch func
    case 'Find'
        Find(varargin{1});
    case 'FindNext'
        FindNext(varargin{1});   
    case 'Sort'
        Sort(varargin{1});
    case 'FindMoving'
        FindMoving(varargin{1});
    case 'FindReference'
        FindReference(varargin{1});        
    case 'Normalize'
        Normalize(varargin{1});        
    case 'Filter'
        Filter;   
    case 'ManualTracking'
        ManualTracking(varargin{1});
    case 'ReconnectStatic'
        ReconnectStatic;
    case 'Undo'
        Undo(varargin{1});
    case 'CombineTracks'
        CombineTracks;
    case 'DeleteSelectedTracks'
        DeleteSelectedTracks;
end

function Sort(mode)
global Molecule;
global Filament;
hMainGui = getappdata(0,'hMainGui');
if ~isempty(Molecule)
   Molecule = SortList(Molecule,mode);
end
if ~isempty(Filament)
   Filament = SortList(Filament,mode);
end
fRightPanel('UpdateList',hMainGui.RightPanel.pData.MolList,Molecule,hMainGui.RightPanel.pData.sMolList,hMainGui.Menu.ctListMol);
fRightPanel('UpdateList',hMainGui.RightPanel.pData.FilList,Filament,hMainGui.RightPanel.pData.sFilList,hMainGui.Menu.ctListFil);

function Object = SortList(Object,mode)
if strncmp(mode,'Length',6)
    len = zeros(1,length(Object));
    for n = 1:length(Object)
        len(n) = size(Object(n).Results,1);
    end
    if strcmp(mode(7:end),'S-L')
        [~,idx]=sort(len);
    else
        [~,idx]=sort(len,'descend');
    end

else
    name = cell(1,length(Object));
    for n = 1:length(Object)
        name{n} = Object(n).Name;
    end
    [~,idx]=sort(name);
    if strcmp(mode(5:end),'Z-A')
        idx = fliplr(idx);
    end
end
Object = Object(idx);

function CombineTracks
global Molecule;
global Filament;
hMainGui = getappdata(0,'hMainGui');
fBackUpData(hMainGui);
hMainGui.Values.PostSpecial = 'Parallax';
if strcmp(hMainGui.Values.PostSpecial,'Parallax')
    conv_fact = str2double(fInputDlg('Enter Parallax conversion factor:','1')); 
    if isnan(conv_fact)
        conv_fact = 1;
    end
    Channel = [Molecule.Channel];
    Selected = [Molecule.Selected];
    stidx = sort(unique([Molecule(Selected==1).Channel]));
    if any(Selected) && min(stidx)==1 && max(stidx)==2
        idx = cell(1,2);
        XY = cell(1,2);
        for m = 1:2
            idx{m} = find(Selected==1 & Channel==m);
            nMol = numel(idx{m});
            XY{m} = zeros(nMol,2);
            for n = 1:nMol
                XY{m}(n,:) = [mean(Molecule(idx{m}(n)).Results(:,3)) mean(Molecule(idx{m}(n)).Results(:,4))]/Molecule(idx{m}(n)).PixelSize;
            end
            if m>1
                pairs = matchReferencePoints(XY{1},XY{2});
            end
        end
        idx = [idx{1}(pairs(:,1))' idx{2}(pairs(:,2))'];
        MolSelect = zeros(1,length(Molecule));
        for n = 1:size(pairs,1)
            Z =[];
            for m = size(Molecule(idx(n,1)).Results(:,3),1):-1:1
                k = find(Molecule(idx(n,1)).Results(m,1)==Molecule(idx(n,2)).Results(:,1),1);
                if isempty(k)
                    Molecule(idx(n,1)).Results(m,:) = [];
                else
                    Z = [(Molecule(idx(n,1)).Results(m,4)-Molecule(idx(n,2)).Results(k,4))/2*conv_fact;Z];
                    Molecule(idx(n,1)).Results(m,:) = (Molecule(idx(n,1)).Results(m,:)+Molecule(idx(n,2)).Results(k,:))/2;
                end
            end
            Molecule(idx(n,1)).Results(:,5) = Z;
            if isempty(Molecule(idx(n,1)).Results)
                MolSelect(idx(n,1)) = 1;
            end
        end
        MolSelect(idx(:,2)) = 1;
        fShared('DeleteTracks',hMainGui,MolSelect,[]);
    end
    %Filament = fTransformCoord(Filament,0,0);
    Channel = [Filament.Channel];
    Selected = [Filament.Selected];
    if any(Selected) && min(stidx)==1 && max(stidx)==2
        idx = cell(1,2);
        XY = cell(1,2);
        for m = 1:2
            idx{m} = find(Selected==1 & Channel==m);
            nMol = numel(idx{m});
            XY{m} = zeros(nMol,2);
            for n = 1:nMol
                XY{m}(n,:) = [mean(Filament(idx{m}(n)).Results(:,3)) mean(Filament(idx{m}(n)).Results(:,4))]/Filament(idx{m}(n)).PixelSize;
            end
            if m>1
                pairs = matchReferencePoints(XY{1},XY{2});
            end
        end
        idx = [idx{1}(pairs(:,1))' idx{2}(pairs(:,2))'];
        FilSelect = zeros(1,length(Filament));
        for n = 1:size(idx,1)
            ZS =[];
            ZC =[];
            ZE =[];
            if all(Filament(idx(n,1)).Results(:,3)==Filament(idx(n,1)).PosStart(:,1))
                ref = 1;
            elseif all(Filament(idx(n,1)).Results(:,3)==Filament(idx(n,1)).PosCenter(:,1))
                ref = 2;
            else
                ref = 3;
            end
            for m = size(Filament(idx(n,1)).Results(:,3),1):-1:1
                k = find(Filament(idx(n,1)).Results(m,1)==Filament(idx(n,2)).Results(:,1),1);
                if isempty(k)
                    Filament(idx(n,1)).Results(m,:) = [];
                    Filament(idx(n,1)).Data(m) = [];
                    Filament(idx(n,1)).PosCenter(m,:) = [];
                    Filament(idx(n,1)).PosStart(m,:) = [];
                    Filament(idx(n,1)).PosEnd(m,:) = [];
                else
                    ZS = [(Filament(idx(n,1)).PosStart(m,4)-Filament(idx(n,2)).PosStart(k,4))/2*conv_fact;ZS];
                    ZC = [(Filament(idx(n,1)).PosCenter(m,4)-Filament(idx(n,2)).PosCenter(k,4))/2*conv_fact;ZC];
                    ZE = [(Filament(idx(n,1)).PosEnd(m,4)-Filament(idx(n,2)).PosEnd(k,4))/2*conv_fact;ZE];
                    Filament(idx(n,1)).Results(m,:) = (Filament(idx(n,1)).Results(m,:)+Filament(idx(n,2)).Results(k,:))/2;
                    Filament(idx(n,1)).PosStart(m,:) = (Filament(idx(n,1)).PosStart(m,:)+Filament(idx(n,2)).PosStart(m,:))/2;
                    Filament(idx(n,1)).PosCenter(m,:) = (Filament(idx(n,1)).PosCenter(m,:)+Filament(idx(n,2)).PosCenter(m,:))/2;
                    Filament(idx(n,1)).PosEnd(m,:) = (Filament(idx(n,1)).PosEnd(m,:)+Filament(idx(n,2)).PosEnd(m,:))/2;
                    X1 = Filament(idx(n,1)).Data{m}(:,1);
                    X2 = Filament(idx(n,2)).Data{k}(:,1);
                    Y1 = Filament(idx(n,1)).Data{m}(:,2);
                    Y2 = Filament(idx(n,2)).Data{k}(:,2);
                    if length(X1)>length(X2)
                        xi = linspace(1,length(X2),length(X1))';
                        X2 = interp1(X2,xi);
                        Y2 = interp1(Y2,xi);
                    elseif length(X2)>length(X1)
                        xi = linspace(1,length(X1),length(X2))';
                        X1 = interp1(X1,xi);
                        Y1 = interp1(Y1,xi);
                        Filament(idx(n,1)).Data{m}= Filament(idx(n,2)).Data{k};
                    end
                    Filament(idx(n,1)).Data{m}(:,1) = ( X1+X2 )/2;
                    Filament(idx(n,1)).Data{m}(:,2) = ( Y1+Y2 )/2;
                    Filament(idx(n,1)).Data{m}(:,3) = ( Y1-Y2 )/2*conv_fact;
                end
            end
            Filament(idx(n,1)).PosStart(:,3) = ZS;
            Filament(idx(n,1)).PosCenter(:,3) = ZC;
            Filament(idx(n,1)).PosEnd(:,3) = ZE;
            if ref == 1
                Filament(idx(n,1)).Results(:,3:5) = Filament(idx(n,1)).PosStart;
            elseif ref == 2
                Filament(idx(n,1)).Results(:,3:5) = Filament(idx(n,1)).PosCenter;
            else
                Filament(idx(n,1)).Results(:,3:5) = Filament(idx(n,1)).PosEnd;
            end
            Filament(idx(n,1)).Results(:,6) = fDis(Filament(idx(n,1)).Results(:,3:5));
            if isempty(Filament(idx(n,1)).Results)
                FilSelect(idx(n,1)) = 1;
            end
        end
        FilSelect(idx(:,2)) = 1;
        fShared('DeleteTracks',hMainGui,[],FilSelect);
    end
  %  set(hMainGui.Menu.mAlignChannels,'Checked','on');
    fShow('Tracks');
end

function DeleteSelectedTracks
hMainGui = getappdata(0,'hMainGui');
fBackUpData(hMainGui);
fShared('DeleteTracks',hMainGui,[],[]);

function Undo(hMainGui)
global Molecule;
global Filament;
global KymoTrackMol;
global KymoTrackFil;
global BackUp;
Molecule = BackUp.Molecule;
Filament = BackUp.Filament;
h = [KymoTrackFil.PlotHandles KymoTrackMol.PlotHandles]; 
delete(h(ishandle(h)));                                 
KymoTrackMol = BackUp.KymoTrackMol;
KymoTrackFil = BackUp.KymoTrackFil;
fRightPanel('UpdateList',hMainGui.RightPanel.pData.MolList,Molecule,hMainGui.RightPanel.pData.sMolList,hMainGui.Menu.ctListMol);
fRightPanel('UpdateList',hMainGui.RightPanel.pData.FilList,Filament,hMainGui.RightPanel.pData.sFilList,hMainGui.Menu.ctListFil);
set(hMainGui.Menu.mUndo,'Enable','off');
fShared('UpdateMenu',hMainGui);
fShared('ReturnFocus');
fRightPanel('UpdateKymoTracks',hMainGui);
fShow('Image');
fShow('Tracks');
if ~isempty(Molecule)||~isempty(Filament)
    set(hMainGui.MidPanel.pView,'Visible','on');
    set(hMainGui.MidPanel.pNoData,'Visible','off');
    set(hMainGui.MidPanel.tNoData,'String','No Stack or Tracks present','Visible','off');      
    drawnow expose
end

function Find(hMainGui)
global Molecule;
global Filament;
hMainGui.Search.String = fInputDlg('Find what:','');
hMainGui.Search.Mol=[];
hMainGui.Search.Fil=[];
nMol=length(Molecule);
nFil=length(Filament);
nSearchMol=1;
for i=1:nMol
    k=strfind(Molecule(i).Name,hMainGui.Search.String);
    if k>0
        hMainGui.Search.Mol(nSearchMol)=i;
        nSearchMol=nSearchMol+1;
    end
end
nSearchFil=1;
for i=1:nFil
    k=strfind(Filament(i).Name,hMainGui.Search.String);
    if k>0
        hMainGui.Search.Fil(nSearchFil)=i;
        nSearchFil=nSearchFil+1;
    end
end
hMainGui.Search.MolP=0;
hMainGui.Search.FilP=0;
if nSearchMol>1
    p=nMol-6-hMainGui.Search.Mol(1);
    if p<1
        p=1;
    end
    fMainGui('SelectObject',hMainGui,'Molecule',hMainGui.Search.Mol(1),'normal');
    getappdata(0,'hMainGui');
    set(hMainGui.RightPanel.pData.sMolList,'Value',p)
    fRightPanel('DataPanel',hMainGui);
    fRightPanel('DataMoleculesPanel',hMainGui);
    hMainGui.Search.MolP=1;
else
    if nSearchFil>1
        p=nFil-6-hMainGui.Search.Fil(1);
        if p<1
            p=1;
        end
        fMainGui('SelectObject',hMainGui,'Filament',hMainGui.Search.Fil(1),'normal');     
        getappdata(0,'hMainGui');        
        set(hMainGui.RightPanel.pData.sFilList,'Value',p)
        fRightPanel('DataPanel',hMainGui);
        fRightPanel('DataFilamentsPanel',hMainGui);
        hMainGui.Search.FilP=1;
    end
end
if nSearchMol+nSearchFil>3
    set(hMainGui.Menu.mFindNext,'Enable','on');
else    
    set(hMainGui.Menu.mFindNext,'Enable','off');
end
setappdata(0,'hMainGui',hMainGui);
fRightPanel('UpdateList',hMainGui.RightPanel.pData.MolList,Molecule,hMainGui.RightPanel.pData.sMolList,hMainGui.Menu.ctListMol);
fRightPanel('UpdateList',hMainGui.RightPanel.pData.FilList,Filament,hMainGui.RightPanel.pData.sFilList,hMainGui.Menu.ctListFil);

function FindNext(hMainGui)
global Molecule;
global Filament;
nMol=length(Molecule);
nFil=length(Filament);
nSearchMol=length(hMainGui.Search.Mol);
nSearchFil=length(hMainGui.Search.Fil);
if nSearchMol>hMainGui.Search.MolP
    p=nMol-6-hMainGui.Search.Mol(hMainGui.Search.MolP+1);
    if p<1
        p=1;
    end
    fMainGui('SelectObject',hMainGui,'Molecule',hMainGui.Search.Mol(hMainGui.Search.MolP+1),'normal');
    getappdata(0,'hMainGui');
    set(hMainGui.RightPanel.pData.sMolList,'Value',p)
    fRightPanel('DataPanel',hMainGui);
    fRightPanel('DataMoleculesPanel',hMainGui);    
    hMainGui.Search.MolP=hMainGui.Search.MolP+1;
else
    if nSearchFil>hMainGui.Search.FilP
        p=nFil-6-hMainGui.Search.Fil(hMainGui.Search.FilP+1);
        if p<1
            p=1;
        end
        fMainGui('SelectObject',hMainGui,'Filament',hMainGui.Search.Fil(hMainGui.Search.FilP+1),'normal');     
        getappdata(0,'hMainGui');            
        set(hMainGui.RightPanel.pData.sFilList,'Value',p)
        fRightPanel('DataPanel',hMainGui);
        fRightPanel('DataFilamentsPanel',hMainGui);        
        hMainGui.Search.FilP=hMainGui.Search.FilP+1;
    end
end
if hMainGui.Search.MolP+hMainGui.Search.FilP==nSearchMol+nSearchFil
    set(hMainGui.Menu.mFindNext,'Enable','off');
end
setappdata(0,'hMainGui',hMainGui);
%fRightPanel('UpdateList',hMainGui.RightPanel.pData.MolList,Molecule,hMainGui.RightPanel.pData.sMolList,hMainGui.Menu.ctListMol);
%fRightPanel('UpdateList',hMainGui.RightPanel.pData.FilList,Filament,hMainGui.RightPanel.pData.sFilList,hMainGui.Menu.ctListFil);

function FindMoving(hMainGui)
global Molecule;
global KymoTrackMol;
global Filament;
global KymoTrackFil;
mode=get(gcbo,'UserData');
nMol=length(Molecule);
nFil=length(Filament);
nDataMol=zeros(nMol,1);
nDisMol=zeros(nMol,1);
for i=1:nMol
    nDataMol(i)=size(Molecule(i).Results,1);
    nDisMol(i)=norm([Molecule(i).Results(nDataMol(i),3)-Molecule(i).Results(1,3) Molecule(i).Results(nDataMol(i),4)-Molecule(i).Results(1,4)]);
end
nDataFil=zeros(nFil,1);
nDisFil=zeros(nFil,1);
for i=1:nFil
    nDataFil(i)=size(Filament(i).Results,1);
    nDisFil(i)=norm([Filament(i).Results(nDataFil(i),3)-Filament(i).Results(1,3) Filament(i).Results(nDataFil(i),4)-Filament(i).Results(1,4)]);
end
if strcmp(mode,'moving') 
    answer = fInputDlg({'Enter minmum distance in nm:','Minimum number of frames'},{'100',num2str(round(max([max(nDataMol) max(nDataFil)])*0.9))});
else
    answer = fInputDlg({'Enter maxium distance in nm:','Minimum number of frames'},{'100',num2str(round(max([max(nDataMol) max(nDataFil)])*0.9))});
end
if ~isempty(answer)
    Dis = str2double(answer{1});
    mFrame = str2double(answer{2});
    for i=1:nMol
        if strcmp(mode,'moving')
            if nDisMol(i)>=Dis && nDataMol(i)>=mFrame
                Molecule(i) = fShared('SelectOne',Molecule(i),KymoTrackMol,i,1);
            else
                Molecule(i) = fShared('SelectOne',Molecule(i),KymoTrackMol,i,0);
            end
        else
            if nDisMol(i)<=Dis && nDataMol(i)>=mFrame
                Molecule(i) = fShared('SelectOne',Molecule(i),KymoTrackMol,i,1);
            else
                Molecule(i) = fShared('SelectOne',Molecule(i),KymoTrackMol,i,0);
            end
        end
    end
    for i=1:nFil
        if strcmp(mode,'moving')
            if nDisFil(i)>=Dis && nDataFil(i)>=mFrame
                Filament(i) = fShared('SelectOne',Filament(i),KymoTrackFil,i,1);
            else
                Filament(i) = fShared('SelectOne',Filament(i),KymoTrackFil,i,0);
            end
        else
            if nDisFil(i)<=Dis && nDataFil(i)>=mFrame
                Filament(i) = fShared('SelectOne',Filament(i),KymoTrackFil,i,1);
            else
                Filament(i) = fShared('SelectOne',Filament(i),KymoTrackFil,i,0);
            end
        end
    end            
    fRightPanel('UpdateList',hMainGui.RightPanel.pData.MolList,Molecule,hMainGui.RightPanel.pData.sMolList,hMainGui.Menu.ctListMol);
    fRightPanel('UpdateList',hMainGui.RightPanel.pData.FilList,Filament,hMainGui.RightPanel.pData.sFilList,hMainGui.Menu.ctListFil);
    setappdata(0,'hMainGui',hMainGui);
    fShow('Image');
end

function FindReference(hMainGui)
global Molecule;
global KymoTrackMol;
nMol = length(Molecule);
minFrame = zeros(1,nMol);
maxFrame = zeros(1,nMol);
numFrames = zeros(1,nMol);
Ch = [Molecule.Channel];
for n = 1:nMol
    minFrame(n) = Molecule(n).Results(1,1);
    maxFrame(n) = Molecule(n).Results(end,1);
    numFrames(n) = size(Molecule(n).Results,1);
end
NumDriftMol = str2double(fInputDlg('Enter number of molecules:','5'));
if ~isempty(NumDriftMol)
    R = cell(1,max(Ch));
    XY = cell(1,max(Ch));
    idx = cell(1,max(Ch));
    sidx = cell(1,max(Ch));
    gR = NaN;
    for n = unique(Ch)
        frames = 1:max(maxFrame(Ch==n));
        idx{n} = find(Ch==n & minFrame==1 & maxFrame>0.9*frames(end));
        cX = zeros(numel(frames),numel(idx{n}));
        cY = zeros(numel(frames),numel(idx{n}));
        nMol = numel(idx{n});
        XY{n} = zeros(nMol,2); 
        for m = 1:nMol
            if numel(frames)>1
                cX(:,m) = interp1(Molecule(idx{n}(m)).Results(:,1),Molecule(idx{n}(m)).Results(:,3),frames,'linear','extrap');
                cY(:,m) = interp1(Molecule(idx{n}(m)).Results(:,1),Molecule(idx{n}(m)).Results(:,4),frames,'linear','extrap');
            end
            XY{n}(m,:) = [mean(Molecule(idx{n}(m)).Results(:,3)) mean(Molecule(idx{n}(m)).Results(:,4))]/Molecule(idx{n}(m)).PixelSize;
        end
        %c = perms(1:numel(idx{n}));
        if numel(frames)>1
            R{n} = sum(0.5*corrcoef(cX)+0.5*corrcoef(cY))/numel(idx{n});
        else
            R{n} = ones(1,numel(idx{n}));
        end
        if ~isempty(XY{1})
            if n==1
                midx = zeros(numel(idx{1}),numel(idx));
                midx(:,1) = 1:numel(idx{1});
                gR = R{1};
            else
                pairs = matchReferencePoints(XY{n},XY{1});
                if isempty(pairs)
                    gR(:) = NaN;
                else
                    k = ismember(midx(:,1),pairs(:,2));
                    midx(k,n) = pairs(:,1);
                    gR(k) = gR(k) + R{n}(pairs(:,1));
                    gR(~k) = NaN;
                end
            end
        end
    end
    if all(isnan(gR))
        for n = unique(Ch)
            [~,k] = sort(R{n});
            sidx{n} = idx{n}(k);
            if numel(sidx{n})>NumDriftMol
                sidx{n}(NumDriftMol+1:end) = [];
            end
        end
        fMsgDlg({'Could not match enough reference molecules, please check whether there are enough molecules in each channel that have been tracked and connected properly.','',...
                ['Only selected the ' num2str(NumDriftMol) ' most similiar molecules per channel (if possible).']},'warn');
    else
        k = isnan(gR);
        gR(k) = [];
        midx(k,:) = [];
        [~,k] = sort(gR,'descend');
        for n = 1:max(Ch)
            sidx{n} = idx{n}(midx(k,n));
            if numel(sidx{n})>NumDriftMol
                sidx{n}(NumDriftMol+1:end) = [];
            end    
        end
        if numel(gR)<NumDriftMol
            fMsgDlg({'Could not match enough reference molecules, please check whether there are enough molecules in each channel that have been tracked and connected properly.','',...
                ['Only selected the ' num2str(numel(gR)) ' most similiar molecules that could be matched.']},'warn');
        end
    end
    for n = k
        Molecule(n)=fShared('SelectOne',Molecule(n),KymoTrackMol,n,0);
    end
    for n = cell2mat(sidx)
        Molecule(n)=fShared('SelectOne',Molecule(n),KymoTrackMol,n,1);
    end
    fRightPanel('UpdateList',hMainGui.RightPanel.pData.MolList,Molecule,hMainGui.RightPanel.pData.sMolList,hMainGui.Menu.ctListMol);
    setappdata(0,'hMainGui',hMainGui);
end

function [cObj,tObj] = FindSpots(X,F,nPoints)
[class,~]=dbscan(X,nPoints-1,1);
p=1;
cObj=[];
tObj=[];
for n=1:max(class)
    cX=X(class==n,:);
    cF=F(class==n,:);
    if size(cX,1)>=nPoints
        try
            gm = gmdistribution.fit(cX,1);
        catch
            continue;
        end
    else
        continue;
    end
    [~,~,s] = pcacov(gm.Sigma);
    if max(s) > 80 && size(cX,1)>=2*nPoints
        try
            gm2 = gmdistribution.fit(cX,2);
            if gm.NlogL>gm2.NlogL && gm2.NlogL>0
                LogL = gm2.NlogL/gm.NlogL;  
            else
                LogL = gm.NlogL/gm2.NlogL;   
            end
        catch
            LogL = Inf;
        end
    else
        LogL = Inf;
    end
    if LogL > 0.5
        cObj(p,:) = [mean(cX(:,1)) mean(cX(:,2)) max(sqrt( (cX(:,1)-mean(cX(:,1))).^2+(cX(:,2)-mean(cX(:,2))).^2))];
        tObj{p} = cF;
        p=p+1;
    else
        hX = cX;
        hF = cF;
        idx = cluster(gm2,hX);
        for n=1:2
            cX=hX(idx==n,:);
            cF=hF(idx==n,:);
            if size(cX,1)>=nPoints
                cObj(p,:) = [mean(cX(:,1)) mean(cX(:,2)) max(sqrt( (cX(:,1)-mean(cX(:,1))).^2+(cX(:,2)-mean(cX(:,2))).^2))];
                tObj{p} = cF;
                p=p+1;
            end
        end
        
    end
end

function [cObj,tObj] = DisregardSpots(cObj,tObj)
[cObj,idx] = sortrows(cObj,3);
tObj = tObj(idx);
for n = size(cObj,1):-1:2
    r = cObj(1:n-1,3);
    R = cObj(n,3);
    d = sqrt( (cObj(1:n-1,1)-cObj(n,1)).^2 + (cObj(1:n-1,2)-cObj(n,2)).^2 );
    if any(d<r+R)
        cObj(n,:)=[];
        tObj(n)=[];
    end
end

function ReconnectStatic
global Molecule;
global Objects;
global Config;
tObj =[];
hMainGui=getappdata(0,'hMainGui');
setappdata(0,'hMainGui',hMainGui);
XM = [];
FI =[];
nPoints = str2double(fInputDlg('Minimum number of frames per object:','5'));
set(hMainGui.fig,'Pointer','watch'); 
for n = 1:length(Objects)
    if isfield(Objects{n},'length')
        k = find(Objects{n}.length(1,:) == 0);
        if ~isempty(k)
            XM = [XM; double(Objects{n}.center_x(k)')/hMainGui.Values.PixSize double(Objects{n}.center_y(k)')/hMainGui.Values.PixSize];
            FI = [FI; ones(length(k),1)*n k'];
        end
    end
end
if ~isempty(XM)
    [cObj,tObj] = FindSpots(XM,FI,nPoints);
    [~,tObj] = DisregardSpots(cObj,tObj);  
end
if ~isempty(tObj)
    Molecule=[];
    Molecule=fDefStructure(Molecule,'Molecule');
    nMolTrack=length(tObj);
    frame_idx = getFrameIdx(hMainGui);
    nCh = frame_idx(1);
    for n=1:nMolTrack
        nData=size(tObj{n},1);
        Molecule(n).Name = ['Molecule ' num2str(n)];
        Molecule(n).File = Config.StackName;
        Molecule(n).Comments = '';

        Molecule(n).Selected = 0;
        Molecule(n).Visible = 1;    
        Molecule(n).Drift = 0;   
        Molecule(n).Channel=nCh(1);
        Molecule(n).TformMat=hMainGui.Values.TformChannel{nCh(1)};
        Molecule(n).PixelSize = Config.PixSize;    

        Molecule(n).Color = [0 0 1];

        for j = 1:nData
            f = tObj{n}(j,1);
            m = tObj{n}(j,2);

            Molecule(n).Results(j,1) = single(f);
            Molecule(n).Results(j,2) = Objects{f}.time;
            Molecule(n).Results(j,3) = Objects{f}.center_x(m);
            Molecule(n).Results(j,4) = Objects{f}.center_y(m);
            Molecule(n).Results(j,5) = NaN;
            Molecule(n).Results(j,7) = Objects{f}.width(1,m);
            Molecule(n).Results(j,8) = Objects{f}.height(1,m);                
            Molecule(n).Results(j,9) = single(sqrt((Objects{f}.com_x(2,m))^2+(Objects{f}.com_y(2,m))^2));
            if size(Objects{f}.data{m},2)==1
                Molecule(n).Results(j,9:10) = Objects{f}.data{m}';                
                Molecule(n).Results(j,11) = single(mod(Objects{f}.orientation(1,m),2*pi));                
                Molecule(n).Type = 'stretched';
                Molecule(n).Results(j,12) = 0; 
            elseif size(Objects{f}.data{m},2)==3
                Molecule(n).Results(j,9:11) = Objects{f}.data{m}(1,:);                
                Molecule(n).Type = 'ring1';
                Molecule(n).Results(j,12) = 0; 
            else
                Molecule(n).Type = 'symmetric';
                Molecule(n).Results(j,10) = 0; 
            end
            if Config.OnlyTrack.IncludeData == 1
                Molecule(n).TrackingResults{j} = Objects{f}.points{m};
            else
                Molecule(n).TrackingResults{j} = [];
            end  
        end
        Molecule(n).Results(:,6) = fDis(Molecule(n).Results(:,3:5));
    end
    fRightPanel('UpdateList',hMainGui.RightPanel.pData.MolList,Molecule,hMainGui.RightPanel.pData.sMolList,hMainGui.Menu.ctListMol);
    fRightPanel('UpdateKymoTracks',hMainGui);
    fShow('Image');
    fShow('Tracks');
    set(hMainGui.fig,'Pointer','arrow'); 
end

function ReTrack=GetReTrack(Object,molecule,ReconnectObj)
global Stack;
ReTrack = repmat(struct('Data',{},'Idx',[]), 1, length(Stack));
if isempty(Object)
    return;
end
mX=ReconnectObj(:,1);
mY=ReconnectObj(:,2);
for n=1:length(Stack)
    p=1;
    for m=1:length(Object)
        if~any(Object(m).Results(:,1)==n)
            if molecule
                ReTrack(n).Data{p}=[mX(m) mY(m)];
            else
                [~,t]=min(abs(Object(m).Results(:,1)-n));
                ReTrack(n).Data{p}=Object(m).Data{t}(:,1:2);
            end
            ReTrack(n).Idx(p)=m;
            p=p+1;
        end
    end
end

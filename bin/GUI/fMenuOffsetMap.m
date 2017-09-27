function fMenuOffsetMap(func,varargin)
switch func
    case 'AddTo'
        AddTo(varargin{1});
    case 'Clear'
        Clear;
    case 'Load'
        Load(varargin{1});
    case 'Save'
        Save(varargin{1});    
    case 'Correct'
        Correct(varargin{1});          
    case 'Show'
        Show;          
    case 'AlignCheck'
        AlignCheck;
    case 'CreateOffsetMap'
        CreateOffsetMap;
    case 'Apply'
        ApplyOffset;
end

function AlignCheck
global Molecule;
global Filament;
if strcmp(get(gcbo,'Checked'),'on')==1
    set(gcbo,'Checked','off');
    mode = 1;
else
    set(gcbo,'Checked','on');
    mode = 0;
end
Molecule = fTransformCoord(Molecule,mode,0);
Filament = fTransformCoord(Filament,mode,1);
fShow('Image');
fShow('Tracks');

function CreateOffsetMap
global Molecule;
global Filament;
hMainGui = getappdata(0,'hMainGui');
set(hMainGui.Menu.mAlignChannels,'Checked','off');
Molecule = fTransformCoord(Molecule,1,0);
Filament = fTransformCoord(Filament,1,1);
fShared('UpdateMenu',hMainGui);        
fShow('Image');
fShow('Tracks');
Channel = [Molecule.Channel];
for n = 1:max(Channel)
    k = find(Channel==n);
    for m = 1:length(k)
        X = mean(Molecule(k(m)).Results(:,3)/Molecule(k(m)).PixelSize);
        Y = mean(Molecule(k(m)).Results(:,4)/Molecule(k(m)).PixelSize);
        points{n}(m,:) = double([X Y]);
    end
    if n>1
        Selected = [Molecule.Selected];
        if any(Selected==1)
            hpoints = zeros(size(points{n}));
            k_select = find(Selected==1);
            idx1 = find(Channel(k_select)==1,1,'first');
            idx2 = find(Channel(k_select)==n,1,'first');
            dx = mean(Molecule(k_select(idx2)).Results(:,3)/Molecule(k_select(idx2)).PixelSize)-mean(Molecule(k_select(idx1)).Results(:,3)/Molecule(k_select(idx1)).PixelSize);
            dy = mean(Molecule(k_select(idx2)).Results(:,4)/Molecule(k_select(idx2)).PixelSize)-mean(Molecule(k_select(idx1)).Results(:,4)/Molecule(k_select(idx1)).PixelSize);
            hpoints(:,1) = points{n}(:,1)-dx;
            hpoints(:,2) = points{n}(:,2)-dy;
            [nidx,D] = knnsearch(hpoints,points{1});
        else
            [nidx,D] = knnsearch(points{n},points{1});
        end
        idx = 1:size(points{1},1);
        [m,k] = min(D);
        sD = sort(D);
        id = min([5 length(sD)]);
        md = max([median(D) sD(id)]);
        nm = 0;
        p = 1;
        ref = [];
        dist = [];
        while ~isempty(m) && (m<=md || m<mean(nm)+5*std(nm)) 
            ref(p,:) = [points{1}(idx(k),1) points{1}(idx(k),2)];
            dist(p,:) = [points{n}(nidx(k),1) points{n}(nidx(k),2)];
            idx(k) = [];
            nidx(k) = [];
            D(k) = [];
            nm(p) = m;
            [m,k] = min(D);
            p = p+1;
        end
        T = estimateGeometricTransform(dist,ref,'similarity');
        hMainGui.Values.TformChannel{n}(:,1:2) = T.T(:,1:2);
        OffsetMap(n-1).Match = [ref dist];
        OffsetMap(n-1).T = T.T;
    end
end
setappdata(hMainGui.fig,'OffsetMap',OffsetMap);
set(hMainGui.Menu.mAlignChannels,'Enable','on');
setappdata(0,'hMainGui',hMainGui);
if strcmp(get(hMainGui.Menu.mShowOffsetMap,'Checked'),'on')
    fShow('OffsetMap',hMainGui);  
end
fShared('UpdateMenu',hMainGui);

function ApplyOffset
global Molecule;
global Filament;
hMainGui = getappdata(0,'hMainGui');
set(hMainGui.Menu.mAlignChannels,'Checked','off');
Molecule = fTransformCoord(Molecule,1,0);
Filament = fTransformCoord(Filament,1,1);
fShared('UpdateMenu',hMainGui);        
fShow('Image');
fShow('Tracks');
for n = 1:length(Molecule)
    c = Molecule(n).Channel;
    Molecule(n).TformMat = hMainGui.Values.TformChannel{c};
    Molecule(n).TformMat(3,3) = 1;
end
for n = 1:length(Filament)
    c = Filament(n).Channel;
    Filament(n).TformMat = hMainGui.Values.TformChannel{c};   
    Filament(n).TformMat(3,3) = 1;
end

function Show
hMainGui = getappdata(0,'hMainGui');
if strcmp(get(hMainGui.Menu.mShowOffsetMap,'Checked'),'on')
    set(hMainGui.Menu.mShowOffsetMap,'Checked','Off');
    delete(findobj('Tag','pOffset'));
else
    set(hMainGui.Menu.mShowOffsetMap,'Checked','On');
    fShow('OffsetMap',hMainGui);  
end

function Clear
global Molecule;
global Filament;
hMainGui = getappdata(0,'hMainGui');
set(hMainGui.Menu.mAlignChannels,'Checked','off');
Molecule = fTransformCoord(Molecule,1,0);
Filament = fTransformCoord(Filament,1,1);
setappdata(hMainGui.fig,'OffsetMap',[]);
fShared('UpdateMenu',hMainGui);        
fShow('Image');
fShow('Tracks');

function Load(hMainGui)
fRightPanel('CheckOffset',hMainGui);
[FileName, PathName] = uigetfile({'*.mat','FIESTA Offset Map(*.mat)'},'Load FIESTA Offset Map',fShared('GetLoadDir'));
if FileName~=0
    fShared('SetLoadDir',PathName);
    OffsetMap=fLoad([PathName FileName],'OffsetMap');
    for n = 1:length(OffsetMap)
        hMainGui.Values.TformChannel{n+1} = OffsetMap(n).T;
    end
    setappdata(hMainGui.fig,'OffsetMap',OffsetMap);
    set(hMainGui.Menu.mAlignChannels,'Enable','on');
    if strcmp(get(hMainGui.Menu.mShowOffsetMap,'Checked'),'on')
        fShow('OffsetMap',hMainGui);    
    end
    fShared('UpdateMenu',hMainGui);
end
setappdata(0,'hMainGui',hMainGui);

function Save(hMainGui)
OffsetMap=getappdata(hMainGui.fig,'OffsetMap'); %#ok<NASGU>
[FileName, PathName] = uiputfile({'*.mat','MAT-files (*.mat)'},'Save FIESTA Offset Map',fShared('GetSaveDir'));
if FileName~=0
    fShared('SetSaveDir',PathName);
    file = [PathName FileName];
    if isempty(findstr('.mat',file))
        file = [file '.mat'];
    end
    save(file,'OffsetMap');
end

function newData = CalcNewPos(data,Coeff)
newData(:,1)=data(:,1) * Coeff(1) + data(:,2) * Coeff(2) + Coeff(5);
newData(:,2)=data(:,1) * Coeff(3) + data(:,2) * Coeff(4) + Coeff(6);

function Correct(hMainGui)
global Molecule;
global Filament;
OffsetMap=getappdata(hMainGui.fig,'OffsetMap');
if ~isempty(OffsetMap.Match)
    m=size(OffsetMap.Match,1)*2;
    A=zeros(m,6);
    B=zeros(m,1);
    if strcmp(get(gcbo,'UserData'),'GreenRed')
        A(1:2:m,1:2)=OffsetMap.Match(:,3:4);
        A(2:2:m,3:4)=OffsetMap.Match(:,3:4);    
        B(1:2:m)=OffsetMap.Match(:,1);
        B(2:2:m)=OffsetMap.Match(:,2);
    else
        A(1:2:m,1:2)=OffsetMap.Match(:,1:2);
        A(2:2:m,3:4)=OffsetMap.Match(:,1:2);    
        B(1:2:m)=OffsetMap.Match(:,3);
        B(2:2:m)=OffsetMap.Match(:,4);
    end
    A(1:2:m,5)=1;
    A(2:2:m,6)=1;        
    Coeff=A\B;
    k = find([Molecule.Selected]==1);
    for n = k
        Molecule(n).Results(:,3:4) = CalcNewPos(Molecule(n).Results(:,3:4),Coeff);
    end
    k = find([Filament.Selected]==1);
    for n = k
        Filament(n).Results(:,3:4) = CalcNewPos(Filament(n).Results(:,3:4),Coeff);
        Filament(n).PosStart = CalcNewPos(Filament(n).PosStart,Coeff);
        Filament(n).PosCenter = CalcNewPos(Filament(n).PosCenter,Coeff);
        Filament(n).PosEnd = CalcNewPos(Filament(n).PosEnd,Coeff);
        for m = 1:length(Filament(n).Data)
            Filament(n).Data{m}(:,1:2) =  CalcNewPos(Filament(n).Data{m}(:,1:2),Coeff);
        end
    end
    fShow('Marker',hMainGui,hMainGui.Values.FrameIdx);
    fShow('Tracks');
end
function cObj = fMenuStatistics(func,varargin)
cObj =[];
switch func
    case 'MSD'
        MSD;
    case 'AverageFilament'
        AverageFilament;   
    case 'CountObjects'
        cObj = CountObjects(varargin{1});
    case 'AlignFilament'
        AlignFilament;
end

function AlignFilament
global Molecule
global Filament
nFil = length(Filament);
[XPosFil,YPosFil,FrameFil,~]=InterpolFil(Filament);
SwitchFil=zeros(1,nFil);
hMainGui=getappdata(0,'hMainGui');
h=progressdlg('String','Aligning Filaments','Min',0,'Max',length(Molecule),'Parent',hMainGui.fig,'Cancel','on');
for n = 1:length(Molecule)
    s = zeros(nFil,1);
    for m = 1:nFil
        [~,~,~,Side] = FilamentPath(Molecule(n).Results,XPosFil(m,:),YPosFil(m,:),FrameFil{m},0,[]);
        s(m) = mean(abs(Side));
    end
    [~,k] = min(s);
    start_dis = sqrt( (Molecule(n).Results(1,3) - XPosFil{k}(1))^2 + (Molecule(n).Results(1,4) - YPosFil{k}(1))^2);
    end_dis = sqrt( (Molecule(n).Results(end,3) - XPosFil{k}(1))^2 + (Molecule(n).Results(end,4) - YPosFil{k}(1))^2);
    if start_dis>end_dis
        SwitchFil(k) = SwitchFil(k) + 1;
    else
        SwitchFil(k) = SwitchFil(k) - 1;
    end
    if isempty(h)
        return
    end
    h=progressdlg(n);
end
for n = 1:nFil
    if SwitchFil(n)>0
        Filament(n) = Switch(Filament(n));
    end
end

function Object=Switch(Object)
PosStart=Object.PosStart;
PosEnd=Object.PosEnd;
Orientation=Object.Results(:,9);
Object.Data{1}=flipud(Object.Data{1});
Orientation(1)=mod(Orientation(1)+pi,2*pi);
PosStart(1,:)=Object.PosEnd(1,:);
PosEnd(1,:)=Object.PosStart(1,:);    
if all(Object.PosStart==Object.Results(:,3:5))
    Object.Results(:,3:5)=PosStart;
elseif all(Object.PosEnd==Object.Results(:,3:5))
    Object.Results(:,3:5)=PosEnd;
end
Object.PosStart=PosStart;
Object.PosEnd=PosEnd;    
Object.Results(:,9)=Orientation;   
Object.Results(:,6) = fDis(Object.Results(:,3:5));

function [xi,yi,fi,fL]=InterpolFil(Filament)
nFil = length(Filament);
hMainGui=getappdata(0,'hMainGui');
progressdlg('String','Interpolating Filaments','Min',0,'Max',nFil,'Parent',hMainGui.fig,'Cancel','on');
fi = cell(nFil,1);
fL = cell(nFil,1);
for n = 1:nFil
    for m = 1:length(Filament(n).Data)
        X = Filament(n).Data{m}(:,1);
        Y = Filament(n).Data{m}(:,2);
        P = 1:length(X);
        pi = 1:0.01:length(X);
        xi{n,m} = interp1(P,X,pi); %#ok<AGROW>
        yi{n,m} = interp1(P,Y,pi); %#ok<AGROW>
    end
    fi{n} = Filament(n).Results(:,1);
    fL{n} = Filament(n).Results(:,7);
    h=progressdlg(n);
    if isempty(h)
        return
    end 
end

function [PathX,PathY,Dis,Side]=FilamentPath(Results,xi,yi,frames,GetDis,LengthFil)
nData = size(Results,1);
PathX = zeros(1,nData);
PathY = zeros(1,nData);
Dis = zeros(1,nData);
Side = zeros(1,nData);
for n = 1:size(Results,1)
    [~,k] = min(abs(Results(n,1)-frames));
    idx = k(1);
    X = xi{idx};
    Y = yi{idx};
    [m_dis,k] = min(sqrt( (Results(n,3)-X).^2+ (Results(n,4)-Y).^2));
    k = k(1);
    Side(n) = -m_dis*sum(sign(cross([X(k)-X(1) Y(k)-Y(1) 0],[Results(n,3)-X(k) Results(n,4)-Y(k) 0])));
    if Side(n) == 0
        Side(n) = m_dis;
    end
    if GetDis==1 
        L = LengthFil(idx);
        PathX(n) = X(k);
        PathY(n) = Y(k);
        if length(frames)>1
            if n>1
                Dis(n) = Dis(n-1) + norm([PathX(n)-PathX(n-1) PathY(n)-PathY(n-1)]);
            end
        else
            for m = 2:k
                Dis(n) = Dis(n) + norm([X(m)-X(m-1) Y(m)-Y(m-1)]);
            end
        end
        Dis(n) = Dis(n) + 1i*(L-Dis(n));
    end
end

function cObj = CountObjects(display)
global Objects;
cObj=cell(1,2);
hMainGui=getappdata(0,'hMainGui');
nCh = getChIdx;
hMainGui.Values.FrameIdx(nCh)=hMainGui.Values.FrameIdx(nCh)-4i;
setappdata(0,'hMainGui',hMainGui);
fShow('Image');
XF = [];
XM = [];
nPoints = str2double(fInputDlg('Minimum number of frames per object:','5'));
set(hMainGui.fig,'Pointer','watch'); 
for n = 1:length(Objects) 
    if isfield(Objects{n},'length') && ~isempty(Objects{n})
        k = Objects{n}.length(1,:) == 0;
        if any(k)
            XM = [XM; double(Objects{n}.center_x(k)')/hMainGui.Values.PixSize double(Objects{n}.center_y(k)')/hMainGui.Values.PixSize];
        end
        if any(~k)
            XF = [XF; Objects{n}.center_x(~k)'/hMainGui.Values.PixSize Objects{n}.center_y(~k)'/hMainGui.Values.PixSize];
        end
    end
end
if ~isempty(XM)
    cObj{1} = CountSpots(XM,nPoints);
    cObj{1} = DisregardSpots(cObj{1});
    if ~isempty(cObj{1})
        line(cObj{1}(:,1),cObj{1}(:,2),'LineStyle','none','Marker','+','Tag','pObjects','Color','r');
        h = viscircles([cObj{1}(:,1) cObj{1}(:,2)],cObj{1}(:,3),'DrawBackgroundCircle',false);
        set(h,'Tag','pObjects');
    end
end
if ~isempty(XF)
    cObj{2} = CountSpots(XM,nPoints);
    cObj{2} = DisregardSpots(cObj{2});
    if ~isempty(cObj{2})
        line(cObj{2}(:,1),cObj{2}(:,2),'LineStyle','none','Marker','x','Tag','pObjects','Color','r');
        h = viscircles([cObj{2}(:,1) cObj{2}(:,2)],cObj{2}(:,3),'DrawBackgroundCircle',false,'LineStyle',':');
        set(h,'Tag','pObjects');
    end
end
set(hMainGui.fig,'Pointer','arrow'); 
if display
    fMsgDlg({['Found Molecules: ' num2str(size(cObj{1},1))],['Found Filaments: ' num2str(size(cObj{2},1))]},'');
end

function cObj = DisregardSpots(cObj)
cObj = sortrows(cObj,3);
for n = size(cObj,1):-1:2
    r = cObj(1:n-1,3);
    R = cObj(n,3);
    d = sqrt( (cObj(1:n-1,1)-cObj(n,1)).^2 + (cObj(1:n-1,2)-cObj(n,2)).^2 );
    if any(d<r+R)
        cObj(n,:)=[];
    end
end


function cObj = CountSpots(X,nPoints)
[class,~]=dbscan(X,nPoints-1,1);
p=1;
cObj=[];
for n=1:max(class)
    cX=X(class==n,:);
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
        p=p+1;
    else
        hX = cX;
        idx = cluster(gm2,hX);
        for n=1:2
            cX=hX(idx==n,:);
            if size(cX,1)>=nPoints
                cObj(p,:) = [mean(cX(:,1)) mean(cX(:,2)) max(sqrt( (cX(:,1)-mean(cX(:,1))).^2+(cX(:,2)-mean(cX(:,2))).^2))];
                p=p+1;
            end
        end
        
    end
end


function AverageFilament
global Filament;
Selected = [Filament.Selected];
if max(Selected)==0
    fMsgDlg('No Filaments selected!','error');
    return;
end
for m = find(Selected)
    nFrames = size(Filament(m).Results,1);
    nData = zeros(1,nFrames);
    for n =1:nFrames
        nData(n)=size(Filament(m).Data{n},1);
    end
    X = zeros(max(nData),nFrames);
    Y = zeros(max(nData),nFrames);
    D = zeros(max(nData),nFrames);
    W = zeros(max(nData),nFrames);
    H = zeros(max(nData),nFrames);
    B = zeros(max(nData),nFrames);
    %create average filament
    if min(nData)~=max(nData)
        %number of pixel positions per frame is different
        for n =1:nFrames
            if nData(n)~=max(nData);
                %interpolated to get the same number of pixel positions per frame
                new_vector = 1:(2*nData(n)-max(nData))/nData(n):nData(n);
                old_vector = 1:nData(n);
                X(:,n) = interp1(old_vector,Filament(m).Data{n}(:,1),new_vector);
                Y(:,n) = interp1(old_vector,Filament(m).Data{n}(:,2),new_vector);
                D(:,n) = interp1(old_vector,Filament(m).Data{n}(:,3),new_vector);
                W(:,n) = interp1(old_vector,Filament(m).Data{n}(:,4),new_vector);
                H(:,n) = interp1(old_vector,Filament(m).Data{n}(:,5),new_vector);
                B(:,n) = interp1(old_vector,Filament(m).Data{n}(:,6),new_vector);   
            else
                X(:,n) = Filament(m).Data{n}(:,1);
                Y(:,n) = Filament(m).Data{n}(:,2);
                D(:,n) = Filament(m).Data{n}(:,3);
                W(:,n) = Filament(m).Data{n}(:,4);
                H(:,n) = Filament(m).Data{n}(:,5);
                B(:,n) = Filament(m).Data{n}(:,6);
            end
        end
    else
        %number of pixel positions per frame is the same
        for n =1:nFrames
            X(:,n) = Filament(m).Data{n}(:,1);
            Y(:,n) = Filament(m).Data{n}(:,2);
            D(:,n) = Filament(m).Data{n}(:,3);
            W(:,n) = Filament(m).Data{n}(:,4);
            H(:,n) = Filament(m).Data{n}(:,5);
            B(:,n) = Filament(m).Data{n}(:,6);
        end
    end
    %average the filament pixel positions over all frames
    Filament(m).Data{1} = [mean(X,2) mean(Y,2) mean(D,2) mean(W,2) mean(H,2) mean(B,2)];  
    Filament(m).Data(2:end)=[];
    Filament(m).Results(2:end,:)=[];
    Filament(m).PosStart(2:end,:)=[];
    Filament(m).PosCenter(2:end,:)=[];
    Filament(m).PosEnd(2:end,:)=[];
    if ~isempty(Filament(m).PathData)
        Filament(m).PathData(2:end,:)=[];
    end
end

function [sd,tau] = CalcSD(Results,Dis,sd,tau)
%get frame numbers, time, X/Y position
F=Results(:,1);
T=Results(:,2);
X=Results(:,3);
Y=Results(:,4);    
%calculate square displacment and time difference with interpolated data
min_frame=min(F);
max_frame=max(F);
for k=1:fix(log2(max_frame-min_frame))
    if length(sd)<k
        %create cell for sd and tau if not existing
        sd{k}=[];
        tau{k}=[];
    end
    n=1;
    while F(n)+2^(k-1)<max_frame
        %check if datapoint was tracked 
        num_frame = find(F(n)+2^(k-1) == F, 1);
        if ~isempty(num_frame)
           %calculate square displacment
            if ~isempty(Dis) %1D
                sd{k}=[sd{k} ((Dis(num_frame)-Dis(n))/1000)^2];
            else %2D
                sd{k}=[sd{k} ((X(num_frame)-X(n))/1000)^2 + ((Y(num_frame)-Y(n))/1000)^2];
            end
            %calculate time difference
            tau{k}=[tau{k} T(num_frame)-T(n)];                
            n=num_frame;
        else
            n=n+1;
        end
    end
end

function MSD
global Molecule
global Filament
%check whether to use 1D or 2D mean square displacement
if isempty(Molecule) && isempty(Filament)
    return;
end
Selected = [ [Molecule.Selected] [Filament.Selected]];
if max(Selected)==0
    fMsgDlg('No Track selected!','error');
    return;
end
Mode =  fQuestDlg({'Do you want to calculate the','mean square displacement for all','selected tracks in one dimension or two?'},'Mean Square Displacement',{'1D','2D','Cancel'},'1D');
if ~strcmp(Mode,'Cancel') && ~isempty(Mode)
    %define variable for square displacment and time difference
    sd=[];
    tau=[];
    if ~isempty(Molecule)
        %for every selected molecule
        for n = find([Molecule.Selected]==1)
            if strcmp(Mode,'2D')
                Dis = []; 
            else
                if ~isempty(Molecule(n).PathData)
                    Dis = Molecule(n).PathData(:,3);
                else
                    fMsgDlg({'Some tracks have no path present.','Use ''Path Statistics'' to get path.'},'error');
                    return;
                end
            end
            [sd,tau] = CalcSD(Molecule(n).Results,Dis,sd,tau);
        end
    end
    if ~isempty(Filament)
        %for every selected filament
        for n = find([Filament.Selected]==1)
            if strcmp(Mode,'2D')
                Dis = []; 
            else
                if ~isempty(Filament(n).PathData)
                    Dis = Filament(n).PathData(:,3);
                else
                    fMsgDlg({'Some tracks have no path present.','Use ''Path Statistics'' to get path.'},'error');
                    return;
                end
            end
            %calculate square displacement
            [sd,tau] = CalcSD(Filament(n).Results,Dis,sd,tau);
        end
    end
    for m=1:length(sd)
        TimeVsMSD(m,1)=mean(tau{m});
        TimeVsMSD(m,2)=mean(sd{m});
        TimeVsMSD(m,3)=std(sd{m})/sqrt(length(sd{m}));
        TimeVsMSD(m,4)=length(sd{m});
    end
    [FileName, PathName, FilterIndex] = uiputfile({'*.mat','MAT-file (*.mat)';'*.txt','TXT-File (*.txt)'},'Save FIESTA Mean Square Displacement',fShared('GetSaveDir'));
    file = [PathName FileName];
    if FilterIndex==1
        fShared('SetSaveDir',PathName);
        if isempty(strfind(file,'.mat'))
            file = [file '.mat'];
        end
        save(file,'TimeVsMSD');
    elseif FilterIndex==2
        fShared('SetSaveDir',PathName);
        if isempty(strfind(file,'.txt'))
            file = [file '.txt'];
        end
        f = fopen(file,'w');
        fprintf(f,'Time[s]\tMSD[?m?]\tError(mean)\tN\n');
        fprintf(f,'%f\t%f\t%f\t%f\n',TimeVsMSD');
        fclose(f);
    end
end
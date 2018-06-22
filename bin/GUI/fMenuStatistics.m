function cObj = fMenuStatistics(func,varargin)
cObj =[];
switch func
    case 'DiffusionAnalysis'
        DiffusionAnalysis;
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
hMainGui.Values.FrameIdx(nCh)=-4i;
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
%[class,~]=dbscan(X,nPoints-1,1);
class = clusterdata(X,'criterion','distance','cutoff',1,'savememory','on','linkage','centroid');
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
            if nData(n)~=max(nData)
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
    Filament(m).Results(1,1:2) = [1 0]; % reset frame number and time
    Filament(m).Data(2:end)=[];
    Filament(m).Results(2:end,:)=[];
    Filament(m).PosStart(2:end,:)=[];
    Filament(m).PosCenter(2:end,:)=[];
    Filament(m).PosEnd(2:end,:)=[];
    if ~isempty(Filament(m).PathData)
        Filament(m).PathData(2:end,:)=[];
    end
end

function [sd_2D,sd_1D,tau] = CalcSD(Results,Dis,sd_2D,sd_1D,tau)
%get frame numbers, time, X/Y position
F=double(Results(:,1));
T=double(Results(:,2));
X=double(Results(:,3));
Y=double(Results(:,4));    
%calculate square displacment and time difference with interpolated data
min_frame=min(F);
max_frame=max(F);
for k=1:(max_frame-min_frame)
    if length(sd_2D)<k
        %create cell for sd and tau if not existing
        sd_2D{k}=[];
        tau{k}=[];
        if ~isempty(Dis)
            sd_1D{k}=[];
        end
    end
    n=1;
    while F(n)+k<=max_frame
        %check if datapoint was tracked 
        num_frame = find(F(n)+k == F, 1);
        if ~isempty(num_frame)
           %calculate square displacment
            if ~isempty(Dis) %1D
                sd_1D{k}=[sd_1D{k} ((Dis(num_frame)-Dis(n))/1000)^2];
            end
            sd_2D{k}=[sd_2D{k} ((X(num_frame)-X(n))/1000)^2 + ((Y(num_frame)-Y(n))/1000)^2];
            %calculate time difference
            tau{k}=[tau{k} T(num_frame)-T(n)];                
            n=num_frame;
        else
            n=n+1;
        end
    end
end

function DiffusionAnalysis
global Molecule
global Filament
if isempty(Molecule) && isempty(Filament)
    return;
end
Selected = [ [Molecule.Selected] [Filament.Selected]];
if max(Selected)==0
    fMsgDlg('No Track selected!','error');
    return;
end
Mode =  fQuestDlg({'Do you want to calculate the','diffusion coefficient?'},'Diffusion Analysis',{'CVE','MSD','Cancel'},'CVE');
if ~strcmp(Mode,'Cancel') && ~isempty(Mode)
    if strcmp(Mode,'CVE')
        MolSelect = find([Molecule.Selected]==1);
        FilSelect = find([Filament.Selected]==1);
        if ~isempty(MolSelect) && isempty(FilSelect)   
            DiffusionCVE(Molecule(MolSelect));
        elseif isempty(MolSelect) && ~isempty(FilSelect)   
            DiffusionCVE(Filament(FilSelect));
        else
            fMsgDlg('Select either Molecules or Filaments (not both)!','error');
            return;
        end
    else
        DiffusionMSD;
    end
end

function [IndD_2D,IndD_1D,nData] = CalcIndCVE(Object)
nObj = length(Object);
IndD_2D = zeros(1,nObj);
IndD_1D = zeros(1,nObj);
nData = zeros(1,nObj);
%parfor (n=1:nObj,Config.NumCores)
for n = 1:nObj
    nData(n) = size(Object(n).Results,1);
    F=double(Object(n).Results(:,1));
    T=double(Object(n).Results(:,2));
    X=double(Object(n).Results(:,3)/1000);
    Y=double(Object(n).Results(:,4)/1000);    
    idx1 = find(F(2:end)-F(1:end-1)==1);
    idx2 = find(F(2:end-1)-F(1:end-2)==1 & F(3:end)-F(2:end-1)==1);
    dT = T(2:end)-T(1:end-1);
    dX= X(2:end)-X(1:end-1);
    dY= Y(2:end)-Y(1:end-1);
    IndD_2D(n) = (mean(dX(idx1).^2)/(2*mean(dT(idx1)))+ mean(dX(idx2).*dX(idx2+1))/mean((dT(idx2)+dT(idx2+1))/2))/2+...
                 (mean(dY(idx1).^2)/(2*mean(dT(idx1)))+ mean(dY(idx2).*dY(idx2+1))/mean((dT(idx2)+dT(idx2+1))/2))/2; %according to Jens
    if ~isempty(Object(n).PathData)
        Dis = double(real(Object(n).PathData(:,4))/1000);
        dDis = Dis(2:end)-Dis(1:end-1);
        IndD_1D(n) = mean(dDis(idx1).^2)/(2*mean(dT(idx1)))+ mean(dDis(idx2).*dDis(idx2+1))/mean((dT(idx2)+dT(idx2+1))/2);
    end
end
if all(IndD_1D==0)
    IndD_1D = [];
end
IndD_2D(isnan(IndD_2D)) = 0;
IndD_1D(isnan(IndD_1D)) = 0;

function [D2D,D1D] = CalcGlobalCVE(Object)
nObj = length(Object);
F = NaN;
T = NaN;
X = NaN;
Y = NaN;
Dis = NaN;
for n = 1:nObj
    F=[F;double(Object(n).Results(:,1));NaN];
    T=[T;double(Object(n).Results(:,2));NaN];
    X=[X;double(Object(n).Results(:,3))/1000;NaN];
    Y=[Y;double(Object(n).Results(:,4))/1000;NaN];
    if ~isempty(Object(n).PathData)
        Dis = [Dis;double(real(Object(n).PathData(:,4))/1000);NaN];
    end
end
idx1 = find(F(2:end)-F(1:end-1)==1);
idx2 = find(F(2:end-1)-F(1:end-2)==1 & F(3:end)-F(2:end-1)==1);
dT = T(2:end)-T(1:end-1);
dX= X(2:end)-X(1:end-1);
dY= Y(2:end)-Y(1:end-1);
D2D = (mean(dX(idx1).^2)/(2*mean(dT(idx1)))+ mean(dX(idx2).*dX(idx2+1))/mean((dT(idx2)+dT(idx2+1))/2))/2+...
      (mean(dY(idx1).^2)/(2*mean(dT(idx1)))+ mean(dY(idx2).*dY(idx2+1))/mean((dT(idx2)+dT(idx2+1))/2))/2;
if length(Dis)>1
    dDis = Dis(2:end)-Dis(1:end-1);
    D1D = mean(dDis(idx1).^2)/(2*mean(dT(idx1)))+ mean(dDis(idx2).*dDis(idx2+1))/mean((dT(idx2)+dT(idx2+1))/2);
else 
    D1D = 0;
end


function DiffusionCVE(Object)
global Config;
[FileName, PathName] = uiputfile({'*.mat','MAT-file (*.mat)'},'Save FIESTA Mean Square Displacement',fShared('GetSaveDir'));
if FileName ~= 0
    fShared('SetSaveDir',PathName);
    [file, ~] = strtok(FileName, '.');
    rng('shuffle');
    nBoot = 100;
    nObj = length(Object);
    WeightedD_2D = zeros(1,100);
    WeightedD_1D = zeros(1,100);
    GlobalD_2D = zeros(1,100);
    GlobalD_1D = zeros(1,100);
    FittedD_2D = zeros(1,100);
    FittedD_1D = zeros(1,100);
    [IndD_2D,IndD_1D,nData] = CalcIndCVE(Object);
    xd_2D = median(IndD_2D)-3*iqr(IndD_2D):6*iqr(IndD_2D)/1000:median(IndD_2D)+3*iqr(IndD_2D);
    D2Dmat = zeros(nBoot,length(xd_2D));
    Fit2Dmat = zeros(nBoot,length(xd_2D));
    xd_1D = median(IndD_1D)-3*iqr(IndD_1D):6*iqr(IndD_1D)/1000:median(IndD_1D)+3*iqr(IndD_1D);
    D1Dmat = zeros(nBoot,length(xd_1D));
    Fit1Dmat = zeros(nBoot,length(xd_1D));
    parfor (n=1:100,Config.NumCores)
        ridx = randi(nObj,1,nObj);
        w = mle(IndD_2D(ridx),'distribution','normal');
        FittedD_2D(n) = w(1);
        WeightedD_2D(n) = sum(IndD_2D(ridx).*nData(ridx))/sum(nData(ridx));
        [N,edges] = histcounts(IndD_2D(ridx),'BinMethod','scott','Normalization','pdf','BinLimits',[median(IndD_2D)-3*iqr(IndD_2D) median(IndD_2D)+3*iqr(IndD_2D)]);
        xb = (edges(2:end)+edges(1:end-1))/2;
        D2Dmat(n,:) = interp1(xb,N,xd_2D);
        Fit2Dmat(n,:) = pdf('normal',xd_2D,w(1),w(2));
        if ~isempty(IndD_1D)
            w = mle(IndD_1D(ridx),'distribution','normal');
            FittedD_1D(n) = w(1);
            WeightedD_1D(n) = sum(IndD_1D(ridx).*nData(ridx))/sum(nData(ridx));
            [N,edges] = histcounts(IndD_1D(ridx),'BinMethod','scott','Normalization','pdf','BinLimits',[median(IndD_1D)-3*iqr(IndD_1D) median(IndD_1D)+3*iqr(IndD_1D)]);
            xb = (edges(2:end)+edges(1:end-1))/2;
            D1Dmat(n,:) = interp1(xb,N,xd_1D);
            Fit1Dmat(n,:) = pdf('normal',xd_1D,w(1),w(2));
        end
        [D2D,D1D] = CalcGlobalCVE(Object(ridx));
        GlobalD_2D(n) = D2D;
        GlobalD_1D(n) = D1D;
    end
    if all(FittedD_1D==0)
        fig = figure('Units','centimeters','Position',[2 2 8 8],'Toolbar','none','MenuBar','none','DockControls','off',...
                    'PaperUnits','centimeters','PaperSize',[8 8],'Color','w','PaperPositionMode','manual','PaperPosition',[0 0 8 8]);
    else
        fig = figure('Units','centimeters','Position',[2 2 16 8],'Toolbar','none','MenuBar','none','DockControls','off',...
                    'PaperUnits','centimeters','PaperSize',[16 8],'Color','w','PaperPositionMode','manual','PaperPosition',[0 0 16 8]);
    end
    aPlot2D = axes(fig,'Units','centimeters','Position',[1.5 1.25 6 6],'TickDir','out','Color','none');
    plot(xd_2D,mean(D2Dmat,1),'b-');
    hold on;
    plot(xd_2D,mean(D2Dmat,1)+2*std(D2Dmat,[],1),'b--');
    plot(xd_2D,mean(D2Dmat,1)-2*std(D2Dmat,[],1),'b--');
    plot(xd_2D,mean(Fit2Dmat,1),'k-','LineWidth',1);
    xlim([min(xd_2D) max(xd_2D)]);
    ylim([0 1.8*max(mean(D2Dmat,1))]);
    xlabel(['diffusion coefficient [' char(181) 'm' char(178) '/s]']);
    ylabel('probabilty density');
    text(aPlot2D,'Units','normalized','HorizontalAlignment','right','Position',[0.95 0.82],'String',...
                 {['D(weighted) = ' val2str(mean(WeightedD_2D),2*std(WeightedD_2D)) char(181) 'm' char(178) '/s'],...
                  ['D(global) = ' val2str(mean(GlobalD_2D),2*std(GlobalD_2D)) char(181) 'm' char(178) '/s'],...
                  ['D(fitted) = ' val2str(mean(FittedD_2D),2*std(FittedD_2D)) char(181) 'm' char(178) '/s'],...
                  ['N = ' num2str(nObj)]});axes(fig,'Units','centimeters','Position',get(aPlot2D,'Position'),'Box','on','xtick',[],'ytick',[]);
    axes(aPlot2D); 
    save([PathName file '.mat'],'GlobalD_2D','WeightedD_2D','FittedD_2D');
    if any(FittedD_1D>0)
        title('Diffusion Analysis in 2D');
        aPlot1D = axes(fig,'Units','centimeters','Position',[9.5 1.25 6 6],'TickDir','out','Color','none');
        plot(xd_1D,mean(D1Dmat,1),'b-');
        hold on;
        plot(xd_1D,mean(D1Dmat,1)+2*std(D1Dmat,[],1),'b--');
        plot(xd_1D,mean(D1Dmat,1)-2*std(D1Dmat,[],1),'b--');
        plot(xd_1D,mean(Fit1Dmat,1),'k-','LineWidth',1);
        xlim([min(xd_1D) max(xd_1D)]);
        ylim([0 1.8*max(mean(D1Dmat,1))]);
        xlabel(['diffusion coefficient [' char(181) 'm' char(178) '/s]']);
        ylabel('probabilty density');
        text(aPlot1D,'Units','normalized','HorizontalAlignment','right','Position',[0.95 0.82],'String',...
                     {['D(weighted)= ' val2str(mean(WeightedD_1D),2*std(WeightedD_1D)) char(181) 'm' char(178) '/s'],...
                      ['D(global) = ' val2str(mean(GlobalD_1D),2*std(GlobalD_1D)) char(181) 'm' char(178) '/s'],...
                      ['D(fitted) = ' val2str(mean(FittedD_1D),2*std(FittedD_1D)) char(181) 'm' char(178) '/s'],...
                      ['N = ' num2str(nObj)]});
        axes(fig,'Units','centimeters','Position',get(aPlot1D,'Position'),'Box','on','xtick',[],'ytick',[]);
        axes(aPlot1D); 
        title('Diffusion Analysis in 1D');
        save([PathName file '.mat'],'WeightedD_1D','GlobalD_1D','FittedD_1D','-append');
    end
    saveas(fig,[PathName file '.pdf'],'pdf');
    savefig(fig,[PathName file '.fig']);
    delete(fig);
end
    
function DiffusionMSD 
global Molecule
global Filament
%define variable for square displacment and time difference
sd_1D=[];
sd_2D=[];
tau=[];
if ~isempty(Molecule)
    %for every selected molecule
    for n = find([Molecule.Selected]==1)
        if isempty(Molecule(n).PathData)
            Dis = [];
        else
            Dis = real(double(Molecule(n).PathData(:,4)));
        end
        [sd_2D,sd_1D,tau] = CalcSD(Molecule(n).Results,Dis,sd_2D,sd_1D,tau);
    end
end
if ~isempty(Filament)
    %for every selected filament
    for n = find([Filament.Selected]==1)
        if isempty(Filament(n).PathData)
            Dis = [];
        else
            Dis = real(double(Filament(n).PathData(:,4)));
        end
        [sd_2D,sd_1D,tau] = CalcSD(Filament(n).Results,Dis,sd_2D,sd_1D,tau);
    end
end
[FileName, PathName, FilterIndex] = uiputfile({'*.mat','MAT-file (*.mat)';'*.txt','TXT-File (*.txt)'},'Save FIESTA Mean Square Displacement',fShared('GetSaveDir'));
if FileName ~= 0
    fShared('SetSaveDir',PathName);
    [file, ~] = strtok(FileName, '.');
    for m=1:length(sd_2D)
        MSD_2D(m,1)=mean(tau{m});
        MSD_2D(m,2)=mean(sd_2D{m});
        MSD_2D(m,3)=std(sd_2D{m})/sqrt(length(sd_2D{m}));
        MSD_2D(m,4)=length(sd_2D{m});
    end
    N = MSD_2D(:,4);
    idx = N<0.01*sum(N);
    MSD_2D(idx,:) = [];
    if isempty(sd_1D)
        MSD_1D = 'Diffusion Analysis in 1D require path data. Use Path Statistics before Diffusion Analysis!';
    else 
        for m=1:length(sd_1D)
            MSD_1D(m,1)=mean(tau{m});
            MSD_1D(m,2)=mean(sd_1D{m});
            MSD_1D(m,3)=std(sd_1D{m})/sqrt(length(sd_1D{m}));
            MSD_1D(m,4)=length(sd_1D{m});
        end
        MSD_1D(idx,:) = [];
    end
    if FilterIndex==1
        save([PathName file '.mat'],'MSD_2D','MSD_1D');
    elseif FilterIndex==2
        f = fopen([PathName file '.txt'],'w');
        fprintf(f,'Diffusion Analysis in 2D\n');
        fprintf(f,['Time[s]\tMSD[' char(181) 'm' char(178) ']\tError(mean)\tN\n']);
        fprintf(f,'%f\t%f\t%f\t%f\n',MSD_2D');
        if ~isempty(sd_1D)
            fprintf(f,'\n');    
            fprintf(f,'Diffusion Analysis in 1D\n');
            fprintf(f,['Time[s]\tMSD[' char(181) 'm' char(178) ']\tError(mean)\tN\n']);
            fprintf(f,'%f\t%f\t%f\t%f\n',MSD_1D');
        end
        fclose(f);
    end
    if isempty(sd_1D)
        fig = figure('Units','centimeters','Position',[2 2 8 8],'Toolbar','none','MenuBar','none','DockControls','off',...
                    'PaperUnits','centimeters','PaperSize',[8 8],'Color','w','PaperPositionMode','manual','PaperPosition',[0 0 8 8]);
    else
        fig = figure('Units','centimeters','Position',[2 2 16 8],'Toolbar','none','MenuBar','none','DockControls','off',...
                    'PaperUnits','centimeters','PaperSize',[16 8],'Color','w','PaperPositionMode','manual','PaperPosition',[0 0 16 8]);
    end
    aPlot2D = axes(fig,'Units','centimeters','Position',[1.5 1.25 6 6],'TickDir','out','Color','none');
    errorbar(MSD_2D(:,1),MSD_2D(:,2),MSD_2D(:,3),'Marker','s','MarkerEdgeColor','b','MarkerFaceColor','b','LineStyle','none');
    f = fit(MSD_2D(:,1),MSD_2D(:,2),'poly1','Weights',MSD_2D(:,4));
    hold on
    x = [0 MSD_2D(:,1)'];
    plot(x,f(x),'k-');
    D = LinearRegressD(MSD_2D);
    xlim([0 max(MSD_2D(:,1))]);
    xlabel('time intervals [s]');
    ylabel(['mean squared displacement [' char(181) 'm' char(178) ']']);
    text(aPlot2D,'Units','normalized','HorizontalAlignment','right','Position',[0.95 0.2],'String',{'Weighted linear fit',[num2str(f.p1,2) '*x+' num2str(f.p2,2)],['D = ' num2str(f.p1/4,2) ' ' char(181) 'm' char(178) '/s'],'Linear Regression',['D = ' val2str(D(1),D(2)) ' ' char(181) 'm' char(178) '/s']});
    axes(fig,'Units','centimeters','Position',get(aPlot2D,'Position'),'Box','on','xtick',[],'ytick',[]);
    axes(aPlot2D); 
    if ~isempty(sd_1D)
        title('Diffusion Analysis in 2D');
        aPlot1D = axes(fig,'Units','centimeters','Position',[9.5 1.25 6 6],'TickDir','out','Color','none');
        errorbar(MSD_1D(:,1),MSD_1D(:,2),MSD_1D(:,3),'Marker','s','MarkerEdgeColor','b','MarkerFaceColor','b','LineStyle','none');
        f = fit(MSD_1D(:,1),MSD_1D(:,2),'poly1','Weights',MSD_1D(:,4));
        hold on
        x = [0 MSD_1D(:,1)'];
        plot(x,f(x),'k-');
        D = LinearRegressD(MSD_1D);
        xlim([0 max(MSD_2D(:,1))]);
        xlabel('time intervals [s]');
        ylabel(['mean squared displacement [' char(181) 'm' char(178) ']']);
        text(aPlot1D,'Units','normalized','HorizontalAlignment','right','Position',[0.95 0.2],'String',{'Weighted linear fit',[num2str(f.p1,2) '*x+' num2str(f.p2,2)],['D = ' num2str(f.p1/4,2) ' ' char(181) 'm' char(178) '/s'],'Linear Regression',['D = ' val2str(D(1),D(2)) ' ' char(181) 'm' char(178) '/s']});
        axes(fig,'Units','centimeters','Position',get(aPlot1D,'Position'),'Box','on','xtick',[],'ytick',[]);
        axes(aPlot1D); 
        title('Diffusion Analysis in 1D');
    end
    saveas(fig,[PathName file '.pdf'],'pdf');
    savefig(fig,[PathName file '.fig']);
    delete(fig);
end

function D = LinearRegressD(data)
N = data(:,4);
idx = N>0.01*sum(N);
x = data(idx,1);
y = data(idx,2);
s = data(idx,3);
delta = sum(1./s.^2)*sum(x.^2./s.^2)-(sum(x./s.^2))^2;
b = 1/delta*(sum(1.^2./s.^2)*sum(x.*y./s.^2)-sum(x./s.^2)*sum(y./s.^2));
db = sqrt(1/delta*sum(1.^2./s.^2));
D=[b./4 db];
    
function str = val2str(val,err)
rd = floor(log10(round(err,1,'significant')));
if rd>=0
    err = ceil(err);
    val = round(val);
    p = '%.0f';
else
    err = ceil(err*10^-rd)/10^-rd;
    val = round(val,-rd);
    p = ['%.' num2str(abs(rd)) 'f'];
end
str = [num2str(val,p) char([32 177 32]) num2str(err,p)];

function fRightPanel(func,varargin)
switch func
    case 'UpdateMeasure'
        UpdateMeasure(varargin{1});
    case 'NewScan'
        NewScan(varargin{1});    
    case 'CreateFilamentScan'
        CreateFilamentScan(varargin{1});        
    case 'NewKymoGraph'
        NewKymoGraph(varargin{1});                
    case 'KymoFrames'
        KymoFrames(varargin{1});                        
    case 'UpdateLineScan'
        UpdateLineScan(varargin{1});                
    case 'DataPanel'
        DataPanel(varargin{1});        
    case 'ToolsPanel'
        ToolsPanel(varargin{1});
    case 'QueuePanel'
        QueuePanel(varargin{1});
    case 'DataMoleculesPanel'
        DataMoleculesPanel(varargin{1});     
    case 'DataFilamentsPanel'
        DataFilamentsPanel(varargin{1});          
    case 'ToolsMeasurePanel'
        ToolsMeasurePanel(varargin{1});     
    case 'ToolsScanPanel'
        ToolsScanPanel(varargin{1});   
    case 'QueueServerPanel'
        QueueServerPanel(varargin{1});     
    case 'QueueLocalPanel'
        QueueLocalPanel(varargin{1});   
    case 'ToggleTool'
        ToggleTool(varargin{1});
    case 'AllToolsOff'
        AllToolsOff(varargin{1});
    case 'MeasureTable'
        MeasureTable(varargin{1});
    case 'ScanSize'
        ScanSize(varargin{1});
    case 'ShowKymoGraph'
        ShowKymoGraph(varargin{1});
    case 'DeleteScan'
        DeleteScan(varargin{1});        
    case 'UpdateList'
        UpdateList(varargin{1},varargin{2},varargin{3},varargin{4});
    case 'ListSlider'
        ListSlider(varargin{1});
    case 'ListButton'
        ListButton(varargin{1},varargin{2});
    case 'ListVisible'
        ListVisible(varargin{1},varargin{2});
    case 'QueueCheck'
        QueueCheck(varargin{1});
    case 'UpdateQueue'
        UpdateQueue(varargin{1});
    case 'QueueSlider'
        QueueSlider;        
    case 'ShowAllFil'
        ShowAllFil;        
    case 'ApplyCorrections'
        ApplyCorrections(varargin{1});
    case 'DeleteQueue'
        DeleteQueue(varargin{1});
    case 'SaveMeasure'
        SaveMeasure(varargin{1});        
    case 'KeepMeasure'
        KeepMeasure;    
    case 'ExportScan'
        ExportScan(varargin{1});           
    case 'ExportKymo'
        ExportKymo(varargin{1});          
    case 'RefreshServerQueue'
        RefreshServerQueue(varargin{1});
    case 'CheckReference'
        CheckReference(varargin{1});      
    case 'CorrectKymoIndex'
        CorrectKymoIndex(varargin{1});      
    case 'IgnoreObjects'   
        IgnoreObjects(varargin{1},varargin{2});
    case 'RenameObject'   
        RenameObject(varargin{1},varargin{2});        
    case 'LoadQueue'   
        LoadQueue;        
    case 'SaveQueue'   
        SaveQueue;                
    case 'UpdateKymoTracks'   
        UpdateKymoTracks(varargin{1});                        
    case 'CheckConfig'   
        CheckConfig;                 
end

function CheckConfig
fConfigGui('Create');
fShared('ReturnFocus');

function ExportKymo(hMainGui)
[FileName, PathName, FilterIndex] = uiputfile({'*.tif','TIFF-File (*.tif)';'*.pdf','Portable Document Format (*.pdf)';'*.*','Both pdf and tif'},'Save FIESTA Kymograph',fShared('GetSaveDir')); 
if FileName~=0
    fShared('SetSaveDir',PathName);
    FileName = strrep(FileName, '.pdf', '');
    FileName = strrep(FileName, '.tif', '');
    file = [PathName FileName];
    Image=hMainGui.KymoImage;
    if FilterIndex==1||FilterIndex==3
        imwrite(uint16(Image(:,:,1)),[file '.tif'],'Compression','none');  
        if size(Image,3)>1
            for c=2:size(Image,3)
                imwrite(uint16(Image(:,:,c)),[file '.tif'],'Compression','none','WriteMode','append');  
            end
        end
    end
    if FilterIndex==2||FilterIndex==3
        saveas(hMainGui.MidPanel.aKymoGraph, [file '.pdf'], 'pdf') %Save figure;
    end
    if get(hMainGui.RightPanel.pTools.cKymoLocation,'Value')==1
        set(hMainGui.MidPanel.pView,'Visible','on');
        set(hMainGui.MidPanel.pKymoGraph,'Visible','off');
        saveas(hMainGui.MidPanel.aView, [file '.jpg'], 'jpg') %Save figure;
        set(hMainGui.MidPanel.pView,'Visible','off');
        set(hMainGui.MidPanel.pKymoGraph,'Visible','on');
    end
end
fShared('ReturnFocus');

function ExportScan(hMainGui)
global Stack;
global Config;
[FileName, PathName, FilterIndex] = uiputfile({'*.mat','MAT-File (*.mat)';'*.txt','TXT-File (*.txt)';'*.jpg','JPG-File (*.jpg)'},'Save FIESTA LineScan',fShared('GetSaveDir'));
if PathName~=0
    fShared('SetSaveDir',PathName);
    set(hMainGui.fig,'Pointer','watch');   
    if FilterIndex==3
        if isempty(strfind(FileName,'.jpg'))
            file=sprintf('%s/%s.jpg',PathName,FileName);
        else
            file=sprintf('%s/%s',PathName,FileName);
        end
    elseif FilterIndex==1
        if isempty(strfind(FileName,'.mat'))
            file=sprintf('%s/%s.mat',PathName,FileName);
        else
            file=sprintf('%s/%s',PathName,FileName);
        end
    elseif FilterIndex==2
        if isempty(strfind(FileName,'.txt'))
            file=sprintf('%s/%s.txt',PathName,FileName);
        else
            file=sprintf('%s/%s',PathName,FileName);
        end
    end
    stidx=hMainGui.Values.FrameIdx(1);
    if length(hMainGui.Values.FrameIdx)>2
        idx=hMainGui.Values.FrameIdx(stidx+1);
    else
        idx=hMainGui.Values.FrameIdx(2);
    end
    if all(isreal(idx)) && all(idx)>0
        if strcmp(get(hMainGui.ToolBar.ToolChannels(5),'State'),'off')
            Image=double(Stack{stidx}(:,:,idx));
        else
            for n = 1:length(hMainGui.Values.StackColor)
                t = min([n+1 length(hMainGui.Values.FrameIdx)]);
                idx(n) = hMainGui.Values.FrameIdx(t);
                Image(:,:,n)=double(Stack{n}(:,:,idx(n)));
            end
        end   
    else
        cidx = imag(idx);
        switch(cidx)
            case {-1,-4} %Maximum or objects profection
                Image = double(getappdata(hMainGui.fig,'MaxImage'));
                if strcmp(get(hMainGui.ToolBar.ToolChannels(5),'State'),'off')
                    Image = Image(:,:,stidx);
                end
            case -2 %Average
                Image=double(getappdata(hMainGui.fig,'AverageImage'));
                if strcmp(get(hMainGui.ToolBar.ToolChannels(5),'State'),'off')
                    Image = Image(:,:,stidx);
                end
            otherwise
                idx = real(idx);
                Image = double(Stack{stidx}(:,:,idx));
        end
    end
    for n = 1:size(Image,3)
        Z = interp2(double(Image(:,:,n)),hMainGui.Scan.InterpX,hMainGui.Scan.InterpY);
        I(n,:) = mean(Z,1);
    end
    if FilterIndex==3
        h=figure('PaperUnits','centimeter','Visible','off','PaperType','A4','PaperPositionMode','manual','PaperPosition',[0 0 29.7 21]);
        if size(I,1)>1
            for n = 1:size(I,1)
                c = get(hMainGui.ToolBar.ToolColors(hMainGui.Values.StackColor(n)),'CData');
                c = squeeze(c(1,1,1:3));
                line(hMainGui.Scan.InterpD*hMainGui.Values.PixSize/1000,I(n,:),'Color',c,'LineStyle','-');
            end
        else
            line(hMainGui.Scan.InterpD*hMainGui.Values.PixSize/1000,I,'Color','black','LineStyle','-');
        end
        plot(D,I,'b-');
        xlabel('Intensity vs. Distance in um');
        print(h,file,'-djpeg','-r600');
        close(h);
    elseif FilterIndex==1
        LineScan = [hMainGui.Scan.InterpD*hMainGui.Values.PixSize/1000 I'];
        save(file,'LineScan');
    elseif FilterIndex==2
        fh=fopen(file,'w');
        fprintf(fh,'%s - Frame: %d\n',Config.StackName,f);
        fprintf(fh,'Distance[um]\tIntensity[counts]\n');
        for j=1:length(D)
            fprintf(fh,'%f\t%f\n',D(j),I(j));
        end
        fclose(fh);
    end
    setappdata(0,'hMainGui',hMainGui);
    set(hMainGui.fig,'Pointer','arrow');       
end        
fShared('ReturnFocus');

function KeepMeasure
hMainGui = getappdata(0,'hMainGui');
Data = [hMainGui.Measure.Data];
Data = reshape(Data,4,size(Data,2)/4)';
hMainGui.Measurements = [hMainGui.Measurements; Data];
for n = numel(hMainGui.Measure):-1:1
    hMainGui.Measure(n) = [];
    delete(hMainGui.Plots.Measure(n));
    hMainGui.Plots.Measure(n) = [];
end
setappdata(0,'hMainGui',hMainGui);
UpdateMeasure(hMainGui);

function SaveMeasure(hMainGui)
[FileName, PathName, FilterIndex] = uiputfile({'*.mat','MAT-File (*.mat)';'*.txt','TXT-File (*.txt)'},'Save FIESTA Measurements',fShared('GetSaveDir'));
if FileName~=0
    file = [PathName FileName];
    if FilterIndex == 1
        if ~contains(file,'.mat')
            file = [file '.mat'];
        end  
    else
        if ~contains(file,'.txt')
            file = [file '.txt'];
        end
    end
    fShared('SetSaveDir',PathName);
    Data = hMainGui.Measurements;
    k = Data(:,1)./Data(:,2) ~= Data(:,4);
    if any(k)
        StackMeasurements = array2table(Data(k,:),'VariableNames',{'LengthArea','Mean','Integral','STD'});
        StackMeasurements.Properties.VariableUnits = {'µm/µm^2','','',''};
        if FilterIndex == 1
            save(file,'StackMeasurements');
        else
           writetable(StackMeasurements,file);
        end
    end
    k = Data(:,1)./Data(:,2) == Data(:,4);
    if any(k)
        KymoMeasurements = array2table(Data(k,:),'VariableNames',{'Distance','Time','Frames','Velocity'});
        KymoMeasurements.Properties.VariableUnits = {'µm','s','','µm/s'};
        if FilterIndex == 1
            if isfile(file)                   
                save(file,'KymoMeasurements','-append');
            else
                save(file,'KymoMeasurements');
            end
        else
            if isfile(file)
                try
                    writetable(KymoMeasurements,file,'WriteMode','Append');
                catch
                    writetable(KymoMeasurements,strrep(file,'.txt.','-kymo.txt'));
                end
            else
                writetable(KymoMeasurements,file);
            end
        end
    end
end
fShared('ReturnFocus');

function ApplyCorrections(hMainGui)
global Molecule;
global Filament;
Drift=getappdata(hMainGui.fig,'Drift');
if ~isempty(Drift)
    fDataGui('DeleteGUI',1);
    Value=get(gcbo,'Value');
    set(hMainGui.RightPanel.pData.cMolCorrections,'Value',Value);
    set(hMainGui.RightPanel.pData.cFilCorrections,'Value',Value);    
    nMol=length(Molecule);
    nFil=length(Filament);
    for i=1:nMol
        if length(Drift)>=Molecule(i).Channel && ~isempty(Drift{Molecule(i).Channel})
            Molecule(i)=fCorrectPos(Molecule(i),Drift{Molecule(i).Channel},Value);
        end
    end
    for i=1:nFil
        if length(Drift)>=Filament(i).Channel && ~isempty(Drift{Filament(i).Channel})
            Filament(i)=fCorrectPos(Filament(i),Drift{Filament(i).Channel},Value);
        end
    end
    fShow('Image');
    fShow('Tracks');
else
    set(hMainGui.RightPanel.pData.cMolDrift,'Value',0);
    set(hMainGui.RightPanel.pData.cFilDrift,'Value',0);    
end
fShared('ReturnFocus');

function CheckReference(hMainGui)
Drift=getappdata(hMainGui.fig,'Drift');
if ~isempty(Drift)
    set(hMainGui.RightPanel.pData.cMolCorrections,'Value',0);   
    set(hMainGui.RightPanel.pData.cFilCorrections,'Value',0); 
    fShow('Marker',hMainGui,hMainGui.Values.FrameIdx);
    fShow('Tracks');    
end
fShared('ReturnFocus');

function ShowAllFil
fShared('ReturnFocus');
fShared('UpdateMenu',getappdata(0,'hMainGui'));
fShow('Image');

function ListButton(hMainGui,type)
global Molecule;
global Filament;
fShared('BackUp',hMainGui);
if strcmp(type,'Molecule')
    Object=Molecule;
else
    Object=Filament;
end
nObj=length(Object);
idx=get(gcbo,'UserData');
if strcmp(type,'Molecule')==1
    value=round(get(hMainGui.RightPanel.pData.sMolList,'Value'));
else
    value=round(get(hMainGui.RightPanel.pData.sFilList,'Value'));
end
if nObj>8
    fDataGui('Create',type,nObj-7-value+idx);
else
    fDataGui('Create',type,idx);
end


function QueueCheck(hMainGui)
global Queue;
nQue=length(Queue);
idx=get(gcbo,'UserData');
value=round(get(hMainGui.RightPanel.pQueue.sLocList,'Value'));
if nQue>8
    Queue(nQue-7-value+idx).Check=get(gcbo,'Value');
else
    Queue(idx).Check=get(gcbo,'Value');
end
fShared('ReturnFocus');

function ListVisible(hMainGui,Mode)
global Molecule;
global Filament;
global KymoTrackMol;
global KymoTrackFil;
idx=get(gcbo,'UserData');
if strcmp(Mode,'Molecule')
    Molecule=fShared('VisibleOne',Molecule,KymoTrackMol,hMainGui.RightPanel.pData.MolList,idx*1i,[],hMainGui.RightPanel.pData.sMolList);
else
    Filament=fShared('VisibleOne',Filament,KymoTrackFil,hMainGui.RightPanel.pData.FilList,idx*1i,[],hMainGui.RightPanel.pData.sFilList);
end
fShared('ReturnFocus');
fShow('Image');

function ListSlider(hMainGui)
global Molecule;
global Filament;
UpdateList(hMainGui.RightPanel.pData.MolList,Molecule,hMainGui.RightPanel.pData.sMolList,hMainGui.Menu.ctListMol);
UpdateList(hMainGui.RightPanel.pData.FilList,Filament,hMainGui.RightPanel.pData.sFilList,hMainGui.Menu.ctListFil);
fShared('ReturnFocus');

function ShowKymoGraph(hMainGui)
NewKymoGraph(hMainGui);
fShared('ReturnFocus');

function IgnoreObjects(hMainGui,Mode)
global Molecule;
global Filament;
global KymoTrackMol;
global KymoTrackFil;
Value=get(gcbo,'Value');
if strcmp(Mode,'Molecule')
    Object=Molecule;
    KymoObject=KymoTrackMol;
else
    Object=Filament;
    KymoObject=KymoTrackFil;
end
for n=1:length(Object)
    Object(n).Selected=-Value;
    visible='off';
    if Object(n).Selected==0&&Object(n).Visible==1
        visible='on';
    end
    set(Object(n).PlotHandles(1),'Visible',visible);
    k=find([KymoObject.Index]==n);
    if ~isempty(k)
        set(KymoObject(k).PlotHandles(1),'Visible',visible);                 
    end  
end
if strcmp(Mode,'Molecule')
    Molecule=Object;
else
    Filament=Object;
end
UpdateList(hMainGui.RightPanel.pData.MolList,Molecule,hMainGui.RightPanel.pData.sMolList,hMainGui.Menu.ctListMol);
UpdateList(hMainGui.RightPanel.pData.FilList,Filament,hMainGui.RightPanel.pData.sFilList,hMainGui.Menu.ctListFil);
fShow('Marker',hMainGui,hMainGui.Values.FrameIdx);
fShared('ReturnFocus');

function KymoFrames(hMainGui)
s=str2double(get(hMainGui.RightPanel.pTools.eKymoStart,'String'));
e=str2double(get(hMainGui.RightPanel.pTools.eKymoEnd,'String'));
if strcmp(get(hMainGui.ToolBar.ToolChannels(5),'State'),'off')
    stidx=hMainGui.Values.FrameIdx(1);
    if stidx>length(hMainGui.Values.MaxIdx)-1
        N = hMainGui.Values.MaxIdx(2);
    else
        N = hMainGui.Values.MaxIdx(stidx+1);
    end
else
    N = max(hMainGui.Values.MaxIdx(2:end));
end
if strcmp(get(gcbo,'UserData'),'Start')
    s=min([s e-1]);
    s=max([s 1]);
    e=max([e s+1]);
else    
    e=min([e N]);
 	e=max([e s+1]);
end    
set(hMainGui.RightPanel.pTools.eKymoStart,'String',num2str(s));
set(hMainGui.RightPanel.pTools.eKymoEnd,'String',num2str(e));
fShared('ReturnFocus');

function ScanSize(hMainGui)
value=round(str2double(get(hMainGui.RightPanel.pTools.eScanSize,'String')));
if value<1
    value=1;
end
if ~isnan(value)
   if value>10
       value=10;
   end
   hMainGui.Values.ScanSize=value;
   setappdata(0,'hMainGui',hMainGui);
   NewScan(hMainGui);
end
set(hMainGui.RightPanel.pTools.eScanSize,'String',num2str(value));
fShared('ReturnFocus');

function MeasureTable(hMainGui)
idx=get(hMainGui.RightPanel.pTools.lMeasureTable,'Value');
set(hMainGui.RightPanel.pTools.lMeasureTable,'UserData',idx-1);
setappdata(0,'hMainGui',hMainGui);
fShared('ReturnFocus');

function str=formatstr(width,format,value)
str=sprintf(format,value);
str = strrep(str, 'e+00', 'e+');
l=width-length(str);
for i=0.5:0.5:l
    str=[' ' str]; %#ok<AGROW>
end

function UpdateLineScan(hMainGui)
global Stack
stidx=hMainGui.Values.FrameIdx(1);
if length(hMainGui.Values.FrameIdx)>2
    idx=hMainGui.Values.FrameIdx(stidx+1);
else
    idx=hMainGui.Values.FrameIdx(2);
end
if all(isreal(idx)) && all(idx)>0
    if strcmp(get(hMainGui.ToolBar.ToolChannels(5),'State'),'off')
        Image=double(Stack{stidx}(:,:,idx));
    else
        for n = 1:length(hMainGui.Values.StackColor)
            t = min([n+1 length(hMainGui.Values.FrameIdx)]);
            idx(n) = hMainGui.Values.FrameIdx(t);
            Image(:,:,n)=double(Stack{n}(:,:,idx(n)));
        end
    end   
else
    cidx = imag(idx);
    switch(cidx)
        case {-1,-4} %Maximum or objects profection
            Image = double(getappdata(hMainGui.fig,'MaxImage'));
            if strcmp(get(hMainGui.ToolBar.ToolChannels(5),'State'),'off')
                Image = Image(:,:,stidx);
            end
        case -2 %Average
            Image=double(getappdata(hMainGui.fig,'AverageImage'));
            if strcmp(get(hMainGui.ToolBar.ToolChannels(5),'State'),'off')
                Image = Image(:,:,stidx);
            end
        otherwise
            idx = real(idx);
            Image = double(Stack{stidx}(:,:,idx));
    end
end
for n = 1:size(Image,3)
    Z = interp2(double(Image(:,:,n)),hMainGui.Scan.InterpX,hMainGui.Scan.InterpY);
    I(n,:) = mean(Z,1);
end
set(hMainGui.RightPanel.pTools.pLineScan,'Visible','on');
set(hMainGui.RightPanel.pTools.aLineScan,'Visible','on');
delete(findobj(hMainGui.RightPanel.pTools.aLineScan,'Tag','plotLineScan'));
if size(I,1)>1
    for n = 1:size(I,1)
        c = get(hMainGui.ToolBar.ToolColors(hMainGui.Values.StackColor(n)),'CData');
        c = squeeze(c(1,1,1:3));
        line(hMainGui.RightPanel.pTools.aLineScan,hMainGui.Scan.InterpD*hMainGui.Values.PixSize/1000,I(n,:),'Color',c,'LineStyle','-','UIContextMenu',hMainGui.Menu.ctScan,'Tag','plotLineScan');
    end
else
    line(hMainGui.RightPanel.pTools.aLineScan,hMainGui.Scan.InterpD*hMainGui.Values.PixSize/1000,I,'Color','black','LineStyle','-','UIContextMenu',hMainGui.Menu.ctScan,'Tag','plotLineScan');
end
xlim(hMainGui.RightPanel.pTools.aLineScan,[0 max(hMainGui.Scan.InterpD*hMainGui.Values.PixSize/1000)]);
xlabel(hMainGui.RightPanel.pTools.aLineScan,['Distance [' char(956) 'm]']);
ylabel(hMainGui.RightPanel.pTools.aLineScan,'Intensity [counts]');
setappdata(0,'hMainGui',hMainGui);

function NewKymoGraph(hMainGui)
global Stack;
global Molecule;
global Filament;
global KymoTrackMol;
global KymoTrackFil;
s=str2double(get(hMainGui.RightPanel.pTools.eKymoStart,'String'));
e=str2double(get(hMainGui.RightPanel.pTools.eKymoEnd,'String'));
stepsize = str2double(get(hMainGui.RightPanel.pTools.eKymoStep,'String'));
if ~isnan(s)&&~isnan(e)&&~isempty(Stack)
    [KymoGraph,KymoPixSize,KymoInfo]=NewKymo(hMainGui.Scan);
    KymoGraph(e+1:end,:,:)=[];
    KymoGraph(1:s-1,:,:)=[];
    KymoGraph = KymoGraph(1:stepsize:end,:,:);
    KymoInfo.Time(e+1:end,:)=[];
    KymoInfo.Time(1:s-1,:)=[];
    KymoInfo.Time = KymoInfo.Time(1:stepsize:end,:);
    try
        delete(hMainGui.MidPanel.aKymoGraph);
    catch
        delete(findobj('Tag','aKymoGraph'));
    end
    hMainGui.MidPanel.aKymoGraph = axes('Parent',hMainGui.MidPanel.pKymoGraph,'Units','normalized','UIContextMenu',hMainGui.Menu.ctKymoGraph,'Position',[0 0 1 1],'Tag','aKymoGraph','NextPlot','add','Visible','off');  
    [y,x,~]=size(KymoGraph);
    if y/x >= hMainGui.ZoomKymo.aspect
        borders = ((y/hMainGui.ZoomKymo.aspect)-x)/2;
        hMainGui.ZoomKymo.globalXY = {[0.5-borders x+0.5+borders],[0.5 y+0.5]};
    else
        borders = ((x*hMainGui.ZoomKymo.aspect)-y)/2;
        hMainGui.ZoomKymo.globalXY = {[0.5 x+0.5],[0.5-borders y+0.5+borders]};
    end
    hMainGui.KymoImage=KymoGraph;
    if strcmp(get(hMainGui.ToolBar.ToolChannels(5),'State'),'off')
        n = hMainGui.Values.FrameIdx(1);
        Image=(KymoGraph-hMainGui.Values.ScaleMin(n))/(hMainGui.Values.ScaleMax(n)-hMainGui.Values.ScaleMin(n)+1);
    else
        IRGB = zeros(size(KymoGraph,1),size(KymoGraph,2),3);
        for n = 1:length(hMainGui.Values.StackColor)
            c = get(hMainGui.ToolBar.ToolColors(hMainGui.Values.StackColor(n)),'CData');
            c = squeeze(c(1,1,1:3));
            KymoGraph(:,:,n) = (KymoGraph(:,:,n)-hMainGui.Values.ScaleMin(n))/(hMainGui.Values.ScaleMax(n)-hMainGui.Values.ScaleMin(n)+1);
            IRGB(:,:,1) = IRGB(:,:,1)+KymoGraph(:,:,n)*c(1);
            IRGB(:,:,2) = IRGB(:,:,2)+KymoGraph(:,:,n)*c(2);
            IRGB(:,:,3) = IRGB(:,:,3)+KymoGraph(:,:,n)*c(3);
        end
        Image = IRGB;
    end
    Image(Image<0)=0;
    Image(Image>1)=1;
    if size(Image,3)==1
       Image=Image*2^16;
    end
    hMainGui.KymoGraph = image(Image,'Parent',hMainGui.MidPanel.aKymoGraph,'CDataMapping','scaled');
    hMainGui.KymoInfo = KymoInfo;
    set(hMainGui.MidPanel.aKymoGraph,'CLim',[0 65535],'YDir','reverse'); 
    set(hMainGui.MidPanel.aKymoGraph,'Visible','on'); 
    set(hMainGui.fig,'colormap',colormap('Gray'));
    set(hMainGui.KymoGraph,'Tag','plotScan','UserData',KymoPixSize);
    if ~isempty(Molecule)
        [hMainGui,KymoTrackMol]=ShowTracksKymo(hMainGui,Molecule,hMainGui.Scan.InterpX,hMainGui.Scan.InterpY,s,e,hMainGui.Scan.lx,hMainGui.Scan.ux,hMainGui.Scan.ly,hMainGui.Scan.uy,KymoPixSize);
    end
    if ~isempty(Filament)
        [hMainGui,KymoTrackFil]=ShowTracksKymo(hMainGui,Filament,hMainGui.Scan.InterpX,hMainGui.Scan.InterpY,s,e,hMainGui.Scan.lx,hMainGui.Scan.ux,hMainGui.Scan.ly,hMainGui.Scan.uy,KymoPixSize);
    end
    set(hMainGui.MidPanel.aKymoGraph,{'xlim','ylim'},hMainGui.ZoomKymo.globalXY,'Visible','off'); 
    hMainGui.ZoomKymo.currentXY=hMainGui.ZoomKymo.globalXY;
    hMainGui.ZoomKymo.level=0;
    setappdata(0,'hMainGui',hMainGui);
    if gcbo == hMainGui.RightPanel.pTools.bShowKymoGraph
        fToolBar('KymoGraph',hMainGui)
    end
end

function [KymoGraph,KymoPix,KymoInfo] = NewKymo(Scan)
global Stack;
global Config;
global FiestaDir;
global TimeInfo;
hMainGui=getappdata(0,'hMainGui');
Drift=getappdata(hMainGui.fig,'Drift');
iX=Scan.InterpX;
iY=Scan.InterpY;
d = Scan.InterpD;
KymoPix = mean(d(2:end)-d(1:end-1));
hMainGui=getappdata(0,'hMainGui'); 
if strcmp(get(hMainGui.ToolBar.ToolChannels(5),'State'),'off')
    stidx=hMainGui.Values.FrameIdx(1);
    if stidx>length(hMainGui.Values.MaxIdx)-1
        N = hMainGui.Values.MaxIdx(2);
        tN(stidx) = N;
    else
        N = hMainGui.Values.MaxIdx(stidx+1);
        tN = hMainGui.Values.MaxIdx(2:end);
    end
else
    stidx=1:numel(Stack);
    N = max(hMainGui.Values.MaxIdx(2:end));
    tN = hMainGui.Values.MaxIdx(2:end);
end
for k = stidx
    if length(Drift)<k || isempty(Drift{k})
        Drift{k} = [ 1 0 0; 0 1 0; 0 0 1 ];
    end
end
dirStatus = [FiestaDir.AppData 'fiestastatus' filesep];  
parallelprogressdlg('String','Creating KymoGraph','Max',sum(tN),'Parent',hMainGui.fig,'Directory',FiestaDir.AppData);
KymoGraph = zeros(N,length(d),length(stidx))*NaN; 
KymoTime = zeros(N,length(stidx)); 
if get(hMainGui.RightPanel.pTools.cKymoDrift,'Value')==1 && ~isempty(Drift)
    if get(hMainGui.RightPanel.pTools.mKymoMethod,'Value')==1
        for k = stidx
            S = Stack{k};
            D = Drift{k};
            nS = size(S,3);
            parfor(n = 1:nS,Config.NumCores)
                fidx = min([n size(D,3)]);
                T = D(:,:,fidx);
                Det = T(1,1).*T(2,2) - T(1,2) .* T(2,1);
                T = [ T(2,2) -T(1,2) 0; -T(2,1) T(1,1) 0; T(2,1).*T(3,2)-T(3,1).*T(2,2) T(1,2).*T(3,1)-T(3,2).*T(2,2) Det] / Det;
                NX = iX * T(1,1) + iY * T(2,1) + T(3,1);
                NY = iX * T(1,2) + iY * T(2,2) + T(3,2);
                Z = interp2(double(S(:,:,n)),NX,NY,'nearest');
                KymoGraph(n,:,k)=max(Z,[],1);
                KymoTime(n,k) = TimeInfo{k}(n)-TimeInfo{k}(1);
                fSave(dirStatus,sum(tN(1:k-1))+n);
            end     
        end
    else
        for k = stidx
            S = Stack{k};
            D = Drift{k};
            nS = size(S,3);
            parfor(n = 1:nS,Config.NumCores)
                fidx = min([n size(D,3)]);
                T = D(:,:,fidx);
                Det = T(1,1).*T(2,2) - T(1,2) .* T(2,1);
                T = [ T(2,2) -T(1,2) 0; -T(2,1) T(1,1) 0; T(2,1).*T(3,2)-T(3,1).*T(2,2) T(1,2).*T(3,1)-T(3,2).*T(2,2) Det] / Det;
                NX = iX * T(1,1) + iY * T(2,1) + T(3,1);
                NY = iX * T(1,2) + iY * T(2,2) + T(3,2);
                Z = interp2(double(S(:,:,n)),NX,NY);
                KymoGraph(n,:,k)=mean(Z,1);
                KymoTime(n,k) = TimeInfo{k}(n)-TimeInfo{k}(1);
                fSave(dirStatus,sum(tN(1:k-1))+n);
            end     
        end
    end
else
    if get(hMainGui.RightPanel.pTools.mKymoMethod,'Value')==1
        for k = stidx
            S = Stack{k};
            nS = size(S,3);
            parfor(n = 1:nS,Config.NumCores)
                Z = interp2(double(S(:,:,n)),iX,iY,'nearest');
                KymoGraph(n,:,k)=max(Z,[],1);
                KymoTime(n,k) = TimeInfo{k}(n)-TimeInfo{k}(1);
                fSave(dirStatus,sum(tN(1:k-1))+n);
            end     
        end
    else
        for k = stidx
            S = Stack{k};
            nS = size(S,3);
            parfor(n = 1:nS,Config.NumCores)
                Z = interp2(double(S(:,:,n)),iX,iY);
                KymoGraph(n,:,k)=mean(Z,1);
                KymoTime(n,k) = TimeInfo{k}(n)-TimeInfo{k}(1);
                fSave(dirStatus,sum(tN(1:k-1))+n);
            end     
        end
    end
end
parallelprogressdlg('close');
for n = stidx
    k = find(any(isnan(KymoGraph(:,:,n)),2),1,'first');
    if ~isempty(k)
        KymoGraph(k:N,:,n) = repmat(KymoGraph(k-1,:,n),N-k+1,1);
        KymoTime(k:N,n) = repmat(KymoTime(k-1,n),N-k+1,1);
    end
end
KymoGraph = KymoGraph(:,:,stidx);
KymoInfo.FrameIdx = stidx;
KymoInfo.Time = KymoTime/1000;

function UpdateKymoTracks(hMainGui)
global Molecule;
global Filament;
global KymoTrackMol;
global KymoTrackFil;
s=str2double(get(hMainGui.RightPanel.pTools.eKymoStart,'String'));
e=str2double(get(hMainGui.RightPanel.pTools.eKymoEnd,'String'));
if ~isempty(hMainGui.KymoImage)
    KymoPixSize = get(hMainGui.KymoGraph,'UserData');
    if ~isempty(Molecule)
        h = [KymoTrackMol.PlotHandles];
        delete(h(ishandle(h)));
        [hMainGui,KymoTrackMol]=ShowTracksKymo(hMainGui,Molecule,hMainGui.Scan.InterpX,hMainGui.Scan.InterpY,s,e,hMainGui.Scan.lx,hMainGui.Scan.ux,hMainGui.Scan.ly,hMainGui.Scan.uy,KymoPixSize);
    end
    if ~isempty(Filament)
        h = [KymoTrackFil.PlotHandles];
        delete(h(ishandle(h)));
        [hMainGui,KymoTrackFil]=ShowTracksKymo(hMainGui,Filament,hMainGui.Scan.InterpX,hMainGui.Scan.InterpY,s,e,hMainGui.Scan.lx,hMainGui.Scan.ux,hMainGui.Scan.ly,hMainGui.Scan.uy,KymoPixSize);
    end
end
setappdata(0,'hMainGui',hMainGui);

function CreateFilamentScan(hMainGui)
global Filament;
k = find([Filament.Selected]==1);
if isempty(k)
    fMsgDlg('No filament selected','error');
else
    hMainGui.Scan(1).X = (double(Filament(k(1)).Data{1}(:,1))/Filament(k(1)).PixelSize)';
    hMainGui.Scan(1).Y = (double(Filament(k(1)).Data{1}(:,2))/Filament(k(1)).PixelSize)';
end
NewScan(hMainGui)

function NewScan(hMainGui)
nX=hMainGui.Scan.X';
nY=hMainGui.Scan.Y';
ScanSize=hMainGui.Values.ScanSize;
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
d = [0; cumsum(sqrt((X(2:end)-X(1:end-1)).^2 + (Y(2:end)-Y(1:end-1)).^2))];
lx = iX(1,:);
ux = iX(end,:);
ly = iY(1,:);
uy = iY(end,:);
delete(findobj('Tag','plotScan'));
line(hMainGui.MidPanel.aView,X,Y,'Color','red','LineStyle','-.','Tag','plotScan','UIContextMenu',hMainGui.Menu.ctScan,'LineWidth',2);
line(hMainGui.MidPanel.aView,lx,ly,'Color','red','LineStyle',':','Tag','plotScan','UIContextMenu',hMainGui.Menu.ctScan,'LineWidth',2);
line(hMainGui.MidPanel.aView,ux,uy,'Color','red','LineStyle',':','Tag','plotScan','UIContextMenu',hMainGui.Menu.ctScan,'LineWidth',2);
hMainGui.Scan.InterpX=iX;
hMainGui.Scan.InterpY=iY;
hMainGui.Scan.lx=lx;
hMainGui.Scan.ux=ux;
hMainGui.Scan.ly=ly;
hMainGui.Scan.uy=uy;
hMainGui.Scan.InterpD=d;
hMainGui.CursorMode='Normal';
set(hMainGui.RightPanel.pTools.bLineScanExport,'Enable','on');
set(get(hMainGui.RightPanel.pTools.pKymoGraph,'Children'),'Enable','on');
if strcmp(get(hMainGui.Menu.mCorrectStack,'Checked'),'on')
    set(hMainGui.RightPanel.pTools.cKymoDrift,'Enable','off','Value',0);
end
setappdata(0,'hMainGui',hMainGui);
UpdateLineScan(hMainGui);
AllToolsOff(hMainGui);
fToolBar('Cursor',hMainGui);

function DeleteScan(hMainGui)
global KymoTrackMol;
global KymoTrackFil;
plotScan=findobj('Tag','plotScan');
hMainGui.KymoGraph=[];
hMainGui.KymoImage=[];
hMainGui.Scan=[];
if ~isempty(plotScan)
    hMainGui.Values.CursorDownPos(:)=0;
    h = [KymoTrackMol.PlotHandles KymoTrackFil.PlotHandles];
    delete(h(ishandle(h)));
    KymoTrackMol(:)=[];
    KymoTrackFil(:)=[];
    delete(plotScan);
    delete(findobj('Tag','plotLineScan'));
    mObj = findobj('Parent',hMainGui.MidPanel.aKymoGraph,'-and','Tag','plotMeasure');
    for n = numel(mObj):-1:1
        hMainGui.Measure(n) = [];
        delete(hMainGui.Plots.Measure(n));
        hMainGui.Plots.Measure(n) = [];
    end
    setappdata(0,'hMainGui',hMainGui);   
    cla(hMainGui.MidPanel.aKymoGraph,'reset');
    cla(hMainGui.RightPanel.pTools.aLineScan,'reset');
    set(hMainGui.RightPanel.pTools.bLineScanExport,'Enable','off');
    set(get(hMainGui.RightPanel.pTools.pKymoGraph,'Children'),'Enable','off');
    fToolBar('NormImage',hMainGui);
else
    setappdata(0,'hMainGui',hMainGui);    
end


function [hMainGui,KymoTrackObj]=ShowTracksKymo(hMainGui,Objects,X,Y,s,e,lx,ux,ly,uy,KymoPixSize)
KymoTrackObj=struct('Index',{},'Track',{},'PlotHandles',{});
nTrack=1;
newX=mean(X,1);
newY=mean(Y,1);
fi = 1:0.1:numel(newX);
newX = interp1(1:numel(newX),newX,fi);
newY = interp1(1:numel(newY),newY,fi);
stidx = getChannels(hMainGui);
kObj = fliplr(find(ismember([Objects.Channel],stidx)));
for idx=kObj
    polyX=[lx ux(length(ux):-1:1)];
    polyY=[ly uy(length(uy):-1:1)];    
    OX=Objects(idx).Results(:,3)/hMainGui.Values.PixSize;
    OY=Objects(idx).Results(:,4)/hMainGui.Values.PixSize;
    IN=find(inpolygon(OX,OY,polyX,polyY)==1);
    k=find(Objects(idx).Results(IN,1)>=s&Objects(idx).Results(IN,1)<=e);
    KymoTrack=[];
    for n=1:length(k)
        [~,t]=min(sqrt( (newX-OX(IN(k(n)))).^2 + (newY-OY(IN(k(n)))).^2));
        KymoTrack(n,1:2)=[Objects(idx).Results(IN(k(n)),1)-s+1 fi(t)*KymoPixSize]; %#ok<AGROW> 
    end
    if isfield(Objects(idx),'PosStart') && ~isempty(KymoTrack)
        KymoTrack(end+1,:) = NaN;
        OX=Objects(idx).PosStart(:,1)/hMainGui.Values.PixSize;
        OY=Objects(idx).PosStart(:,2)/hMainGui.Values.PixSize;
        for n=1:length(k)
            [~,t]=min(sqrt( (newX-OX(IN(k(n)))).^2 + (newY-OY(IN(k(n)))).^2));
            KymoTrack(length(k)+1+n,1:2)=[Objects(idx).Results(IN(k(n)),1)-s+1 fi(t)*KymoPixSize]; %#ok<AGROW> 
        end
        KymoTrack(end+1,:) = NaN;
        OX=Objects(idx).PosEnd(:,1)/hMainGui.Values.PixSize;
        OY=Objects(idx).PosEnd(:,2)/hMainGui.Values.PixSize;
        for n=1:length(k)
            [~,t]=min(sqrt( (newX-OX(IN(k(n)))).^2 + (newY-OY(IN(k(n)))).^2));
            KymoTrack(2*length(k)+2+n,1:2)=[Objects(idx).Results(IN(k(n)),1)-s+1 fi(t)*KymoPixSize]; %#ok<AGROW> 
        end
    end
    if ~isempty(KymoTrack)
        KymoTrackObj(nTrack).Name=Objects(idx).Name;
        KymoTrackObj(nTrack).Index=idx;        
        KymoTrackObj(nTrack).Track=KymoTrack;        
        KymoTrackObj(nTrack).PlotHandles(1,1) = line(hMainGui.MidPanel.aKymoGraph,KymoTrack(:,2),KymoTrack(:,1),'Color',Objects(idx).Color,'Visible','off','Tag','pKymoTracks');
        if Objects(idx).Visible
            set(KymoTrackObj(nTrack).PlotHandles(1,1),'Visible','on');
        end
        nTrack=nTrack+1;
    end
end
idx = [KymoTrackObj.Index];
[~,k] = sort(idx);
KymoTrackObj = KymoTrackObj(k);

function CorrectKymoIndex(mode)
global Molecule;
global Filament;
global KymoTrackMol;
global KymoTrackFil;
if strcmp(mode,'Molecule')
    Objects=Molecule;
    KymoTrack=KymoTrackMol;
else
    Objects=Filament;
    KymoTrack=KymoTrackFil;
end
Names=cell(1,length(Objects));
for n=1:length(Objects)
    Names{n}=Objects(n).Name;
end    
for n=1:length(KymoTrack)
    KymoTrack(n).Index=strmatch(KymoTrack(n).Name, Names);    
end
if strcmp(mode,'Molecule')
    Molecule=Objects;
    KymoTrackMol=KymoTrack;
else
    Filament=Objects;
    KymoTrackFil=KymoTrack;
end
    

function UpdateMeasure(hMainGui)
set(hMainGui.fig,'Units','pixels');
ssizetemp = get(hMainGui.fig,'Position');
set(hMainGui.fig,'Units','normalized');
ssize = ssizetemp(3);
ssize = ssize * 0.178;
big = ceil(0.26*ssize);
if ~isempty(hMainGui.Measure)
    Data = [hMainGui.Measure.Data];
    Data = reshape(Data,4,size(Data,2)/4)';
    if isempty(Data)
        set(hMainGui.RightPanel.pTools.lCurrentMeasure,'Data',[],'ColumnName',[],'Enable','off','UIContextMenu','','UserData',{[],[]});
        set(hMainGui.RightPanel.pTools.bKeep,'Enable','off');
    else
        if strcmp(get(hMainGui.ToolBar.ToolKymoGraph,'State'),'off')
            k = find(Data(:,1)./Data(:,2) ~= Data(:,4)); % get all data from kymographs
            Data = Data(k,:);
            set(hMainGui.RightPanel.pTools.lCurrentMeasure,'Data',Data(:,1:4),'Enable','on','ColumnFormat',{'bank','bank','bank','bank'},...
                                                         'ColumnWidth',{big,big,big,big},'RowName','','ColumnName',...
                                                         {['<html><CENTER>Length/Area<br><CENTER>[' char(181) 'm/' char(181) 'm^2]'],...
                                                           '<html><CENTER>Mean<br><CENTER>',...
                                                           '<html><CENTER>Integral<br><CENTER>',...
                                                           '<html><CENTER>STD<br><CENTER>'},...
                                                           'UIContextMenu',hMainGui.Menu.ctMeasure,'UserData',{k,[]});
        else
            k = find(Data(:,1)./Data(:,2) == Data(:,4)); % get all data from kymographs
            Data = Data(k,:);
            velunit = char(181);
            if mean(Data(:,4))<0.1
                velunit = 'n';
                Data(:,4) = Data(:,4)*1000;
            end
            set(hMainGui.RightPanel.pTools.lCurrentMeasure,'Data',Data(:,1:4),'Enable','on','ColumnFormat',{'bank','bank','bank','bank'},...
                                                         'ColumnWidth',{big,big,big,big},'RowName','','ColumnName',...
                                                         {['<html><CENTER>Distance<br><CENTER>[' char(181) 'm]'],...
                                                           '<html><CENTER>Time<br><CENTER>[s]',...
                                                           '<html><CENTER>Frames<br><CENTER>',...
                                                          ['<html><CENTER>Velocity<br><CENTER>[' velunit 'm/s]']},...
                                                          'UIContextMenu',hMainGui.Menu.ctMeasure,'UserData',{k,[]});
        end
        set(hMainGui.RightPanel.pTools.bKeep,'Enable','on');
    end
    jTable = findjobj(hMainGui.RightPanel.pTools.lCurrentMeasure);
    jTable.setVerticalScrollBarPolicy(22);
    jTable.setHorizontalScrollBarPolicy(31);
    set(hMainGui.fig,'pointer','arrow');
else
    set(hMainGui.RightPanel.pTools.lCurrentMeasure,'Data',[],'ColumnName',[],'Enable','off','UIContextMenu','','UserData',{[],[]});
    set(hMainGui.RightPanel.pTools.bKeep,'Enable','off');
end    
if ~isempty(hMainGui.Measurements)
    Data = hMainGui.Measurements;
    if strcmp(get(hMainGui.ToolBar.ToolKymoGraph,'State'),'off')
        k = find(Data(:,1)./Data(:,2) ~= Data(:,4)); % get all data from kymographs
        Data = Data(k,:);
        set(hMainGui.RightPanel.pTools.lMeasureTable,'Data',Data(:,1:4),'Enable','on','ColumnFormat',{'bank','bank','bank','bank'},...
                                                     'ColumnWidth',{big,big,big,big},'RowName','','ColumnName',...
                                                     {['<html><CENTER>Length/Area<br><CENTER>[' char(181) 'm/' char(181) 'm^2]'],...
                                                       '<html><CENTER>Mean<br><CENTER>',...
                                                       '<html><CENTER>Integral<br><CENTER>',...
                                                       '<html><CENTER>STD<br><CENTER>'},...
                                                       'UIContextMenu',hMainGui.Menu.ctMeasure,'UserData',{k,[]});
    else
        k = find(Data(:,1)./Data(:,2) == Data(:,4)); % get all data from kymographs
        Data = Data(k,:);
        velunit = char(181);
        if mean(Data(:,4))<0.1
            velunit = 'n';
            Data(:,4) = Data(:,4)*1000;
        end
        set(hMainGui.RightPanel.pTools.lMeasureTable,'Data',Data(:,1:4),'Enable','on','ColumnFormat',{'bank','bank','bank','bank'},...
                                                     'ColumnWidth',{big,big,big,big},'RowName','','ColumnName',...
                                                     {['<html><CENTER>Distance<br><CENTER>[' char(181) 'm]'],...
                                                       '<html><CENTER>Time<br><CENTER>[s]',...
                                                       '<html><CENTER>Frames<br><CENTER>',...
                                                      ['<html><CENTER>Velocity<br><CENTER>[' velunit 'm/s]']},...
                                                      'UIContextMenu',hMainGui.Menu.ctMeasure,'UserData',{k,[]});
    end
    set(hMainGui.RightPanel.pTools.bSave,'Enable','on');
%    jTable = findjobj(hMainGui.RightPanel.pTools.lMeasureTable);
%    jTable.setVerticalScrollBarPolicy(22);
%    jTable.setHorizontalScrollBarPolicy(31);
else
    set(hMainGui.RightPanel.pTools.lMeasureTable,'Data',[],'ColumnName',[],'Enable','off','UIContextMenu','','UserData',{[],[]});
    set(hMainGui.RightPanel.pTools.bSave,'Enable','off');
end
setappdata(0,'hMainGui',hMainGui); 

function SetAllPanelsOff(hMainGui)
set(hMainGui.RightPanel.pData.panel,'Visible','off');
set(hMainGui.RightPanel.pTools.panel,'Visible','off');
set(hMainGui.RightPanel.pQueue.panel,'Visible','off');

function DataPanel(hMainGui)
SetAllPanelsOff(hMainGui);
set(hMainGui.RightPanel.pData.panel,'Visible','on');

function ToolsPanel(hMainGui)
SetAllPanelsOff(hMainGui);
set(hMainGui.RightPanel.pTools.panel,'Visible','on');

function QueuePanel(hMainGui)
SetAllPanelsOff(hMainGui);
set(hMainGui.RightPanel.pQueue.panel,'Visible','on');

function DataMoleculesPanel(hMainGui)
SetAllPanelsOff(hMainGui);
set(hMainGui.RightPanel.pData.panel,'Visible','on');
set(hMainGui.RightPanel.pData.pMoleculesPan,'Visible','on');
set(hMainGui.RightPanel.pData.pFilamentsPan,'Visible','off');

function DataFilamentsPanel(hMainGui)
SetAllPanelsOff(hMainGui);
set(hMainGui.RightPanel.pData.panel,'Visible','on');
set(hMainGui.RightPanel.pData.pMoleculesPan,'Visible','off');
set(hMainGui.RightPanel.pData.pFilamentsPan,'Visible','on');

function ToolsMeasurePanel(hMainGui)
SetAllPanelsOff(hMainGui);
set(hMainGui.RightPanel.pTools.panel,'Visible','on');
set(hMainGui.RightPanel.pTools.pMeasurePan,'Visible','on');
set(hMainGui.RightPanel.pTools.pScanPan,'Visible','off');

function ToolsScanPanel(hMainGui)
SetAllPanelsOff(hMainGui);
set(hMainGui.RightPanel.pTools.panel,'Visible','on');
set(hMainGui.RightPanel.pTools.pMeasurePan,'Visible','off');
set(hMainGui.RightPanel.pTools.pScanPan,'Visible','on');

function QueueServerPanel(hMainGui)
SetAllPanelsOff(hMainGui);
set(hMainGui.RightPanel.pQueue.panel,'Visible','on');
set(hMainGui.RightPanel.pQueue.pServerPan,'Visible','on');
set(hMainGui.RightPanel.pQueue.pLocalPan,'Visible','off');

function QueueLocalPanel(hMainGui)
SetAllPanelsOff(hMainGui);
set(hMainGui.RightPanel.pQueue.panel,'Visible','on');
set(hMainGui.RightPanel.pQueue.pServerPan,'Visible','off');
set(hMainGui.RightPanel.pQueue.pLocalPan,'Visible','on');

function AllToolsOff(hMainGui)
set(hMainGui.RightPanel.pTools.bLine,'Value',0);
set(hMainGui.RightPanel.pTools.bSegLine,'Value',0);
set(hMainGui.RightPanel.pTools.bFreehand,'Value',0);
set(hMainGui.RightPanel.pTools.bRectangle,'Value',0);
set(hMainGui.RightPanel.pTools.bEllipse,'Value',0);
set(hMainGui.RightPanel.pTools.bPolygon,'Value',0);
set(hMainGui.RightPanel.pTools.bLineScan,'Value',0);
set(hMainGui.RightPanel.pTools.bSegLineScan,'Value',0);
set(hMainGui.RightPanel.pTools.bFreehandScan,'Value',0);
if isfield(hMainGui,'Plots')
    if isfield(hMainGui.Plots,'Measure')
        nMeasure=numel(hMainGui.Plots.Measure);
        for n = nMeasure:-1:1
            if ~isgraphics(hMainGui.Plots.Measure(n))
                hMainGui.Plots.Measure(n)=[];
                hMainGui.Measure(n)=[];
            end
        end
        nMeasure=numel(hMainGui.Plots.Measure);
        if nMeasure>0
            color=get(hMainGui.Plots.Measure(nMeasure),'Color');    
            if sum(color)==3
                hMainGui.Values.CursorDownPos(:)=0; 
                delete(hMainGui.Plots.Measure(nMeasure));    
                hMainGui.Measure(nMeasure)=[];
                hMainGui.Plots.Measure(nMeasure)=[];
            end
        end
    end
    if isfield(hMainGui,'Region')
        nRegion=length(hMainGui.Region);
        if nRegion>0
            color=get(hMainGui.Plots.Region(nRegion),'Color');    
            if sum(color)==3
                hMainGui.Values.CursorDownPos(:)=0; 
                delete(hMainGui.Plots.Region(nRegion));
                hMainGui.Region(nRegion)=[];
                hMainGui.Plots.Region(nRegion)=[];
            end
        end
    end
end
plotScan=findobj('Tag','plotScan','-and','Type','line');
if ~isempty(plotScan)
    color=get(plotScan(1),'Color');    
    if sum(color)==3
        hMainGui.Values.CursorDownPos(:)=0;
        delete(plotScan);    
        hMainGui.Scan=[];
    end
end
setappdata(0,'hMainGui',hMainGui);

function ToggleTool(hMainGui)
value=get(gcbo,'Value');
fToolBar('Cursor',hMainGui);
hMainGui=getappdata(0,'hMainGui');
set(gcbo,'Value',value);
if value==1
    if strcmp(get(gcbo,'UserData'),'FilamentScan')
        set(gcbo,'Value',0);
    	CreateFilamentScan(hMainGui);
        hMainGui=getappdata(0,'hMainGui');
    else
        hMainGui.CursorMode=get(gcbo,'UserData');
    end
else
    hMainGui.CursorMode='Normal';
end
hMainGui.Values.CursorDownPos(:)=0;
setappdata(0,'hMainGui',hMainGui);

function UpdateList(hList,List,slider,UIContext)
l=length(List);
if l>8
    slider_step(1) = 1/(l-8);
    slider_step(2) = 8/(l-8);
    if strcmp(get(slider,'Enable'),'on')==1
        v=get(slider,'Value');
        if v>l-7
            v=l-7;
        end
        set(slider,'sliderstep',slider_step,...
         'max',l-7,'min',1,'Value',v)
    else
        set(slider,'sliderstep',slider_step,...
         'max',l-7,'min',1,'Value',l-7,'Enable','on')
    end
    ListBegin=(l-7)-round(get(slider,'Value'));
    ListLength=8;
else
    slider_step(1) = 0.1;
    slider_step(2) = 0.1;
    set(slider,'sliderstep',slider_step,...
         'max',1,'min',0,'Value',1,'Enable','off')
     ListLength=l;
     ListBegin=0;
end
CDataVisible(:,:,1)=[NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0.964705882352941,0.886274509803922,0.811764705882353,0.721568627450980,0.650980392156863,0.635294117647059,0.721568627450980,0.862745098039216,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,0.858823529411765,0.596078431372549,0.462745098039216,0.356862745098039,0.262745098039216,0.196078431372549,0.176470588235294,0.262745098039216,0.431372549019608,0.709803921568628,NaN,NaN,NaN;NaN,NaN,NaN,NaN,0.992156862745098,0.600000000000000,0.168627450980392,0,0,0,0,0,0,0,0,0,0,0.258823529411765,0.905882352941177,NaN;NaN,NaN,NaN,0.843137254901961,0.227450980392157,0,0,0,0,0,0,0,0,0,0,0,0,0,0.372549019607843,NaN;NaN,NaN,0.729411764705882,0.0509803921568627,0,0,0,0,0,0,0,0,0.0274509803921569,0.211764705882353,0.00392156862745098,0,0,0.0745098039215686,0.874509803921569,NaN;NaN,0.650980392156863,0,0,0,0,0.0392156862745098,0.168627450980392,0,0,0,0,0.0666666666666667,0.968627450980392,0.827450980392157,0.325490196078431,0,0,0.329411764705882,0.886274509803922;0.682352941176471,0.239215686274510,0.235294117647059,0,0.462745098039216,0.352941176470588,0.231372549019608,NaN,0.156862745098039,0,0,0,0.125490196078431,0.976470588235294,NaN,0.913725490196078,0.0117647058823529,0.129411764705882,0.129411764705882,0.800000000000000;0.937254901960784,0.674509803921569,0.0431372549019608,0.247058823529412,NaN,0.882352941176471,0.0941176470588235,0.976470588235294,0.403921568627451,0,0,0,0.376470588235294,NaN,NaN,0.603921568627451,0,0.317647058823529,0.960784313725490,0.960784313725490;0.984313725490196,0.121568627450980,0,0.447058823529412,NaN,NaN,0.407843137254902,0.266666666666667,0.258823529411765,0,0,0.0549019607843137,0.858823529411765,NaN,0.854901960784314,0.0627450980392157,0.0156862745098039,0.298039215686275,0.996078431372549,NaN;NaN,0.345098039215686,0,0.0313725490196078,0.717647058823529,NaN,NaN,0.305882352941177,0,0,0.164705882352941,0.784313725490196,NaN,0.858823529411765,0.109803921568627,0,0.384313725490196,0.890196078431373,NaN,NaN;NaN,0.862745098039216,0.0431372549019608,0,0,0.368627450980392,0.827450980392157,NaN,0.945098039215686,0.894117647058824,NaN,NaN,0.592156862745098,0.00784313725490196,0.0117647058823529,0.203921568627451,0.662745098039216,NaN,NaN,NaN;NaN,NaN,0.698039215686275,0,0,0,0,0.188235294117647,0.329411764705882,0.392156862745098,0.317647058823529,0.0823529411764706,0.0274509803921569,0.431372549019608,0.615686274509804,0.682352941176471,0.937254901960784,NaN,NaN,NaN;NaN,NaN,NaN,0.709803921568628,0.341176470588235,0,0,0,0.0313725490196078,0,0.266666666666667,0.372549019607843,0.537254901960784,0.690196078431373,0.937254901960784,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,0.972549019607843,0.592156862745098,0.109803921568627,0.0745098039215686,0.501960784313726,0.631372549019608,0.400000000000000,0.721568627450980,0.819607843137255,0.952941176470588,0.964705882352941,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,0.972549019607843,0.913725490196078,0.843137254901961,NaN,0.929411764705882,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;];
CDataVisible(:,:,2)=[NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0.964705882352941,0.886274509803922,0.811764705882353,0.721568627450980,0.650980392156863,0.635294117647059,0.721568627450980,0.862745098039216,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,0.858823529411765,0.596078431372549,0.462745098039216,0.356862745098039,0.262745098039216,0.196078431372549,0.176470588235294,0.262745098039216,0.431372549019608,0.709803921568628,NaN,NaN,NaN;NaN,NaN,NaN,NaN,0.992156862745098,0.600000000000000,0.168627450980392,0,0,0,0,0,0,0,0,0,0,0.258823529411765,0.905882352941177,NaN;NaN,NaN,NaN,0.843137254901961,0.227450980392157,0,0,0,0,0,0,0,0,0,0,0,0,0,0.372549019607843,NaN;NaN,NaN,0.729411764705882,0.0509803921568627,0,0,0,0,0,0,0,0,0.0274509803921569,0.211764705882353,0.00392156862745098,0,0,0.0745098039215686,0.874509803921569,NaN;NaN,0.650980392156863,0,0,0,0,0.0392156862745098,0.168627450980392,0,0,0,0,0.0666666666666667,0.968627450980392,0.827450980392157,0.325490196078431,0,0,0.329411764705882,0.886274509803922;0.682352941176471,0.239215686274510,0.235294117647059,0,0.462745098039216,0.352941176470588,0.231372549019608,NaN,0.156862745098039,0,0,0,0.125490196078431,0.976470588235294,NaN,0.913725490196078,0.0117647058823529,0.129411764705882,0.129411764705882,0.800000000000000;0.937254901960784,0.674509803921569,0.0431372549019608,0.247058823529412,NaN,0.882352941176471,0.0941176470588235,0.976470588235294,0.403921568627451,0,0,0,0.376470588235294,NaN,NaN,0.603921568627451,0,0.317647058823529,0.960784313725490,0.960784313725490;0.984313725490196,0.121568627450980,0,0.447058823529412,NaN,NaN,0.407843137254902,0.266666666666667,0.258823529411765,0,0,0.0549019607843137,0.858823529411765,NaN,0.854901960784314,0.0627450980392157,0.0156862745098039,0.298039215686275,0.996078431372549,NaN;NaN,0.345098039215686,0,0.0313725490196078,0.717647058823529,NaN,NaN,0.305882352941177,0,0,0.164705882352941,0.784313725490196,NaN,0.858823529411765,0.109803921568627,0,0.384313725490196,0.890196078431373,NaN,NaN;NaN,0.862745098039216,0.0431372549019608,0,0,0.368627450980392,0.827450980392157,NaN,0.945098039215686,0.894117647058824,NaN,NaN,0.592156862745098,0.00784313725490196,0.0117647058823529,0.203921568627451,0.662745098039216,NaN,NaN,NaN;NaN,NaN,0.698039215686275,0,0,0,0,0.188235294117647,0.329411764705882,0.392156862745098,0.317647058823529,0.0823529411764706,0.0274509803921569,0.431372549019608,0.615686274509804,0.682352941176471,0.937254901960784,NaN,NaN,NaN;NaN,NaN,NaN,0.709803921568628,0.341176470588235,0,0,0,0.0313725490196078,0,0.266666666666667,0.372549019607843,0.537254901960784,0.690196078431373,0.937254901960784,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,0.972549019607843,0.592156862745098,0.109803921568627,0.0745098039215686,0.501960784313726,0.631372549019608,0.400000000000000,0.721568627450980,0.819607843137255,0.952941176470588,0.964705882352941,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,0.972549019607843,0.913725490196078,0.843137254901961,NaN,0.929411764705882,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;];
CDataVisible(:,:,3)=[NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0.964705882352941,0.886274509803922,0.811764705882353,0.721568627450980,0.650980392156863,0.635294117647059,0.721568627450980,0.862745098039216,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,0.858823529411765,0.596078431372549,0.462745098039216,0.356862745098039,0.262745098039216,0.196078431372549,0.176470588235294,0.262745098039216,0.431372549019608,0.709803921568628,NaN,NaN,NaN;NaN,NaN,NaN,NaN,0.992156862745098,0.600000000000000,0.168627450980392,0,0,0,0,0,0,0,0,0,0,0.258823529411765,0.905882352941177,NaN;NaN,NaN,NaN,0.843137254901961,0.227450980392157,0,0,0,0,0,0,0,0,0,0,0,0,0,0.372549019607843,NaN;NaN,NaN,0.729411764705882,0.0509803921568627,0,0,0,0,0,0,0,0,0.0274509803921569,0.211764705882353,0.00392156862745098,0,0,0.0745098039215686,0.874509803921569,NaN;NaN,0.650980392156863,0,0,0,0,0.0392156862745098,0.168627450980392,0,0,0,0,0.0666666666666667,0.968627450980392,0.827450980392157,0.325490196078431,0,0,0.329411764705882,0.886274509803922;0.682352941176471,0.239215686274510,0.235294117647059,0,0.462745098039216,0.352941176470588,0.231372549019608,NaN,0.156862745098039,0,0,0,0.125490196078431,0.976470588235294,NaN,0.913725490196078,0.0117647058823529,0.129411764705882,0.129411764705882,0.800000000000000;0.937254901960784,0.674509803921569,0.0431372549019608,0.247058823529412,NaN,0.882352941176471,0.0941176470588235,0.976470588235294,0.403921568627451,0,0,0,0.376470588235294,NaN,NaN,0.603921568627451,0,0.317647058823529,0.960784313725490,0.960784313725490;0.984313725490196,0.121568627450980,0,0.447058823529412,NaN,NaN,0.407843137254902,0.266666666666667,0.258823529411765,0,0,0.0549019607843137,0.858823529411765,NaN,0.854901960784314,0.0627450980392157,0.0156862745098039,0.298039215686275,0.996078431372549,NaN;NaN,0.345098039215686,0,0.0313725490196078,0.717647058823529,NaN,NaN,0.305882352941177,0,0,0.164705882352941,0.784313725490196,NaN,0.858823529411765,0.109803921568627,0,0.384313725490196,0.890196078431373,NaN,NaN;NaN,0.862745098039216,0.0431372549019608,0,0,0.368627450980392,0.827450980392157,NaN,0.945098039215686,0.894117647058824,NaN,NaN,0.592156862745098,0.00784313725490196,0.0117647058823529,0.203921568627451,0.662745098039216,NaN,NaN,NaN;NaN,NaN,0.698039215686275,0,0,0,0,0.188235294117647,0.329411764705882,0.392156862745098,0.317647058823529,0.0823529411764706,0.0274509803921569,0.431372549019608,0.615686274509804,0.682352941176471,0.937254901960784,NaN,NaN,NaN;NaN,NaN,NaN,0.709803921568628,0.341176470588235,0,0,0,0.0313725490196078,0,0.266666666666667,0.372549019607843,0.537254901960784,0.690196078431373,0.937254901960784,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,0.972549019607843,0.592156862745098,0.109803921568627,0.0745098039215686,0.501960784313726,0.631372549019608,0.400000000000000,0.721568627450980,0.819607843137255,0.952941176470588,0.964705882352941,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,0.972549019607843,0.913725490196078,0.843137254901961,NaN,0.929411764705882,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;];
for i=1:ListLength
    fgcolor=[1 1 1];
    enableText='inactive';    
    enable='on';    
    bgcolor=get(slider,'Background');    
    switch(List(i+ListBegin).Selected)
        case 2
            bgcolor=[0.8 0 0];
        case 1
            bgcolor=[0 0 0.8];
        case 0
            fgcolor=[0 0 0];
        otherwise
            bgcolor=get(slider,'Background');
            enable='off';
            enableText='off';  
    end
    if List(i+ListBegin).Visible
        CData=CDataVisible;
    else
        CData=[];        
    end
    set(hList.Pan(i),'Visible','on','UIContextMenu',UIContext);    
    set(hList.Visible(i),'Enable',enable,'CData',CData,'UIContextMenu',UIContext);        
    set(hList.Name(i),'Enable',enableText,'BackgroundColor',bgcolor,'ForegroundColor',fgcolor,'UIContextMenu',UIContext,'String',List(i+ListBegin).Name);
    set(hList.File(i),'Enable',enableText,'BackgroundColor',bgcolor,'ForegroundColor',fgcolor,'UIContextMenu',UIContext,'String',List(i+ListBegin).File);
    set(hList.Back(i),'BackgroundColor',bgcolor);            
    set(hList.Button(i),'Enable',enable,'UIContextMenu',UIContext);
end
for i=ListLength+1:8
    set(hList.Pan(i),'Visible','off');    
end

function QueueSlider
Mode=get(gcbo,'UserData');
UpdateQueue(Mode);
fShared('ReturnFocus');

function UpdateQueue(mode)
hMainGui=getappdata(0,'hMainGui');
global Queue;
if strcmp(mode,'Local')
    hQueue=hMainGui.RightPanel.pQueue.LocList;
    slider=hMainGui.RightPanel.pQueue.sLocList;
    NewQueue=Queue;
else
    DirServer = fShared('CheckServer');
    hQueue=hMainGui.RightPanel.pQueue.SrvList;
    slider=hMainGui.RightPanel.pQueue.sSrvList;
    [NewQueue,Status]=fGetServerQueue;
end    
l=length(NewQueue);
if l>9
    slider_step(1) = 1/(l-9);
    slider_step(2) = 9/(l-9);
    if strcmp(get(slider,'Enable'),'on')==1
        v=get(slider,'Value');
        if v>l-8
            v=l-8;
        end
    else
        v=l-8;
    end
    set(slider,'sliderstep',slider_step,'max',l-8,'min',1,'Value',v,'Enable','on')
    QueueBegin=(l-8)-round(get(slider,'Value'));
    QueueLength=9;
else
    slider_step(1) = 0.1;
    slider_step(2) = 0.1;
    set(slider,'sliderstep',slider_step,...
         'max',1,'min',0,'Value',1,'Enable','off')
     QueueLength=l;
     QueueBegin=0;
end
for i=1:QueueLength
    bgcolor=get(slider,'Background');    
    fgcolor=[1 1 1];
    switch(NewQueue(i+QueueBegin).Selected)
        case 1
            bgcolor=[0 0 0.8];
        case 0
            fgcolor=[0 0 0];
    end            
    if strcmp(mode,'Local')
        set(hQueue.Pan(i),'Visible','on','UIContextMenu',hMainGui.Menu.ctListLoc);    
        set(hQueue.Name(i),'Enable','inactive','BackgroundColor',bgcolor,'ForegroundColor',fgcolor,'UIContextMenu',hMainGui.Menu.ctListLoc,'String',NewQueue(i+QueueBegin).StackName);
        set(hQueue.File(i),'Enable','inactive','BackgroundColor',bgcolor,'ForegroundColor',fgcolor,'UIContextMenu',hMainGui.Menu.ctListLoc,'String',NewQueue(i+QueueBegin).Directory);
        set(hQueue.Back(i),'BackgroundColor',bgcolor,'UIContextMenu',hMainGui.Menu.ctListLoc); 
    else
        set(hQueue.Pan(i),'Visible','on');    
        set(hQueue.Name(i),'Enable','inactive','BackgroundColor',bgcolor,'ForegroundColor',fgcolor,'String',NewQueue(i+QueueBegin).StackName);
        set(hQueue.File(i),'BackgroundColor',bgcolor,'ForegroundColor',fgcolor,'Enable','inactive','String','');
        set(hQueue.Back(i),'BackgroundColor',bgcolor); 
    end
end
for i=QueueLength+1:9
    set(hQueue.Pan(i),'Visible','off');
end
if strcmp(mode,'Local')
    enable='off';
    if l>0
        enable='on';
    end
    set(hMainGui.Menu.mAnalyseQueue,'Enable',enable);
    set(hMainGui.RightPanel.pButton.bAnalyse,'Enable',enable);
else
    for n=1:length(Status)
        dirStatus = [DirServer 'Queue' filesep 'Job' int2str(Status(n).JobNr) filesep 'Status'];
        if isdir(dirStatus) && ~isempty(Status(n).FramesT)
            files = dir([dirStatus filesep '*.mat']);
            Status(n).StatusT = length(files)/Status(n).FramesT;
        else
            Status(n).StatusT = 0;
        end
        if isnan(Status(n).StatusT)
            Status(n).StatusT = 0;
        end
        if strcmp(get(slider,'Enable'),'on')==1 && l>9
            QueueNr = v-l+8 + n;
        else
            QueueNr=n;
        end
        if QueueNr>0
            set(hQueue.File(QueueNr),'String',{sprintf('Tracking: %3.0f%% (%s)',Status(n).StatusT*100,getTime(Status(n).TimeT,Status(n).StatusT)),...
                                               sprintf('Connecting: %3.0f%% (%s)',Status(n).StatusC*100,getTime(Status(n).TimeC,Status(n).StatusC)),...
                                               sprintf('Postprocessing: %3.0f%% (%s)',Status(n).StatusP*100,getTime(Status(n).TimeP,Status(n).StatusP))});
        end                                  
    end
end

function timeleft = getTime(starttime,status)
if status>0
    try
        runtime = etime(clock,starttime);
    catch
        runtime = 0;
    end
    if runtime>0
        timeleft = sec2timestr( runtime/status - runtime );
    else
        timeleft = '??:??:??';
    end
else
    timeleft = '??:??:??';
end

function RefreshServerQueue(hMainGui)
DirServer = fShared('CheckServer');
if isempty(DirServer)
    fShared('ReturnFocus');
    return;
end
set(hMainGui.RightPanel.pQueue.bSrvRefresh,'String','Refresh SERVER Queue');
UpdateQueue('Server');
fShared('ReturnFocus');

function LoadQueue
global Queue;
[FileName, PathName] = uigetfile({'*.mat','FIESTA Queue(*.mat)'},'Load FIESTA Queue',fShared('GetLoadDir'));
if FileName~=0
    fShared('SetLoadDir',PathName);
    Queue=fLoad([PathName FileName],'Queue');
    UpdateQueue('Local');    
end
fShared('ReturnFocus');

function SaveQueue
global Queue;
if ~isempty(Queue)
    [FileName, PathName] = uiputfile({'*.mat','MAT-files (*.mat)'},'Save FIESTA Queue',fShared('GetSaveDir'));
    if FileName~=0
        file = [PathName FileName];
        if isempty(findstr('.mat',file))
            file = [file '.mat'];
        end
        fShared('SetSaveDir',PathName);
        save(file,'Queue');
    end
end
fShared('ReturnFocus');

function timestr = sec2timestr(sec)
% Convert seconds to hh:mm:ss
h = floor(sec/3600); % Hours
sec = sec - h*3600;
m = floor(sec/60); % Minutes
sec = sec - m*60;
s = floor(sec); % Seconds

if isnan(sec),
    h = 0;
    m = 0;
    s = 0;
end

if h < 10; h0 = '0'; else h0 = '';end     % Put leading zero on hours if < 10
if m < 10; m0 = '0'; else m0 = '';end     % Put leading zero on minutes if < 10
if s < 10; s0 = '0'; else s0 = '';end     % Put leading zero on seconds if < 10
timestr = strcat(h0,num2str(h),':',m0,...
          num2str(m),':',s0,num2str(s));

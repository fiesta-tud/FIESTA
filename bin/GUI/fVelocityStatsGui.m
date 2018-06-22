function fVelocityStatsGui(func,varargin)
if nargin == 0
    func = 'Create';
end
switch func
    case 'Create'
        Create;
    case 'Calculate'
        Calculate(varargin{1});               
    case 'Save'
        Save;   
    case 'Export'
        Export;   
    case 'Update'
        Update;  
    case 'FitGauss'
        FitGauss;  
    case 'Draw'
        Draw(varargin{1});
end

function Create
global Molecule;
global Filament;

h=findobj('Tag','hVelocityStatsGui');
close(h)

MolSelect = [Molecule.Selected];
FilSelect = [Filament.Selected];

if any(MolSelect) && any(FilSelect)
    fMsgDlg({'Molecules and filaments selected','Choose only molecules or only filaments'},'error');
    return;
elseif any(MolSelect)
    Objects=Molecule(MolSelect==1);
    hVelocityStatsGui.Mode = 'Molecule';
elseif any(FilSelect)
    Objects=Filament(FilSelect==1);
    hVelocityStatsGui.Mode = 'Filament';
else
    fMsgDlg('No track selected!','error');
    return;
end
    
hVelocityStatsGui.fig = figure('Units','normalized','WindowStyle','normal','DockControls','off','IntegerHandle','off','MenuBar','none','Name','Average Velocity',...
                      'NumberTitle','off','Position',[0.4 0.3 0.2 0.3],'HandleVisibility','callback','Tag','hVelocityStatsGui',...
                      'Visible','off','Resize','off','Renderer', 'painters');

fPlaceFig(hVelocityStatsGui.fig,'big');

if ispc
    set(hVelocityStatsGui.fig,'Color',[236 233 216]/255);
end

c = get(hVelocityStatsGui.fig,'Color');

hVelocityStatsGui.pPlotPanel = uipanel('Parent',hVelocityStatsGui.fig,'Position',[0.4 0.55 0.575 0.42],'Tag','PlotPanel','BackgroundColor','white');

hVelocityStatsGui.aPlot = axes('Parent',hVelocityStatsGui.pPlotPanel,'Units','normalized','OuterPosition',[0 0 1 1],'Tag','Plot','TickDir','in');

str=cell(length(Objects),1);
for i=1:length(Objects)
    str{i}=Objects(i).Name;
end

hVelocityStatsGui.lSelection = uicontrol('Parent',hVelocityStatsGui.fig,'Units','normalized','BackgroundColor',[1 1 1],'Callback','fVelocityStatsGui(''Draw'',getappdata(0,''hVelocityStatsGui''));',...
                                   'Position',[0.025 0.78 0.35 0.19],'String',str,'Style','listbox','Value',1,'Tag','lSelection');
                    
hVelocityStatsGui.pOptions = uipanel('Parent',hVelocityStatsGui.fig,'Units','normalized','Title','Options',...
                             'Position',[0.025 0.55 0.35 0.2],'Tag','pOptions','BackgroundColor',c);
                         
hVelocityStatsGui.tMethod = uicontrol('Parent',hVelocityStatsGui.pOptions,'Units','normalized','BackgroundColor',c,...
                             'Position',[0.05 0.8 0.225 0.125],'String','Method:','Style','text','Tag','tMethod','HorizontalAlignment','left');                        
                         
hVelocityStatsGui.mMethod = uicontrol('Parent',hVelocityStatsGui.pOptions,'Units','normalized','Callback','fVelocityStatsGui(''Update'');',...
                             'Position',[0.3 0.8 0.65 0.125],'BackgroundColor','white','String',{'2D point-point velocity','1D point-point velocity','1D linear fit to complete trace','1D linear fit to partial trace'},'Style','popupmenu','Tag','mMethod');

hVelocityStatsGui.tData = uicontrol('Parent',hVelocityStatsGui.pOptions,'Units','normalized','BackgroundColor',c,...
                             'Position',[0.05 0.65 0.225 0.125],'String','Data:','Style','text','Tag','tData','HorizontalAlignment','left');     

hVelocityStatsGui.mData = uicontrol('Parent',hVelocityStatsGui.pOptions,'Units','normalized','Callback','fVelocityStatsGui(''Update'');',...
                            'Position',[0.3 0.65 0.65 0.125],'BackgroundColor','white','String','','Style','popupmenu','Tag','mData','Enable','on');             
 
hVelocityStatsGui.tSmooth = uicontrol('Parent',hVelocityStatsGui.pOptions,'Units','normalized','BackgroundColor',c,...
                             'Position',[0.05 0.5 0.225 0.125],'String','Smooth:','Style','text','Tag','tSmooth','HorizontalAlignment','left'); 
                        
hVelocityStatsGui.mSmooth = uicontrol('Parent',hVelocityStatsGui.pOptions,'Units','normalized','Callback','fVelocityStatsGui(''Update'');',...
                             'Position',[0.3 0.5 0.65 0.125],'BackgroundColor','white','String',{'none'},'Style','popupmenu','Tag','mSmooth','Enable','on');
                         
hVelocityStatsGui.aEquation = axes('Parent',hVelocityStatsGui.pOptions,'Units','normalized',....
                                  'Position',[0.05 .025 .9 .45],'Tag','aEquation','Visible','off');  

ShowEquation(hVelocityStatsGui)

SetData(hVelocityStatsGui);
if strcmp(hVelocityStatsGui.Mode,'Filament')
    set(hVelocityStatsGui.mData,'Value',2);
end

hVelocityStatsGui.pResultsPanel = uipanel('Parent',hVelocityStatsGui.fig,'Position',[0.025 0.08 0.95 0.445],'Tag','PlotPanel','BackgroundColor','white');

hVelocityStatsGui.aResults = axes('Parent',hVelocityStatsGui.pResultsPanel,'Units','normalized','OuterPosition',[0 0 1 1],'Tag','Plot','TickDir','in');
                        
hConfigGui.pButtons = uipanel('Parent',hVelocityStatsGui.fig,'Units','normalized','Fontsize',12,'Bordertype','none',...
                                     'Position',[0 0 1 0.07],'Tag','pNorm','Visible','on','BackgroundColor',c);
       
hConfigGui.bFitGauss = uicontrol('Parent',hConfigGui.pButtons,'Style','pushbutton','Units','normalized',...
                              'Position',[.025 .2 .2 .7],'Tag','bFitGauss','Fontsize',12,...
                              'String','Fit Gaussian','Callback','fVelocityStatsGui(''FitGauss'');');     
                          
hConfigGui.bSave = uicontrol('Parent',hConfigGui.pButtons,'Style','pushbutton','Units','normalized',...
                              'Position',[.325 .2 .2 .7],'Tag','bSave','Fontsize',12,...
                              'String','Save Data','Callback','fVelocityStatsGui(''Save'');');         
                          
hConfigGui.bExport = uicontrol('Parent',hConfigGui.pButtons,'Style','pushbutton','Units','normalized',...
                              'Position',[.55 .2 .2 .7],'Tag','bSave','Fontsize',12,...
                              'String','Export Histogram','Callback','fVelocityStatsGui(''Export'');');   
                          
hConfigGui.bClose = uicontrol('Parent',hConfigGui.pButtons,'Style','pushbutton','Units','normalized',...
                              'Position',[.775 .2 .2 .7],'Tag','bClose','Fontsize',12,...
                              'String','Close','Callback','close(findobj(0,''Tag'',''hVelocityStatsGui''));');                        
                                   
setappdata(0,'hVelocityStatsGui',hVelocityStatsGui);
setappdata(hVelocityStatsGui.fig,'Objects',Objects);
Update;
set(hVelocityStatsGui.fig,'Visible','on');


function ShowEquation(hVelocityStatsGui)
cla(hVelocityStatsGui.aEquation);
switch get(hVelocityStatsGui.mMethod,'Value')
    case 1
        str = '\(v_k=\frac{ \sum \limits_{^{n=k-1}}^{_{k+1}} \sqrt{ \left(x_{n}-x_{k}\right)^2 + \left(y_{n}-y_{k}\right)^2}}{t_{k+1}-t_{k-1}}\)';
    case 2
        str = '\(v_k=\frac{D_{k+1}-D_{k-1}}{t_{k+1}-t_{k-1}}\)';
    case 3
        str = '\(v=a \ \ \ \ \ \begin{array}{cc} D_{k} = a \cdot t_{k}+b \\ \forall k=1...N \end{array} \)';
    case 4
        str = '\( \begin{array}{ll} \tilde{t}_{k}=  \sum \limits_{^{k-f}}^{_{k+f}} \frac{t_{n}}{2f+1} \\ v_{k}=a \end{array} \ \begin{array}{cc} D_{n} = a \cdot t_{n}+b \\ _{\forall n=k-f...k+f} \end{array} \)';
        
end
text('Parent',hVelocityStatsGui.aEquation,'Interpreter','latex','Position',[0.01 0.5],...
     'FontSize',14,'BackgroundColor',get(hVelocityStatsGui.fig,'Color'),'String',str);
 
function SetData(hVelocityStatsGui)
switch get(hVelocityStatsGui.mMethod,'Value')
    case 1
        if strcmp(hVelocityStatsGui.Mode,'Molecule')
            str = 'x-y-position';
            set(hVelocityStatsGui.mData,'Value',1)
        else
            str = {'x-y-position(start)','x-y-position(center)','x-y-position(end)'};
        end
        set(hVelocityStatsGui.mSmooth,'String','none','Value',1);
    otherwise
        str = {'distance to origin','distance along path'};
        set(hVelocityStatsGui.mSmooth,'String',{'none','rolling frame average'});
end
set(hVelocityStatsGui.mData,'String',str);
       
function Save
hVelocityStatsGui = getappdata(0,'hVelocityStatsGui');
Data = getappdata(hVelocityStatsGui.fig,'Data');
Units = getappdata(hVelocityStatsGui.fig,'Units');
[FileName, PathName, FilterIndex] = uiputfile({'*.mat','MAT-File (*.mat)';'*.txt','TXT-File (*.txt)';},'Save Velocity Data',fShared('GetSaveDir'));
if FileName~=0
    fShared('SetSaveDir',PathName);
    file = [PathName FileName];
    if FilterIndex==1
        if isempty(strfind(file,'.mat'))
            file = [file '.mat'];
        end
        Histogram=Data.hist; %#ok<NASGU>
        Velocities=cell2mat(Data.vel)'; %#ok<NASGU>
        Objects=cell(1,length(Data.vel));
        for n=1:length(Data.vel)
            Objects{n}=[Data.time{n}' Data.vel{n}'];
        end
        if isfield(Data,'fit')
            GaussFit=Data.fit; %#ok<NASGU>
            save(file,'Histogram','Velocities','Objects','GaussFit');
        else
            save(file,'Histogram','Velocities','Objects');
        end
    else
        if isempty(strfind(file,'.txt'))
            file = [file '.txt'];
        end
        f = fopen(file,'w');
        fprintf(f,['Velocity Statistics for ' num2str(length(Data.vel)) ' ' hVelocityStatsGui.Mode 's (' datestr(clock) ')\n']);
        fprintf(f,['Velocity(mean): ' num2str(mean(cell2mat(Data.vel)),Units.fmt) ' ' char(177) ' ' num2str(std(cell2mat(Data.vel)),Units.fmt) ' ' Units.str '/s (SD)\n']);
        if isfield(Data,'fit')
            params = coeffvalues(Data.fit);
            for n = 1:round(length(params)/3);
                fprintf(f,['Velocity(peak' num2str(n) '): ' num2str(params(3*n-1),Units.fmt) ' ' char(177) ' ' num2str(params(n*3)/sqrt(2),Units.fmt) ' ' Units.str '/s (SD)\n']); 
            end
        end
        fprintf(f,'\n');
        fprintf(f,'Histogram(center of bins)\n');
        fprintf(f,['velocity[' Units.str '/s]\tfrequency[counts]\n']);
        for n = 1:size(Data.hist,1)
            fprintf(f,[Units.fmt '\t%9.0f\n'],Data.hist(n,1),Data.hist(n,2));
        end
        fprintf(f,'\n');
        fprintf(f,'velocities[nm/s]\n');
        vel = cell2mat(Data.vel);
        for n = 1:length(vel)
            fprintf(f,[Units.fmt '\n'],vel(n));
        end
        fclose(f);
    end  
    fShared('SetSaveDir',PathName);
end

function Export
hVelocityStatsGui = getappdata(0,'hVelocityStatsGui');
Data = getappdata(hVelocityStatsGui.fig,'Data');
Units = getappdata(hVelocityStatsGui.fig,'Units');
[FileName, PathName, FilterIndex] = uiputfile({'*.jpg','JPEG-File (*.jpg)';'*.png','PNG-File (*.png)';'*.eps','EPS-File (*.eps)'},'Export Histogram',fShared('GetSaveDir'));
if FileName~=0
    file = [PathName FileName];
    hFig = figure('Visible','on');
    hAxes = axes('Parent',hFig,'TickDir','in');
    bar(hAxes,Data.hist(:,1),Data.hist(:,2),'BarWidth',1,'FaceColor',[179/255 199/255 1]); 
    if isfield(Data,'fit')
        hold on
        f = Data.fit;
        plot(f,'r-');
        params = coeffvalues(f);
        for m = 1:length(params)/3
            text(params(m*3-1),f(params(m*3-1))+max(Data.hist(:,2))*0.05,['Velocity: ' num2str(params(m*3-1),Units.fmt) ' ' char(177) ' ' num2str(params(m*3)/sqrt(2),Units.fmt) ' nm/s (SD)'],'VerticalAlignment','Bottom','HorizontalAlignment','center','Tag','fit','FontSize',12,'FontWeight','normal','BackgroundColor','w');   
        end
        legend(hAxes,{'Velocities','Gaussian fit'},'Location','best');
    else
        legend(hAxes,{'Velocities'},'Location','best');
    end
    xlabel(hAxes,['velocity [' Units.str '/s]']);
    ylabel(hAxes,'frequency [counts]');  
    barwidth = (Data.xy{1}(2)-Data.xy{1}(1))/size(Data.hist,1);
    if Data.hist(1,1)<0 && Data.hist(end,1)>0
        ticks = [fliplr(0:-2*barwidth:Data.hist(1,1)-barwidth/2) 2*barwidth:2*barwidth:Data.hist(end,1)+barwidth/2];
    else
        ticks = Data.hist(1,1)-barwidth/2:2*barwidth:Data.hist(end,1)+barwidth/2;
    end
    set(hAxes,{'xlim','ylim'},Data.xy,'XTick',ticks);
    box on;
    switch FilterIndex
        case 1
            if isempty(strfind(file,'.jpg'))
                file = [file '.jpg'];
            end
            print(hFig,'-djpeg','-r600',file);
        case 2
            if isempty(strfind(file,'.png'))
                file = [file '.png'];
            end
            print(hFig,'-dpng','-r600',file);
        case 3
            if isempty(strfind(file,'.eps'))
                file = [file '.eps'];
            end
            print(hFig,'-depsc','-cmyk',file);
    end
    delete(hFig);
    fShared('SetSaveDir',PathName);
end

function Update
hVelocityStatsGui = getappdata(0,'hVelocityStatsGui');
ShowEquation(hVelocityStatsGui);
SetData(hVelocityStatsGui);
if gcbo == hVelocityStatsGui.mMethod && get(hVelocityStatsGui.mMethod,'Value')>3
    hVelocityStatsGui.FitInterval = str2double(fInputDlg('Enter interval f for fitting [k-f ... k+f]','5'));
    if isnan(hVelocityStatsGui.FitInterval)
        hVelocityStatsGui.FitInterval = [];
    end   
end
if gcbo == hVelocityStatsGui.mSmooth && get(hVelocityStatsGui.mSmooth,'Value')>1
    hVelocityStatsGui.SmoothBox = str2double(fInputDlg('Enter box size for smoothing using a rolling frame average','5'));
    if isnan(hVelocityStatsGui.SmoothBox)
        hVelocityStatsGui.SmoothBox = [];
        set(hVelocityStatsGui.mSmooth,'Value',1);
    end   
end
if gcbo == hVelocityStatsGui.mMethod && get(hVelocityStatsGui.mData,'Value')>2
    set(hVelocityStatsGui.mData,'Value',2)
end  
setappdata(0,'hVelocityStatsGui',hVelocityStatsGui);
Calculate(hVelocityStatsGui)

function vel=CalcVelocity2D(T,XYZ)
global Config;
nData=size(XYZ,1);
if any(isnan(XYZ(:,3)))
    XYZ(:,3)=0;
end
if nData>1
    vel=zeros(1,nData);
    vel(1)=sqrt(sum((XYZ(2,:)-XYZ(1,:)).^2))/(T(2) - T(1));
    vel(nData)=sqrt(sum((XYZ(nData,:)-XYZ(nData-1,:)).^2))/(T(nData) - T(nData-1));
    parfor (i=2:nData-1,Config.NumCores)
       vel(i)= (sqrt(sum((XYZ(i+1,:)-XYZ(i,:)).^2)) + sqrt(sum((XYZ(i,:)-XYZ(i-1,:)).^2)))/(T(i+1) - T(i-1));
    end
else
    vel=0;
end

function vel = CalcVelocity1D(T,D)
nData = length(D);
if nData>1
    vel = zeros(1,nData);
    vel(1) = ( D(2) - D(1) ) / ( T(2) - T(1) );
    vel(2:nData-1) = ( D(3:nData) - D(1:nData-2) ) ./ ( T(3:nData) - T(1:nData-2) );
    vel(nData) = ( D(nData) - D(nData-1) ) / ( T(nData) - T(nData-1) );
else
    vel = [];
end

function vel = Fit1D(T,D,f)
global Config;
nData = length(D);
T = double(T);
D = double(D);
if nData>1
    vel = zeros(1,nData);
    parfor (n = 1:nData,Config.NumCores)
        p = fit(T(max([1 n-f]):min([nData n+f])),D(max([1 n-f]):min([nData n+f])),'poly1');
        vel(n) = p.p1;
    end
else
    vel = [];
end

function Calculate(hVelocityStatsGui)
Objects = getappdata(hVelocityStatsGui.fig,'Objects');
vel = cell(1,length(Objects));
time = cell(1,length(Objects));
switch get(hVelocityStatsGui.mMethod,'Value')
    case 1
        for n = 1:length(Objects)
            vel{n}=[];
            time{n}=[];
            if size(Objects(n).Results,1)>1
                if strcmp(hVelocityStatsGui.Mode,'Molecule')
                    vel{n} = CalcVelocity2D(Objects(n).Results(:,2),Objects(n).Results(:,3:5));
                else
                    if get(hVelocityStatsGui.mData,'Value') == 1 
                        vel{n} = CalcVelocity2D(Objects(n).Results(:,2),Objects(n).PosStart(:,1:3));
                    end
                    if get(hVelocityStatsGui.mData,'Value') == 2 
                        vel{n} = CalcVelocity2D(Objects(n).Results(:,2),Objects(n).PosCenter(:,1:3));
                    end
                    if get(hVelocityStatsGui.mData,'Value') == 3 
                        vel{n} = CalcVelocity2D(Objects(n).Results(:,2),Objects(n).PosEnd(:,1:3));
                    end
                end
                time{n} = Objects(n).Results(:,2)';
            end
        end    
    case 2
        for n = 1:length(Objects)  
            vel{n}=[];
            time{n}=[];
            if size(Objects(n).Results,1)>1
                if get(hVelocityStatsGui.mData,'Value')==1
                    if get(hVelocityStatsGui.mSmooth,'Value')==1 || isempty(hVelocityStatsGui.SmoothBox)
                        vel{n} = CalcVelocity1D(Objects(n).Results(:,2),Objects(n).Results(:,6));
                    else
                        vel{n} = CalcVelocity1D(Objects(n).Results(:,2),smooth(Objects(n).Results(:,6),hVelocityStatsGui.SmoothBox));
                    end
                else
                    if ~isempty(Objects(n).PathData)
                        if get(hVelocityStatsGui.mSmooth,'Value')==1 || isempty(hVelocityStatsGui.SmoothBox)
                            vel{n} = CalcVelocity1D(Objects(n).Results(:,2),real(Objects(n).PathData(:,4)));
                        else
                            vel{n} = CalcVelocity1D(Objects(n).Results(:,2),smooth(real(Objects(n).PathData(:,4)),hVelocityStatsGui.SmoothBox));
                        end
                    end
                end
                time{n} = Objects(n).Results(:,2)';
            end
        end  
    case 3
        for n = 1:length(Objects) 
            f=[];
            if size(Objects(n).Results,1)>1
                if get(hVelocityStatsGui.mData,'Value')==1
                    if get(hVelocityStatsGui.mSmooth,'Value')==1 || isempty(hVelocityStatsGui.SmoothBox)
                        f = fit(double(Objects(n).Results(:,2)),double(Objects(n).Results(:,6)),'poly1');
                    else
                        f = fit(double(Objects(n).Results(:,2)),smooth(double(Objects(n).Results(:,6)),hVelocityStatsGui.SmoothBox),'poly1');
                    end
                else
                    if ~isempty(Objects(n).PathData)
                        if get(hVelocityStatsGui.mSmooth,'Value')==1 || isempty(hVelocityStatsGui.SmoothBox)
                            f = fit(double(Objects(n).Results(:,2)),double(real(Objects(n).PathData(:,4))),'poly1');
                        else
                            f = fit(double(Objects(n).Results(:,2)),smooth(double(real(Objects(n).PathData(:,4))),hVelocityStatsGui.SmoothBox),'poly1');
                        end
                    end
                end
            end
            if isempty(f) 
                vel{n} = [];
                time{n} = [];
            else
                vel{n} = f.p1;
                time{n} = f.p2;
            end
        end
    case 4
        progressdlg('String','Calculating velocities','Min',0,'Max',length(Objects),'Parent',hVelocityStatsGui.fig);
        for n = 1:length(Objects)  
            vel{n}=[];
            time{n}=[];
            if size(Objects(n).Results,1)>1 
                if get(hVelocityStatsGui.mData,'Value')==1
                    if get(hVelocityStatsGui.mSmooth,'Value')==1 || isempty(hVelocityStatsGui.SmoothBox)
                        vel{n} = Fit1D(Objects(n).Results(:,2),Objects(n).Results(:,6),hVelocityStatsGui.FitInterval);
                    else
                        vel{n} = Fit1D(Objects(n).Results(:,2),smooth(Objects(n).Results(:,6),hVelocityStatsGui.SmoothBox),hVelocityStatsGui.FitInterval);
                    end
                else
                    if ~isempty(Objects(n).PathData)
                        if get(hVelocityStatsGui.mSmooth,'Value')==1 || isempty(hVelocityStatsGui.SmoothBox)
                            vel{n} = Fit1D(Objects(n).Results(:,2),real(Objects(n).PathData(:,4)),hVelocityStatsGui.FitInterval);
                        else
                            vel{n} = Fit1D(Objects(n).Results(:,2),smooth(real(Objects(n).PathData(:,4)),hVelocityStatsGui.SmoothBox),hVelocityStatsGui.FitInterval);
                        end
                    end
                end
                time{n} = Objects(n).Results(:,2)';
            end     
            progressdlg(n);
        end
end
Data = [];
if mean(cell2mat(vel))+std(cell2mat(vel))>1500
    Units.str = 'um';
    Units.val = 1000;
    Units.fmt = '%5.2f';
else
    Units.str = 'nm';
    Units.val = 1;
    Units.fmt = '%4.0f';
end
for n=1:length(vel)
    vel{n}=vel{n}/Units.val;
end 
Data.vel=vel;
Data.time=time;
setappdata(hVelocityStatsGui.fig,'Data',Data);
setappdata(hVelocityStatsGui.fig,'Units',Units);
Draw(hVelocityStatsGui)

function Draw(hVelocityStatsGui)
Objects = getappdata(hVelocityStatsGui.fig,'Objects');
Data = getappdata(hVelocityStatsGui.fig,'Data');
Units = getappdata(hVelocityStatsGui.fig,'Units');
nObject = get(hVelocityStatsGui.lSelection,'Value');
cla(hVelocityStatsGui.aPlot);
if isempty(Data.vel{nObject})
    text(0.2,0.5,'No data available for current object','Parent',hVelocityStatsGui.aPlot,'FontWeight','bold','FontSize',16);
    set(hVelocityStatsGui.aPlot,'Visible','off');
    legend(hVelocityStatsGui.aPlot,'off');
else
    switch get(hVelocityStatsGui.mMethod,'Value')
        case 1
            plot(hVelocityStatsGui.aPlot,Data.time{nObject},Data.vel{nObject},'b-');
            legend(hVelocityStatsGui.aPlot,['Velocity: ' num2str(mean(Data.vel{nObject}),Units.fmt) ' ' char(177) ' ' num2str(std(Data.vel{nObject}),Units.fmt) ' ' Units.str '/s (SD)'],'Location','best');
            xlabel(hVelocityStatsGui.aPlot,'time [s]');
            ylabel(hVelocityStatsGui.aPlot,['velocity [' Units.str '/s]']);
            set(hVelocityStatsGui.aPlot,'Visible','on');
        case 2
            if isempty(Data.vel{nObject})
                text(0.3,0.5,'No path available','Parent',hVelocityStatsGui.aPlot,'FontWeight','bold','FontSize',16);
                set(hVelocityStatsGui.aPlot,'Visible','off');
                legend(hVelocityStatsGui.aPlot,'off');
            else
                plot(hVelocityStatsGui.aPlot,Data.time{nObject},Data.vel{nObject},'b-');
                legend(hVelocityStatsGui.aPlot,['Velocity: ' num2str(mean(Data.vel{nObject}),Units.fmt) ' ' char(177) ' ' num2str(std(Data.vel{nObject}),Units.fmt) ' ' Units.str '/s (SD)'],'Location','best');
                xlabel(hVelocityStatsGui.aPlot,'time [s]');
                ylabel(hVelocityStatsGui.aPlot,['velocity [' Units.str '/s]']);   
                set(hVelocityStatsGui.aPlot,'Visible','on');
            end
        case 3
            if isempty(Data.vel{nObject})
                text(0.3,0.5,'No path available','Parent',hVelocityStatsGui.aPlot,'FontWeight','bold','FontSize',16);
                set(hVelocityStatsGui.aPlot,'Visible','off');
                legend(hVelocityStatsGui.aPlot,'off');
            else            
                if get(hVelocityStatsGui.mData,'Value')==1
                    if get(hVelocityStatsGui.mSmooth,'Value')==1 || isempty(hVelocityStatsGui.SmoothBox)
                        plot(hVelocityStatsGui.aPlot,Objects(nObject).Results(:,2),Objects(nObject).Results(:,6)/Units.val,'b-');
                    else
                        plot(hVelocityStatsGui.aPlot,Objects(nObject).Results(:,2),smooth(Objects(nObject).Results(:,6),hVelocityStatsGui.SmoothBox)/Units.val,'b-');
                    end
                else
                    if get(hVelocityStatsGui.mSmooth,'Value')==1 || isempty(hVelocityStatsGui.SmoothBox)
                        plot(hVelocityStatsGui.aPlot,Objects(nObject).Results(:,2),real(Objects(nObject).PathData(:,4))/Units.val,'b-');
                    else
                        plot(hVelocityStatsGui.aPlot,Objects(nObject).Results(:,2),smooth(real(Objects(nObject).PathData(:,4)),hVelocityStatsGui.SmoothBox)/Units.val,'b-');
                    end
                end
                hold(hVelocityStatsGui.aPlot,'on');
                plot(hVelocityStatsGui.aPlot,Objects(nObject).Results(:,2),Data.vel{nObject}*Objects(nObject).Results(:,2)+Data.time{nObject}/Units.val,'r-');
                legend(hVelocityStatsGui.aPlot,{'distance vs. time',['Velocity: ' num2str(mean(Data.vel{nObject}),Units.fmt) ' ' Units.str '/s (fit)']},'Location','best');
                xlabel(hVelocityStatsGui.aPlot,'time [s]');
                ylabel(hVelocityStatsGui.aPlot,['distance [' Units.str ']']); 
                set(hVelocityStatsGui.aPlot,'Visible','on');
            end  
        case 4
            if isempty(Data.vel{nObject})
                text(0.3,0.5,'No path available','Parent',hVelocityStatsGui.aPlot,'FontWeight','bold','FontSize',16);
                set(hVelocityStatsGui.aPlot,'Visible','off');
                legend(hVelocityStatsGui.aPlot,'off');
            else
                plot(hVelocityStatsGui.aPlot,Data.time{nObject},Data.vel{nObject},'b-');
                legend(hVelocityStatsGui.aPlot,['Velocity: ' num2str(mean(Data.vel{nObject}),Units.fmt) ' ' char(177) ' ' num2str(std(Data.vel{nObject}),Units.fmt) ' ' Units.str '/s (SD)'],'Location','best');
                xlabel(hVelocityStatsGui.aPlot,'time [s]');
                ylabel(hVelocityStatsGui.aPlot,['velocity [' Units.str '/s]']);   
                set(hVelocityStatsGui.aPlot,'Visible','on');
            end
    end
end
vel = cell2mat(Data.vel);
cla(hVelocityStatsGui.aResults,'reset');
if isempty(vel)
    text(0.3,0.5,'No data or path available for any objects','Parent',hVelocityStatsGui.aResults,'FontWeight','bold','FontSize',16);
    set(hVelocityStatsGui.aResults,'Visible','off');
    legend(hVelocityStatsGui.aResults,'off');
else
    barchoice=[0.1 0.2 0.4 0.5 1 2 4 5 10 20 25 50 100 200 250 500 1000 2000 5000];
    total=(max(vel)-min(vel))/15;
    [~,t]=min(abs(total-barchoice));
    barwidth=barchoice(t(1));
    xout=fix(min(vel)/barwidth)*barwidth+barwidth/2:barwidth:ceil(max(vel)/barwidth)*barwidth-barwidth/2; 
    if length(xout)<=1
       xout=fix(min(vel)/barwidth)*barwidth-barwidth/2:barwidth:ceil(max(vel)/barwidth)*barwidth+barwidth/2; 
       if length(xout)<=1
           xout=[xout xout+barwidth];
       end
    end
    n = hist(vel,xout);
    Data.hist = [xout' n'];
    Data.xy = {[min(xout)-barwidth/2 max(xout)+barwidth/2],[0 max(n)*1.2]};
    bar(hVelocityStatsGui.aResults,xout,n,'BarWidth',1,'FaceColor',[0 0 0.5]); 
    set(hVelocityStatsGui.aResults,{'xlim','ylim'},Data.xy);
    n = hist(Data.vel{nObject},xout);
    hold on
    bar(hVelocityStatsGui.aResults,xout,n,'BarWidth',1,'FaceColor',[179/255 199/255 1]); 
    if Data.hist(1,1)<0 && Data.hist(end,1)>0
        ticks = [fliplr(0:-2*barwidth:Data.hist(1,1)-barwidth/2) 2*barwidth:2*barwidth:Data.hist(end,1)+barwidth/2];
    else
        ticks = Data.hist(1,1)-barwidth/2:2*barwidth:Data.hist(end,1)+barwidth/2;
    end
    set(hVelocityStatsGui.aResults,'Visible','on','XTick',ticks);
    xlabel(hVelocityStatsGui.aResults,['velocity [' Units.str '/s]']);
    ylabel(hVelocityStatsGui.aResults,'frequency [counts]');
    legend(hVelocityStatsGui.aResults,{'all objects','current object'},'Location','best');
end
setappdata(hVelocityStatsGui.fig,'Data',Data);

function FitGauss
hVelocityStatsGui = getappdata(0,'hVelocityStatsGui');
Data = getappdata(hVelocityStatsGui.fig,'Data');
Units = getappdata(hVelocityStatsGui.fig,'Units');
xout = Data.hist(:,1);
n = Data.hist(:,2);
legend(hVelocityStatsGui.aResults,'off');
delete(findobj('Parent',hVelocityStatsGui.aResults,'-and','Tag','fit'));
text(hVelocityStatsGui.aResults,(max(xout)-min(xout))/2,max(n)*1.1,'Choose peak(s) by left-click, press any key or right-click to continue.','VerticalAlignment','Bottom','HorizontalAlignment','center','Tag','choose');  
k = 0;
p = 1;
while k == 0
    k = waitforbuttonpress;
    if k == 0 
        if strcmp(get(hVelocityStatsGui.fig,'SelectionType'),'normal')
            cp = get(hVelocityStatsGui.aResults,'CurrentPoint');
            x(p) = cp(1,1);
            p = p + 1;
        else
            k = 1;
        end
    end
end
if p>1
    mode = ['gauss' num2str(length(x))];
    params0 = zeros(1,length(x)*3);
    for m = 1:length(x)
        [~,t] = min(abs(x(m)-xout));
        params0(m*3-2) = n(t);
        params0(m*3-1) = xout(t);
        params0(m*3) = 2*(abs(xout(2)-xout(1)));
    end
    opt = fitoptions(mode,'Startpoint',params0);
    f = fit(xout,n,mode,opt);
    params = coeffvalues(f);
    Data.fit = f;
    delete(findobj('Parent',hVelocityStatsGui.aResults,'-and','Tag','choose'));
    hold on;
    h = plot(f,'r-');
    set(h,'Tag','fit');
    for m = 1:length(x)
        text(hVelocityStatsGui.aResults,params(m*3-1),f(params(m*3-1))+max(n)*0.05,['Velocity: ' num2str(params(m*3-1),Units.fmt) ' ' char(177) ' ' num2str(params(m*3)/sqrt(2),Units.fmt) ' nm/s (SD)'],'VerticalAlignment','Bottom','HorizontalAlignment','center','Tag','fit','FontSize',12,'FontWeight','bold','BackgroundColor','w');   
    end
    set(hVelocityStatsGui.aResults,{'xlim','ylim'},Data.xy);
    legend(hVelocityStatsGui.aResults,{'all objects','current object','Gaussian fit'},'Location','best');
    xlabel(hVelocityStatsGui.aResults,['velocity [' Units.str '/s]']);
    ylabel(hVelocityStatsGui.aResults,'frequency [counts]');
    legend(hVelocityStatsGui.aPlot,'show');
    setappdata(hVelocityStatsGui.fig,'Data',Data);
else
    Draw(hVelocityStatsGui)
end


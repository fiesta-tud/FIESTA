function fEstimateMotilityParamsGui(func,varargin)
if nargin == 0
    func = 'Create';
end
switch func
    case 'Create'
        Create;
    case 'Refresh'
        Refresh;
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
    case 'ChangeUnits'
        ChangeUnits;
    case 'Draw'
        Draw(varargin{1});
    case 'LoadBleach'
        LoadBleach;
end

function Create
global Molecule;
global Config;

hMainGui = getappdata(0,'hMainGui');
h=findall(0,'Tag','hEstimateMotilityGui');
close(h)

Objects = [];
if isempty(Molecule)
    [FileName, PathName] = uigetfile({'*.mat','FIESTA Data(*.mat)'},'Load FIESTA Tracks',fShared('GetLoadDir'),'MultiSelect','on');
    if ~iscell(FileName)
        FileName={FileName};
    end
    if PathName~=0
        FileName = sort(FileName);
        progressdlg('String',['Loading file 1 of ' num2str(length(FileName)) '...'],'Min',0,'Max',length(FileName),'Parent',hMainGui.fig);
        for n = 1 : length(FileName)
            tempMol = fLoad([PathName FileName{n}],'Molecule');
            if ~isempty(tempMol)
                Objects = [Objects tempMol];
            end
            progressdlg(n,['Loading file ' num2str(n) ' of ' num2str(length(FileName)) '...']);
        end
        progressdlg('close');
        if isempty(Objects)
            fMsgDlg({'Problems with loading tracks','Choose FIESTA molecule tracks'},'error');
            return;  
        end 
        fShared('SetLoadDir',PathName);
    else
        fMsgDlg({'Problems with loading tracks','Choose FIESTA molecule tracks'},'error');
        return;
    end
else
    MolSelect = [Molecule.Selected]==1;
    if ~any(MolSelect) 
        fMsgDlg({'No molecules selected','Choose molecule tracks'},'error');
        return;
    end
    Objects = Molecule(MolSelect);
end

data = fEvaluateTracks(Objects,5);
bleach = [];
results = [];

hEstimateMotilityGui.fig = figure('Units','normalized','WindowStyle','normal','DockControls','off','IntegerHandle','off','MenuBar','none','Name','Motility Parameters',...
                      'NumberTitle','off','Position',[0.4 0.3 0.2 0.3],'HandleVisibility','callback','Tag','hEstimateMotilityGui',...
                      'Visible','off','Resize','off','Renderer', 'painters');

fPlaceFig(hEstimateMotilityGui.fig,'full');

if ispc
    set(hEstimateMotilityGui.fig,'Color',[236 233 216]/255);
end

c = get(hEstimateMotilityGui.fig ,'Color');

hEstimateMotilityGui.aVelPlot = axes('Parent',hEstimateMotilityGui.fig,'Units','normalized','OuterPosition',[0 0.5 0.33 .5],'Tag','Plot','TickDir','in');

hEstimateMotilityGui.aBleachPlot = axes('Parent',hEstimateMotilityGui.fig,'Units','normalized','OuterPosition',[0.33 0.5 0.33 .5],'Tag','Plot','TickDir','in');

hEstimateMotilityGui.aIntTimePlot = axes('Parent',hEstimateMotilityGui.fig,'Units','normalized','OuterPosition',[0.66 0.5 0.33 .5],'Tag','Plot','TickDir','in');

hEstimateMotilityGui.aRunlengthPlot = axes('Parent',hEstimateMotilityGui.fig,'Units','normalized','OuterPosition',[0.66 0 0.33 .5],'Tag','Plot','TickDir','in');



hEstimateMotilityGui.tNumIter = uicontrol('Parent',hEstimateMotilityGui.fig,'Units','normalized','Position',[0.05 0.45 0.175 0.03],'Style','text','Tag','tNumIter',...
                                          'String','Number of bootstrapping iterations:','Enable','on','FontUnits','normalized','FontSize',0.6,...
                                          'HorizontalAlignment','left','BackgroundColor',c);

hEstimateMotilityGui.eNumIter = uicontrol('Parent',hEstimateMotilityGui.fig,'Units','normalized','Position',[0.23 0.45 0.07 0.03],'Style','edit','Tag','eNumIter',...
                                          'Callback','fEstimateMotilityParamsGui(''Refresh'');','String','100','Enable','on','FontUnits','normalized','FontSize',0.55,...
                                          'HorizontalAlignment','center','BackgroundColor','w');
                
if Config.NumCores>0
    str = 'Parallel processing is activated';
else
    str = 'Parallel processing can speed up evaluation (Check Configuration)';
end
hEstimateMotilityGui.tParallel = uicontrol('Parent',hEstimateMotilityGui.fig,'Units','normalized','Position',[0.065 0.415 0.25 0.03],'Style','text','Tag','tParallel',...
                                          'String',str,'Enable','on','FontUnits','normalized','FontSize',0.475,'HorizontalAlignment','left','BackgroundColor',c);
                                                                         
hEstimateMotilityGui.tUnits = uicontrol('Parent',hEstimateMotilityGui.fig,'Units','normalized','Position',[0.05 0.37 0.03 0.03],'Style','text','Tag','tUnits',...
                                          'String','Units:','Enable','on','FontUnits','normalized','FontSize',0.6,...
                                          'HorizontalAlignment','left','BackgroundColor',c);
                                      
hEstimateMotilityGui.tUnitVel = uicontrol('Parent',hEstimateMotilityGui.fig,'Units','normalized','Position',[0.085 0.37 0.04 0.03],'Style','text','Tag','tUnitVel',...
                                          'String','velocity','Enable','on','FontUnits','normalized','FontSize',0.6,...
                                          'HorizontalAlignment','center','BackgroundColor',c);

hEstimateMotilityGui.mUnitVel = uicontrol('Parent',hEstimateMotilityGui.fig,'Units','normalized','Position',[0.13 0.36 0.06 0.04],'Style','popupmenu',...
                                                'Tag','mUnitVel','Enable','on','FontUnits','normalized','FontSize',0.4,'HorizontalAlignment','left',...
                                                'String',{'nm/s',[char(181) 'm/s'],'mm/s'},'UserData',{10^-9,10^-6,10^-3},'Callback','fEstimateMotilityParamsGui(''Refresh'');');
                                            
hEstimateMotilityGui.tUnitRunlen = uicontrol('Parent',hEstimateMotilityGui.fig,'Units','normalized','Position',[0.195 0.37 0.05 0.03],'Style','text','Tag','tUnitRunlen',...
                                          'String','run length','Enable','on','FontUnits','normalized','FontSize',0.6,...
                                          'HorizontalAlignment','center','BackgroundColor',c);
                                      
hEstimateMotilityGui.mUnitRunlen = uicontrol('Parent',hEstimateMotilityGui.fig,'Units','normalized','Position',[0.25 0.36 0.053 0.04],'Style','popupmenu',...
                                                'Tag','mUnitRunlen','Enable','on','FontUnits','normalized','FontSize',0.4,'HorizontalAlignment','left',...
                                                'String',{'nm',[char(181) 'm'],'mm'},'UserData',{10^-9,10^-6,10^-3},'Callback','fEstimateMotilityParamsGui(''ChangeUnits'');');
                                      
hEstimateMotilityGui.tFilterData = uicontrol('Parent',hEstimateMotilityGui.fig,'Units','normalized','Position',[0.05 0.32 0.25 0.03],'Style','text','Tag','tFilterData',...
                                             'String','Filter data for evaluation','Enable','on','FontUnits','normalized','FontSize',0.6,'HorizontalAlignment','left','BackgroundColor',c);    

hEstimateMotilityGui.tMinItime = uicontrol('Parent',hEstimateMotilityGui.fig,'Units','normalized','Position',[0.065 0.28 0.12 0.03],'Style','text','Tag','tMinItime',...
                                          'String','minimum interaction time','Enable','on','FontUnits','normalized','FontSize',0.6,...
                                          'HorizontalAlignment','left','BackgroundColor',c);

hEstimateMotilityGui.eMinItime = uicontrol('Parent',hEstimateMotilityGui.fig,'Units','normalized','Position',[0.2 0.28 0.04 0.03],'Style','edit','Tag','eMinItime',...
                                          'Callback','fEstimateMotilityParamsGui(''Refresh'');','String','','Enable','on','FontUnits','normalized','FontSize',0.55,...
                                          'HorizontalAlignment','center','BackgroundColor','w');
                                      
uicontrol('Parent',hEstimateMotilityGui.fig,'Units','normalized','Position',[0.241 0.28 0.02 0.03],'Style','text',...
                                          'String','s','Enable','on','FontUnits','normalized','FontSize',0.6,...
                                          'HorizontalAlignment','left','BackgroundColor',c); 
                                      
hEstimateMotilityGui.tMinRunlength = uicontrol('Parent',hEstimateMotilityGui.fig,'Units','normalized','Position',[0.065 0.24 0.12 0.03],'Style','text','Tag','tMinRunlength',...
                                          'String','minimum run length','Enable','on','FontUnits','normalized','FontSize',0.6,...
                                          'HorizontalAlignment','left','BackgroundColor',c);

hEstimateMotilityGui.eMinRunlength = uicontrol('Parent',hEstimateMotilityGui.fig,'Units','normalized','Position',[0.2 0.24 0.04 0.03],'Style','edit','Tag','eMinRunlength',...
                                          'Callback','fEstimateMotilityParamsGui(''Refresh'');','String','','Enable','on','FontUnits','normalized','FontSize',0.55,...
                                          'HorizontalAlignment','center','BackgroundColor','w','UserData',10^-9);
                                      
hEstimateMotilityGui.tUnitDis(1) = uicontrol('Parent',hEstimateMotilityGui.fig,'Units','normalized','Position',[0.241 0.24 0.02 0.03],'Style','text',...
                                          'String','nm','Enable','on','FontUnits','normalized','FontSize',0.6,...
                                          'HorizontalAlignment','left','BackgroundColor',c); 

hEstimateMotilityGui.bRefresh = uicontrol('Parent',hEstimateMotilityGui.fig,'Units','normalized','Position',[0.065 0.15 0.2 0.05],'Style','pushbutton',...
                                          'Callback','fEstimateMotilityParamsGui(''Update'');','Tag','bRefresh','String','Refresh Evaluation','Enable','off','FontUnits','normalized','FontSize',0.5);   
                                            
hEstimateMotilityGui.bSave = uicontrol('Parent',hEstimateMotilityGui.fig,'Units','normalized','Position',[0.065 0.09 0.2 0.05],'Style','pushbutton',...
                                        'Callback','fEstimateMotilityParamsGui(''Save'');','Tag','bSave','String','Save Results','Enable','off','FontUnits','normalized','FontSize',0.5);   

hEstimateMotilityGui.bExport = uicontrol('Parent',hEstimateMotilityGui.fig,'Units','normalized','Position',[0.065 0.03 0.2 0.05],'Style','pushbutton',...
                                          'Callback','fEstimateMotilityParamsGui(''Export'');','Tag','bExport','String','Export Figures','Enable','off','FontUnits','normalized','FontSize',0.5);   

hEstimateMotilityGui.tEndCorrection = uicontrol('Parent',hEstimateMotilityGui.fig,'Units','normalized','Position',[0.375 0.45 0.15 0.03],'Style','text','Tag','tEndCorrection',...
                                          'String','Filament length correction:','Enable','on','FontUnits','normalized','FontSize',0.6,...
                                          'HorizontalAlignment','left','BackgroundColor',c);

hEstimateMotilityGui.eEndCorrection = uicontrol('Parent',hEstimateMotilityGui.fig,'Units','normalized','Position',[0.51 0.45 0.04 0.03],'Style','edit','Tag','eEndCorrection',...
                                          'Callback','fEstimateMotilityParamsGui(''Refresh'');','String',mean([Objects.PixelSize]),'Enable','on','FontUnits','normalized','FontSize',0.55,...
                                          'HorizontalAlignment','center','BackgroundColor','w');
                                      
uicontrol('Parent',hEstimateMotilityGui.fig,'Units','normalized','Position',[0.551 0.45 0.02 0.03],'Style','text',...
                                          'String','nm','Enable','on','FontUnits','normalized','FontSize',0.6,...
                                          'HorizontalAlignment','left','BackgroundColor',c);               
                                      
hEstimateMotilityGui.tEndCorrectionInfo = uicontrol('Parent',hEstimateMotilityGui.fig,'Units','normalized','Position',[0.575 0.435 0.11 0.05],'Style','text','Tag','tEndCorrectionInfo',...
                                          'String',{'If the detachment position is within','this distance from the filament end','the motor trace is treated as censored.'},...
                                          'Enable','on','FontUnits','normalized','FontSize',0.2,'HorizontalAlignment','left','BackgroundColor',c);
                                      
hEstimateMotilityGui.tBleaching = uicontrol('Parent',hEstimateMotilityGui.fig,'Units','normalized','Position',[0.375 0.4 0.125 0.03],'Style','text','Tag','tBleaching',...
                                          'String','Photobleaching correction:','Enable','on','FontUnits','normalized','FontSize',0.6,'HorizontalAlignment','left',...
                                          'BackgroundColor',c);                                      

hEstimateMotilityGui.bLoadBleaching = uicontrol('Parent',hEstimateMotilityGui.fig,'Units','normalized','Position',[0.51 0.395 0.12 0.04],'Style','pushbutton',...
                                                'Tag','bLoadBleaching','String','Load Bleaching Analysis','Enable','on','FontUnits','normalized','FontSize',0.4,...
                                                'Callback','fEstimateMotilityParamsGui(''LoadBleach'');');                                      

hEstimateMotilityGui.mBleachingMode = uicontrol('Parent',hEstimateMotilityGui.fig,'Units','normalized','Position',[0.39 0.35 0.22 0.04],'Style','popupmenu',...
                                                'Callback','fEstimateMotilityParamsGui(''Refresh'');','Tag','mBleachingMode','Enable','off','FontUnits','normalized','FontSize',0.4,'HorizontalAlignment','left',...
                                                'String',{'Individual fit (bleaching time per fluorophore)','Global fit (bleaching time per motor)'});

hEstimateMotilityGui.cBleachManual = uicontrol('Parent',hEstimateMotilityGui.fig,'Units','normalized','Position',[0.39 0.3 0.3 0.03],'Style','checkbox','Tag','cBleachManual',...
                                               'String','Manual input of bleaching time (not recommended!)','Enable','on','FontUnits','normalized','FontSize',0.6,...
                                               'Callback','fEstimateMotilityParamsGui(''Refresh'');','HorizontalAlignment','left','BackgroundColor',c);

hEstimateMotilityGui.tBleachTime = uicontrol('Parent',hEstimateMotilityGui.fig,'Units','normalized','Position',[0.41 0.26 0.089 0.03],'Style','text','Tag','tBleachTime',...
                                          'String','Bleaching time [s]:','Enable','off','FontUnits','normalized','FontSize',0.6,'HorizontalAlignment','left',...
                                          'BackgroundColor',c);   

hEstimateMotilityGui.eBleachTime = uicontrol('Parent',hEstimateMotilityGui.fig,'Units','normalized','Position',[0.5 0.26 0.03 0.03],'Style','edit','Tag','eBleachTime',...
                                          'Callback','fEstimateMotilityParamsGui(''Refresh'');','String','','Enable','off','FontUnits','normalized','FontSize',0.55,...
                                          'HorizontalAlignment','center','BackgroundColor','w');
                                      
hEstimateMotilityGui.tBleachRho = uicontrol('Parent',hEstimateMotilityGui.fig,'Units','normalized','Position',[0.55 0.26 0.05 0.03],'Style','text','Tag','tBleachRho',...
                                          'String','Ratio Rho:','Enable','off','FontUnits','normalized','FontSize',0.6,'HorizontalAlignment','left',...
                                          'BackgroundColor',c);  
                                      
hEstimateMotilityGui.eBleachRho = uicontrol('Parent',hEstimateMotilityGui.fig,'Units','normalized','Position',[0.6 0.26 0.03 0.03],'Style','edit','Tag','eBleachRho',...
                                          'Callback','fEstimateMotilityParamsGui(''Refresh'');','String','','Enable','off','FontUnits','normalized','FontSize',0.55,...
                                          'HorizontalAlignment','center','BackgroundColor','w');
                                      
hEstimateMotilityGui.tRhoInfo = uicontrol('Parent',hEstimateMotilityGui.fig,'Units','normalized','Position',[0.54 0.21 0.11 0.05],'Style','text','Tag','tRhoInfo',...
                                          'String',{'ratio for mix of one and two fluorophores','  1=all motors have one fluorophore','  0=all motors have two fluorophores'},...
                                          'Enable','off','FontUnits','normalized','FontSize',0.2,'HorizontalAlignment','left','BackgroundColor',c);

hEstimateMotilityGui.tExpEvaluation = uicontrol('Parent',hEstimateMotilityGui.fig,'Units','normalized','Position',[0.375 0.177 0.125 0.03],'Style','text','Tag','tExpEvaluation',...
                                          'String','Exponential evaluation:','Enable','on','FontUnits','normalized','FontSize',0.6,'HorizontalAlignment','left',...
                                          'BackgroundColor',c);  

hEstimateMotilityGui.mExponentialMethod = uicontrol('Parent',hEstimateMotilityGui.fig,'Units','normalized','Position',[0.49 0.1675 0.15 0.04],'Style','popupmenu',...
                                                'Callback','fEstimateMotilityParamsGui(''Refresh'');','Tag','mExponentialMethod','Enable','on','FontUnits','normalized','FontSize',0.4,'HorizontalAlignment','left',...
                                                'String',{'LSF Single-Exponential','LSF Single-Exponential(weighted)','MLE Single-Exponential','LSF Double-Exponential','LSF Double-Exponential(weighted)','MLE Double-Exponential'});                     
                                            
hEstimateMotilityGui.tCutoff = uicontrol('Parent',hEstimateMotilityGui.fig,'Units','normalized','Position',[0.39 0.131 0.25 0.03],'Style','text','Tag','tCutoff',...
                                             'String','Set cutoff x0 for each distribution','Enable','on','FontUnits','normalized','FontSize',0.475,'HorizontalAlignment','left','BackgroundColor',c);    

hEstimateMotilityGui.tX0itime = uicontrol('Parent',hEstimateMotilityGui.fig,'Units','normalized','Position',[0.41 0.1 0.12 0.03],'Style','text','Tag','tX0itime',...
                                          'String','x0 for interaction time','Enable','on','FontUnits','normalized','FontSize',0.6,...
                                          'HorizontalAlignment','left','BackgroundColor',c);

hEstimateMotilityGui.eX0itime = uicontrol('Parent',hEstimateMotilityGui.fig,'Units','normalized','Position',[0.535 0.1 0.04 0.03],'Style','edit','Tag','eX0itime',...
                                          'Callback','fEstimateMotilityParamsGui(''Refresh'');','String','','Enable','on','FontUnits','normalized','FontSize',0.55,...
                                          'HorizontalAlignment','center','BackgroundColor','w');
                                      
uicontrol('Parent',hEstimateMotilityGui.fig,'Units','normalized','Position',[0.576 0.1 0.02 0.03],'Style','text',...
                                          'String','s','Enable','on','FontUnits','normalized','FontSize',0.6,...
                                          'HorizontalAlignment','left','BackgroundColor',c);    
                                      
hEstimateMotilityGui.tX0runlength = uicontrol('Parent',hEstimateMotilityGui.fig,'Units','normalized','Position',[0.41 0.065 0.12 0.03],'Style','text','Tag','tX0runlength',...
                                          'String','x0 for run length','Enable','on','FontUnits','normalized','FontSize',0.6,...
                                          'HorizontalAlignment','left','BackgroundColor',c);

hEstimateMotilityGui.eX0runlength = uicontrol('Parent',hEstimateMotilityGui.fig,'Units','normalized','Position',[0.535 0.065 0.04 0.03],'Style','edit','Tag','eX0runlength',...
                                          'Callback','fEstimateMotilityParamsGui(''Refresh'');','String','','Enable','on','FontUnits','normalized','FontSize',0.55,...
                                          'HorizontalAlignment','center','BackgroundColor','w','UserData',10^-9);
                                      
hEstimateMotilityGui.tUnitDis(2) = uicontrol('Parent',hEstimateMotilityGui.fig,'Units','normalized','Position',[0.576 0.065 0.02 0.03],'Style','text',...
                                          'String','nm','Enable','on','FontUnits','normalized','FontSize',0.6,...
                                          'HorizontalAlignment','left','BackgroundColor',c);                                       
                                      
hEstimateMotilityGui.tX0bleach = uicontrol('Parent',hEstimateMotilityGui.fig,'Units','normalized','Position',[0.41 0.03 0.12 0.03],'Style','text','Tag','tX0bleach',...
                                          'String','x0 for bleaching time','Enable','off','FontUnits','normalized','FontSize',0.6,...
                                          'HorizontalAlignment','left','BackgroundColor',c);

hEstimateMotilityGui.eX0bleach = uicontrol('Parent',hEstimateMotilityGui.fig,'Units','normalized','Position',[0.535 0.03 0.04 0.03],'Style','edit','Tag','eX0bleach',...
                                          'Callback','fEstimateMotilityParamsGui(''Refresh'');','String','','Enable','off','FontUnits','normalized','FontSize',0.55,...
                                          'HorizontalAlignment','center','BackgroundColor','w');
                                      
hEstimateMotilityGui.tX0bleachUnit = uicontrol('Parent',hEstimateMotilityGui.fig,'Units','normalized','Position',[0.576 0.03 0.02 0.03],'Style','text',...
                                          'String','s','Enable','off','FontUnits','normalized','FontSize',0.6,...
                                          'HorizontalAlignment','left','BackgroundColor',c);    
                                      
hEstimateMotilityGui.Methods = {'lsf1','lsw1','mle1','lsf2','lsw2','mle2'};

setappdata(hEstimateMotilityGui.fig,'bleach',bleach);
setappdata(hEstimateMotilityGui.fig,'data',data);
setappdata(hEstimateMotilityGui.fig,'results',results);
setappdata(0,'hEstimateMotilityGui',hEstimateMotilityGui);
Update;

function Refresh
hEstimateMotilityGui = getappdata(0,'hEstimateMotilityGui');
bleach = getappdata(hEstimateMotilityGui.fig,'bleach');
set(hEstimateMotilityGui.bRefresh,'Enable','on');
set(hEstimateMotilityGui.bSave,'Enable','off');
set(hEstimateMotilityGui.bExport,'Enable','off');
enable = 'off';
if get(hEstimateMotilityGui.cBleachManual,'Value')
    enable = 'on';
end
set(hEstimateMotilityGui.tBleachTime,'Enable',enable);
set(hEstimateMotilityGui.eBleachTime,'Enable',enable);
set(hEstimateMotilityGui.tBleachRho,'Enable',enable);
set(hEstimateMotilityGui.eBleachRho,'Enable',enable);
set(hEstimateMotilityGui.tRhoInfo,'Enable',enable);
if ~isempty(bleach)
    set(hEstimateMotilityGui.mBleachingMode,'Enable','on');
else
    set(hEstimateMotilityGui.mBleachingMode,'Enable','off');
end

function Update
hEstimateMotilityGui = getappdata(0,'hEstimateMotilityGui');
data = getappdata(hEstimateMotilityGui.fig,'data');
bleach = getappdata(hEstimateMotilityGui.fig,'bleach');
numIter = str2double(get(hEstimateMotilityGui.eNumIter,'String'));
if isnan(numIter) || numIter<10
    numIter = 100;
    set(hEstimateMotilityGui.eNumIter,'String',100);
end
min_itime = str2double(get(hEstimateMotilityGui.eMinItime,'String'));
if ~isnan(min_itime)
    data(data(:,2)<min_itime,:) = [];
end
min_runlen = str2double(get(hEstimateMotilityGui.eMinRunlength,'String'));
if ~isnan(min_runlen)
    data(data(:,3)<min_runlen,:) = [];
end
dis_end = str2double(get(hEstimateMotilityGui.eEndCorrection,'String'));
if isnan(dis_end)
    dis_end = mean([Objects.PixelSize]);
end
if ~isempty(bleach)
   set(hEstimateMotilityGui.mBleachingMode,'Enable','on');
   set(hEstimateMotilityGui.eX0bleach,'Enable','on');
   set(hEstimateMotilityGui.tX0bleach,'Enable','on');
   set(hEstimateMotilityGui.tX0bleachUnit,'Enable','on');
   if get(hEstimateMotilityGui.mBleachingMode,'Value')==2
       bleach = max(bleach(:,1:2),[],2);
   end
else
   set(hEstimateMotilityGui.mBleachingMode,'Enable','off');
   set(hEstimateMotilityGui.eX0bleach,'Enable','off');
   set(hEstimateMotilityGui.tX0bleach,'Enable','off');
   set(hEstimateMotilityGui.tX0bleachUnit,'Enable','off');
end
if get(hEstimateMotilityGui.cBleachManual,'Value')
    bleach = zeros(1,2);
    bleach(1) = str2double(get(hEstimateMotilityGui.eBleachTime,'String'));
    bleach(2) = str2double(get(hEstimateMotilityGui.eBleachRho,'String'));
    if any(isnan(bleach)) || bleach(1)<0 || bleach(2)<0 || bleach(2)>1 
        bleach = [];
        set(hEstimateMotilityGui.eBleachTime,'String','NaN');
        set(hEstimateMotilityGui.eBleachRho,'String','NaN');
    end
end
x0 = zeros(1,3);
x0(1) = str2double(get(hEstimateMotilityGui.eX0itime,'String'));
x0(2) = str2double(get(hEstimateMotilityGui.eX0runlength,'String'));
x0(3) = str2double(get(hEstimateMotilityGui.eX0bleach,'String'));
method = hEstimateMotilityGui.Methods{get(hEstimateMotilityGui.mExponentialMethod,'Value')};
scale = get(hEstimateMotilityGui.mUnitVel,'Userdata');
scale_vel = scale{get(hEstimateMotilityGui.mUnitVel,'Value')}/10^-9;
scale = get(hEstimateMotilityGui.mUnitRunlen,'Userdata');
scale_runlen = scale{get(hEstimateMotilityGui.mUnitRunlen,'Value')}/10^-9;
if str2double(method(4))==1
    results = fEstimateMotilityParameters(data(:,5)/scale_vel,data(:,2),data(:,3)/scale_runlen,data(:,4)<dis_end,bleach,method(1:3),numIter,x0,hEstimateMotilityGui);
else
    results = fEstimateMotilityParameters2(data(:,5)/scale_vel,data(:,2),data(:,3)/scale_runlen,data(:,4)<dis_end,bleach,method(1:3),numIter,x0,hEstimateMotilityGui);
end
if isempty(results)
   close(hEstimateMotilityGui.fig);
   return
end
str = get(hEstimateMotilityGui.mUnitVel,'String');
title = get(hEstimateMotilityGui.aVelPlot,'Title');
title.String = [title.String ' ' str{get(hEstimateMotilityGui.mUnitVel,'Value')}];
hEstimateMotilityGui.aVelPlot.XLabel.String = [hEstimateMotilityGui.aVelPlot.XLabel.String ' [' str{get(hEstimateMotilityGui.mUnitVel,'Value')} ']'];
set(hEstimateMotilityGui.aVelPlot,'Title',title);
str = get(hEstimateMotilityGui.mUnitRunlen,'String');
title = get(hEstimateMotilityGui.aRunlengthPlot,'Title');
title.String = [title.String ' ' str{get(hEstimateMotilityGui.mUnitRunlen,'Value')}];
hEstimateMotilityGui.aRunlengthPlot.XLabel.String = [hEstimateMotilityGui.aRunlengthPlot.XLabel.String ' [' str{get(hEstimateMotilityGui.mUnitRunlen,'Value')} ']'];
set(hEstimateMotilityGui.aRunlengthPlot,'Title',title);
set(hEstimateMotilityGui.bRefresh,'Enable','off');
set(hEstimateMotilityGui.bSave,'Enable','on');
set(hEstimateMotilityGui.bExport,'Enable','on');
setappdata(hEstimateMotilityGui.fig,'results',results);

function ChangeUnits
hEstimateMotilityGui = getappdata(0,'hEstimateMotilityGui');
str = get(hEstimateMotilityGui.mUnitRunlen,'String');
set(hEstimateMotilityGui.tUnitDis,'String',str{get(hEstimateMotilityGui.mUnitRunlen,'Value')});
scale = get(hEstimateMotilityGui.mUnitRunlen,'Userdata');
h = str2double(get(hEstimateMotilityGui.eMinRunlength,'String'));
if ~isnan(h)
    set(hEstimateMotilityGui.eMinRunlength,'String',num2str(h*get(hEstimateMotilityGui.eMinRunlength,'Userdata')/scale{get(hEstimateMotilityGui.mUnitRunlen,'Value')}));
    set(hEstimateMotilityGui.eMinRunlength,'Userdata',scale{get(hEstimateMotilityGui.mUnitRunlen,'Value')});
end
h = str2double(get(hEstimateMotilityGui.eX0runlength,'String'));
if ~isnan(h)
    set(hEstimateMotilityGui.eX0runlength,'String',num2str(h*get(hEstimateMotilityGui.eX0runlength,'Userdata')/scale{get(hEstimateMotilityGui.mUnitRunlen,'Value')}));
    set(hEstimateMotilityGui.eX0runlength,'Userdata',scale{get(hEstimateMotilityGui.mUnitRunlen,'Value')});
end
fEstimateMotilityParamsGui('Refresh');

function LoadBleach
hEstimateMotilityGui = getappdata(0,'hEstimateMotilityGui');
[file,path] = uigetfile({'*.mat','FIESTA bleaching analysis (*.mat)'},'Pick FIESTA bleaching file',fShared('GetLoadDir'),'MultiSelect','on');
if path == 0
    bleach = [];
else
    if ~iscell(file)
        file = {file};
    end
    bleach = [];
    for n = 1:length(file)
        load([path file{n}],'BleachingTime');
        k = BleachingTime(:,3);
        bleach = [bleach; BleachingTime(k>0,1:2)];
    end
end
setappdata(hEstimateMotilityGui.fig,'bleach',bleach);
fEstimateMotilityParamsGui('Refresh');

function Export
hEstimateMotilityGui = getappdata(0,'hEstimateMotilityGui');
fig = figure('Units','centimeters','Position',[2 2 16 17],'Toolbar','none','MenuBar','none','DockControls','off',...
             'PaperUnits','centimeters','PaperSize',[16 17],'Color','w','PaperPositionMode','manual','PaperPosition',[0 0 16 17]);
%set(fig,'Units','normalized');
aVelPlot = copyobj(hEstimateMotilityGui.aVelPlot,fig);
set(aVelPlot,'Units','centimeters','Position',[1.5 9.5 6 6],'TickDir','out','Color','none');
axes('Units','centimeters','Position',get(aVelPlot,'Position'),'Box','on','xtick',[],'ytick',[]);
axes(aVelPlot);
ex = aVelPlot.YAxis.Exponent;
if ex~=0
    set(aVelPlot,'YTickLabels',get(aVelPlot,'YTickLabels'));
    aVelPlot.YLabel.String = [aVelPlot.YLabel.String ' (x10^{' num2str(ex) '})'];
end 
aBleachPlot = copyobj(hEstimateMotilityGui.aBleachPlot,fig);
set(aBleachPlot,'Units','centimeters','Position',[9.5 9.5 6 6],'TickDir','out','Color','none');
axes('Units','centimeters','Position',get(aBleachPlot,'Position'),'Box','on','xtick',[],'ytick',[]);
axes(aBleachPlot);
aIntTimePlot = copyobj(hEstimateMotilityGui.aIntTimePlot,fig);
set(aIntTimePlot,'Units','centimeters','Position',[1.5 1.5 6 6],'TickDir','out','Color','none');
axes('Units','centimeters','Position',get(aIntTimePlot,'Position'),'Box','on','xtick',[],'ytick',[]);
axes(aIntTimePlot);
aRunlengthPlot = copyobj(hEstimateMotilityGui.aRunlengthPlot,fig);
set(aRunlengthPlot,'Units','centimeters','Position',[9.5 1.5 6 6],'TickDir','out','Color','none');
axes('Units','centimeters','Position',get(aRunlengthPlot,'Position'),'Box','on','xtick',[],'ytick',[]);
axes(aRunlengthPlot);
[filename, path, filterindex] = uiputfile( ...
{'*.pdf', 'Adobe vector graphics (*.pdf)';...
 '*.svg','Scalable vector graphics (*.svg)';...
 '*.jpg','JPEG 24-bit 600dpi (*.jpg)';...
 '*.png','PNG 24-bit 600dpi (*.png)';...
 '*.fig','MATLAB figure (*.fig)'},'Save as',fShared('GetSaveDir'));
if filename ~= 0
    fShared('SetSaveDir',path);
    [file, ~] = strtok(filename, '.');
    switch filterindex
        case 1
            saveas(fig,[path file '.pdf'],'pdf');
        case 2 
            saveas(fig,[path file '.svg'],'svg');
        case 3 
            print(fig,[path file '.jpg'],'-djpeg','-r600');
        case 4
            print(fig,[path file '.png'],'-dpng','-r600');
        case 5 
            savefig(fig,[path file '.fig']);
    end
end
delete(fig);

function Save
hEstimateMotilityGui = getappdata(0,'hEstimateMotilityGui');
results = getappdata(hEstimateMotilityGui.fig,'results');
data = getappdata(hEstimateMotilityGui.fig,'data');
[filename, path] = uiputfile({'*.mat','MATLAB file (*.mat)'},'Save as',fShared('GetSaveDir'));
if filename ~= 0
    fShared('SetSaveDir',path);
    [file, ~] = strtok(filename, '.');
    velocity = results{1,1};
    bootstrapdist_velocity = results{1,2};
    interactiontime_global = results{2,1};
    bootstrapdist_interactiontime_global = results{2,2};
    interactiontime = results{3,1};
    bootstrapdist_interactiontime = results{3,2};
    runlength = results{4,1};
    bootstrapdist_runlength = results{4,2};
    scale = get(hEstimateMotilityGui.mUnitVel,'Userdata');
    scale_vel = scale{get(hEstimateMotilityGui.mUnitVel,'Value')}/10^-9;
    scale = get(hEstimateMotilityGui.mUnitRunlen,'Userdata');
    scale_runlen = scale{get(hEstimateMotilityGui.mUnitRunlen,'Value')}/10^-9;
    velocities = data(:,5)/scale_vel;
    interactiontimes = data(:,2);
    runlengths = data(:,3)/scale_runlen;
    save([path file '.mat'],'velocity','bootstrapdist_velocity','interactiontime_global','bootstrapdist_interactiontime_global',...
                            'interactiontime','bootstrapdist_interactiontime','runlength','bootstrapdist_runlength',...
                            'velocities','interactiontimes','runlengths');
    if size(results,1)>4
        h = results{5,1};
        if ~isempty(h)
            bleachingtime = h(1,:);
            bleachingrho = h(2,:);
            h = results{5,2};
            bootstrapdist_bleachingtime = h(:,1);
            bootstrapdist_bleachingrho = h(:,2);
            save([path file '.mat'],'bleachingtime','bootstrapdist_bleachingtime','bleachingrho','bootstrapdist_bleachingrho','-append');
        end
        if size(results,1)>5
            wratio = results{5,1}; %tau_global; tau; R
            bootstrapdist_wratio = results{5,2}; %tau_global tau R  
            save([path file '.mat'],'wratio','bootstrapdist_wratio','-append');
        end
    end
end
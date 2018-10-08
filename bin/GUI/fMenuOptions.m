function fMenuOptions(func,varargin)
switch func
    case 'LoadConfig'
        LoadConfig(varargin{1});
    case 'SaveConfig'
        SaveConfig;
    case 'SetDefaultConfig'
        SetDefaultConfig;
     case 'SaveCorrections'
        SaveCorrections(varargin{1});
    case 'LoadCorrections'
        LoadCorrections(varargin{1});
end

function LoadConfig(hMainGui)
global Config;
[FileName, PathName] = uigetfile({'*.mat','FIESTA Config(*.mat)'},'Load FIESTA Config',fShared('GetLoadDir'));
if FileName~=0
    fShared('SetLoadDir',PathName);
    tempConfig=fLoad([PathName FileName],'Config');
    Config.ConnectMol=tempConfig.ConnectMol;
    Config.ConnectFil=tempConfig.ConnectFil;    
    Config.Threshold=tempConfig.Threshold;
    Config.RefPoint=tempConfig.RefPoint;
    Config.OnlyTrack=tempConfig.OnlyTrack;
    Config.BorderMargin=tempConfig.BorderMargin;
    Config.Model=tempConfig.Model;
    Config.MaxFunc=tempConfig.MaxFunc;
    Config.DynamicFil=tempConfig.DynamicFil;
    Config.ReduceFitBox=tempConfig.ReduceFitBox;
    Config.FilFocus=tempConfig.FilFocus;
end
fShow('Image',hMainGui);

function SaveConfig
global Config; %#ok<NUSED>
[FileName, PathName] = uiputfile({'*.mat','MAT-File(*.mat)'},'Save FIESTA Config',fShared('GetSaveDir'));
if FileName~=0
    fShared('SetSaveDir',PathName);
    file = [PathName FileName];
    if isempty(findstr('.mat',file))
        file = [file '.mat'];
    end
    save(file,'Config');
end

function SetDefaultConfig
global Config;
global DirCurrent
button = fQuestDlg('Overwrite the default configuration?','FIESTA Warning',{'Overwrite','Cancel'},'Cancel');
if strcmp(button,'Overwrite')==1
    if isdeployed
        if ismac
            file_id = fopen('~/Library/Fiesta/fiesta.ini','w');
        elseif ispc
            file_id = fopen([winqueryreg('HKEY_CURRENT_USER','Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders','Local AppData') '\Fiesta\fiesta.ini'],'w');
        end
    else
        file_id = fopen([DirCurrent 'fiesta.ini'],'w');
    end
    fwrite(file_id,jsonencode(Config));
    fclose(file_id);
end

function LoadCorrections(hMainGui)
global Stack;
fRightPanel('CheckReference',hMainGui);
[FileName, PathName] = uigetfile({'*.mat','FIESTA Transformation (*.mat)'},'Load FIESTA Reference Transformations',fShared('GetLoadDir'));
if FileName~=0
    fShared('SetLoadDir',PathName);    
    Drift=fLoad([PathName FileName],'Drift');
    if ~isempty(Drift)
        if ~iscell(Drift)
            fMsgDlg('References not compatible with this FIESTA version','error');
            return;
        end
        if numel(Stack)>numel(Drift)
            Drift{numel(Stack)} = [];
        end
        setappdata(hMainGui.fig,'Drift',Drift);
    end
    fShared('UpdateMenu',hMainGui);
end
setappdata(0,'hMainGui',hMainGui);

function SaveCorrections(hMainGui)
Drift=getappdata(hMainGui.fig,'Drift'); %#ok<NASGU>
[FileName, PathName] = uiputfile({'*.mat','MAT-files (*.mat)'},'Save FIESTA Reference Transformations',fShared('GetSaveDir'));
if FileName~=0
    fShared('SetSaveDir',PathName);
    file = strtok(FileName,'.');
    save([PathName file '.mat'],'Drift');  
end
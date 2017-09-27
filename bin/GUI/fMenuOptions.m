function fMenuOptions(func,varargin)
switch func
    case 'LoadConfig'
        LoadConfig(varargin{1});
    case 'SaveConfig'
        SaveConfig;
    case 'SetDefaultConfig'
        SetDefaultConfig;
     case 'SaveDrift'
        SaveDrift(varargin{1});
    case 'LoadDrift'
        LoadDrift(varargin{1});
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
button = questdlg('Overwrite the default configuration?','Warning','Overwrite','Cancel','Cancel');
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
    fprintf(file_id,'FIESTA DEFAULT CONFIG\n');
    fprintf(file_id,'%% general initial values %%\n');
    fprintf(file_id,'\n');
    fprintf(file_id,'TrackingServer=%s\n',Config.TrackingServer);
    fprintf(file_id,'PixelSize[nm]=%g\n',Config.PixSize);
    fprintf(file_id,'TimeDifference[ms]=%g\n',Config.Time);
    fprintf(file_id,'\n');
    fprintf(file_id,'%% Selective tracking of objects(use Mol for Molecule and Fil for Filaments)\n');
    if Config.OnlyTrack.MolFull
        fprintf(file_id,'OnlyTrack(FullImage)=Mol\n');
    elseif Config.OnlyTrack.FilFull
        fprintf(file_id,'OnlyTrack(FullImage)=Fil\n');
    else
        fprintf(file_id,'OnlyTrack(FullImage)=\n');
    end
    if Config.OnlyTrack.MolLeft
        fprintf(file_id,'OnlyTrack(LeftHalfImage)=Mol\n');
    elseif Config.OnlyTrack.FilLeft
        fprintf(file_id,'OnlyTrack(LeftHalfImage)=Fil\n');
    else
        fprintf(file_id,'OnlyTrack(LeftHalfImage)=\n');
    end
    if Config.OnlyTrack.MolRight
        fprintf(file_id,'OnlyTrack(RightHalfImage)=Mol\n');
    elseif Config.OnlyTrack.FilRight
        fprintf(file_id,'OnlyTrack(RightHalfImage)=Fil\n');
    else
        fprintf(file_id,'OnlyTrack(RightHalfImage)=\n');
    end
    fprintf(file_id,'\n');
    fprintf(file_id,'%% Treshold values\n');
    fprintf(file_id,'AreaSize[pixel]=%g\n',Config.Threshold.Area);
    fprintf(file_id,'ThresholdMode(constant, relative or variable)=%s\n',Config.Threshold.Mode);
    fprintf(file_id,'Heigth=%g\n',Config.Threshold.Height);
    fprintf(file_id,'Fit(CoD)=%g\n',Config.Threshold.Fit);
    fprintf(file_id,'FWHM(Est.)[nm]=%g\n',Config.Threshold.FWHM);
    fprintf(file_id,'BorderMargin[pixel]=%g\n',Config.BorderMargin);
    fprintf(file_id,'Filter(none, average or smooth)=%s\n',Config.Threshold.Filter);
    fprintf(file_id,'\n');fprintf(file_id,'\n');
    fprintf(file_id,'%% Specific tracking and connecting options of molecules\n');
    fprintf(file_id,'%% Feature point tracking parameters\n');
    fprintf(file_id,'MaximumVelocity[nm/s]=%g\n',Config.ConnectMol.MaxVelocity);
    fprintf(file_id,'PositionWeigths=%g\n',Config.ConnectMol.Position);
    fprintf(file_id,'DirectionWeigths=%g\n',Config.ConnectMol.Direction);
    fprintf(file_id,'SpeedWeigths=%g\n',Config.ConnectMol.Speed);
    fprintf(file_id,'IntensityWeigths=%g\n',Config.ConnectMol.IntensityOrLength);    
    fprintf(file_id,'UseIntensity(1 for yes, 0 for no)=%g\n',Config.ConnectMol.UseIntensity);    
    fprintf(file_id,'\n');
    fprintf(file_id,'%% Post-processing parameters\n');
    fprintf(file_id,'MinimumLength=%g\n',Config.ConnectMol.MinLength); 
    fprintf(file_id,'MaximumBreak=%g\n',Config.ConnectMol.MaxBreak); 
    fprintf(file_id,'MaxAngle(deg)=%g\n',Config.ConnectMol.MaxAngle);     
    fprintf(file_id,'NumberOfVerification=%g\n',Config.ConnectMol.NumberVerification);         
    fprintf(file_id,'\n');
    fprintf(file_id,'%% Fitting models\n');
    fprintf(file_id,'MaximumFunctions=%g\n',Config.MaxFunc);         
    switch(Config.Model)
        case 'GaussSymmetric'
            fprintf(file_id,'GaussianModel(symmetric, stretched, ring1 or ring2)=symmetric\n');
        case 'GaussStretched' 
            fprintf(file_id,'GaussianModel(symmetric, stretched, ring1 or ring2)=stretched\n');
        case 'GaussPlusRing'
            fprintf(file_id,'GaussianModel(symmetric, stretched, ring1 or ring2)=ring1\n');
        case 'GaussPlus2Rings'
            fprintf(file_id,'GaussianModel(symmetric, stretched, ring1 or ring2)=ring2\n');
    end
    fprintf(file_id,'\n');fprintf(file_id,'\n');
    fprintf(file_id,'%% Specific tracking and connecting options of filaments\n');
    fprintf(file_id,'%% Feature point tracking parameters\n');
    fprintf(file_id,'MaximumVelocity[nm/s]=%g\n',Config.ConnectFil.MaxVelocity);
    fprintf(file_id,'PositionWeigths=%g\n',Config.ConnectFil.Position);
    fprintf(file_id,'DirectionWeigths=%g\n',Config.ConnectFil.Direction);
    fprintf(file_id,'SpeedWeigths=%g\n',Config.ConnectFil.Speed);
    fprintf(file_id,'LengthWeigths=%g\n',Config.ConnectFil.IntensityOrLength);    
    fprintf(file_id,'DisregardEdge(1 for yes, 0 for no)=%g\n',Config.ConnectFil.DisregardEdge);    
    fprintf(file_id,'ReferencePoint(start, center or end)=%s\n',Config.RefPoint);    
    fprintf(file_id,'ReduceFitBox=%g\n',Config.ReduceFitBox); 
    fprintf(file_id,'\n');
    fprintf(file_id,'%% Post-processing parameters\n');
    fprintf(file_id,'MinimumLength=%g\n',Config.ConnectFil.MinLength); 
    fprintf(file_id,'MaximumBreak=%g\n',Config.ConnectFil.MaxBreak); 
    fprintf(file_id,'MaxAngle(deg)=%g\n',Config.ConnectFil.MaxAngle);     
    fprintf(file_id,'NumberOfVerification=%g\n',Config.ConnectFil.NumberVerification);         
    fclose(file_id);
end

function LoadDrift(hMainGui)
fRightPanel('CheckDrift',hMainGui);
[FileName, PathName] = uigetfile({'*.mat','FIESTA Drift(*.mat)'},'Load FIESTA Drift',fShared('GetLoadDir'));
if FileName~=0
    fShared('SetLoadDir',PathName);    
    Drift=fLoad([PathName FileName],'Drift');
    if ~isempty(Drift)
        if ~iscell(Drift)
            Drift = num2cell(Drift,[1 2]);
        end
        for n = 1:hMainGui.Values.MaxIdx(1)
            if length(Drift)<n
                Drift{n} = [];
            else     
                if size(Drift{n},2)==5
                    nData = size(Drift{n},1);
                    Drift{n} = [Drift{n}(:,1:3) ones(nData,1)*NaN Drift{n}(:,4:5) ones(nData,1)*NaN];
                end
            end
        end
        setappdata(hMainGui.fig,'Drift',Drift);
    end
    fShared('UpdateMenu',hMainGui);
end
setappdata(0,'hMainGui',hMainGui);

function SaveDrift(hMainGui)
Drift=getappdata(hMainGui.fig,'Drift'); %#ok<NASGU>
[FileName, PathName] = uiputfile({'*.mat','MAT-files (*.mat)'},'Save FIESTA Drift',fShared('GetSaveDir'));
if FileName~=0
    fShared('SetSaveDir',PathName);
    file = [PathName FileName];
    if isempty(findstr('.mat',file))
        file = [file '.mat'];
    end
    save(file,'Drift');
end
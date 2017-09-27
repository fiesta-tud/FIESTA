function Config = fLoadConfig(dir)
%open config file
file_id = fopen([dir 'fiesta.ini'],'r');

%skip header
fgetl(file_id);fgetl(file_id);fgetl(file_id);

%general initial values
Config.TrackingServer = ReadString(file_id);
Config.PixSize = str2double(ReadString(file_id));
Config.Time = str2double(ReadString(file_id));

Config.FileName = {''};
Config.StackName = {''};
Config.Directory = {''};
Config.StackType = {''};
Config.FirstCFrame = 0;
Config.FirstTFrame = 0;
Config.LastFrame = 0;
Config.FilFocus = 0;

%skip
fgetl(file_id);fgetl(file_id);

% Selective tracking of objects
str = ReadString(file_id);
if strcmp(str,'Mol')
    Config.OnlyTrack.MolFull=1;
    Config.OnlyTrack.FilFull=0;
elseif strcmp(str,'Fil')
    Config.OnlyTrack.MolFull=0;
    Config.OnlyTrack.FilFull=1;
else
    Config.OnlyTrack.MolFull=0;
    Config.OnlyTrack.FilFull=0;
end
str = fgetl(file_id);
if ~isempty(strfind(str,'IncludeFitData'))
    k = strfind(str,'=');
    Config.OnlyTrack.IncludeData = str2double(str(k(1)+1:end));
else
    Config.OnlyTrack.IncludeData = 0;
end
str = fgetl(file_id);
while isempty(strfind(str,'Treshold values'))
    str = fgetl(file_id);
end

% Treshold values
Config.Threshold.Area = str2double(ReadString(file_id));
Config.Threshold.Mode = ReadString(file_id);
Config.Threshold.Height = str2double(ReadString(file_id));
Config.Threshold.Fit = str2double(ReadString(file_id));
Config.Threshold.FWHM = str2double(ReadString(file_id));
Config.BorderMargin = str2double(ReadString(file_id));
Config.Threshold.Filter = ReadString(file_id);

%skip
fgetl(file_id);fgetl(file_id);fgetl(file_id);fgetl(file_id);

% Specific tracking and connecting options of molecules
% Feature point tracking parameters
Config.ConnectMol.MaxVelocity = str2double(ReadString(file_id));
Config.ConnectMol.Position = str2double(ReadString(file_id));
Config.ConnectMol.Direction = str2double(ReadString(file_id));
Config.ConnectMol.Speed = str2double(ReadString(file_id));
Config.ConnectMol.IntensityOrLength = str2double(ReadString(file_id));
Config.ConnectMol.UseIntensity = str2double(ReadString(file_id));

%skip
fgetl(file_id);fgetl(file_id);

% Post-processing parameters
Config.ConnectMol.MinLength = str2double(ReadString(file_id));
Config.ConnectMol.MaxBreak = str2double(ReadString(file_id));
Config.ConnectMol.MaxAngle = str2double(ReadString(file_id));
Config.ConnectMol.NumberVerification = str2double(ReadString(file_id));
Config.ConnectMol.ReEval = 0;

%skip
fgetl(file_id);fgetl(file_id);

% Fitting models
Config.MaxFunc = str2double(ReadString(file_id));
str = ReadString(file_id);
switch(str)
    case 'symmetric'
        Config.Model='GaussSymmetric';
    case 'stretched' 
        Config.Model='GaussStretched';
    case 'ring1'
        Config.Model='GaussPlusRing';
    case 'ring2'
        Config.Model='GaussPlus2Rings';
end

%skip
fgetl(file_id);fgetl(file_id);fgetl(file_id);fgetl(file_id);

% Specific tracking and connecting options of filaments
% Feature point tracking parameters
Config.ConnectFil.MaxVelocity = str2double(ReadString(file_id));
Config.ConnectFil.Position = str2double(ReadString(file_id));
Config.ConnectFil.Direction = str2double(ReadString(file_id));
Config.ConnectFil.Speed = str2double(ReadString(file_id));
Config.ConnectFil.IntensityOrLength = str2double(ReadString(file_id));
Config.ConnectFil.DisregardEdge = str2double(ReadString(file_id));
Config.RefPoint = ReadString(file_id);
Config.ReduceFitBox = str2double(ReadString(file_id));

%skip
fgetl(file_id);fgetl(file_id);

% Post-processing parameters
Config.ConnectFil.MinLength = str2double(ReadString(file_id));
Config.ConnectFil.MaxBreak = str2double(ReadString(file_id));
Config.ConnectFil.MaxAngle = str2double(ReadString(file_id));
Config.ConnectFil.NumberVerification = str2double(ReadString(file_id));
Config.ConnectFil.ReEval = 0;

function output = ReadString(file_id)
str = fgetl(file_id);
k = strfind(str,'=');
output = str(k(1)+1:end);

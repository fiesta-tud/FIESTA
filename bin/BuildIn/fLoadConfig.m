function Config = fLoadConfig(dir)
%open config file
file_id = fopen([dir 'fiesta.ini'],'r');

Config = jsondecode(fread(file_id,'*char'));

Config.StackName = {''};
Config.Directory = {''};
Config.StackType = {''};
Config.FirstCFrame = 0;
Config.FirstTFrame = 0;
Config.LastFrame = 0;

fclose(file_id);
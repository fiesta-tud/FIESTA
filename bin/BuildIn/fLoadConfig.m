function Config = fLoadConfig(dir)
%open config file
file_id = fopen([dir 'fiesta.ini'],'r');

file_str = fread(file_id,'*char');
if size(file_str,1)>size(file_str,2)
    file_str = file_str';
end
Config = jsondecode(file_str);

Config.StackName = {''};
Config.Directory = {''};
Config.StackType = {''};
Config.FirstCFrame = 0;
Config.FirstTFrame = 0;
Config.LastFrame = 0;

fclose(file_id);
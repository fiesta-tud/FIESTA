function Fiesta
%FIESTA starting the Fluorescence Image Evaluation Software for Tracking and Analysis
% The script automatically looks for a new version of the software and does start an
% update, if necessary.

%Name of PC where the FIESTA Tracking Server runs
global PathBackup;
global DirRoot;
global DirCurrent;

%backup path to reset path after closing FIESTA
PathBackup = path;

%get path where fiesta.m was started
DirRoot = [fileparts( mfilename('fullpath') ) filesep];

if isdeployed
    if ispc
        DirCurrent = [pwd filesep];
        DirUpdater = DirCurrent;
    else
        if isfolder('/Applications/Fiesta.app')
            DirCurrent = DirRoot;
            DirUpdater = '/Applications/Fiesta.app/Contents/Updater/';
        else
            errordlg({'The FIESTA application is not located in the applications folder','','Please move the Fiesta.app folder to applications','','Support: fiesta@mailbox.tu-dresden.de'},'FIESTA Error','modal');
            return;
        end 
    end
else
    DirCurrent = DirRoot;
    DirUpdater = DirCurrent;
end

%Set root directory for FIESTA
DirBin = [DirRoot 'bin' filesep];

%get online version of FIESTA
link_fiestainfo{1} = 'https://cloudstore.zih.tu-dresden.de/index.php/s/QXWit4TjaHi30T4/download';
link_fiestainfo{2} = 'http://bcube-dresden.de/fileadmin/www.bcube-dresden.de/uploads/diez/fiesta/fiestainfo.json';
link_fiestainfo{3} = 'http://bcube-dresden.de/fileadmin/www.bcube-dresden.de/uploads/diez/fiesta/fiestainfo.json';
online_num = zeros(size(link_fiestainfo));
online_str = '';
opt = weboptions('ContentType','json');
for n = 1:numel(link_fiestainfo)
    try
        fiesta_info = webread(link_fiestainfo{n},opt);
    catch
        fiesta_info = [];
    end
    if isfield(fiesta_info,'CurrentFiestaVersion')
        online_version = fiesta_info.CurrentFiestaVersion';
        online_num(n) = online_version(1)*100 + online_version(2)*10 + online_version(3);
        if online_num(n) == max( online_num )
           online_str =  [num2str(online_version(1)) '.' num2str(online_version(2)) '.' num2str(online_version(3))];
        end
    end
end

version='';

%get local version of FIESTA
file_id = fopen([DirUpdater 'readme.txt'], 'r'); 
if file_id ~= -1
    index = fgetl(file_id);
    str_version = index(66:end);
    str_version = textscan(str_version,'%s','Delimiter','.');
    local_version = str2double(str_version{1});
    local_num = local_version(1)*100 + local_version(2)*10 + local_version(3);
    fclose(file_id); 
else
    local_num = 0;
end

%compare local version with online version
if ~isempty(online_str) && local_num<max(online_num)
    button = questdlg({'There is FIESTA update available!','',['Do you want to update to version ' online_str ' now?']},'FIESTA Update','Yes','No','Yes');
    if strcmp(button,'Yes')
        [~,idx] = max(online_num);
        try
            jsondecode(webread(link_fiestainfo{idx}));
            version='latest';
        catch
            t=warndlg({'Could not update FIESTA!','','Make sure that your internet is working.','','Support: fiesta@mailbox.tu-dresden.de'},'FIESTA Warning','modal');
            uiwait(t);  
        end
    else
        version='';
    end        
elseif isempty(online_str)
    t=warndlg({'Could not check for FIESTA updates!','','Please check manually for updates.','','Support: fiesta@mailbox.tu-dresden.de'},'FIESTA Warning','modal');
    uiwait(t);  
end

%check if FIESTA is the Library folder on Win and MacOS is available and correct
if isempty(version)&&isdeployed
    if ismac
        if isfolder('~/Library/Fiesta')
            d1 = dir('/Applications/Fiesta.app/Contents/AppData');
            d2 = dir('~/Library/Fiesta');
            if ~isequal([d1.name],[d2.name])
                rmdir('~/Library/Fiesta','s');
                mkdir('~/Library/Fiesta');
                copyfile('/Applications/Fiesta.app/Contents/AppData/*','~/Library/Fiesta/');    
            end
            try
                fLoadConfig(file_id,'~/Library/Fiesta/fiesta.ini');
            catch
                rmdir('~/Library/Fiesta','s');
                mkdir('~/Library/Fiesta');
                copyfile('/Applications/Fiesta.app/Contents/AppData/*','~/Library/Fiesta/');  
            end
        else
            mkdir('~/Library/Fiesta');
            copyfile('/Applications/Fiesta.app/Contents/AppData/*','~/Library/Fiesta/');
        end
    elseif ispc
        folder = [winqueryreg('HKEY_CURRENT_USER','Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders','Local AppData') filesep 'Fiesta' filesep];
        if isfolder(folder)
            d1 = dir([DirCurrent 'AppData']);
            d2 = dir(folder);
            if ~isequal([d1.name],[d2.name])
                rmdir(folder,'s');
                mkdir(folder);
                copyfile([DirCurrent 'AppData\*'],folder);    
            end
            try
                fLoadConfig(file_id,[folder '\fiesta.ini']);
            catch
                rmdir(folder,'s');
                mkdir(folder);
                copyfile([DirCurrent 'AppData\*'],folder);    
            end
        else
            mkdir(folder);
            copyfile([DirCurrent 'AppData\*'],folder);
        end
    end 
end

%check whether to download and install FIESTA 
if ~isempty(version)
    if isdeployed
        try
            if ispc
                uacrun([DirCurrent 'fiestaUpdater.exe'])
            elseif ismac
                unix('osascript -e ''do shell script "java -jar /Applications/Fiesta.app/Contents/Updater/FiestaUpdater.jar" with administrator privileges'' &');
            end
        catch ME
            errordlg(getReport(ME, 'extended'),'FIESTA Error','modal');
            return
        end
    else
        FiestaUpdater;
    end
else
    if strcmp(DirRoot,DirCurrent)
        %add path to FIESTA functions
        addpath(genpath(DirBin));
    end
    
    % add dependency for compiler
    if  0   
        %#function uacrun
        %#function uacrun.mexw64
        h = imread('About.jpg');
        h = imread('uacrun.mexw64');
        h = imread('bioformats_package.jar');
    end
    
    % finally start the application
    try
        fMainGui('Create');
    catch ME
        errordlg(getReport(ME, 'extended','hyperlinks','off'),'FIESTA Error','modal');
        return
    end
end
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
    else
        if isdir('/Applications/Fiesta.app')
            DirCurrent = DirRoot;
        else
            errordlg({'The FIESTA application is not located in the applications folder','','Please move the Fiesta.app folder to applications','','Support: ruhnow@bcube-dresden.de'},'FIESTA Error','modal');
            return;
        end 
    end
else
    DirCurrent = DirRoot;
end

%Set root directory for FIESTA
DirBin = [DirRoot 'bin' filesep];

%get online version of FIESTA
o = weboptions('CertificateFilename','');
data = [];%webread('https://www.bcube-dresden.de/fiesta/uploads/readme.txt',o);
if ~isempty(data)
    online_version = native2unicode(data(66:74),'UTF-8');
else
    online_version = '';
end

version='';

%get local version of FIESTA
file_id = fopen([DirCurrent 'readme.txt'], 'r'); 
if file_id ~= -1
    index = fgetl(file_id);
    local_version = index(66:74);
    fclose(file_id); 
else
    local_version = '';
end

%compare local version with online version
if ~strcmp( local_version , online_version ) && ~isempty(online_version)
    button = questdlg({'There is FIESTA update available!','',['Do you want to update to version ' online_version ' now?']},'FIESTA Update','Yes','No','Yes');
    if strcmp(button,'Yes')
        [~,s] = urlread('http://www.bcube-dresden.de/fiesta/uploads/');
        if s
            version='latest';
        else
            t=warndlg({'Could not update FIESTA!','','Make sure that your internet is working.','','Support: ruhnow@bcube-dresden.de'},'FIESTA Warning','modal');
            uiwait(t);  
        end
    else
        version='';
    end        
end

%check if FIESTA is the Library folder on Win and MacOS is available and correct
if isempty(version)&&isdeployed
    if ismac
        if isdir('~/Library/Fiesta')
            d1 = dir('/Applications/Fiesta.app/Contents/AppData');
            d2 = dir('~/Library/Fiesta');
            if ~isequal([d1.name],[d2.name])
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
        if isdir(folder)
            d1 = dir([DirCurrent 'AppData']);
            d2 = dir(folder);
            if ~isequal([d1.name],[d2.name])
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
if ~isempty(version)&&status
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
    % finally start the application
    try
        fMainGui('Create');
    catch ME
        errordlg(getReport(ME, 'extended','hyperlinks','off'),'FIESTA Error','modal');
        return
    end
end
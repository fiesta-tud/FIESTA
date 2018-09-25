function FiestaUpdater

%get path where fiesta.m was started
DirRoot = [fileparts( mfilename('fullpath') ) filesep];

warning('off','all');

if isfile([DirRoot 'update.zip'])
    delete([DirRoot 'update.zip']);
end

if isfile([DirRoot 'fiesta.ini_backup'])
    delete([DirRoot 'fiesta.ini_backup']);
end

%check if FIESTA online is available
disp('Checking available versions - Please wait...');
link_fiestainfo{1} = 'https://cloudstore.zih.tu-dresden.de/index.php/s/QXWit4TjaHi30T4/download';
link_fiestainfo{2} = 'http://bcube-dresden.de/fileadmin/www.bcube-dresden.de/uploads/diez/fiesta/fiestainfo.json';
link_fiestainfo{3} = 'http://bcube-dresden.de/fileadmin/www.bcube-dresden.de/uploads/diez/fiesta/fiestainfo.json';
online_num = zeros(size(link_fiestainfo));
fiesta_info = [];
opt = weboptions('ContentType','json');
for n = 1:numel(link_fiestainfo)
    try
        info = webread(link_fiestainfo{n},opt);
    catch
        info = [];
    end
    if isfield(info,'CurrentFiestaVersion')
        online_version = info.CurrentFiestaVersion';
        online_num(n) = online_version(1)*100 + online_version(2)*10 + online_version(3);
        if online_num(n) == max( online_num )
           fiesta_info = info;
        end
    end
end

list = ListFiestaVersion(fiesta_info);


urlzip = GetUserVersion(list,fiesta_info.DownloadSource);
disp('Downloading update - Please wait...');
outfilename = websave([DirRoot 'update.zip'],urlzip);

if isempty(outfilename)
    %FIESTA online files are available but wrong version input
    errordlg('Latest FIESTA version corrupted','FIESTA Update Error','modal');
    return;
end
  
RestoreFiestaIni = false;

files = dir(DirRoot);
disp('Removing old version - Please wait...');
for n = 1:length(files)
    if ~files(n).isdir 
        if contains(files(n).name,'fiesta.ini')
            movefile([DirRoot 'fiesta.ini'],[DirRoot 'fiesta.ini_backup']);
            RestoreFiestaIni = true;
        elseif ~contains(files(n).name,'update.zip')
            delete([DirRoot files(n).name]);
        end
    else
        if ~contains(files(n).name,'.')
            rmpath(genpath([DirRoot files(n).name]));
            rmdir([DirRoot files(n).name],'s');   
        end
    end
end
disp('Extracting new version - Please wait...');
filenames = unzip(outfilename,DirRoot);
for i=1:length(filenames)
    fileattrib(filenames{i},'+w');
end
if RestoreFiestaIni
    try
        file_id = fopen([DirRoot 'fiesta.ini_backup'],'r');
        Config = jsondecode(fread(file_id,'*char'));
        fclose(file_id);
        if ~isempty(Config)
            delete([DirRoot 'fiesta.ini']);
            movefile([DirRoot 'fiesta.ini_backup'],[DirRoot 'fiesta.ini']);
        else
            disp('Using new fiesta.ini');
            delete([DirRoot 'fiesta.ini_backup']);
        end
    catch
        if isfile([DirRoot 'fiesta.ini_backup'])
            disp('Using new fiesta.ini');
            delete([DirRoot 'fiesta.ini_backup']);
        end
    end
end
if isfile([DirRoot 'update.zip'])
    delete([DirRoot 'update.zip']);
end
warning('on','all');
disp('Update complete - restart FIESTA');
msgbox('FIESTA Update complete - please restart FIESTA','FIESTA Update');

function list = ListFiestaVersion(info)
archive = info.ArchiveSource;
list = cell(numel(archive),2);
for n = 1:numel(archive)
    version = archive(n).Version;
    list{n,1} = [num2str(version(1)) '.' num2str(version(2)) '.' num2str(version(3))];
    list{n,2} = archive(n).Download;
end

function version = GetUserVersion(list,latest_link)
hVersionDialog = dialog('Name','FIESTA Update','Units','normalized');
uicontrol('Parent',hVersionDialog,'Units','normalized','Position',[0.1 0.75 0.8 0.2],'Style','pushbutton','String','Get latest FIESTA version','FontSize',12,'FontWeight','bold','UserData',latest_link,'Callback',@doCallback);
uicontrol('Parent',hVersionDialog,'Units','normalized','Position',[0.1 0.6 0.8 0.05],'Style','text','String','Available FIESTA version','FontSize',12);
uicontrol('Parent',hVersionDialog,'Units','normalized','Position',[0.1 0.2 0.8 0.4],'Tag','lArchievedVersion','Style','listbox','String',list(:,1),'FontSize',12);
uicontrol('Parent',hVersionDialog,'Units','normalized','Position',[0.1 0.05 0.8 0.1],'Style','pushbutton','String','Get archieved FIESTA version','FontSize',12,'UserData',list,'Callback',@doCallback);
uiwait(hVersionDialog);
version = get(hVersionDialog,'UserData');
delete(hVersionDialog);

function doCallback(obj, ~) 
data = get(obj,'UserData');
if ~iscell(data)
    set(gcbf,'UserData',data);    
else
    h = findobj('Tag','lArchievedVersion');
    n = get(h,'Value');
    set(gcbf,'UserData',data{n,2});
end
uiresume(gcbf);
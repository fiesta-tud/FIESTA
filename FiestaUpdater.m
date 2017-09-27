function FiestaUpdater

%Set current directory for FIESTA
DirCurrent = [pwd filesep];

%get path where fiesta.m was started
DirRoot = [fileparts( mfilename('fullpath') ) filesep];

if ~isdeployed
    warning('off','all');
    rmpath(genpath(DirCurrent));
    warning('on','all');
end

%check wether version runs in MatLab or as Redistributable
if ~isdeployed
    %Fiesta runs in MatLab - get Fiesta code
    mode = 'source';
    archive = '';
    DirCurrent = DirRoot;
else
    if ispc || ismac ||isunix
        %get computer type
        mode = computer;
        archive = ['/' computer];
    else
        errordlg('FIESTA for your Operation System is not yet supported','FIESTA Update Error','modal');
        return;
    end
end

%check if FIESTA online is available
[~,status]=urlread('http://www.bcube-dresden.de/fiesta/uploads/'); %#ok<*ASGLU>
if status
    %check if user has access to FIESTA online
    [index,~]=urlread(['http://www.bcube-dresden.de/fiesta/uploads/archive' archive]); %#ok<*ASGLU>
else
    errordlg({'Could not update FIESTA!','','Make sure that your internet is working.','','Support: ruhnow@bcube-dresden.de'},'FIESTA Error','modal');
    return;
end


list = ListFiestaVersion(index);
version = GetUserVersion(list);

if strcmp(version,'latest')
    [index,~] = urlread('http://www.bcube-dresden.de/fiesta/uploads/readme.txt');
    online_version = native2unicode(index(66:74),'UTF-8');
else
    online_version = version;
end

file_id = fopen([DirCurrent 'readme.txt'], 'r'); 
if file_id ~= -1
    index = fgetl(file_id);
    local_version = index(66:74);
    fclose(file_id); 
    if str2double(online_version(4))>str2double(local_version(4))
        % install new or update new MCR 
    end
end
    
if strcmp(version,'latest')
    %get newest version
    urlzip =['http://www.bcube-dresden.de/fiesta/uploads/FIESTA(' mode ').zip']; 
    [index,status] = urlread(urlzip);                    
    if ~status
        %FIESTA online files are available but wrong version input
        errordlg('Latest FIESTA version corrupted','FIESTA Update Error','modal');
        return;
    end
else
    %get version x.xx.xxxx
    urlzip=['http://www.bcube-dresden.de/fiesta/uploads/archive' archive '/' version '.zip'];                
    %check if FIESTA version x.xx.xxxx is available
    [index,status] = urlread(urlzip);  
    if ~status
        %FIESTA online files are available but wrong version input
        errordlg(['Version ' version ' corrupted'],'FIESTA Update Error','modal');
        return;
    end
end

RestoreFiestaIni = false;

files = dir(DirCurrent);

for n = 1:length(files)
    if ~files(n).isdir 
        if isempty(strfind(files(n).name,'fiesta.ini'))
            delete([DirCurrent files(n).name]);
        else
            movefile([DirCurrent 'fiesta.ini'],[DirCurrent 'fiesta.ini_backup']);
            RestoreFiestaIni = true;
        end
    else
        if strcmp(mode,'source') && isempty(strfind(files(n).name,'.'))
            rmdir([DirCurrent files(n).name],'s');
        end
    end
end

filenames = unzip(urlzip,DirCurrent);
for i=1:length(filenames)
    fileattrib(filenames{i},'+w');
end
if RestoreFiestaIni
    delete([DirCurrent 'fiesta.ini']);
    movefile([DirCurrent 'fiesta.ini_backup'],[DirCurrent 'fiesta.ini']);
end
msgbox('FIESTA Update complete - please restart FIESTA','FIESTA Update');

function list = ListFiestaVersion(index)
list=[];
%get online version of FIESTA
index = native2unicode(index,'UTF-8');
p = strfind(index,'<hr>');
str = index(p(1)+4:p(2)-1);
k = find( double(str) == 10 );
start = 1;
p = 1;
for n = 1:length(k)
    if ~isempty(strfind(str(start:k(n)),'.zip'))
        h_str = strrep(str(start:k(n)-1),'.zip</a>','');
        ps = strfind(h_str,'.zip">');
        list{p} = h_str(ps(1)+6:end);         %#ok<AGROW>
        start = k(n)+1;
        p=p+1;
    end
end

function version = GetUserVersion(list)
hVersionDialog = dialog('Name','FIESTA Update','Units','normalized');
uicontrol('Parent',hVersionDialog,'Units','normalized','Position',[0.1 0.75 0.8 0.2],'Style','pushbutton','String','Get latest FIESTA version','FontSize',12,'FontWeight','bold','UserData','latest','Callback',@doCallback);
uicontrol('Parent',hVersionDialog,'Units','normalized','Position',[0.1 0.6 0.8 0.05],'Style','text','String','Available FIESTA version','FontSize',12);
uicontrol('Parent',hVersionDialog,'Units','normalized','Position',[0.1 0.2 0.8 0.4],'Tag','lArchievedVersion','Style','listbox','String',list,'FontSize',12);
uicontrol('Parent',hVersionDialog,'Units','normalized','Position',[0.1 0.05 0.8 0.1],'Style','pushbutton','String','Get archieved FIESTA version','FontSize',12,'UserData','archieved','Callback',@doCallback);
uiwait(hVersionDialog);
version = get(hVersionDialog,'UserData');
delete(hVersionDialog);

function doCallback(obj, evd) %#ok
if strcmp(get(obj,'UserData'),'latest')
  set(gcbf,'UserData','latest');
else
  h = findobj('Tag','lArchievedVersion');
  str = get(h,'String');
  n = get(h,'Value');
  set(gcbf,'UserData',str{n}(1:9));
end
uiresume(gcbf);
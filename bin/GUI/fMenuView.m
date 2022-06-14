function fMenuView(func,varargin)
switch func
    case 'View'
        View(varargin{1},varargin{2});
    case 'ViewCheck'
        ViewCheck;
    case 'ColorOverlay'
        ColorOverlay;
    case 'CorrectStack'
        CorrectStack;
    case 'ApplyCorrections'
        ApplyCorrections;
    case 'MoveAverage'
        MoveAverage;
    case 'ShowCorrections'
        ShowCorrections;
    case 'EstimateCorrections'
        EstimateCorrections;
    case 'CreateDynamicFilStack'
        CreateDynamicFilStack;
    case 'CropStack'
        CropStack;
end

function MoveAverage
global Stack;
global TimeInfo;
hMainGui=getappdata(0,'hMainGui');
frames = str2double(fInputDlg('No of frames to average','10'));
frames = frames-1;
for m = 1:numel(Stack)
    [y,x,nFrames] = size(Stack{m});
    nStack = uint16(zeros(y,x,nFrames-frames));
    nTimeInfo = zeros(1,nFrames-frames);
    progressdlg('String',['Moving average for channel ' num2str(m)],'Max',nFrames-frames,'Parent',hMainGui.fig);
    for n = 1:nFrames-frames
         nStack(:,:,n) = uint16(mean(Stack{m}(:,:,n:n+frames),3));
         nTimeInfo(n) = mean(TimeInfo{m}(n:n+frames));
         progressdlg(n);
    end
    progressdlg('close');
    nTimeInfo = nTimeInfo-nTimeInfo(1);
    Stack{m} = nStack;
    TimeInfo{m} = nTimeInfo;
end
hMainGui = getappdata(0,'hMainGui');
hMainGui.Values.MaxIdx = [1 size(Stack{1},3)];
fMainGui('InitGui',hMainGui);
hMainGui = getappdata(0,'hMainGui');
setappdata(0,'hMainGui',hMainGui);
fShow('Image');

function EstimateCorrections
global Stack;
global Config;
global FiestaDir;
hMainGui=getappdata(0,'hMainGui');
Drift = cell(1,numel(Stack));
for m = 1:numel(Stack)
    dirStatus = [FiestaDir.AppData 'fiestastatus' filesep];  
    z = size(Stack{m},3);
    parallelprogressdlg('String',['Estimating corrections for channel ' num2str(m)],'Max',z,'Parent',hMainGui.fig,'Directory',FiestaDir.AppData);
    fft_ref = fft2(Stack{m}(:,:,1));
    drift = zeros(3,3,z);
    drift(:,:,1) = [1 0 0; 0 1 0; 0 0 1];
    parfor(n = 2:z,Config.NumCores)
        output = dftregistration(fft2(Stack{m}(:,:,n)), fft2(Stack{m}(:,:,n-1)), 1); % Detect shift neighbouring images
        drift(:,:,n) = [1 0 0; 0 1 0; -output(4) -output(3) 1];
        fSave(dirStatus,n);
    end
    parallelprogressdlg('close');
    
%     x = drift(3,1,:);
%     y = drift(3,2,:);
%     dz = round(z/10);
%     idx = isoutlier(x,'movmedian',dz) | isoutlier(y,'movmedian',dz);
%     idx(1) = 0;
%     idx(end) = 0;
%     n = 1:numel(x);
%     x(idx) = [];
%     y(idx) = [];
%     x = smooth(x,dz);
%     y = smooth(y,dz);
%     x = interp1(n(~idx),x,n);
%     y = interp1(n(~idx),y,n);
%     drift(3,1,:) = x;
%     drift(3,2,:) = y;
    
    drift(3,1,:) = cumsum(drift(3,1,:));
    drift(3,2,:) = cumsum(drift(3,2,:));
    Drift{m} = drift;
end
setappdata(hMainGui.fig,'Drift',Drift);
fShared('UpdateMenu',hMainGui);
% for n = 2:size(Stack{1},3)
%     output = dftregistration(fft_stack(:,:,n), fft_stack(:,:,n-1), 100); % Detect shift neighbouring images
%     drift1(n,1:2) = drift1(n-1,1:2)+output(3:4);
% end
% for n = 4:1:size(Stack{1},3)
%     output = dftregistration(fft_stack(:,:,n), fft_stack(:,:,n-3), 100); % Detect shift neighbouring images
%     drift3(ceil(n/3),1:2) = drift3(ceil(n/3)-1,1:2)+output(3:4);
% end
% figure;
% plot(drift1)

function CreateDynamicFilStack
global Stack;
global TimeInfo;
global Config;
TimeInfo{2} = TimeInfo{1};
TimeInfo{3} = TimeInfo{1};
Config.Time(2) = Config.Time(1);
Config.Time(3) = Config.Time(1);
nFrames = size(Stack{1},3);
frames = str2double(fInputDlg({'No of frames to subtract forward','No of frames to subtract backward'},{'4','2'}));
frames = frames+1;
% for n = 1:size(Stack{1},3)
%     Stack{1}(:,:,n) = fibermetric(Stack{1}(:,:,n),8)*10000;
% end
StackForward = Stack{1}(:,:,frames(1):1:end)-Stack{1}(:,:,1:1:end-frames(1)+1);
StackBackward = Stack{1}(:,:,1:1:end-frames(2)+1)-Stack{1}(:,:,frames(2):1:end);
StackForward(:,:,end+1:nFrames) = mean2(StackForward(:,:,end));
StackBackward(:,:,end+1:nFrames) = mean2(StackBackward(:,:,end));
Stack{2} = StackForward+1;
Stack{3} = StackBackward+1;
hMainGui = getappdata(0,'hMainGui');
hMainGui.Values.MaxIdx = [3 size(Stack{1},3) size(Stack{1},3) size(Stack{1},3)];
fMainGui('InitGui',hMainGui);
hMainGui = getappdata(0,'hMainGui');
hMainGui.Values.StackColor = [1 5 3];
set(hMainGui.ToolBar.ToolChannels(5),'State','on');
setappdata(0,'hMainGui',hMainGui);
fShow('Image');

function CropStack
global Stack;
hMainGui = getappdata(0,'hMainGui');
if ~isempty(hMainGui.Region)
    x = [min(hMainGui.Region(end).X) max(hMainGui.Region(end).X)];
    y = [min(hMainGui.Region(end).Y) max(hMainGui.Region(end).Y)];
    for n = 1:numel(Stack)
        Stack{n} = Stack{n}(y(1):y(2),x(1):x(2),:);
    end
    fMainGui('InitGui',hMainGui);
    hMainGui = getappdata(0,'hMainGui');
    fMenuContext('DeleteRegion',hMainGui);
end
        
function ApplyCorrections
if strcmp(get(gcbo,'Checked'),'on')
    set(gcbo,'Checked','off');
else
    set(gcbo,'Checked','on');
    hMainGui = getappdata(0,'hMainGui');
    set(hMainGui.Menu.mShowCorrections,'Checked','off');
    delete(findobj(hMainGui.MidPanel.aView,'Tag','pCorrections'));
end
fShow('Image');

function ShowCorrections
hMainGui = getappdata(0,'hMainGui');
if strcmp(get(gcbo,'Checked'),'on')
    set(gcbo,'Checked','off');
    delete(findobj(hMainGui.MidPanel.aView,'Tag','pCorrections'));
else
    set(gcbo,'Checked','on');
    set(hMainGui.Menu.mApplyCorrections,'Checked','off');
end
fShow('Image');

function CorrectStack
global Stack;
global Config;
global FiestaDir;
hMainGui = getappdata(0,'hMainGui');
Drift=getappdata(hMainGui.fig,'Drift');
for m = 1:length(Stack)
    if numel(Drift)>=m && ~isempty(Drift{m})
        S = Stack{m};
        D = Drift{m};
        [y,x,z] = size(S); 
        NS = zeros(size(S),'like',S);
        dirStatus = [FiestaDir.AppData 'fiestastatus' filesep];  
        parallelprogressdlg('String',['Correcting channel ' num2str(m)],'Max',z,'Parent',hMainGui.fig,'Directory',FiestaDir.AppData);
        parfor(n = 1:z,Config.NumCores)   
            I = S(:,:,n);
            fidx = min([n size(D,3)]);
            T = D(:,:,fidx);
            Det = T(1,1).*T(2,2) - T(1,2) .* T(2,1);
            T = [ T(2,2) -T(1,2) 0; -T(2,1) T(1,1) 0; T(2,1).*T(3,2)-T(3,1).*T(2,2) T(1,2).*T(3,1)-T(3,2).*T(2,2) Det] / Det;
            X = repmat(1:x,y,1);
            Y = repmat(1:y,1,x);
            X = X(:);
            Y = Y(:);
            NX = X * T(1,1) + Y * T(2,1) + T(3,1) + 10^-13;
            NY = X * T(1,2) + Y * T(2,2) + T(3,2) + 10^-13;
            k = NX<1 | NX>x | NY<1 | NY>y;
            NX(k) = [];
            NY(k) = [];
            X(k) = [];
            Y(k) = [];
            idx = Y + (X - 1).*y;
            NX1 = fix(NX);
            NX2 = ceil(NX);
            NY1 = fix(NY);
            NY2 = ceil(NY);
            idx11 = NY1 + (NX1 - 1).*y;
            idx12 = NY2 + (NX1 - 1).*y;
            idx21 = NY1 + (NX2 - 1).*y;
            idx22 = NY2 + (NX2 - 1).*y;
            W11=(NX2-NX).*(NY2-NY);
            W12=(NX2-NX).*(NY-NY1);
            W21=(NX-NX1).*(NY2-NY);
            W22=(NX-NX1).*(NY-NY1);
            NI = zeros(y,x);
            I = double(I);
            NI(idx) = I(idx11).*W11+...
                  I(idx21).*W21+...
                  I(idx12).*W12+...
                  I(idx22).*W22;
            NS(:,:,n) = uint16(NI);
            fSave(dirStatus,n);
        end
        parallelprogressdlg('close');
        Stack{m} = NS;
        set(hMainGui.Menu.mCorrectStack,'Enable','off','Checked','on');
        set(hMainGui.Menu.mApplyCorrections,'Enable','off');
        set(hMainGui.Menu.mShowCorrections,'Enable','off');
    end
    if strcmp(get(hMainGui.Menu.mCorrectStack,'Checked'),'on')
        Config.StackName = ['~' Config.StackName];
        fMainGui('InitGui',hMainGui);
        fShared('UpdateMenu',hMainGui);        
        fShow('Image');
        fShow('Tracks');
    end
end

function View(hMainGui,idx)
n = getChIdx;
if ~isempty(idx)
   hMainGui.Values.FrameIdx(2:end)=real(hMainGui.Values.FrameIdx(2:end))+idx*1i;
else
   hMainGui.Values.FrameIdx(n) = round(get(hMainGui.MidPanel.sFrame,'Value')); 
   hMainGui.Values.FrameIdx(2:end) = real(hMainGui.Values.FrameIdx(2:end));
end
setappdata(0,'hMainGui',hMainGui);
fShow('Image');

function ViewCheck
if strcmp(get(gcbo,'Checked'),'on')==1
    set(gcbo,'Checked','off');
else
    set(gcbo,'Checked','on');
end
fShow('Image');

function ColorOverlay
hMainGui=getappdata(0,'hMainGui');
if strcmp(get(hMainGui.Menu.mColorOverlay,'Checked'),'on')
    s = 'off';
else
    s ='on';
end
set(hMainGui.ToolBar.ToolChannels(5),'State',s);
fToolBar('Overlay');
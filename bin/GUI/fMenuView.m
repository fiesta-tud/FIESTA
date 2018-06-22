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
    case 'ShowCorrections'
        ShowCorrections;
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
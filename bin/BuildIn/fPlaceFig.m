function NewPos = fPlaceFig(hFig,mode)
hMainGui = getappdata(0,'hMainGui');
set(hMainGui.fig,'Units','pixels');
Pos = get(hMainGui.fig,'Position');
switch(mode)
    case 'small' 
        NewPos = [Pos(1)+0.4*Pos(3) Pos(2)+0.425*Pos(4) Pos(3)*0.2 Pos(4)*0.15];
        if NewPos(3)<300
            NewPos(3)=300;
        end
        if NewPos(4)<100
            NewPos(4)=100;
        end
    case 'big'
        NewPos = [Pos(1)+0.05*Pos(3) Pos(2)+0.05*Pos(4) Pos(3)*0.65 Pos(4)*0.95];
    case 'speed'
        NewPos = [Pos(1)+0.4*Pos(3) Pos(2)+0.3*Pos(4) Pos(3)*0.2 Pos(4)*0.3];
    case 'export'
        NewPos = [Pos(1)+0.65*Pos(3) Pos(2)+0.15*Pos(4) Pos(3)*0.3 Pos(4)*0.7];
    case 'special'
        NewPos = [Pos(1)+0.35*Pos(3) Pos(2)+0.25*Pos(4) Pos(3)*0.30 Pos(4)*0.5];
    case 'reposition'
        set(hFig,'Units','pixels');
        PosFig = get(hFig,'Position');
        NewPos = [Pos(1)+0.5*(Pos(3)-PosFig(3)) Pos(2)+0.5*(Pos(4)-PosFig(4)) PosFig(3) PosFig(4)];
    case 'full'
        NewPos = [Pos(1)+0.01*Pos(3) Pos(2)+0.01*Pos(4) Pos(3)*0.98 Pos(4)*0.98];
end
set(hMainGui.fig,'Units','normalized');
if ~isempty(hFig)
    set(hFig,'Units','pixels');
    set(hFig,'Position',NewPos);
    set(hFig,'Units','normalized','Visible','on');
end
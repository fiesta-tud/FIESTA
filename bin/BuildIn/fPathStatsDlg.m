function options = fPathStatsDlg
global Config;
hPathStatsDlg = dialog('Name','Options for FIESTA Path Statistics','Visible','off');
fPlaceFig(hPathStatsDlg,'speed');
uicontrol('Parent',hPathStatsDlg ,'Units','normalized','Position',[0.05 0.85 0.9 0.1],'Style','text',...
          'String','How should FIESTA find the path?','HorizontalAlignment','left','FontSize',12);
mMode = uicontrol('Parent',hPathStatsDlg ,'Units','normalized','Position',[0.15 0.75 0.7 0.08],'Style','popupmenu',...
                  'String',{'Fit','Filament','Average path'},'Callback',@Update,'FontSize',12);
h(1) = uicontrol('Parent',hPathStatsDlg ,'Units','normalized','Position',[0.05 0.6 0.9 0.1],'Style','text','Tag','tFit',...
          'String','Choosing fitting mode for path','HorizontalAlignment','left','FontSize',12);
h(2) = uicontrol('Parent',hPathStatsDlg ,'Units','normalized','Position',[0.15 0.5 0.7 0.08],'Style','popupmenu','Tag','mFit',...
                 'String',{'Auto - best fit','Linear path','2nd deg polynomial path','3rd deg polynomial path'},'FontSize',12,'UserData',{'auto','poly1','poly2','poly3'});

h(3) = uicontrol('Parent',hPathStatsDlg ,'Units','normalized','Position',[0.05 0.6 0.9 0.08],'Style','checkbox','Tag','cAlignFil',...
          'String','Align filaments before calculating path','HorizontalAlignment','left','FontSize',12,'Visible','off');
h(4) = uicontrol('Parent',hPathStatsDlg ,'Units','normalized','Position',[0.05 0.5 0.9 0.08],'Style','checkbox','Tag','cBothTips',...
                 'String','Calculate distance in relation to both tips','FontSize',12,'Visible','off');
             
h(5) = uicontrol('Parent',hPathStatsDlg ,'Units','normalized','Position',[0.05 0.6 0.9 0.1],'Style','text','Tag','tAverageDis',...
          'String','Enter distance for averaging path in [nm]:','HorizontalAlignment','left','FontSize',12,'Visible','off');
h(6) = uicontrol('Parent',hPathStatsDlg ,'Units','normalized','Position',[0.25 0.5 0.5 0.08],'Style','edit','Tag','eAverageDis',...
                 'String','','FontSize',12,'Visible','off');
         
set(mMode,'UserData',h);
cOverwrite = uicontrol('Parent',hPathStatsDlg ,'Units','normalized','Position',[0.05 0.35 0.9 0.08],'Style','checkbox','String','Overwrite existing path data','FontSize',12);
if Config.NumCores>0
    str = 'Parallel processing is activated';
else
    str = 'Parallel processing can speed up evaluation (Check Configuration)';
end
uicontrol('Parent',hPathStatsDlg ,'Units','normalized','Position',[0.05 0.25 0.9 0.06],'Style','text',...
          'String',str,'HorizontalAlignment','center','FontSize',8,'FontAngle','italic');
uicontrol('Parent',hPathStatsDlg ,'Units','normalized','Position',[0.05 0.05 0.4 0.15],'Style','pushbutton','String','Ok','FontSize',12,'Callback',@doControlCallback);
uicontrol('Parent',hPathStatsDlg ,'Units','normalized','Position',[0.55 0.05 0.4 0.15],'Style','pushbutton','String','Cancel','FontSize',12,'Callback',@doControlCallback);
uiwait(hPathStatsDlg);
if ~ishandle(hPathStatsDlg)
    options = [];
else
    button = get(hPathStatsDlg,'UserData');
    if strcmp(button,'Ok')
        mode = mMode.Value;
        if mode == 1
            options.mode = 'fit';
            options.fit = h(2).UserData{h(2).Value};
            options.overwrite = cOverwrite.Value;
        elseif mode == 2
            options.mode = 'filament';
            options.align = h(3).Value;
            options.refboth = h(4).Value;
            options.overwrite = cOverwrite.Value;
        else
            options.mode = 'average';
            options.dis = str2double(h(6).String);     
            options.overwrite = cOverwrite.Value;
        end           
    else
        options = [];
    end
    delete(hPathStatsDlg);
end

function Update(obj, ~)
mode = obj.Value;
h = obj.UserData;
set(h,'Visible','off');
if mode == 1
    set(h(1:2),'Visible','on');
elseif mode == 2
    set(h(3:4),'Visible','on');
else
    set(h(5:6),'Visible','on');
end
 
function doControlCallback(obj, ~)
set(gcbf,'UserData',get(obj,'String'));
uiresume(gcbf);
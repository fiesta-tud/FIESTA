function answer = fInputDlg(prompt,default)
drawnow
hInputDlg = dialog('Name','FIESTA Input','UserData','Cancel','KeyPressFcn',@doFigureKeyPress,'Visible','off');
fPlaceFig(hInputDlg,'small');
if ~iscell(prompt)
    uicontrol('Parent',hInputDlg ,'Units','normalized','Position',[0.05 0.7 0.9 0.2],'Style','text','String',prompt,'HorizontalAlignment','left');
    hPrompt = uicontrol('Parent',hInputDlg ,'Units','normalized','Position',[0.05 0.5 0.9 0.2],'Style','edit','BackgroundColor','white','String',default,'Tag','eAnswer','Callback',@doPromptCallback,'HorizontalAlignment','left');
else
    uicontrol('Parent',hInputDlg ,'Units','normalized','Position',[0.05 0.775 0.9 0.15],'Style','text','String',prompt{1},'HorizontalAlignment','left');
    hPrompt(1) = uicontrol('Parent',hInputDlg ,'Units','normalized','Position',[0.05 0.625 0.9 0.15],'Style','edit','BackgroundColor','white','String',default{1},'Tag','eAnswer1','Callback',@doPromptCallback,'HorizontalAlignment','left');
    uicontrol('Parent',hInputDlg ,'Units','normalized','Position',[0.05 0.45 0.9 0.15],'Style','text','String',prompt{2},'HorizontalAlignment','left');
    hPrompt(2) = uicontrol('Parent',hInputDlg ,'Units','normalized','Position',[0.05 0.3 0.9 0.15],'Style','edit','BackgroundColor','white','String',default{2},'Tag','eAnswer2','Callback',@doPromptCallback,'HorizontalAlignment','left');
end
uicontrol('Parent',hInputDlg ,'Units','normalized','Position',[0.05 0.05 0.4 0.2],'Style','pushbutton','String','Ok','UserData','Ok','Callback',@doControlCallback,'KeyPressFcn',@doControlKeyPress);
uicontrol('Parent',hInputDlg ,'Units','normalized','Position',[0.55 0.05 0.4 0.2],'Style','pushbutton','String','Cancel','UserData','Cancel','Callback',@doControlCallback,'KeyPressFcn',@doControlKeyPress);
uicontrol(hPrompt(1));uicontrol(hPrompt(1));
uiwait(hInputDlg);
if ~ishandle(hInputDlg)
    answer = {};
else
    answer = get(hInputDlg,'UserData');
    if strcmp(answer,'Ok')
        if numel(hPrompt)==1
            answer = get(hPrompt,'String');
        else
            answer = cell(1,2);
            answer{1} = get(hPrompt(1),'String');
            answer{2} = get(hPrompt(2),'String');
        end
    else
        answer = {};
    end
    delete(hInputDlg);
    drawnow
end

function doControlCallback(obj, evd) %#ok
if strcmp(get(obj,'UserData'),'Cancel')
  set(gcbf,'UserData','Cancel');
else
  set(gcbf,'UserData','Ok');
end
uiresume(gcbf);

function doPromptCallback(obj, evd) %#ok
hFig = get(obj,'Parent');
if double(get(hFig,'CurrentCharacter'))==13
    set(gcbf,'UserData','Ok');
    uiresume(gcbf);
end

function doFigureKeyPress(obj, evd) %#ok
switch(evd.Key)
  case {'return'}
    set(gcbf,'UserData','Ok');
    uiresume(gcbf);
  case {'escape'}
    set(gcbf,'UserData','Cancel');
    uiresume(gcbf);
end

function doControlKeyPress(obj, evd)
switch(evd.Key)
  case {'return'}
    if ~strcmp(get(obj,'UserData'),'Cancel')
        set(gcbf,'UserData','Ok');
        drawnow update;
    end
    uiresume(gcbf);
  case {'escape'}
    set(gcbf,'UserData','Cancel');
    uiresume(gcbf);
end

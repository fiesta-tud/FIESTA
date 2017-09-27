function answer = fQuestDlg(prompt,name,button,default)
if numel(button)>1
    hQuestDlg = dialog('Name',name,'UserData',default,'KeyPressFcn',@doFigureKeyPress,'Visible','off');
    fPlaceFig(hQuestDlg,'small');
    uicontrol('Parent',hQuestDlg ,'Units','normalized','Position',[0.05 0.45 0.9 0.475],'Style','text','String',prompt,'HorizontalAlignment','left');
    if numel(button)==2
        hPrompt(1) = uicontrol('Parent',hQuestDlg,'Units','normalized','Position',[0.05 0.1 0.4 0.3],'Style','pushbutton','String',button{1},'UserData',button{1},'Callback',@doControlCallback,'KeyPressFcn',@doControlKeyPress);
        hPrompt(2) = uicontrol('Parent',hQuestDlg,'Units','normalized','Position',[0.55 0.1 0.4 0.3],'Style','pushbutton','String',button{2},'UserData',button{2},'Callback',@doControlCallback,'KeyPressFcn',@doControlKeyPress);
    else
        hPrompt(1) = uicontrol('Parent',hQuestDlg,'Units','normalized','Position',[0.05 0.1 0.25 0.3],'Style','pushbutton','String',button{1},'UserData',button{1},'Callback',@doControlCallback,'KeyPressFcn',@doControlKeyPress);
        hPrompt(2) = uicontrol('Parent',hQuestDlg,'Units','normalized','Position',[0.375 0.1 0.25 0.3],'Style','pushbutton','String',button{2},'UserData',button{2},'Callback',@doControlCallback,'KeyPressFcn',@doControlKeyPress);
        hPrompt(3) = uicontrol('Parent',hQuestDlg,'Units','normalized','Position',[0.7 0.1 0.25 0.3],'Style','pushbutton','String',button{3},'UserData',button{3},'Callback',@doControlCallback,'KeyPressFcn',@doControlKeyPress);
    end
    uicontrol(hPrompt(strcmp(default,button)));
    uiwait(hQuestDlg);
    if ~ishandle(hQuestDlg)
        answer = {};
    else
        answer = get(hQuestDlg,'UserData');
        delete(hQuestDlg);
        drawnow;
    end
end

function doControlCallback(obj, evd) %#ok
set(gcbf,'UserData',get(obj,'UserData'));
uiresume(gcbf);

function doFigureKeyPress(obj, evd) %#ok
switch(evd.Key)
  case {'return'}
    uiresume(gcbf);
  case {'escape'}
    uiresume(gcbf);
end

function doControlKeyPress(obj, evd)
switch(evd.Key)
  case {'return'}
    set(gcbf,'UserData',get(obj,'UserData'));
    uiresume(gcbf);
  case {'escape'}
    uiresume(gcbf);
end

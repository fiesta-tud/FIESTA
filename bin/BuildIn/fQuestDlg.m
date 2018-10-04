function answer = fQuestDlg(prompt,name,button,default)
if numel(button)>1
    hQuestDlg = dialog('Name',name,'UserData',default,'KeyPressFcn',@doFigureKeyPress,'Visible','off');
    fPlaceFig(hQuestDlg,'small');
    hText = uicontrol('Parent',hQuestDlg ,'Units','normalized','Position',[0.05 0.45 0.9 0.475],'Style','text','String',prompt,'HorizontalAlignment','left');
    if numel(button)==2
        hPrompt(1) = uicontrol('Parent',hQuestDlg,'Units','normalized','Position',[0.05 0.1 0.4 0.3],'Style','pushbutton','String',button{1},'UserData',button{1},'Callback',@doControlCallback,'KeyPressFcn',@doControlKeyPress);
        hPrompt(2) = uicontrol('Parent',hQuestDlg,'Units','normalized','Position',[0.55 0.1 0.4 0.3],'Style','pushbutton','String',button{2},'UserData',button{2},'Callback',@doControlCallback,'KeyPressFcn',@doControlKeyPress);
    elseif numel(button)==3
        hPrompt(1) = uicontrol('Parent',hQuestDlg,'Units','normalized','Position',[0.05 0.1 0.25 0.3],'Style','pushbutton','String',button{1},'UserData',button{1},'Callback',@doControlCallback,'KeyPressFcn',@doControlKeyPress);
        hPrompt(2) = uicontrol('Parent',hQuestDlg,'Units','normalized','Position',[0.375 0.1 0.25 0.3],'Style','pushbutton','String',button{2},'UserData',button{2},'Callback',@doControlCallback,'KeyPressFcn',@doControlKeyPress);
        hPrompt(3) = uicontrol('Parent',hQuestDlg,'Units','normalized','Position',[0.7 0.1 0.25 0.3],'Style','pushbutton','String',button{3},'UserData',button{3},'Callback',@doControlCallback,'KeyPressFcn',@doControlKeyPress);
    else
        set(hText,'Position',[0.05 0.35 0.9 0.575]);
        hPrompt(1) = uicontrol('Parent',hQuestDlg,'Units','normalized','Position',[0.05 0.1 0.55 0.2],'Style','popupmenu','String',button,'UserData',button);
        hPrompt(2) = uicontrol('Parent',hQuestDlg,'Units','normalized','Position',[0.65 0.1 0.3 0.2],'Style','pushbutton','String','Ok','UserData','Ok','Callback',@doControlCallback,'KeyPressFcn',@doControlKeyPress);
    end
    if strcmp(get(hPrompt(1),'Style'),'pushbutton')
        uicontrol(hPrompt(strcmp(default,button)));
    else
        v = find(strcmp(default,button)==1);
        set(hPrompt,'Value',v);
        uicontrol(hPrompt(2));
    end
    uiwait(hQuestDlg);
    if ~ishandle(hQuestDlg)
        answer = {};
    else
        answer = get(hQuestDlg,'UserData');
        if strcmp(answer,'Ok')
            v = get(hPrompt(1),'Value');
            answer = button{v};
        end
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

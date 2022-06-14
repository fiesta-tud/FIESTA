function answer = fChooseDlg(prompt,name,data,default)

hChooseDlg = dialog('Name',name,'UserData',default,'KeyPressFcn',@doFigureKeyPress,'Visible','off');
fPlaceFig(hChooseDlg,'small');
hText = uicontrol('Parent',hChooseDlg ,'Units','normalized','Position',[0.05 0.45 0.9 0.475],'Style','text','String',prompt,'HorizontalAlignment','left');
hTable = uitable('Parent',hChooseDlg,'Units','normalized','Position',[0.05 0.3 0.9 0.5],'Data',data,'ColumnName',{'','Name','Img','Ch','X','Y'},...
                 'RowName',[],'ColumnEditable',[true false false false false]);
hTable.Units = 'pixels';
xy = hTable.Position;
hTable.ColumnWidth = {30, xy(3)-200, 40, 30, 40, 40};

hPrompt(1) = uicontrol('Parent',hChooseDlg,'Units','normalized','Position',[0.05 0.05 0.4 0.2],'Style','pushbutton','String','Open','UserData','Open','Callback',@doControlCallback,'KeyPressFcn',@doControlKeyPress);
hPrompt(2) = uicontrol('Parent',hChooseDlg,'Units','normalized','Position',[0.55 0.05 0.4 0.2],'Style','pushbutton','String','Cancel','UserData','Cancel','Callback',@doControlCallback,'KeyPressFcn',@doControlKeyPress);

while true
    uiwait(hChooseDlg);
    if ~ishandle(hChooseDlg)
        answer = {};
        break;
    else
        answer = get(hChooseDlg,'UserData');
        if strcmp(answer,'Open')
            v = hTable.Data;
            answer = find(cell2mat(v(:,1)));
            if numel(answer) > 1
                 numT = cell2mat(data(:,3));
                 numT = unique(numT(answer));
                 
                 numX = cell2mat(data(:,5));
                 numX = unique(numX(answer));
                 
                 numY = cell2mat(data(:,6));
                 numY = unique(numY(answer));
                 
                 if numel(numT) > 1
                    fMsgDlg('Stacks with different number of images choosen','error');
                 elseif numel(numX) > 1 || numel(numY) > 1
                    fMsgDlg('Stacks with different number of pixels choosen','error');
                 else
                    delete(hChooseDlg);
                    drawnow;
                    break;
                 end
            else
                delete(hChooseDlg);
                drawnow;
                break;
            end
        else
            answer = {};
            delete(hChooseDlg);
            drawnow;
            break;
        end
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

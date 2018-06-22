function progFigure = parallelprogressdlg(varargin)
%progressdlg show/update progress dialog
%
% progressdlg creates or updates an existing progress dialog that reports on the 
% progress of a task including the estimated time remaining as well as a button to 
% cancel the task. It does not use drawnow in order to improve performance when using 
% one or several other figures (drawnow refreshes all graphics objects in all figures).
% 
% Syntax:
%   progressdlg                 creates default progress dialog
%
%   progressdlg('message');     creates default progress dialog with custom message
%
%   progressdlg(n);             creates default progress dialog with initial value n
%                               or updates existing progress dialog to value n
%
%   progressdlg(n,'message');   creates default progress dialog with message and value n
%                               or updates existing progress dialog to value n and message 
%
%   progressdlg('PropertyName',PropertyValue,...);  creates or updates progress dialog with 
%                                                   properties PropertyName/PropertyValue
%
%   handle = progressdlg(...);  returns the handle to the progress dialog
%                               handle is empty if user aborted by pressing cancel
%
%  PropertyName  | Description                                | Type           | Default
% ---------------|--------------------------------------------|----------------|------------------
%  Min           | Minimum value of ProgressBar               | double         | 0
%  Max           | Minimum value of ProgressBar               | double         | 100
%  Parent        | Parent Figure for Positioning              | figure_handle  | []
%  Position      | Override position of dialog                | [int x, int y] | []
%  ShowTime      | Displays an estimate of the remaining time | 'on/off'       | 'on'
%  Size          | Factor for dialog size (width=400px)       | double         | 1
%  String        | Descriptive text above ProgressBar         | char           | 'Progress'
%  Title         | Title of the dialog                        | char           | 'Progress'
%  Value         | Current Value of ProgressBar               | double         | 0
%  WindowStyle   | Normal or modal window behavior            | 'normal/modal' | 'modal'
%  Directory     | Filedirectory for saving progress          | char           | pwd
% 
%
% Notes:
%   1) Does not use drawnow to refresh the progress bar in order to improve performance, 
%      especially when using one or several additional figures with many graphics objects.
%   2) Performance is slightly decreased when using the remaining time estimation and/or
%      cancel button
%
% Examples:
%   progressdlg('Calculating magic square');
%   for n=1:100
%       magic(1000);
%       progressdlg(n);
%   end
%
%   progressdlg('Title','Progress Dialog','String','Calculating magic squares','Min',0,'Max',1000,'Value',0);
%   for n=1:1000
%       magic(400);
%       progressdlg(n);
%   end
%
%   progressdlg('Title','Progress Dialog','String','Calculating magic squares','Position',[100 100],'WindowStyle','normal');
%   for n=1:10
%       magic(10000);
%       progressdlg(n*10,['Calculating magic square - Round: ' num2str(n)]);
%   end
%
%   h = progressdlg('Title','Progress','String','Calculating magic square','ShowTime','on','Cancel','on','Size',1.5);
%   for n=1:100
%       magic(4000);
%       h = progressdlg(n);
%       if isempty(h)
%           break;
%       end
%   end
%
% Warning:
%   This code heavily relies on undocumented and unsupported Matlab
%   functionality. It works on Matlab 7+, but use at your own risk!
%
% Bugs and suggestions:
%   Please send to Felix Ruhnow (felix.ruhnow at tu-dresden dot de)
%
% See also: WAITBAR, TIMEBAR, PROGRESSBAR (on the File Exchange)
%
% Adapted from: 
% Daniel Claxton's WORKBAR
%
% Inspired by:
% Yair M. Altman's STATUSBAR
%
% Release history:
%    1.0  2013-06-10: initial version
%
% License to use and modify this code is granted freely to all interested, as long as the original author is
% referenced and attributed as such. The original author maintains the right to be solely associated with this work.
%
% Programmed and Copyright by Felix Ruhnow: felix.ruhnow(at)tu-dresden.de


    % keep variables for next call of progressdlg 
    persistent p min max progHandles showtime starttime;
    message = 'Progress';
    value = 0;
    text = [];
    est_text = 'Estimated time remaining: ';  

    % check input arguments
    if nargin < 1   
        % progressdlg; creates default progress dialog
        progHandles = [];

    elseif nargin == 1 
        if ischar(varargin{1})  
            % progressdlg('close'); closes progress dialog
            if strcmp(varargin{1},'close')
                if isfield(progHandles,'figure') && ishandle(progHandles.figure)
                    close(progHandles.figure);
                end
                progHandles = [];
                progFigure =[];
                return
            else
                % progressdlg('message'); creates default progress dialog with custom message
                message = varargin{1};
                progHandles = [];
            end

        elseif isnumeric(varargin{1}) 
            % progressdlg(n); creates default progress dialog with initial value n
            %                 or updates existing progress dialog to value n
            value = varargin{1};
        end
        varargin(:) = [];

    elseif nargin == 2 && isnumeric(varargin{1}) 
        % progressdlg(n,'message');                   
        if isempty(progHandles)
            % creates default progress dialog with message and value n     
            value = varargin{1};
            message = varargin{2};
            varargin(:) = [];
        else
            % updates existing progress dialog to value n and message 
            value = varargin{1};
            text = varargin{2};
        end

    elseif isfield(progHandles,'figure') && ishandle(progHandles.figure)
        % progressdlg('PropertyName',PropertyValue,...); updates progress dialog
        parse(p,varargin{1:end});
        value = p.Results.value;
        text = p.Results.string;

    else
        % progressdlg('PropertyName',PropertyValue,...); creates progress dialog
        progHandles = [];
    end

    if isempty(progHandles)
        % if handles are empty create new dialog
        showtime = 0;

        % get initial input arguments
        p = checkInput(value,message);
        parse(p,varargin{1:end});
        prog = p.Results;
        min = prog.min;
        max = prog.max;

        % define height w/o estimated time remaining or cancel button
        height = 90;
        if strcmp(prog.showtime,'on')
            showtime = 1;
            height = height + 20;
        end

        % get position of progress dialog (middle of screen, if not otherwise)
        if isempty(prog.position)
            if isempty(prog.parent)
                screen = get(0,'ScreenSize');
                pos = ceil([(screen(3)-400*prog.size)/2 (screen(4)-height*prog.size)/2 400 height]);
            else
                units = get(prog.parent,'Units');
                set(prog.parent,'Units','Pixel');
                pos_parent = get(prog.parent,'Position');
                set(prog.parent,'Units',units);
                pos = ceil([pos_parent(1)+(pos_parent(3)-400*prog.size)/2 pos_parent(2)+(pos_parent(4)-height*prog.size)/2 400 height]);
            end
        else
           pos = ceil([prog.position 400 height]); 
        end

        % create dialog dialog
        progFigure = figure('Menubar','none','Numbertitle','off','Resize','off','Tag','ProgressDlg',...
                            'Units','pixels','Visible','off','DockControls','off','IntegerHandle','off',...
                            'Name',prog.title,'Position',pos,'WindowStyle','normal');%prog.windowstyle);

        % get background color of figure to adjust background of its children
        uiColor = get(progFigure,'Color');
        jColor = java.awt.Color(uiColor(1),uiColor(2),uiColor(3));
    
        if ispc   
            barsize = 20;
            buttonsize = 25;
            buttonfont = 11;
        else
            barsize = 40;
            buttonsize = 30;
            buttonfont = 14;
        end
        
        % create descriptive text from PropertyName 'String', use java for updating dialog
        text1 = javaObjectEDT('javax.swing.JTextArea');
        [jText(1),cText(1)] = javacomponent(text1,[20 height-30 300 20],progFigure);
        set(jText(1),'Background',jColor,'Text',prog.string,...
                     'Font',java.awt.Font('Helvetica',java.awt.Font.PLAIN,14*prog.size));
        set(cText(1),'units','normalized');

        % create text for estimated remaining time if 'ShowTime' is 'on', use java for updating dialog
        if showtime
            text2 = javaObjectEDT('javax.swing.JTextArea');
            [jText(2),cText(2)] = javacomponent(text2,[20 height-90 300 20],progFigure);
            set(jText(2),'Background',jColor,'Text',est_text,...
                         'Font',java.awt.Font('Helvetica',java.awt.Font.PLAIN,14*prog.size));
            set(cText(2),'Units','Normalized');   

        end  
  
        % create ProgressBar with java JProgressBar class
        jProgressBar = javaObjectEDT('javax.swing.JProgressBar');
        jProgressBar.setStringPainted(true);
        try
            set(jProgressBar,'Background',jColor,'Minimum',prog.min,'Maximum',prog.max,'Value',prog.value);
        catch
            set(jProgressBar,'Minimum',prog.min,'Maximum',prog.max,'Value',prog.value);
        end

        [hProgressBar,cProgressBar] = javacomponent(jProgressBar,[20 height-65 360 barsize],progFigure);
        set(cProgressBar,'units','normalized','Tag','ProgressBar');

        % resize progress dialog according to PropertyName 'Size'
        set(progFigure,'Position',[pos(1:2) pos(3:4)*prog.size],'Visible','on');

        % save handles of the created objects 
        progHandles.figure = progFigure;
        progHandles.progress = hProgressBar;
        progHandles.text = jText;

        % update dialog (only once!)
        drawnow;

        %save start time for progress
        starttime = [];
        
        statusdir = [prog.directory filesep 'fiestastatus'];
        if isdir(statusdir)
            rmdir(statusdir,'s');
        end
        mkdir(statusdir);
        t = timer('TimerFcn',@RefreshProgressDlg,'Period',2,'TasksToExecute', Inf,'Tag','fParallel',...
          'ExecutionMode','fixedRate','BusyMode','queue','UserData',{starttime,max,progHandles,statusdir});
        start(t)
    else
        if value==max
            disp('bla5')
            % if 'Maximum' value reached close and reset progress dialog
            close(progHandles.figure);
            t= timerfind('Tag','fParallel');
            var = get(t,'UserData');
            stop(t)
            delete(t);
            rmdir(var{4},'s');
            disp('bla6')
        end
    end
    
function RefreshProgressDlg(obj, event) %#ok<INUSD>
    % get userdata
    var = get(obj,'UserData');
    starttime = var{1};
    if isempty(starttime)
        starttime = clock;
        var{1} = starttime;
        set(obj,'UserData',var);
    end
    min = 0;
    max = var{2};
    progHandles = var{3};
    dirStatus = var{4};
    est_text = 'Estimated time remaining: ';  
    files = dir([dirStatus filesep '*.mat']);
    value = length(files);
    if value<max
        % update ProgressBar
        try
            set(progHandles.progress,'Value',value);  
        catch
            return;
        end
        % calculate and update remaining time if required

        if value>0
            runtime = etime(clock,starttime);
            timeleft = runtime*(max-min+1)/(value-min+1) - runtime;
            timeleftstr = sec2timestr(timeleft);
            set(progHandles.text(2),'Text',[est_text timeleftstr]);
        else
            set(progHandles.text(2),'Text',est_text);
        end
    end

%% Define input parameters and their default values
function p = checkInput(value,message)   
    p = inputParser;
    states = {'on','off'};
    style = {'normal','modal'};
    addParameter(p,'title','Progress');
    addParameter(p,'size',1);
    addParameter(p,'value',value);
    addParameter(p,'min',0);
    addParameter(p,'max',100);
    addParameter(p,'position',[],@isnumeric);
    addParameter(p,'string',message);
    addParameter(p,'parent',[],@ishandle);
    addParameter(p,'showtime','on',@(x) any(validatestring(x,states)));
    addParameter(p,'windowstyle','modal',@(x) any(validatestring(x,style)));
    addParameter(p,'directory',pwd);

%% Convert seconds to hh:mm:ss
function timestr = sec2timestr(sec)
    h = floor(sec/3600); % Hours
    sec = sec - h*3600;
    m = floor(sec/60); % Minutes
    sec = sec - m*60;
    s = floor(sec); % Seconds
    timestr = sprintf('%02d:%02d:%02d',h,m,s);

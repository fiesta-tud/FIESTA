function fAboutGui(hMainGui)

file = [fileparts( mfilename('fullpath') ) filesep 'About.jpg'];
I = imread(file);
y = size(I,1);
x = size(I,2);

set(hMainGui.fig,'Units','pixels');
Pos = get(hMainGui.fig,'Position');

hAboutGui.fig = figure('Units','pixel','DockControls','off','IntegerHandle','off','MenuBar','none','Name','About FIESTA',...
                       'NumberTitle','off','Position',[Pos(1)+0.5*(Pos(3)-x) Pos(2)+0.5*(Pos(4)-y) x y],'HandleVisibility','callback','Tag','hAboutGui',...
                       'Visible','on','WindowStyle','modal');
                   
hAboutGui.aPlot = axes('Parent',hAboutGui.fig,'Units','normalized','Position',[0 0 1 1],'Tag','Plot','Visible','off');                   

image(I);
axis off
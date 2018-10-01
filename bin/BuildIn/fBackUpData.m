function fBackUpData(hMainGui)
global Molecule;
global Filament;
global KymoTrackMol;
global KymoTrackFil;
global BackUp;
BackUp.Molecule = Molecule;
BackUp.Filament = Filament;
BackUp.KymoTrackMol = KymoTrackMol;
BackUp.KymoTrackFil = KymoTrackFil;
set(hMainGui.Menu.mUndo,'Enable','on');
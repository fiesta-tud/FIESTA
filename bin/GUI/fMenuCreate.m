%/////////////////////////////////////////////////////////////////////////%
%                           Create Menu                                   %
%/////////////////////////////////////////////////////////////////////////%
function hMenu=fMenuCreate(hMainGui)
%create Data menu

fMenuData(''); %create dependency for compiling;

hMenu.mData=uimenu('Parent',hMainGui.fig,'Label','Data','Tag','mData');

hMenu.mOpenStack = uimenu('Parent',hMenu.mData,'Callback','fMenuData(''OpenStack'',getappdata(0,''hMainGui''));',...
                          'Label','Open Stack','Tag','mOpenStack','Accelerator','S');               

hMenu.mOpenStackSpecial = uimenu('Parent',hMenu.mData,'Callback','fMenuData(''OpenStackSpecial'',getappdata(0,''hMainGui''));',...
                          'Label','Open Stack Special','Tag','mOpenStackSpecial'); 
                      
hMenu.mLoadStack = uimenu('Parent',hMenu.mData,'Callback','fMenuData(''LoadStack'');','Enable','on',...
                          'Label','Load Stack (MAT-File)','Tag','mLoadStack');
                      
hMenu.mSaveStack = uimenu('Parent',hMenu.mData,'Callback','fMenuData(''SaveStack'');','Enable','off',...
                          'Label','Save Stack','Tag','mSaveStack');
                      
hMenu.mCloseStack = uimenu('Parent',hMenu.mData,'Callback','fMenuData(''CloseStack'',getappdata(0,''hMainGui''));','Enable','off',...
                           'Label','Close Stack','Tag','mCloseStack');
                       
hMenu.mLoadTracks = uimenu('Parent',hMenu.mData,'Callback','fMenuData(''LoadTracks'',getappdata(0,''hMainGui''));',...
                         'Label','Load Tracks','Tag','mLoadTracks','Accelerator','L','Separator','on','UserData','local');

hMenu.mLoadServer = uimenu('Parent',hMenu.mData,'Callback','fMenuData(''LoadTracks'',getappdata(0,''hMainGui''));',...
                           'Label','Load Tracks (Server)','Tag','mLoadServer','UserData','server');
                     
hMenu.mSaveTracks = uimenu('Parent',hMenu.mData,'Callback','fMenuData(''SaveTracks'',getappdata(0,''hMainGui''));','Enable','off',...
                         'Label','Save all Tracks','Tag','mSaveTracks','Accelerator','D','UserData','mat');

hMenu.mSaveAs = uimenu('Parent',hMenu.mData,'Label','Save all Tracks as...','Tag','mSaveAs','Enable','off');

hMenu.mSaveStxt = uimenu('Parent',hMenu.mSaveAs,'Callback','fMenuData(''SaveText'',getappdata(0,''hMainGui''));',...
                         'Label','Single  *.txt File','Tag','mSaveStxt','UserData','single');
                     
hMenu.mSaveMtxt = uimenu('Parent',hMenu.mSaveAs,'Callback','fMenuData(''SaveText'',getappdata(0,''hMainGui''));',...
                         'Label','Multiple *.txt Files','Tag','mSaveMtxt','UserData','multiple');
                     
hMenu.mSaveSelection = uimenu('Parent',hMenu.mData,'Callback','fMenuData(''SaveTracks'',getappdata(0,''hMainGui''));','Enable','off',...
                         'Label','Save selected Tracks','Tag','mSaveSelection','UserData','select_mat');

hMenu.mSaveSelAs = uimenu('Parent',hMenu.mData,'Label','Save selected Tracks as...','Tag','mSaveSelAs','Enable','off');

hMenu.mSaveSelStxt = uimenu('Parent',hMenu.mSaveSelAs,'Callback','fMenuData(''SaveText'',getappdata(0,''hMainGui''));',...
                         'Label','Single  *.txt File','Tag','mSaveSelStxt','UserData','select_single');
                     
hMenu.mSaveSelMtxt = uimenu('Parent',hMenu.mSaveSelAs,'Callback','fMenuData(''SaveText'',getappdata(0,''hMainGui''));',...
                         'Label','Multiple *.txt Files','Tag','mSaveSelMtxt','UserData','select_multiple');

hMenu.mClearTracks = uimenu('Parent',hMenu.mData,'Callback','fShared(''ClearTracks'',getappdata(0,''hMainGui''));','Enable','off',...
                           'Label','Clear all Tracks','Tag','mClearTracks','UserData','local');
             
hMenu.mLoadObjects = uimenu('Parent',hMenu.mData,'Callback','fMenuData(''LoadObjects'',getappdata(0,''hMainGui''));',...
                           'Label','Load Objects','Tag','mLoadObjects','Separator','on','UserData','local');
                       
hMenu.mLoadObjServer = uimenu('Parent',hMenu.mData,'Callback','fMenuData(''LoadObjects'',getappdata(0,''hMainGui''));',...
                           'Label','Load Objects (Server)','Tag','mLoadObjServer ','UserData','server');                       
                       
hMenu.mSaveObjects = uimenu('Parent',hMenu.mData,'Callback','fMenuData(''SaveObjects'',getappdata(0,''hMainGui''));','Enable','off',...
                           'Label','Save Objects','Tag','mSaveObjects');
                       
hMenu.mClearObjects = uimenu('Parent',hMenu.mData,'Callback','fMenuData(''ClearObjects'',getappdata(0,''hMainGui''));','Enable','off',...
                           'Label','Clear Objects','Tag','mClearObjects');
                       
hMenu.mExit = uimenu('Parent',hMenu.mData,'Callback','close all;',...
                     'Label','Exit','Tag','mExit','Accelerator','E','Separator','on');
                 
%create Edit menu

fMenuEdit(''); %create dependency for compiling;

hMenu.mEdit = uimenu('Parent',hMainGui.fig,'Label','Edit','Tag','mEdit');

hMenu.mUndo = uimenu('Parent',hMenu.mEdit,'Callback','fMenuEdit(''Undo'',getappdata(0,''hMainGui''));','Enable','off',...
                               'Label','Undo','Tag','mUndo','Accelerator','Z');
                           
hMenu.mAddStackServer = uimenu('Parent',hMenu.mEdit,'Callback','fShared(''AddStack'',getappdata(0,''hMainGui''));','Enable','off',...
                               'Label','Add Stack to SERVER Queue','Tag','mAddStackServer','UserData','Server','Separator','on');
                           
hMenu.mAddStackLocal = uimenu('Parent',hMenu.mEdit,'Callback','fShared(''AddStack'',getappdata(0,''hMainGui''));','Enable','off',...
                               'Label','Add Stack to LOCAL Queue','Tag','mAddStackLocal','UserData','Local');

hMenu.mAnalyseFrame = uimenu('Parent',hMenu.mEdit,'Callback','fShared(''AddStack'',getappdata(0,''hMainGui''));','Enable','off',...
                             'Label','Add Current Frame (LOCAL)','Tag','mAnalyseFrame','UserData','One');
                         
hMenu.mAnalyseQueue = uimenu('Parent',hMenu.mEdit,'Callback','fShared(''AnalyseQueue'',getappdata(0,''hMainGui''));',...
                             'Label','Analyse LOCAL Queue','Tag','mAnalyseQueue','Accelerator','A','Enable','off');

hMenu.mReconnect = uimenu('Parent',hMenu.mEdit,'Callback','fShared(''AddStack'',getappdata(0,''hMainGui''));','Enable','off',...
                          'Label','Reconnect Tracks','Tag','mReconnect','UserData','Reconnect');
                      
hMenu.mReconnectStatic = uimenu('Parent',hMenu.mEdit,'Callback','fMenuEdit(''ReconnectStatic'');','Enable','off',...
                                'Label','Reconnect static objects','Tag','mReconnectStatic');

hMenu.mAddBatchServer = uimenu('Parent',hMenu.mEdit,'Callback','fShared(''AddStack'',getappdata(0,''hMainGui''));','Enable','off',...
                               'Label','Add Batch to SERVER Queue','Tag','mAddBatchServer','UserData','Server','Separator','on');
                           
hMenu.mAddBatchLocal = uimenu('Parent',hMenu.mEdit,'Callback','fShared(''AddStack'',getappdata(0,''hMainGui''));','Enable','off',...
                               'Label','Add Batch to LOCAL Queue','Tag','mAddBatchLocal','UserData','Local');

hMenu.mFind = uimenu('Parent',hMenu.mEdit,'Callback','fMenuEdit(''Find'',getappdata(0,''hMainGui''));','Enable','off',...
                     'Label','Find','Tag','mFind','Separator','on');

hMenu.mFindNext = uimenu('Parent',hMenu.mEdit,'Callback','fMenuEdit(''FindNext'',getappdata(0,''hMainGui''));',...
                         'Label','Find Next','Tag','mFindNext','Accelerator','F','Enable','off');

hMenu.mSort = uimenu('Parent',hMenu.mEdit,'Label','Sort by','Tag','mSort','Enable','off');

hMenu.mSortByNameAZ = uimenu('Parent',hMenu.mSort,'Callback','fMenuEdit(''Sort'',''NameA-Z'');',...
                                  'Label','Name(A>Z)','Tag','mSortByNameAZ');
                              
hMenu.mSortByNameZA = uimenu('Parent',hMenu.mSort,'Callback','fMenuEdit(''Sort'',''NameZ-A'');',...
                                  'Label','Name(Z>A)','Tag','mSortByNameZA');
                              
hMenu.mSortByLengthShort = uimenu('Parent',hMenu.mSort,'Callback','fMenuEdit(''Sort'',''LengthS-L'');',...
                                  'Label','Track-Length(short>long)','Tag','mSortByLengthShort');
                              
hMenu.mSortByLengthLong = uimenu('Parent',hMenu.mSort,'Callback','fMenuEdit(''Sort'',''LengthL-S'');',...
                                  'Label','Track-Length(long>short)','Tag','mSortByLengthLong');                              
                     
hMenu.mFindMoving = uimenu('Parent',hMenu.mEdit,'Callback','fMenuEdit(''FindMoving'',getappdata(0,''hMainGui''));','Enable','off',...
                           'Label','Find all Moving objects','Tag','mFindMoving','Separator','on','UserData','moving');     
                       
hMenu.mFindStatic = uimenu('Parent',hMenu.mEdit,'Callback','fMenuEdit(''FindMoving'',getappdata(0,''hMainGui''));','Enable','off',...
                           'Label','Find all static objects','Tag','mFindStatic','UserData','static');   
                       
hMenu.mFindReference = uimenu('Parent',hMenu.mEdit,'Callback','fMenuEdit(''FindReference'',getappdata(0,''hMainGui''));','Enable','off',...
                           'Label','Find best reference molecules','Tag','mFindReference','UserData','reference');                          
                       
hMenu.mMergeTracks = uimenu('Parent',hMenu.mEdit,'Callback','fShared(''MergeTracks'',getappdata(0,''hMainGui''));','Enable','off',...
                    'Label','Join selected tracks','Tag','mMergeTracks','Accelerator','J','Separator','on');
                
hMenu.mCombineTracks = uimenu('Parent',hMenu.mEdit,'Callback','fMenuEdit(''CombineTracks'');','Enable','off',...
                    'Label','Combine selected tracks','Tag','mCombineTracks');

hMenu.mDeleteTracks = uimenu('Parent',hMenu.mEdit,'Callback','fShared(''DeleteTracks'',getappdata(0,''hMainGui''),[],[]);','Enable','off',...
                       'Label','Delete selected tracks','Tag','mDeleteTracks','Accelerator','X');                 

%create View menu

fMenuView(''); %create dependency for compiling;
fExportViewGui(''); %create dependency for compiling;

hMenu.mView = uimenu('Parent',hMainGui.fig,'Label','View','Tag','mView');

hMenu.mFrame = uimenu('Parent',hMenu.mView,'Callback','fMenuView(''View'',getappdata(0,''hMainGui''),[]);','Enable','off',...
                        'Label','Current frame','Tag','mFrame');
                    
hMenu.mMaximum = uimenu('Parent',hMenu.mView,'Callback','fMenuView(''View'',getappdata(0,''hMainGui''),-1);','Enable','off',...
                        'Label','Maximum projection','Tag','mMaximum');

hMenu.mAverage = uimenu('Parent',hMenu.mView,'Callback','fMenuView(''View'',getappdata(0,''hMainGui''),-2);','Enable','off',...
                        'Label','Average projection','Tag','mAverage');   
                        
hMenu.mZProjection = uimenu('Parent',hMenu.mView,'Callback','fMenuView(''View'',getappdata(0,''hMainGui''),-3);','Enable','off',...
                            'Label','Z-Projection','Tag','mZProjection');     
                        
hMenu.mObjProjection = uimenu('Parent',hMenu.mView,'Callback','fMenuView(''View'',getappdata(0,''hMainGui''),-4);','Enable','off',...
                            'Label','Objects projection','Tag','mObjProjection');     
                        
hMenu.mApplyCorrections = uimenu('Parent',hMenu.mView,'Callback','fMenuView(''ApplyCorrections'');','Enable','off',...
                            'Label','Apply corrections to stack','Tag','mApplyCorrections','Separator','on','Checked', 'off');
                        
hMenu.mShowCorrections = uimenu('Parent',hMenu.mView,'Callback','fMenuView(''ShowCorrections'');','Enable','off',...
                            'Label','Show corrections','Tag','mShowCorrections','Checked', 'off');    
                        
hMenu.mCorrectStack = uimenu('Parent',hMenu.mView,'Callback','fMenuView(''CorrectStack'');','Enable','off',...
                            'Label','Permanently apply corrections','Tag','mCorrectStack','Checked', 'off');        
                    
hMenu.mColorOverlay = uimenu('Parent',hMenu.mView,'Callback','fMenuView(''ColorOverlay'');','Enable','off',...
                                'Label','Color-overlay','Tag','mColorOverlay','Separator','on');  
                            
hMenu.mExport = uimenu('Parent',hMenu.mView,'Callback','fExportViewGui(''Create'');','Enable','off',...
                       'Label','Export current view','Tag','mExport','Separator','on');
                   
%create Options menu

fMenuOptions(''); %create dependency for compiling;
fConfigGui(''); %create dependency for compiling;

hMenu.mOptions = uimenu('Parent',hMainGui.fig,'Label','Options','Tag','mOptions');

hMenu.mConfig = uimenu('Parent',hMenu.mOptions,'Callback','fConfigGui(''Create'');',...
                       'Label','Configuration','Tag','mConfig');
                   
hMenu.mLoadConfig = uimenu('Parent',hMenu.mOptions,'Callback','fMenuOptions(''LoadConfig'',getappdata(0,''hMainGui''));',...
                       'Label','Load configuration','Tag','mLoadConfig','Separator','on');

hMenu.mSaveConfig = uimenu('Parent',hMenu.mOptions,'Callback','fMenuOptions(''SaveConfig'',getappdata(0,''hMainGui''));',...
                           'Label','Save configuration','Tag','mSaveConfig');

hMenu.mSetDefConfig = uimenu('Parent',hMenu.mOptions,'Callback','fMenuOptions(''SetDefaultConfig'',getappdata(0,''hMainGui''));',...
                             'Label','Set default configuration','Tag','mSetDefConfig','Separator','on');

hMenu.mSetReference = uimenu('Parent',hMenu.mOptions,'Callback','fShared(''SetReference'',getappdata(0,''hMainGui''));','Enable','off',...
                      'Label','Set as reference','Tag','mSetReference','Separator','on');

hMenu.mSaveCorrections = uimenu('Parent',hMenu.mOptions,'Callback','fMenuOptions(''SaveCorrections'',getappdata(0,''hMainGui''));','Enable','off',...
                          'Label','Save corrections','Tag','mSaveCorrections');
                      
hMenu.mLoadCorrections = uimenu('Parent',hMenu.mOptions,'Callback','fMenuOptions(''LoadCorrections'',getappdata(0,''hMainGui''));',...
                          'Label','Load corrections','Tag','mLoadCorrections');                       
                        
%create Tools menu

fMenuTools(''); %create dependency for compiling;

hMenu.mTools = uimenu('Parent',hMainGui.fig,'Label','Tools','Tag','mTools');

hMenu.mMeasureLine = uimenu('Parent',hMenu.mTools,'Callback','fMenuTools(''MeasureLine'',getappdata(0,''hMainGui''));','Enable','off',...
                         'Label','Measure Line','Tag','mMeasureLineScan');

hMenu.mMeasureSegLine = uimenu('Parent',hMenu.mTools,'Callback','fMenuTools(''MeasureSegLine'',getappdata(0,''hMainGui''));','Enable','off',...
                         'Label','Measure Segmented Line','Tag','mMeasureLineScan');

hMenu.mMeasureFreehandLine = uimenu('Parent',hMenu.mTools,'Callback','fMenuTools(''MeasureFreehand'',getappdata(0,''hMainGui''));','Enable','off',...
                         'Label','Measure Freehand Line','Tag','mMeasureLineScan');
                     
hMenu.mMeasureRect = uimenu('Parent',hMenu.mTools,'Callback','fMenuTools(''MeasureRect'',getappdata(0,''hMainGui''));','Enable','off',...
                         'Label','Measure Rectangle','Tag','mMeasureRectScan');                     

hMenu.mMeasureEllipse = uimenu('Parent',hMenu.mTools,'Callback','fMenuTools(''MeasureEllipse'',getappdata(0,''hMainGui''));','Enable','off',...
                         'Label','Measure Ellipse','Tag','mMeasureEllipseScan');                     

hMenu.mMeasurePoly = uimenu('Parent',hMenu.mTools,'Callback','fMenuTools(''MeasurePolygon'',getappdata(0,''hMainGui''));','Enable','off',...
                            'Label','Measure Polygon','Tag','mMeasurePolyScan');                     

hMenu.mLineScan = uimenu('Parent',hMenu.mTools,'Callback','fMenuTools(''ScanLine'',getappdata(0,''hMainGui''));','Enable','off',...
                         'Label','Line Scan','Tag','mLineScan','Separator','on');

hMenu.mSegLineScan = uimenu('Parent',hMenu.mTools,'Callback','fMenuTools(''ScanSegLine'',getappdata(0,''hMainGui''));','Enable','off',...
                         'Label','Segmented Line Scan','Tag','mSegLineScan');
                     
hMenu.mFreehandScan = uimenu('Parent',hMenu.mTools,'Callback','fMenuTools(''ScanFreehand'',getappdata(0,''hMainGui''));','Enable','off',...
                         'Label','Freehand Line Scan','Tag','mFreehandScan');            
                     
hMenu.mFilamentScan = uimenu('Parent',hMenu.mTools,'Callback','fMenuTools(''ScanFilament'',getappdata(0,''hMainGui''));','Enable','off',...
                             'Label','Use Filament for Scan','Tag','mFilamentScan');     
                     
%create Statistics menu

fMenuStatistics(''); %create dependency for compiling;
fPathStatsGui(''); %create dependency for compiling;
fEstimateMotilityParamsGui(''); %create dependency for compiling;
fVelocityStatsGui(''); %create dependency for compiling;
fKymoEval; %create dependency for compiling;
fBleachEvaluate(''); %create dependency for compiling;
fFlowEval; %create dependency for compiling;

hMenu.mStats = uimenu('Parent',hMainGui.fig,'Label','Statistics','Tag','mStats');

hMenu.mPathStats = uimenu('Parent',hMenu.mStats,'Callback','fPathStatsGui(''Create'');',...
                            'Label','Path Statistics','Tag','PathStats');
                        
hMenu.mVelocityStats = uimenu('Parent',hMenu.mStats,'Callback','fVelocityStatsGui(''Create'');',...
                             'Label','Velocity Statistics','Tag','mVelocityStats');    
                         
hMenu.mMotilityParameters = uimenu('Parent',hMenu.mStats,'Callback','fEstimateMotilityParamsGui(''Create'');',...
                                 'Label','Estimate Motility Parameters','Tag','mMotilityParameters');  
                        
hMenu.mDiffusionAnalysis = uimenu('Parent',hMenu.mStats,'Callback','fMenuStatistics(''DiffusionAnalysis'');',...
                    'Label','Diffusion Analysis (CVE/MSD)','Tag','mDiffusionAnalysis');            
                
hMenu.mAverageFilament = uimenu('Parent',hMenu.mStats,'Callback','fMenuStatistics(''AverageFilament'');',...
                    'Label','Average Filaments','Tag','mAverageFilament ');    
                
hMenu.mAlignFilament = uimenu('Parent',hMenu.mStats,'Callback','fMenuStatistics(''AlignFilament'');',...
                    'Label','Align Filaments','Tag','mAlignFilament ');    
                
hMenu.mKymoEval = uimenu('Parent',hMenu.mStats,'Callback','fKymoEval(''Create'');',...
                    'Label','Kymograph Evaluation','Tag','mKymoEval');
                
hMenu.mCountObjects = uimenu('Parent',hMenu.mStats,'Callback','fMenuStatistics(''CountObjects'',1);',...
                    'Label','Count Objects','Tag','mCountObjects');
                
hMenu.mBleachEvaluate = uimenu('Parent',hMenu.mStats,'Callback','fBleachEvaluate(''Create'');',...
                    'Label','Bleaching Evaluation','Tag','mBleachEvaluate');
                
hMenu.mFlowEvaluate = uimenu('Parent',hMenu.mStats,'Callback','fFlowEval(''Create'');',...
                             'Label','Flow Evaluation','Tag','mFlowEvaluate');
                        
%create Help menu

fAboutGui(''); %create dependency for compiling;

hMenu.mHelp = uimenu('Parent',hMainGui.fig,'Label','Help','Tag','mHelp');

hMenu.mWebsite = uimenu('Parent',hMenu.mHelp,'Label','Visit FIESTA homepage','Tag','mWebsite','Callback','openhelp');

hMenu.mDocumentation = uimenu('Parent',hMenu.mHelp,'Label','FIESTA documentation','Tag','mDocumentation','Callback','openhelp(''documentation'');');

hMenu.mHowToMol = uimenu('Parent',hMenu.mHelp,'Label','How to track single particles or molecules','Tag','mHowToMol','Separator','on','Callback','openhelp(''How_to_track_single_particles_or_molecules'');');

hMenu.mHowToFil = uimenu('Parent',hMenu.mHelp,'Label','How to track filaments','Tag','mHowToFil','Callback','openhelp(''How_to_track_filaments'');');

hMenu.mAbout = uimenu('Parent',hMenu.mHelp,'Callback','fAboutGui(getappdata(0,''hMainGui''));',...
                      'Label','About FIESTA','Tag','mAbout','Separator','on');

%create region context menu

fMenuContext(''); %create dependency for compiling;

hMenu.ctRegion = uicontextmenu('Parent',hMainGui.fig);

hMenu.mDeleteRegion = uimenu('Parent',hMenu.ctRegion,'Callback','fMenuContext(''DeleteRegion'',getappdata(0,''hMainGui''));',...
                            'Label','Delete','Tag','mDeleteRegion','UserData','one');
                        
hMenu.mDeleteRegionAll = uimenu('Parent',hMenu.ctRegion,'Callback','fMenuContext(''DeleteRegion'',getappdata(0,''hMainGui''));',...
                            'Label','Delete All','Tag','mDeleteRegionAll','UserData','all');
%create measure context menu                        
hMenu.ctMeasure = uicontextmenu('Parent',hMainGui.fig);

hMenu.mDeleteMeasure = uimenu('Parent',hMenu.ctMeasure,'Callback','fMenuContext(''DeleteMeasure'',getappdata(0,''hMainGui''));',...
                            'Label','Delete','Tag','mDeleteMeasure','UserData','one');
                        
hMenu.mDeleteMeasureAll = uimenu('Parent',hMenu.ctMeasure,'Callback','fMenuContext(''DeleteMeasure'',getappdata(0,''hMainGui''));',...
                            'Label','Delete All','Tag','mDeleteMeasureAll','UserData','all');                        

%create scan context menu                                                
hMenu.ctScan = uicontextmenu('Parent',hMainGui.fig);


hMenu.mEstimateFWHM = uimenu('Parent',hMenu.ctScan,'Callback','fMenuContext(''EstimateFWHM'',getappdata(0,''hMainGui''));',...
                            'Label','Estimate FWHM','Tag','mEstimateFWHM');
                        
hMenu.mDeleteScan = uimenu('Parent',hMenu.ctScan,'Callback','fShared(''DeleteScan'',getappdata(0,''hMainGui''));',...
                            'Label','Delete','Tag','mDeleteScan');
                                           
%create kymograph context menu
hMenu.ctKymoGraph = uicontextmenu('Parent',hMainGui.fig);

hMenu.mRefreshKymoGraph = uimenu('Parent',hMenu.ctKymoGraph,'Callback','fRightPanel(''UpdateScan'',getappdata(0,''hMainGui''),1);',...
                                 'Label','Refresh','Tag','mRefreshKymoGraph','UserData','one');             

for i=1:3
    enable='on';
    checked='off';
    if i==2
       enable='off';
       checked='on';
    end
    %create track context menu      
    hMenu.ctTrack(i).menu = uicontextmenu('Parent',hMainGui.fig,'CallBack','fMenuContext(''TransferTrackInfo'',getappdata(0,''hMainGui''));');

    hMenu.ctTrack(i).mOpen = uimenu('Parent',hMenu.ctTrack(i).menu,'Callback','fMenuContext(''OpenTrack'',getappdata(0,''hMainGui''));',...
                                    'Label','Open','Tag','mOpen');     
    
    
    hMenu.ctTrack(i).mSelect = uimenu('Parent',hMenu.ctTrack(i).menu,'Callback','fMenuContext(''SelectTrack'',getappdata(0,''hMainGui''));',...
                                        'Label','Select','Tag','mSelect','UserData','normal','Separator','on','Enable',enable);     
                                    

    hMenu.ctTrack(i).mSelectSelect = uimenu('Parent',hMenu.ctTrack(i).menu,'Callback','fMenuContext(''SelectTrack'',getappdata(0,''hMainGui''));',...
                                        'Label','+/- Selection','Tag','mSelect','UserData','alt','Enable',enable);     

    if i<3
        hMenu.ctTrack(i).mMark = uimenu('Parent',hMenu.ctTrack(i).menu,'Label','Mark','Tag','mMark');        
        
        hMenu.ctTrack(i).Mark.mBlue = uimenu('Parent',hMenu.ctTrack(i).mMark,'Callback','fMenuContext(''MarkTrack'',getappdata(0,''hMainGui''));',...
                                    'Label','Blue','Tag','mBlue','UserData',[0 0 1]);       

        hMenu.ctTrack(i).Mark.mGreen = uimenu('Parent',hMenu.ctTrack(i).mMark,'Callback','fMenuContext(''MarkTrack'',getappdata(0,''hMainGui''));',...
                                        'Label','Green','Tag','mGreen','UserData',[0 1 0]);   

        hMenu.ctTrack(i).Mark.mRed = uimenu('Parent',hMenu.ctTrack(i).mMark,'Callback','fMenuContext(''MarkTrack'',getappdata(0,''hMainGui''));',...
                                        'Label','Red','Tag','mRed','UserData',[1 0 0]);              

        hMenu.ctTrack(i).Mark.mMagenta = uimenu('Parent',hMenu.ctTrack(i).mMark,'Callback','fMenuContext(''MarkTrack'',getappdata(0,''hMainGui''));',...
                                          'Label','Magenta','Tag','mMagenta ','UserData',[1 0 1]);                             

        hMenu.ctTrack(i).Mark.mCyan = uimenu('Parent',hMenu.ctTrack(i).mMark,'Callback','fMenuContext(''MarkTrack'',getappdata(0,''hMainGui''));',...
                                          'Label','Cyan','Tag','mCyan','UserData',[0 1 1]);                                                           

        hMenu.ctTrack(i).Mark.mPink = uimenu('Parent',hMenu.ctTrack(i).mMark,'Callback','fMenuContext(''MarkTrack'',getappdata(0,''hMainGui''));',...
                                          'Label','Pink','Tag','mPink ','UserData',[1 0.5 0.5]);       
        
    else
        hMenu.ctTrack(i).mMark = uimenu('Parent',hMenu.ctTrack(i).menu,'Label','Mark selection','Tag','mMark');    
        
        hMenu.ctTrack(i).Mark.mBlue = uimenu('Parent',hMenu.ctTrack(i).mMark,'Callback','fMenuContext(''MarkSelection'');',...
                                    'Label','Blue','Tag','mBlue','UserData',[0 0 1]);       

        hMenu.ctTrack(i).Mark.mGreen = uimenu('Parent',hMenu.ctTrack(i).mMark,'Callback','fMenuContext(''MarkSelection'');',...
                                        'Label','Green','Tag','mGreen','UserData',[0 1 0]);   

        hMenu.ctTrack(i).Mark.mRed = uimenu('Parent',hMenu.ctTrack(i).mMark,'Callback','fMenuContext(''MarkSelection'');',...
                                        'Label','Red','Tag','mRed','UserData',[1 0 0]);              

        hMenu.ctTrack(i).Mark.mMagenta = uimenu('Parent',hMenu.ctTrack(i).mMark,'Callback','fMenuContext(''MarkSelection'');',...
                                          'Label','Magenta','Tag','mMagenta ','UserData',[1 0 1]);                             

        hMenu.ctTrack(i).Mark.mCyan = uimenu('Parent',hMenu.ctTrack(i).mMark,'Callback','fMenuContext(''MarkSelection'');',...
                                          'Label','Cyan','Tag','mCyan','UserData',[0 1 1]);                                                           

        hMenu.ctTrack(i).Mark.mPink = uimenu('Parent',hMenu.ctTrack(i).mMark,'Callback','fMenuContext(''MarkSelection'');',...
                                          'Label','Pink','Tag','mPink ','UserData',[1 0.5 0.5]);          
        
    end
    
    hMenu.ctTrack(i).mSetAsCurrent = uimenu('Parent',hMenu.ctTrack(i).menu,'Callback','fMenuContext(''SetCurrentTrack'',getappdata(0,''hMainGui''),''Set'');',...
                                            'Label','Set as Current','Tag','mSetAsCurrent','Separator','on','Checked',checked);      
end

%create molecule list context menu                                     
hMenu.ctListMol= uicontextmenu('Parent',hMainGui.fig);                            

hMenu.ListMol.mSelectAll = uimenu('Parent',hMenu.ctListMol,'Callback','fMenuContext(''SelectList'',getappdata(0,''hMainGui''));',...
                                'Label','Select all Tracks','Tag','mSelectAllTrack','UserData','All');
                            
hMenu.ListMol.mSelectAllMol = uimenu('Parent',hMenu.ctListMol,'Callback','fMenuContext(''SelectList'',getappdata(0,''hMainGui''));',...
                                'Label','Select all Molecules','Tag','mSelectAllMol','UserData','Molecule');

hMenu.ListMol.mSelectInverse = uimenu('Parent',hMenu.ctListMol,'Callback','fMenuContext(''SelectList'',getappdata(0,''hMainGui''));',...
                                'Label','Inverse Selection','Tag','mSelectInverse','UserData','Inverse');   
         
hMenu.ListMol.mClearCurrent = uimenu('Parent',hMenu.ctListMol,'Callback','fMenuContext(''SetCurrentTrack'',getappdata(0,''hMainGui''),''Clear'');',...
                                'Label','Clear Current Track','Separator','on','Tag','mClearCurrent');
                            
hMenu.ListMol.mShowAll = uimenu('Parent',hMenu.ctListMol,'Callback','fMenuContext(''VisibleList'',getappdata(0,''hMainGui''));',...
                                'Label','Show all Tracks','Tag','mShowAll','UserData','All','Separator','on');
                            
hMenu.ListMol.mShowSelection = uimenu('Parent',hMenu.ctListMol,'Callback','fMenuContext(''VisibleList'',getappdata(0,''hMainGui''));',...
                                'Label','Show/Hide Selection','Tag','mShowSelection','UserData','Selection');

hMenu.ListMol.mMarkSelection = uimenu('Parent',hMenu.ctListMol,'Label','Mark selection','Tag','mMarkSelection');        
        
hMenu.ListMol.Mark.mBlue = uimenu('Parent',hMenu.ListMol.mMarkSelection,'Callback','fMenuContext(''MarkSelection'');',...
                            'Label','Blue','Tag','mBlue','UserData',[0 0 1]);       

hMenu.ListMol.Mark.mGreen = uimenu('Parent',hMenu.ListMol.mMarkSelection,'Callback','fMenuContext(''MarkSelection'');',...
                                'Label','Green','Tag','mGreen','UserData',[0 1 0]);   

hMenu.ListMol.Mark.mRed = uimenu('Parent',hMenu.ListMol.mMarkSelection,'Callback','fMenuContext(''MarkSelection'');',...
                                'Label','Red','Tag','mRed','UserData',[1 0 0]);              

hMenu.ListMol.Mark.mMagenta = uimenu('Parent',hMenu.ListMol.mMarkSelection,'Callback','fMenuContext(''MarkSelection'');',...
                                  'Label','Magenta','Tag','mMagenta ','UserData',[1 0 1]);                             

hMenu.ListMol.Mark.mCyan = uimenu('Parent',hMenu.ListMol.mMarkSelection,'Callback','fMenuContext(''MarkSelection'');',...
                                  'Label','Cyan','Tag','mCyan','UserData',[0 1 1]);                                                           

hMenu.ListMol.Mark.mPink = uimenu('Parent',hMenu.ListMol.mMarkSelection,'Callback','fMenuContext(''MarkSelection'');',...
                                  'Label','Pink','Tag','mPink ','UserData',[1 0.5 0.5]);          
                            
hMenu.ListMol.mSetReference = uimenu('Parent',hMenu.ctListMol,'Callback','fShared(''SetReference'',getappdata(0,''hMainGui''));',...
                                'Label','Set as reference','Tag','mSetReference','Separator','on');
                            
hMenu.ListMol.mMerge = uimenu('Parent',hMenu.ctListMol,'Callback','fShared(''MergeTracks'',getappdata(0,''hMainGui''));',...
                                'Label','Join selected tracks','Separator','on','Tag','mMergeMol','UserData','Molecule');

hMenu.ListMol.mDelete = uimenu('Parent',hMenu.ctListMol,'Callback','fShared(''DeleteTracks'',getappdata(0,''hMainGui''),[],[]);',...
                                'Label','Delete selected tracks','Tag','mDelete');   
                            
%create microtubule list context menu                                     
hMenu.ctListFil = uicontextmenu('Parent',hMainGui.fig);                            

hMenu.ListFil.mSelectAll = uimenu('Parent',hMenu.ctListFil,'Callback','fMenuContext(''SelectList'',getappdata(0,''hMainGui''));',...
                                'Label','Select all Tracks','Tag','mSelectAllTrack','UserData','All');
                            
hMenu.ListFil.mSelectAllFil = uimenu('Parent',hMenu.ctListFil,'Callback','fMenuContext(''SelectList'',getappdata(0,''hMainGui''));',...
                                'Label','Select all Filaments','Tag','mSelectAllTrack','UserData','Filament');
                            
hMenu.ListFil.mSelectInverse = uimenu('Parent',hMenu.ctListFil,'Callback','fMenuContext(''SelectList'',getappdata(0,''hMainGui''));',...
                                'Label','Inverse Selection','Tag','mSelectAllTrack','UserData','Inverse');   
                          
hMenu.ListFil.mClearCurrent = uimenu('Parent',hMenu.ctListFil,'Callback','fMenuContext(''SetCurrentTrack'',getappdata(0,''hMainGui''),''Clear'');',...
                                'Label','Clear Current Track','Separator','on','Tag','mClearCurrent');
                            
hMenu.ListFil.mShowAll = uimenu('Parent',hMenu.ctListFil,'Callback','fMenuContext(''VisibleList'',getappdata(0,''hMainGui''));',...
                                'Label','Show all Tracks','Tag','mShowAll','UserData','All','Separator','on');
                            
hMenu.ListFil.mShowSelection = uimenu('Parent',hMenu.ctListFil,'Callback','fMenuContext(''VisibleList'',getappdata(0,''hMainGui''));',...
                                'Label','Show/Hide Selection','Tag','mShowSelection','UserData','Selection');                            
                            
hMenu.ListFil.mMarkSelection = uimenu('Parent',hMenu.ctListFil,'Label','Mark selection','Tag','mMarkSelection');        
        
hMenu.ListFil.Mark.mBlue = uimenu('Parent',hMenu.ListFil.mMarkSelection,'Callback','fMenuContext(''MarkSelection'');',...
                            'Label','Blue','Tag','mBlue','UserData',[0 0 1]);       

hMenu.ListFil.Mark.mGreen = uimenu('Parent',hMenu.ListFil.mMarkSelection,'Callback','fMenuContext(''MarkSelection'');',...
                                'Label','Green','Tag','mGreen','UserData',[0 1 0]);   

hMenu.ListFil.Mark.mRed = uimenu('Parent',hMenu.ListFil.mMarkSelection,'Callback','fMenuContext(''MarkSelection'');',...
                                'Label','Red','Tag','mRed','UserData',[1 0 0]);              

hMenu.ListFil.Mark.mMagenta = uimenu('Parent',hMenu.ListFil.mMarkSelection,'Callback','fMenuContext(''MarkSelection'');',...
                                  'Label','Magenta','Tag','mMagenta ','UserData',[1 0 1]);                             

hMenu.ListFil.Mark.mCyan = uimenu('Parent',hMenu.ListFil.mMarkSelection,'Callback','fMenuContext(''MarkSelection'');',...
                                  'Label','Cyan','Tag','mCyan','UserData',[0 1 1]);                                                           

hMenu.ListFil.Mark.mPink = uimenu('Parent',hMenu.ListFil.mMarkSelection,'Callback','fMenuContext(''MarkSelection'');',...
                                  'Label','Pink','Tag','mPink ','UserData',[1 0.5 0.5]);          
                            
hMenu.ListFil.mMerge = uimenu('Parent',hMenu.ctListFil,'Callback','fShared(''MergeTracks'',getappdata(0,''hMainGui''));',...
                                'Label','Join selected tracks','Separator','on','Tag','mMergeFil','UserData','Filament');

hMenu.ListFil.mDelete = uimenu('Parent',hMenu.ctListFil,'Callback','fShared(''DeleteTracks'',getappdata(0,''hMainGui''),[],[]);',...
                                'Label','Delete selected tracks','Tag','mDelete');   
                            
%create local queue context menu                                     
hMenu.ctListLoc = uicontextmenu('Parent',hMainGui.fig);                            

hMenu.ListLoc.mDelete = uimenu('Parent',hMenu.ctListLoc,'Callback','fMenuContext(''DeleteQueue'');',...
                                'Label','Delete Selection','Tag','mDelete ','UserData','Selected');
                            
hMenu.ListLoc.mDeleteAll = uimenu('Parent',hMenu.ctListLoc,'Callback','fMenuContext(''DeleteQueue'');',...
                                'Label','Delete all Stacks','Tag','mDeleteAll','UserData','All');
                            
%create molecule context menu for objects
hMenu.ctObjectMol = uicontextmenu('Parent',hMainGui.fig);                            

hMenu.ObjectMol.mAddToCurrent = uimenu('Parent',hMenu.ctObjectMol,'Callback','fMenuContext(''AddTo'',getappdata(0,''hMainGui''));',...
                                    'Label','Add to current track','Tag','mAddToCurrent','UserData',{'Molecule','Current'});
                            
hMenu.ObjectMol.mAddToNew = uimenu('Parent',hMenu.ctObjectMol,'Callback','fMenuContext(''AddTo'',getappdata(0,''hMainGui''));',...
                                         'Label','Add to new track','Tag','mAddToNew','UserData',{'Molecule','New'});

hMenu.ObjectMol.mDelete = uimenu('Parent',hMenu.ctObjectMol,'Callback','fMenuContext(''DeleteObject'',getappdata(0,''hMainGui''));',...
                                'Label','Delete object','Tag','mDelete','UserData','Molecule');   

%create filament context menu for objects
hMenu.ctObjectFil = uicontextmenu('Parent',hMainGui.fig);                            

hMenu.ObjectFil.mAddToCurrent = uimenu('Parent',hMenu.ctObjectFil,'Callback','fMenuContext(''AddTo'',getappdata(0,''hMainGui''));',...
                                    'Label','Add to current track','Tag','mAddToCurrent','UserData',{'Filament','Current'});
                            
hMenu.ObjectFil.mAddToNew = uimenu('Parent',hMenu.ctObjectFil,'Callback','fMenuContext(''AddTo'',getappdata(0,''hMainGui''));',...
                                         'Label','Add to new track','Tag','mAddToNew','UserData',{'Filament','New'});

hMenu.ObjectFil.mDelete = uimenu('Parent',hMenu.ctObjectFil,'Callback','fMenuContext(''DeleteObject'',getappdata(0,''hMainGui''));',...
                                'Label','Delete object','Tag','mDelete','UserData','Filament');
                            
                            
hMenu.ctOffsetMap = uicontextmenu('Parent',hMainGui.fig);                            

hMenu.OffsetMap.mDeleteOffset = uimenu('Parent',hMenu.ctOffsetMap ,'Callback','fMenuContext(''DeleteOffset'',getappdata(0,''hMainGui''));',...
                                       'Label','Delete offset point','Tag','mDeleteOffset');
                           
hMenu.ctOffsetMapMatch = uicontextmenu('Parent',hMainGui.fig);                            

hMenu.OffsetMap.mDeleteMatch = uimenu('Parent',hMenu.ctOffsetMapMatch ,'Callback','fMenuContext(''DeleteOffsetMatch'',getappdata(0,''hMainGui''));',...
                                      'Label','Delete offset match','Tag','mDeleteMatch');
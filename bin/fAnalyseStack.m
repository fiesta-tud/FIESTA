function abort=fAnalyseStack(Stack,TimeInfo,Config,JobNr,Objects)
global logfile;
global error_events;
global DirCurrent;
global FiestaDir;
hMainGui=getappdata(0,'hMainGui'); 

error_events=[];
abort=0;

params.bw_region = Config.Region;
params.dynamicfil = 0;
if isfield(Config,'DynamicFil')
    params.dynamicfil = Config.DynamicFil;
    if Config.DynamicFil
        [y,x] = size(params.bw_region);
        bw_region = zeros(y,x,10);
        orig_region = params.bw_region;
    end
end
if isfield(Config,'TformChannel')
    params.transform = Config.TformChannel;
end

params.bead_model=Config.Model;
params.max_beads_per_region=Config.MaxFunc;
params.scale=Config.PixSize;
params.ridge_model = 'quadratic';

params.find_molecules=1;
params.find_beads=1;

if Config.OnlyTrackMol==1
    params.find_molecules=0;
end
if Config.OnlyTrackFil==1
    params.find_beads=0;
end
params.include_data = Config.OnlyTrack.IncludeData;
params.area_threshold=Config.Threshold.Area;
params.height_threshold=Config.Threshold.Height;   
params.fwhm_estimate=Config.Threshold.FWHM;
if isempty(Config.BorderMargin)
    params.border_margin = 2 * Config.Threshold.FWHM / params.scale / (2*sqrt(2*log(2)));
else
    params.border_margin = Config.BorderMargin;
end

if isempty(Config.ReduceFitBox)
    params.reduce_fit_box = 1;
else
    params.reduce_fit_box = Config.ReduceFitBox;
end

params.focus_correction = Config.FilFocus;
params.min_cod=Config.Threshold.Fit;
params.threshold = Config.Threshold.Value;
if length(Config.Threshold.Filter)==1
    [params.binary_image_processing,params.background_filter] = strtok(Config.Threshold.Filter{1},'+');
else
    params.binary_image_processing = [];
    params.background_filter=Config.Threshold.Filter;
end
params.display = 1;

params.options = optimset( 'Display', 'off','UseParallel','never');
params.options.MaxFunEvals = []; 
params.options.MaxIter = [];
params.options.TolFun = [];
params.options.TolX = [];

if ~isempty(TimeInfo) && ~isempty(TimeInfo{1}) 
    params.creation_time_vector = (TimeInfo{1}-TimeInfo{1}(1))/1000;
    %check wether imaging was done during change of date 
    k = params.creation_time_vector<0;
    params.creation_time_vector(k) = params.creation_time_vector(k) + 24*60*60;
end

if strncmp(Config.TrackingServer,'local',5)
    num_cores = str2double(Config.TrackingServer(6:end));
    JobNr = -1;
end
if isinf(Config.LastFrame)
    Config.LastFrame = size(Stack{1},3);
end
if Config.LastFrame > size(Stack{1},3)
   Config.LastFrame = size(Stack{1},3);
end
if isempty(Objects)
    Objects = cell(1,size(Stack,2));
end
if ~isempty(strfind(Config.StackName,'.stk'))
    sName = strrep(Config.StackName, '.stk', '');
elseif ~isempty(strfind(Config.StackName,'.tif'))
    sName = strrep(Config.StackName, '.tif', '');
elseif ~isempty(strfind(Config.StackName,'.tiff'))
    sName = strrep(Config.StackName, '.tiff', '');
elseif ~isempty(strfind(Config.StackName,'.nd2'))
    sName = strrep(Config.StackName, '.nd2', '');
else
    sName = Config.StackName;
end
try
    fData=[Config.Directory sName '(' datestr(clock,'yyyymmddTHHMMSSFFF') ').mat'];
    save(fData,'Config');
catch
    fData=[DirCurrent sName '(' datestr(clock,'yyyymmddTHHMMSSFFF') ').mat'];
    fMsgDlg(['Directory not accessible - File saved in FIESTA directory: ' DirCurrent],'warn');
    save(fData,'Config');
end

filestr = [FiestaDir.AppData 'logfile.txt'];
logfile = fopen(filestr,'w');
if Config.FirstTFrame>0
    FramesT = Config.LastFrame-Config.FirstTFrame+1;
    if JobNr>0
        params.display = 0;
        dirStatus = [DirCurrent 'Queue' filesep 'Job' int2str(JobNr) filesep 'Status' filesep];
        TimeT = clock; %#ok<NASGU>
        save([DirCurrent 'Queue' filesep 'Job' int2str(JobNr) filesep 'FiestaStatus.mat'],'TimeT','FramesT','-append');
        [y,x,z] = size(Stack{1});
        nStack = length(Stack);
        for n = nStack:-1:1
            Stack(n,1:z) = mat2cell(Stack{n},y,x,ones(1,z));
        end
        try
            parfor n=Config.FirstTFrame:Config.LastFrame
                Objects{n}=ScanImage(cat(3,Stack{:,n}),params,n);
                fSave(dirStatus,n);
            end
        catch ME
            save(fData,'-append','Objects','ME');
            return;
        end
    elseif JobNr==-1    
        %parpool(num_cores);
        params.display = 0;
        dirStatus = [FiestaDir.AppData 'fiestastatus' filesep];  
        [y,x,z] = size(Stack{1});
        nStack = length(Stack);
        for n = nStack:-1:1
            Stack(n,1:z) = mat2cell(Stack{n},y,x,ones(1,z));
        end
        parallelprogressdlg('String',['Tracking on ' num2str(num_cores) ' cores'],'Max',Config.LastFrame-Config.FirstTFrame+1,'Parent',hMainGui.fig,'Directory',FiestaDir.AppData);
        try
            parfor n=Config.FirstTFrame:Config.LastFrame
                Objects{n}=ScanImage(cat(3,Stack{:,n}),params,n);
                fSave(dirStatus,n);
            end
        catch ME
            save(fData,'-append','Objects','ME');
            return;
        end  
        parallelprogressdlg('close');
        %delete(gcp);
    else
        h=progressdlg('String',sprintf('Tracking - Frame: %d',Config.FirstTFrame),'Min',Config.FirstTFrame-1,'Max',Config.LastFrame,'Cancel','on','Parent',hMainGui.fig);
        for n=Config.FirstTFrame:Config.LastFrame
            Log(sprintf('Analysing frame %d',n),params);
            try
                Objects{n}=ScanImage(fGetStackFrame(Stack,n),params,n);
            catch ME
                save(fData,'-append','Objects','ME');
                return;
            end
            if params.dynamicfil && ~isempty(Objects{n})
                bw_region(:,:,2:end) = bw_region(:,:,1:end-1);
                bw_region(:,:,1) = 0;
                [y,x] = size(params.bw_region);
                for m = 1:length(Objects{n}.data)
                    if Objects{n}.length(1,m)~=0
                        X = round(Objects{n}.data{m}(:,1)/params.scale);
                        Y = round(Objects{n}.data{m}(:,2)/params.scale);
                        k = X<1 | X>x | Y<1 | Y>y;
                        X(k) = [];
                        Y(k) = [];
                        idx = Y + (X - 1).*y;
                        bw_region(idx) = 1;
                    end
                end
                SE = strel('disk', ceil(params.fwhm_estimate/2/params.scale) , 4);
                bw_region(:,:,1) = imdilate(bw_region(:,:,1),SE);
                params.bw_region = orig_region | sum(bw_region,3)>4;
            end
            if Config.FirstCFrame>0
                if ~isempty(Objects{n})
                    s=sprintf('Tracking - Frame: %d - Objects found: %d',n+1,length(Objects{n}.center_x));
                else
                    s=sprintf('Tracking - Frame: %d - Objects found: %d',n+1,0);
                end
                if isempty(h)
                    abort=1;
                    save(fData,'-append','Objects');
                    return
                end
                h=progressdlg(n,s);
            end
            
        end
        progressdlg('close');
    end
end
fclose(logfile);
disp(Config.StackName)
disp(error_events)
try
    save(fData,'-append','Objects');
catch
    fData=[DirCurrent sName '(' datestr(clock,'yyyymmddTHHMMSSFFF') ').mat'];
    fMsgDlg(['Directory not accessible - File saved in FIESTA directory: ' DirCurrent],'warn');
    save(fData,'Objects','Config');
end
if ~isempty(Objects) && Config.ConnectMol.NumberVerification>0 && Config.ConnectFil.NumberVerification>0
    try
        [MolTrack,FilTrack,abort]=fFeatureConnect(Objects,Config,JobNr);     
    catch ME
        save(fData,'ME','-append');
        return;
    end
    if abort==1
        return
    end
    Molecule=[];
    Filament=[];
    Molecule=fDefStructure(Molecule,'Molecule');
    Filament=fDefStructure(Filament,'Filament');
    nMolTrack=length(MolTrack);

    nChannel = Config.TformChannel{1}(3,3);
    if length(Config.TformChannel)==1
        T = Config.TformChannel{1};
    else
        T = Config.TformChannel{nChannel};
    end
    
    T(3,3) = 1;
   
    for n = 1:nMolTrack
        nData=size(MolTrack{n},1);
        Molecule(n).Name = ['Molecule ' num2str(n)];
        Molecule(n).File = Config.StackName;
        Molecule(n).Comments = '';
        Molecule(n).Selected = 0;
        Molecule(n).Visible = true;    
        Molecule(n).Drift = 0;            
        Molecule(n).PixelSize = Config.PixSize;  
        Molecule(n).Channel = nChannel;
        Molecule(n).TformMat = T;
        Molecule(n).Color = [0 0 1];
        for j = 1:nData
            f = MolTrack{n}(j,1);
            m = MolTrack{n}(j,2);
            Molecule(n).Results(j,1) = single(f);
            Molecule(n).Results(j,2) = Objects{f}.time;
            Molecule(n).Results(j,3) = Objects{f}.center_x(m);
            Molecule(n).Results(j,4) = Objects{f}.center_y(m);
            Molecule(n).Results(j,5) = NaN;
            Molecule(n).Results(j,7) = Objects{f}.width(1,m);
            Molecule(n).Results(j,8) = Objects{f}.height(1,m);                
            Molecule(n).Results(j,9) = single(sqrt((Objects{f}.com_x(2,m))^2+(Objects{f}.com_y(2,m))^2));                        
            if size(Objects{f}.data{m},2)==1
                Molecule(n).Results(j,9:10) = Objects{f}.data{m}';                
                Molecule(n).Results(j,11) = single(mod(Objects{f}.orientation(1,m),2*pi));                
                Molecule(n).Type = 'stretched';
                Molecule(n).Results(j,12) = 0; 
            elseif size(Objects{f}.data{m},2)==3
                Molecule(n).Results(j,9:11) = Objects{f}.data{m}(1,:);                
                Molecule(n).Type = 'ring1';
                Molecule(n).Results(j,12) = 0; 
            else
                Molecule(n).Type = 'symmetric';
                Molecule(n).Results(j,10) = 0; 
            end
            if Config.OnlyTrack.IncludeData == 1
                Molecule(n).TrackingResults{j} = Objects{f}.points{m};
            else
                Molecule(n).TrackingResults{j} = [];
            end       
            
        end
        Molecule(n).Results(:,6) = fDis(Molecule(n).Results(:,3:5));
    end
    if ~isempty(Stack)
        sStack=size(Stack{1});
    end
    nFilTrack=length(FilTrack);
    for n = nFilTrack:-1:1
        nData=size(FilTrack{n},1);
        Filament(n).Name = ['Filament ' num2str(n)];
        Filament(n).File = Config.StackName;
        Filament(n).Comments = '';
        Filament(n).Selected=0;
        Filament(n).Visible=true;    
        Filament(n).Drift=0;    
        Filament(n).PixelSize = Config.PixSize;   
        Filament(n).Channel = nChannel;
        Filament(n).TformMat = T;
        Filament(n).Color=[0 0 1];
        for j=1:nData
            f = FilTrack{n}(j,1);
            m = FilTrack{n}(j,2);
            Filament(n).Results(j,1) = single(f);
            Filament(n).Results(j,2) = Objects{f}.time;
            Filament(n).Results(j,3) = Objects{f}.center_x(m);
            Filament(n).Results(j,4) = Objects{f}.center_y(m);
            Filament(n).Results(j,5) = NaN;
            Filament(n).Results(j,7) = Objects{f}.length(1,m);
            Filament(n).Results(j,8) = Objects{f}.height(1,m);                
            Filament(n).Results(j,9) = single(mod(Objects{f}.orientation(1,m),2*pi));
            Filament(n).Results(j,10) = 0;
            Filament(n).Data{j} = [Objects{f}.data{m}(:,1:2) ones(size(Objects{f}.data{m},1),1)*NaN Objects{f}.data{m}(:,3:end)];
            Filament(n).PosCenter(j,1:3)=[Filament(n).Results(j,3:4) NaN];  
            if Config.OnlyTrack.IncludeData == 1
                Filament(n).TrackingResults{j} = Objects{f}.points{m};
            else
                Filament(n).TrackingResults{j} =[];
            end       
        end
        
        Filament(n) = fAlignFilament(Filament(n),Config);
        
        if Config.ConnectFil.DisregardEdge && ~isempty(Stack)                                          
            xv = [5 5 sStack(2)-4 sStack(2)-4]*Config.PixSize;
            yv = [5 sStack(1)-4 sStack(1)-4 5]*Config.PixSize;            
            X=Filament(n).PosStart(:,1);
            Y=Filament(n).PosStart(:,2);
            IN = inpolygon(X,Y,xv,yv);
            Filament(n).Results(~IN,:)=[];            
            Filament(n).PosStart(~IN,:)=[];
            Filament(n).PosCenter(~IN,:)=[];
            Filament(n).PosEnd(~IN,:)=[];
            Filament(n).Data(~IN)=[];            
            X=Filament(n).PosEnd(:,1);
            Y=Filament(n).PosEnd(:,2);
            IN = inpolygon(X,Y,xv,yv);
            Filament(n).Results(~IN,:)=[];
            Filament(n).PosStart(~IN,:)=[];
            Filament(n).PosCenter(~IN,:)=[];
            Filament(n).PosEnd(~IN,:)=[]; 
            Filament(n).Data(~IN)=[];
            if isempty(Filament(n).Results)
                Filament(n)=[];
            else
                Filament(n).Results(:,6) = fDis(Filament(n).Results(:,3:5));
            end
        end
    end
    try
        save(fData,'-append','Molecule','Filament');
    catch ME
        fData=[DirCurrent sName '(' datestr(clock,'yyyymmddTHHMMSSFFF') ').mat'];
        fMsgDlg(['Directory not accessible - File saved in FIESTA directory: ' DirCurrent],'warn');
        save(fData,'Molecule','Filament','Objects','Config');
    end
    clear Molecule Filament Objects Config;
end

function fSave(dirStatus,frame)
fname = [dirStatus 'frame' int2str(frame) '.mat'];
save(fname,'frame');
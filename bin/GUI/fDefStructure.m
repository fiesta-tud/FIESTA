function Object=fDefStructure(Object,Mode)
nObj=length(Object);
n=nObj;
if nObj==0
    nObj=1;
end
if isfield(Object,'Name')==0
    for i=1:nObj    
        Object(i).Name='';
    end
end
if isfield(Object,'File')==0
    for i=1:nObj    
        Object(i).File='';
    end
end
if isfield(Object,'Directory')==1
    for i=1:nObj    
        Object(i).Comments = Object(i).Directory;
    end
    Object = rmfield(Object,'Directory');
end

if isfield(Object,'Comments')==0
    for i=1:nObj    
        Object(i).Comments = '';
    end
end

if isfield(Object,'Results')==0
    for i=1:nObj    
        Object(i).Results = single([]);
    end
else
    for i=1:nObj
        if size(Object(i).Results,2)~=10 && Object(i).Results(1,5) == 0 
            if strcmp(Mode,'Molecule') && isfield(Object,'Data')==1 && ~isempty(Object(i).Data)
                Object(i).Results = single([Object(i).Results(:,1:4) Object(i).Data Object(i).Results(:,5:8) Object(i).Results(:,1)*0]);
            else
                Object(i).Results = single([Object(i).Results(:,1:4) Object(i).Results(:,1)*NaN Object(i).Results(:,5:8) Object(i).Results(:,1)*0]);
            end
        else    
            Object(i).Results = single(Object(i).Results);
        end
    end
end
if strcmp(Mode,'Molecule') && isfield(Object,'Data')==1
    Object = rmfield(Object,'Data');
end
if strcmp(Mode,'Molecule')
    if isfield(Object,'Type')==0
        for i=1:nObj 
            Object(i).Type = '';  
        end
    end
end
if isfield(Object,'Selected')==0
    for i=1:nObj
        Object(i).Selected=0;
    end
end
if isfield(Object,'Visible')==0
    for i=1:nObj
        Object(i).Visible=true;
    end
else
    for i=1:nObj
        Object(i).Visible=logical(Object(i).Visible);
    end
end
if isfield(Object,'Drift')==0
    for i=1:nObj    
        Object(i).Drift=0;
    end
end
if isfield(Object,'PixelSize')==0
    for i=1:nObj    
        Object(i).PixelSize=1;
    end
end
if isfield(Object,'Channel')==0
    for i=1:nObj    
        Object(i).Channel=1;
    end
end
if isfield(Object,'TformMat')==0
    for i=1:nObj    
        Object(i).TformMat=[1 0 0; 0 1 0; 0 0 1];
    end
end
if isfield(Object,'Color')==0
    for i=1:nObj 
        Object(i).Color=[0 0 1];
    end
else
    for i=1:nObj    
        if ischar(Object(i).Color)
            Object(i).Color=ColorCode(Object(i).Color);
        end
    end
end

if strcmp(Mode,'Filament')
    if isfield(Object,'ResultsCenter') == 1
        for i=1:nObj     
            Object(i).Results = single(Object(i).ResultsCenter);
        end
    end
    if isfield(Object,'Orientation') == 1
        for i=1:nObj     
            if size(Object(i).Results,1) == length(Object(i).Orientation)
                Object(i).Results(:,8) = single(Object(i).Orientation');
            else
                Object(i).Results(:,8) = single(Object(i).Orientation(1:size(Object(i).Results,1))');
            end
        end
    end
    if isfield(Object,'PosStart') == 0
        if isfield(Object,'ResultsCenter') == 0
            for i=1:nObj                
                Object(i).PosStart = single([]);
                Object(i).PosCenter = single([]);
                Object(i).PosEnd = single([]);
            end
        else
            for i=1:nObj    
                Object(i).PosStart = single(Object(i).ResultsStart(:,3:4));
                Object(i).PosCenter = single(Object(i).ResultsCenter(:,3:4));
                Object(i).PosEnd = single(Object(i).ResultsEnd(:,3:4));
            end
        end
    else
        for i=1:nObj
            if size(Object(i).PosStart,2)==2 || size(Object(i).PosCenter,2)==2 || size(Object(i).PosEnd,2)==2
                Object(i).PosStart(:,3) = NaN;
                Object(i).PosCenter(:,3) = NaN;
                Object(i).PosEnd(:,3) = NaN;
            end
        end
    end
    
    if isfield(Object,'Data')==0
        if isfield(Object,'data')==1
            for i=1:nObj    
                for n = 1:length(Object(i).data)
                    Data = Object(i).data{n};
                    Object(i).Data{n} = single([[Data.x]' [Data.y]' [Data.l]' [Data.w]' [Data.h]' [Data.b]']);
                end
            end
        else
            for i=1:nObj    
                Object(i).Data={};
            end
        end
    else
        for i=1:nObj    
            for n = 1:length(Object(i).Data)
                if size(Object(i).Data{n},2)<7
                    Object(i).Data{n} = [Object(i).Data{n}(:,1:2) ones(size(Object(i).Data{n},1),1)*NaN Object(i).Data{n}(:,3:end)];
                end
            end
        end
    end
    
end

if isfield(Object,'PathData')==0
    for i=1:nObj    
        Object(i).PathData = single([]);
    end
else
    for i=1:nObj
        if size(Object(i).PathData,2)==4
            Object(i).PathData(:,4:5) = Object(i).PathData(:,3:4);
            Object(i).PathData(:,3) = NaN;
            Object(i).PathData(:,6) = NaN;
        end
    end
end

for i=1:nObj    
    Object(i).PlotHandles = [];
end      

if isfield(Object,'TrackingResults')==0
    for i=1:nObj 
        Object(i).TrackingResults = cell(1,size(Object(i).Results,1));
    end 
end

if isfield(Object,'p')==1
    Object=rmfield(Object,'p');
end
if isfield(Object,'Config')==1
    Object=rmfield(Object,'Config');
end
if isfield(Object,'DriftControl')==1
    Object=rmfield(Object,'DriftControl');
end
if isfield(Object,'plot1')==1
    Object=rmfield(Object,'plot1');
end
if isfield(Object,'plot2')==1
    Object=rmfield(Object,'plot2');
end
if isfield(Object,'Check')==1
    Object=rmfield(Object,'Check');
end
if isfield(Object,'data')==1
    Object=rmfield(Object,'data');
end
if isfield(Object,'ResultsCenter')==1
    Object=rmfield(Object,'ResultsCenter');
end
if isfield(Object,'ResultsStart')==1
    Object=rmfield(Object,'ResultsStart');
end
if isfield(Object,'ResultsEnd')==1
    Object=rmfield(Object,'ResultsEnd');
end
if isfield(Object,'pTrack')==1
    Object=rmfield(Object,'pTrack');
end
if isfield(Object,'pTrackSelectW')==1
    Object=rmfield(Object,'pTrackSelectW');
end
if isfield(Object,'pTrackSelectB')==1
    Object=rmfield(Object,'pTrackSelectB');
end
if isfield(Object,'NewResults')==1
    Object=rmfield(Object,'NewResults');
end
if isfield(Object,'Path')==1
    Object=rmfield(Object,'Path');
end
if isfield(Object,'Orientation')==1
    Object=rmfield(Object,'Orientation');
end
if n==0
    Object(1)=[];
end

function color=ColorCode(char)
switch(char)
    case 'b'
        color=[0 0 1];
    case 'r'
        color=[1 0 0];
    case 'g'
        color=[1 0 0];
    case 'p'
        color=[1 0.5 0.5];        
    case 'o'
        color=[1 0.5 0];                
    case 'y' 
        color=[1 1 0];
end
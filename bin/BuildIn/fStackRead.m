function [Stack,TimeInfo,PixelSize] = fStackRead(varargin)
%StackRead - read stack images and information (8bit and 16bit)
%   function StackRead(source) returns 2 structures
%  
%   Input:  Source - Path + Filename     
%           Options (optional) - Structure for read options
%
%   Output: [Stack,MetaInfo,StackInfo]
%
%   Stack   - image data
%   
%   Removed TiffInfo due to performance probplems 2012/04/18
%   TiffInfo - stack information, contains all relevent TIFF information (http://partners.adobe.com/public/developer/en/tiff/TIFF6.pdf)
%                                  may contain MetaMorph information (http://support.universal-imaging.com/docs/T10243.pdf)
%
%   Example: [Stack,MetaInfo,StackInfo] = StackRead('ZSER16.STK');
%            [Stack,MetaInfo,StackInfo] = StackRead('ZSER16.TIFF');
%
%   Copyright 2015 Felix Ruhnow 
%   $Revision: 1.4 $  $Date: 2015/06/25

if nargin == 0
    error('No file specified');
else
    source = varargin{1};
    options = [];
    if nargin == 2
        options = varargin{2};
    end
end
file = fopen(source, 'r', 'l');
%read TIFF-header

%read byte order first
order = fread(file, 1, 'uint16');
    
if (order ~= hex2dec('4949'))
    if (order == hex2dec('4D4D'))
        fclose(file);
        file = fopen(source, 'r' , 'b' );
        %read byte order first
        fread(file, 1, 'uint16');
    else
        fclose(file);
        error('No Stack File')
    end
end

%check tiff format
format = fread(file, 1, 'uint16');
if (format ~= 42)
    fclose(file);
    error('No Tiff File');
end
hMainGui=getappdata(0,'hMainGui'); 
progressdlg('close');
if ~isempty(hMainGui)
    progressdlg('Title','FIESTA','String','Reading Stack Information...','Parent',hMainGui.fig);    
end
A_start = fread(file, 1, 'uint32');
A=A_start;
NumFrames = 0;
uic=[];
while A~=0
    h = fseek(file, A, 'bof');
    if h == 0
        NumFrames = NumFrames+1;
    else
        break;
    end
    %number of directory entries
    B = fread(file, 1, 'uint16');
    h = fseek(file, A + 2 + B * 12, 'bof');
    if h==0
        A = fread (file, 1, 'uint32');
    else
        A = 0;
    end
end
A=A_start;
TiffInfo = struct('ImageWidth',cell(1,NumFrames),'ImageLength',cell(1,NumFrames),'BitsPerSample',cell(1,NumFrames),...
                  'StripOffsets',cell(1,NumFrames),'RowsPerStrip',cell(1,NumFrames),'StripByteCounts',cell(1,NumFrames));              
for N=1:NumFrames
    fseek(file, A, 'bof');
    %number of directory entries
    B = fread(file, 1, 'uint16');
    %search tags
    for b = 0:B-1
        fseek(file, A + 2 + b * 12, 'bof');
        tag = fread(file, 1, 'uint16'); %read tag
        type = DefineType(fread(file, 1, 'uint16')); %read and define type
        count = fread(file, 1, 'uint32'); %read count
        switch tag
            case 256 %hex 100
                TiffInfo(N).ImageWidth = fread(file, 1, type); %read Value
            case 257 %hex 101
                TiffInfo(N).ImageLength = fread(file, 1, type); %read Value
            case 258 %hex 102
                TiffInfo(N).BitsPerSample = fread(file, 1, type); %read Value
            case 273 %hex 111
                if count==1
                    TiffInfo(N).StripOffsets = fread(file, 1, type); %read Value
                else
                    offset = fread(file, 1, 'uint32'); %read Offset
                    fseek(file, offset, 'bof');
                    TiffInfo(N).StripOffsets = fread(file, count, type); %read Values
                end
            case 278 %hex 116
                TiffInfo(N).RowsPerStrip = fread(file, 1, type); %read Value
            case 279 %hex 117
                if count==1
                    TiffInfo(N).StripByteCounts = fread(file, 1, type); %read Value
                else
                    offset = fread(file, 1, 'uint32'); %read Offset
                    fseek(file, offset, 'bof');
                    TiffInfo(N).StripByteCounts = fread(file, count, type); %read Values
                end
            %end for TIFF files
            
            %read private tags - MetaMorph UIC tags
            case 33628 %hex 835C - UIC1 tag
                uic(1).count=count; %store count
                uic(1).type=type; %store type
                uic(1).offset=fread(file, 1, 'uint32'); %read & store offset
            case 33629 %hex 835D - UIC2 tag
                uic(2).count=count; %store count
                uic(2).type=type; %store type
                uic(2).offset=fread(file, 1, 'uint32'); %read & store offset
        end
    end
    fseek(file, A + 2 + B * 12, 'bof');
    A = fread (file, 1, 'uint32');
end
PixelSize = [];
if ~isempty(uic) %if file is MetaMorph stack
    MetaInfo=ReadUIC(file,uic);
    if isfield(MetaInfo,'CreationTime')
        N = length(MetaInfo.CreationTime);
    else
        N = 1;
    end
    stripsPerImage = length(TiffInfo.StripOffsets);
    planeOffset = (0:N-1) * (TiffInfo.StripOffsets(stripsPerImage) +...
                             TiffInfo.StripByteCounts(stripsPerImage) - ...
                             TiffInfo.StripOffsets(1)) + TiffInfo.StripOffsets(1);
    ImageWidth = ones(1,N)*TiffInfo.ImageWidth;
    ImageLength = ones(1,N)*TiffInfo.ImageLength;
    BitsPerSample = ones(1,N)*TiffInfo.BitsPerSample;    
else %if file is multilayer TIFF
    planeOffset = [TiffInfo.StripOffsets];
    ImageWidth = [TiffInfo.ImageWidth];
    ImageLength = [TiffInfo.ImageLength];
    BitsPerSample = [TiffInfo.BitsPerSample];
    MetaInfo.CreationTime=zeros(1,N);
    tiffinfo=imfinfo(source);
    if isfield(tiffinfo,'DateTime')
        starthour=str2double(tiffinfo(1).DateTime(10:11));
        for i=1:N
            milisecl=21-length(tiffinfo(i).DateTime);
            milisec=str2double(tiffinfo(i).DateTime(19:end))*10^milisecl;
            hours=(str2double(tiffinfo(i).DateTime(10:11))-starthour);
            if hours<0
                hours=hours+25;
            end
            MetaInfo.CreationTime(i)=hours*3600000+str2double(tiffinfo(i).DateTime(13:14))*60000+str2double(tiffinfo(i).DateTime(16:17))*1000+milisec;
        end
    elseif any([tiffinfo(1).UnknownTags.ID]==51123)
        % Micromanager specific Metadata are stored in Tiff-Tag 51123
        % Timestamp from Camera (only new ones, more precise) 
        % or MM timestamp (less precise, necessary for old cameras)
        for i=1:N
            k = find([tiffinfo(i).UnknownTags.ID]==51123);
            jinfo = jsondecode(tiffinfo(i).UnknownTags(k).Value);
            try
                % In case of hardware timestamp form iXon Ultras,
                % use the HW timestamp due to higher precision
                % MM2.0gamma: jinfo.UserData.Andor_ElapsedTime_ms_HW_.scalar
                time = str2num(jinfo.UserData.Andor_ElapsedTime_ms_HW_.scalar);
            catch
                % in case no HW timestamp is existing
                % use software timestamp from MM
                time = jinfo.ElapsedTime_ms;
            end
            MetaInfo.CreationTime(i) = time;
        end
        PixelSize = jinfo.PixelSizeUm*1000;
    else
        reader = bfGetReader(source);
        meta = reader.getGlobalMetadata();
        metaInfo = char(meta.toString());
        k = strfind(metaInfo,'timestamp'); % nd2 to tif files in FIJI
        if ~isempty(k)
            for n = 1:length(k)
                str = strtok(metaInfo(k(n):end),',');
                str(1:11) = [];
                [idx,t] = strtok(str,'=');
                MetaInfo.CreationTime(str2double(idx)) = str2double(t(2:end))*1000;
            end
            k = strfind(metaInfo,'dCalibration=');
            if ~isempty(k)
                str = strtok(metaInfo(k(1):end),',');
                [~,r] = strtok(str,'=');
                PixelSize = str2double(r(2:end))*1000;
            end
        else
            k = strfind(metaInfo,'Timestamp'); % zvi to tif files  in FIJI?
            if ~isempty(k)
                for n = 1:length(k)
                    str = strtok(metaInfo(k(n):end),',');
                    str(1:10) = [];
                    [idx,t] = strtok(str,'=');
                    [~,~,D,H,MN,S] = datevec(typecast(int64(str2double(t(2:end))),'double'));
                    MetaInfo.CreationTime(str2double(idx)) = (((D*24 + H)*60 + MN)*60 + S)*1000;
                end
                k = strfind(metaInfo,'Scale Factor for X=');
                str = strtok(metaInfo(k(1):end),',');
                [~,r] = strtok(str,'=');
                PixelSize = str2double(r(2:end))*1000;
            end
        end
    end
end

x = max(ImageWidth);
y = max(ImageLength);
if max(BitsPerSample)==8
    datatype = 'uint8';
else
    datatype = 'uint16';
end
progressdlg(0,'Reading Stack...');          
if isempty(options)
    nChannels = 1;
    Region{1} = [1 1 x y];
    Block = 1;
else
    Region = options.Region;
    Block = options.Block;
    nChannels = max([numel(Region) numel(Block)]);
    if isempty(Region)
        Region{1} = [1 1 x y];
    else
        r = cell2mat(Region);
        xblock = min(r(:,1))*x;
        yblock = min(r(:,2))*y;
        for n = 1:nChannels
            Region{n} = [x*Region{n}(1)-xblock+1 y*Region{n}(2)-yblock+1 x*Region{n}(1) y*Region{n}(2)];
        end
    end
    if Block(end) == Inf
       Block(end) = N-sum(Block(1:end-1)); 
    end
end
idxStack = zeros(1,length(Block));
NperChannel = fix(N/sum(Block)).*(Block);
if numel(NperChannel)<nChannels
    NperChannel = NperChannel*ones(1,nChannels);
else
    N = sum(NperChannel);
end
sBlock = sum(Block);
cBlock = [0 cumsum(Block(1:end-1))]; 
TimeInfo = cell(1,nChannels);
Stack = cell(1,nChannels);   
for n = 1:nChannels
    if length(Region)>1
        y = Region{n}(4)-Region{n}(2)+1;
        x = Region{n}(3)-Region{n}(1)+1;
    end
    Stack{n} = zeros(y,x,NperChannel(n),datatype);
end
for n = 1:N
    x = ImageWidth(1,n);
    y = ImageLength(1,n);
    if BitsPerSample(1,n) == 8
        type = '*uint8';
    elseif BitsPerSample(1,n) == 16
        type = '*uint16';
    else
        fclose(file);
        error('Only 8bit or 16bit Stacks supported');
    end            
    fseek(file, planeOffset(1,n), 'bof');
    try
        Img = reshape(fread(file,x*y,type),x,y)';
        if numel(idxStack)>1
            r = n - fix((n-1)/sBlock)*sBlock;
            idx = sum(r>cBlock);
            if isempty(idx)
                idx = nChannels;
            end
            idxStack(idx) = idxStack(idx)+1;
            frame = idxStack(idx);
        else
            idx = 1:nChannels;
            frame = n;
        end
        for m = 1:numel(Region)
            Image = Img(Region{m}(2):Region{m}(4),Region{m}(1):Region{m}(3));
            Stack{idx(m)}(:,:,frame) = Image;   
            TimeInfo{idx(m)}(frame) = MetaInfo.CreationTime(n);
        end 
    catch   
        progressdlg(1);      
        warning('MATLAB:outOfMemory','Out of memory - read %4.0f of %4.0f frames',n-1,N);
        break
    end
    progressdlg(n/N*100);
end
fclose(file);

function type=DefineType(num)
switch (num)
    case 1
        type='uint8';
    case 2
        type='char';
    case 3
        type='uint16';
    case 4
        type='uint32';
    case 5
        type='rational';       
    case 6
        type='int8';
    case 8
        type='int16';
    case 9
        type='int32';
    case 10
        type='srational';  
    case 11
        type='float32';
    case 12
        type='double';
end

function MetaInfo=ReadUIC(file,uic)

if length(uic)>1
    %read UIC2
    fseek(file, uic(2).offset, 'bof'); %set uic2 offset
    for n = 1:uic(2).count
        nom = fread(file, 1, 'uint32'); %read nominator
        denom = fread(file, 1, 'uint32'); %read denominator 
        MetaInfo.ZDistance(n) = nom/denom;
        MetaInfo.CreationDate{n} = fread(file, 1, 'uint32');
        MetaInfo.CreationTime(n) = fread(file, 1, 'uint32');
        MetaInfo.ModificationDate(n) = fread(file, 1, 'uint32');
        MetaInfo.ModificationTime(n) = fread(file, 1, 'uint32');
    end
end
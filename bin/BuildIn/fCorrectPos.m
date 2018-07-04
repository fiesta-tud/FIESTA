function Object=fCorrectPos(Object,Drift,Value)
if ~isempty(Drift) && Value ~= Object.Drift
    f = Object.Results(:,1);
    f(f>size(Drift,3)) = size(Drift,3);
    T = Drift(:,:,f);
    if Value == 0
        Det = T(1,1,:).*T(2,2,:) - T(1,2,:) .* T(2,1,:);
        hT = zeros(size(T));
        hT(1,1,:) = T(2,2,:) ./ Det;
        hT(1,2,:) = -T(1,2,:) ./ Det;
        hT(2,1,:) = -T(2,1,:) ./ Det;
        hT(2,2,:) = T(1,1,:) ./ Det;
        hT(3,1,:) = (T(2,1,:).*T(3,2,:)-T(3,1,:).*T(2,2,:)) ./ Det;
        hT(3,2,:) = (T(1,2,:).*T(3,1,:)-T(3,2,:).*T(2,2,:)) ./ Det;
        T = hT;
    end
    Object.Results(:,3:4) = transformPos(T,Object.Results(:,3:4)/Object.PixelSize)*Object.PixelSize;
    if isfield(Object,'PosCenter')
        Object.PosStart(:,1:2) = transformPos(T,Object.PosStart(:,1:2)/Object.PixelSize)*Object.PixelSize;
        Object.PosCenter(:,1:2) = transformPos(T,Object.PosCenter(:,1:2)/Object.PixelSize)*Object.PixelSize;
        Object.PosEnd(:,1:2) = transformPos(T,Object.PosEnd(:,1:2)/Object.PixelSize)*Object.PixelSize;   
        for n = 1:length(Object.Data)
            Object.Data{n}(:,1:2) = transformPos(T(:,:,n),Object.Data{n}(:,1:2)/Object.PixelSize)*Object.PixelSize;    
        end   
    end
    Object.Results(:,6)=fDis(Object.Results(:,3:5));
    Object.Drift=Value;
end

function NXY = transformPos(T,XY)
NXY = zeros(size(XY));
NXY(:,1) = XY(:,1) .* squeeze(T(1,1,:)) + XY(:,2) .* squeeze(T(2,1,:)) + squeeze(T(3,1,:));
NXY(:,2) = XY(:,1) .* squeeze(T(1,2,:)) + XY(:,2) .* squeeze(T(2,2,:)) + squeeze(T(3,2,:));


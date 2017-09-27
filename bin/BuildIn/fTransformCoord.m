function Object = fTransformCoord(Object,mode,filament)
nObj = length(Object);
for n = 1:nObj
    T = Object(n).TformMat;
    if Object(n).Channel>1 && mode~=T(3,3)
        T(:,3) = [0;0;1];
        if mode
            [X,Y] = transformPointsInverse(affine2d(T),double(Object(n).Results(:,3))/Object(n).PixelSize,double(Object(n).Results(:,4))/Object(n).PixelSize);
            if filament
                for m = 1:length(Object(n).Data)
                    [DX,DY] = transformPointsInverse(affine2d(T),double(Object(n).Data{m}(:,1))/Object(n).PixelSize,double(Object(n).Data{m}(:,2))/Object(n).PixelSize);
                    Object(n).Data{m}(:,1:2) = single([DX DY]*Object(n).PixelSize);
                end
                [PX,PY] = transformPointsInverse(affine2d(T),double(Object(n).PosStart(:,1))/Object(n).PixelSize,double(Object(n).PosStart(:,2))/Object(n).PixelSize);
                Object(n).PosStart(:,1:2) = single([PX PY]*Object(n).PixelSize);
                [PX,PY] = transformPointsInverse(affine2d(T),double(Object(n).PosCenter(:,1))/Object(n).PixelSize,double(Object(n).PosCenter(:,2))/Object(n).PixelSize);
                Object(n).PosCenter(:,1:2) = single([PX PY]*Object(n).PixelSize);
                [PX,PY] = transformPointsInverse(affine2d(T),double(Object(n).PosEnd(:,1))/Object(n).PixelSize,double(Object(n).PosEnd(:,2))/Object(n).PixelSize);
                Object(n).PosEnd(:,1:2) = single([PX PY]*Object(n).PixelSize);
            end
        else
            [X,Y] = transformPointsForward(affine2d(T),double(Object(n).Results(:,3))/Object(n).PixelSize,double(Object(n).Results(:,4))/Object(n).PixelSize);
            if filament
                for m = 1:length(Object(n).Data)
                    [DX,DY] = transformPointsForward(affine2d(T),double(Object(n).Data{m}(:,1))/Object(n).PixelSize,double(Object(n).Data{m}(:,2))/Object(n).PixelSize);
                    Object(n).Data{m}(:,1:2) = single([DX DY]*Object(n).PixelSize); 
                end
                [PX,PY] = transformPointsForward(affine2d(T),double(Object(n).PosStart(:,1))/Object(n).PixelSize,double(Object(n).PosStart(:,2))/Object(n).PixelSize);
                Object(n).PosStart(:,1:2) = single([PX PY]*Object(n).PixelSize);
                [PX,PY] = transformPointsForward(affine2d(T),double(Object(n).PosCenter(:,1))/Object(n).PixelSize,double(Object(n).PosCenter(:,2))/Object(n).PixelSize);
                Object(n).PosCenter(:,1:2) = single([PX PY]*Object(n).PixelSize);
                [PX,PY] = transformPointsForward(affine2d(T),double(Object(n).PosEnd(:,1))/Object(n).PixelSize,double(Object(n).PosEnd(:,2))/Object(n).PixelSize);
                Object(n).PosEnd(:,1:2) = single([PX PY]*Object(n).PixelSize);
            end
        end
        Object(n).Results(:,3:4) = single([X Y]*Object(n).PixelSize);
        Object(n).TformMat(3,3) = mode;
    end
end
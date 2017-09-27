function NI = quickwarp(I,T,invT)
[y,x] = size(I); 
X = repmat(1:x,y,1);
Y = repmat(1:y,1,x);
if invT
    T = [ T(1,1) -T(1,2) 0; -T(2,1) T(2,2) 0; -T(3,1)*T(1,1)-T(3,2)*T(1,2) -T(3,2)*T(1,1)+T(3,1)*T(1,2) 1];
end
NX = round(X(:) * T(1,1) + Y(:) * T(2,1) + T(3,1));
NY = round(X(:) * T(1,2) + Y(:) * T(2,2) + T(3,2));
k = NX<1 | NX>x | NY<1 | NY>y;
NX(k) = [];
NY(k) = [];
X(k) = [];
Y(k) = [];
idx = Y(:) + (X(:) - 1).*y;
tidx = NY + (NX - 1).*y;
NI = zeros(y,x);
NI(tidx) = I(idx);





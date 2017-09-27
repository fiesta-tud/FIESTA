function [tidx,idx] = getwarp(T,x,y)
X = repmat(1:x,y,1);
Y = repmat(1:y,1,x);
NX = round(X(:) * T(1,1) + Y(:) * T(2,1) + T(3,1));
NY = round(X(:) * T(1,2) + Y(:) * T(2,2) + T(3,2));
k = NX<1 | NX>x | NY<1 | NY>y;
NX(k) = [];
NY(k) = [];
X(k) = [];
Y(k) = [];
idx = Y + (X - 1).*y;
tidx = NY + (NX - 1).*y;





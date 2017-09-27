function intersect = rectintersect(A,B)
intersect = 0;
%X greater
if A(1)>B(3) && A(3)>B(3)
    return;
end
%X smaller
if A(1)<B(1) && A(3)<B(1)
    return;
end
%Y greater
if A(2)>B(4) && A(4)>B(4)
    return;
end
%Y smaller
if A(2)<B(2) && A(4)<B(2)
    return;
end
intersect=1;
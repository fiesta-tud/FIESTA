function Objects = fConvertObjects(Objects)
sObjects = length(Objects);
s = zeros(1,sObjects);
for n = 1:sObjects
   s(n) = length(Objects{n});
end
if all(s==1)
    if length(Objects{1}(1).com_x)==1
        s = Inf;
    end
end
if any(s>1) 
    for n = 1:sObjects
        Obj = Objects{n};
        NewObj.time = single( Obj(1).time );
        sObj = length(Obj);
        NewObj.center_x = single(zeros(1,sObj));
        NewObj.center_y = single(zeros(1,sObj));
        NewObj.com_x = single(zeros(2,sObj));
        NewObj.com_y = single(zeros(2,sObj));
        NewObj.orientation = single(zeros(2,sObj));
        NewObj.length = single(zeros(2,sObj));
        NewObj.width = single(zeros(2,sObj));
        NewObj.height = single(zeros(2,sObj));        
        NewObj.background = single(zeros(2,sObj));        
        NewObj.data = cell(1,sObj);        
        for m = 1:sObj
            if isstruct(Obj(m).center_x)
                NewObj.center_x(m) = single(Obj(m).center_x.value);
            else
                NewObj.center_x(m) = single(double(Obj(m).center_x));
            end
            if isstruct(Obj(m).center_y)
                NewObj.center_y(:,m) = single(Obj(m).center_y.value);
            else
                NewObj.center_y(:,m) = single(double(Obj(m).center_y));
            end
            NewObj.com_x(:,m) = single([Obj(m).com_x.value; Obj(m).com_x.error]);
            NewObj.com_y(:,m) = single([Obj(m).com_y.value; Obj(m).com_y.error]);
            %angle of stretched gaussian will be orientation
            nHeight = length(Obj(m).height);
            if length(Obj(m).width)==3 && nHeight==1
                NewObj.orientation(:,m) = single([Obj(m).width(3).value; Obj(m).width(3).error]);
            elseif Obj(m).length.value>0
                NewObj.orientation(:,m) = single([Obj(m).orientation.value; Obj(m).orientation.error]);
            end
            NewObj.length(:,m) = single([Obj(m).length.value; Obj(m).length.error]);
            if length(Obj(m).width)==3 && nHeight==1
                NewObj.width(:,m) = single([mean([Obj(m).width(1:2).value]); mean([Obj(m).width(1:2).error])]);
            else
                NewObj.width(:,m) = single([Obj(m).width(1).value Obj(m).width(1).error]);
            end
            NewObj.height(:,m) = single([Obj(m).height(1).value Obj(m).height(1).error]);
            NewObj.background(:,m) = single([mean([Obj(m).data.b]) 0]);
            if length(Obj(m).width)==1 && nHeight==1 && Obj(m).length.value==0
                %symmetric gauss
                NewObj.data{m} = [];
            elseif length(Obj(m).width)==3 && nHeight==1
                %stretched gauss
                NewObj.data{m} = single([Obj(m).width(1).value; Obj(m).width(2).value]);
            elseif length(Obj(m).width)>1 && nHeight>1
                %symmetric gauss with rings
                h = single([[Obj(m).width.value]' [Obj(m).height.value]' [Obj(m).radius.value]']);
                h(1,:) = [];
                NewObj.data{m} = h;
            else
                %filaments
                NewObj.data{m} = single([[Obj(m).data.x]' [Obj(m).data.y]' [Obj(m).data.l]' [Obj(m).data.w]' [Obj(m).data.h]' [Obj(m).data.b]']);
            end
        end          
        Objects{n}=NewObj;
    end
end
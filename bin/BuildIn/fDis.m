function dis = fDis(data)
if any(isnan(data(:,3)))
    dis = sqrt( (data(:,1)-data(1,1)).^2 + (data(:,2)-data(1,2)).^2 );
else
    dis = sqrt( (data(:,1)-data(1,1)).^2 + (data(:,2)-data(1,2)).^2 + (data(:,3)-data(1,3)).^2);
end
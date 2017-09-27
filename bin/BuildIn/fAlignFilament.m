function Filament = fAlignFilament(Filament,Config)
refPoint = fGetRefPoint(Filament);
dis = norm([Filament.Results(1,3)-Filament.Results(end,3) Filament.Results(1,4)-Filament.Results(end,4)]);  
if dis > 2*Filament.PixelSize
    d_start = sqrt( (Filament.Data{1}(1,1) - Filament.Results(2:end,3)).^2 + (Filament.Data{1}(1,2) - Filament.Results(2:end,4)).^2 );
    d_end = sqrt( (Filament.Data{1}(end,1) - Filament.Results(2:end,3)).^2 + (Filament.Data{1}(end,2) - Filament.Results(2:end,4)).^2 );

    s_start = double(d_start < d_end);
    s_end = double(d_start > d_end);

    weights = (1./(1:length(d_start)).^2)';
    weights = weights / sum(weights);

    if sum(weights.*s_start) < sum(weights.*s_end)
        Filament.Data{1} = flipud(Filament.Data{1});
    end
end

for n = 1:size(Filament.Results,1)
    if n>1
        x_c = Filament.PosCenter(n,1)-Filament.PosCenter(n-1,1);
        y_c = Filament.PosCenter(n,2)-Filament.PosCenter(n-1,2);
        d_ss = sqrt( (Filament.Data{n}(1,1)-Filament.Data{n-1}(1,1)-x_c)^2 + (Filament.Data{n}(1,2)-Filament.Data{n-1}(1,2)-y_c)^2);
        d_se = sqrt( (Filament.Data{n}(end,1)-Filament.Data{n-1}(1,1)-x_c)^2 + (Filament.Data{n}(end,2)-Filament.Data{n-1}(1,2)-y_c)^2);
        d_es = sqrt( (Filament.Data{n}(1,1)-Filament.Data{n-1}(end,1)-x_c)^2 + (Filament.Data{n}(1,2)-Filament.Data{n-1}(end,2)-y_c)^2);
        d_ee = sqrt( (Filament.Data{n}(end,1)-Filament.Data{n-1}(end,1)-x_c)^2 + (Filament.Data{n}(end,2)-Filament.Data{n-1}(end,2)-y_c)^2);
     
        if d_ss>d_se && d_ee>d_es
           Filament.Data{n} = flipud(Filament.Data{n}); 
        end
    end
    Filament.PosStart(n,1:3)=Filament.Data{n}(1,1:3);
    Filament.PosEnd(n,1:3)=Filament.Data{n}(end,1:3);
end
if isempty(Config)
    if refPoint == 1
        Filament.Results(:,3:5) = Filament.PosStart;
    elseif refPoint == 2
        Filament.Results(:,3:5) = Filament.PosCenter;
    else
        Filament.Results(:,3:5) = Filament.PosEnd;
    end
else
    if strcmp(Config.RefPoint,'center')==1
        Filament.Results(:,3:5) = Filament.PosCenter;
    elseif strcmp(Config.RefPoint,'start')==1
        Filament.Results(:,3:5) = Filament.PosStart;
    else
        Filament.Results(:,3:5) = Filament.PosEnd;
    end
end

Filament.Results(:,6) = fDis( Filament.Results(:,3:5) );
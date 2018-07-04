function data = fEvaluateTracks( Molecule, f_min ) 
hMainGui = getappdata(0,'hMainGui');
p = 1;
Tres = [];
for n = 1:length(Molecule)
    F = double(Molecule(n).Results(:,1)); 
    T = double(Molecule(n).Results(:,2)); 
    Tres = [Tres; (T(2:end)-T(1:end-1))./(F(2:end)-F(1:end-1)) ];
end
time_res = mean (Tres);
progressdlg('String','Analyzing tracks','Min',0,'Max',length(Molecule),'Parent',hMainGui.fig);
for n = 1:length(Molecule)
    F = double(Molecule(n).Results(:,1)); 
    T = double(Molecule(n).Results(:,2)); 
    if isempty(Molecule(n).PathData)
        if size(Molecule(n).Results,2)==8
            D = double(Molecule(n).Results(:,5)); 
        else
            D = double(Molecule(n).Results(:,6)); 
        end
        detach = Inf;
    else
        if size(Molecule(n).PathData,2)==4
            D = real(double(Molecule(n).PathData(:,3))); 
            detach = imag(double(Molecule(n).PathData(end,3)));
        else
            D = real(double(Molecule(n).PathData(:,4))); 
            detach = imag(double(Molecule(n).PathData(end,4)));
        end
        if detach == 0 
            detach = Inf;
        end
    end
    if D(end)-D(1)>0.5*Molecule(n).PixelSize
        try
            b = fRobustfit(T(2:end-1),D(2:end-1));
            data(p,1) = F(end)-F(1)+1; % number of frames visible
            data(p,2) = data(p,1)*time_res; % interaction time
            data(p,3) = D(end)-D(1); % run length
            data(p,4) = detach; % end-events censoring
            data(p,5) = b(2); % velocity
            p=p+1;
        catch  
            if nargin == 0
                f_min = max([f_min F(end)-F(1)+2]);
            end
        end
    end
    progressdlg(n);
end
progressdlg('close');
k = data(:,1)<f_min;
data(k,:) = [];
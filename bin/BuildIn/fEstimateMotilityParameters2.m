function results = fEstimateMotilityParameters2(vel,itime,runlen,censor,bleach,mode,n,x0,hFig)
% initialize random generator for bootstrapping
rng('shuffle');
global Config;
global FiestaDir;

% define pdfs and cdfs
Exp2Pdf = @(k_off1,k_off2,w,x,x0) (w*k_off1*exp(-k_off1*x)+(1-w)*k_off2*exp(-k_off2*x)) ./ (-exp(-k_off2*x0)*(w - 1) + w*exp(-k_off1*x0));
Exp2Cdf =  @(k_off1,k_off2,w,x,x0)-(w.*exp(-k_off1.*x+k_off1.*x0+k_off2.*x0)+exp(-k_off2.*x).*(exp(k_off1.*x0+k_off2.*x0)-w.*exp(k_off1.*x0+k_off2.*x0)))./(exp(k_off1.*x0)-w.*exp(k_off1.*x0)+w.*exp(k_off2.*x0))+1.0;
Exp2MixPdf = @(k_bleach,k_off1,k_off2,rho,w,x,x0) (w*(exp(-x*(2*k_bleach + k_off1))*(2*k_bleach + k_off1)*(rho - 1) - exp(-x*(k_bleach + k_off1))*(k_bleach + k_off1)*(rho - 2)) - (exp(-x*(2*k_bleach + k_off2))*(2*k_bleach + k_off2)*(rho - 1) - exp(-x*(k_bleach + k_off2))*(k_bleach + k_off2)*(rho - 2))*(w - 1)) ./ -(exp(- 2*k_bleach*x0 - k_off2*x0)*(rho - 1)*(w - 1) - exp(- k_bleach*x0 - k_off2*x0)*(rho - 2)*(w - 1) + w*exp(- k_bleach*x0 - k_off1*x0)*(rho - 2) - w*exp(- 2*k_bleach*x0 - k_off1*x0)*(rho - 1));
Exp2MixCdf =  @(k_bleach,k_off1,k_off2,rho,w,x,x0)-(w.*exp(-k_bleach.*x+k_bleach.*x0.*6.0-k_off1.*x+k_off1.*x0.*2.0+k_off2.*x0.*2.0).*(rho-2.0)-w.*exp(k_bleach.*x.*-2.0+k_bleach.*x0.*6.0-k_off1.*x+k_off1.*x0.*2.0+k_off2.*x0.*2.0).*(rho-1.0))./(exp(k_bleach.*x0.*4.0+k_off1.*x0.*2.0+k_off2.*x0)-exp(k_bleach.*x0.*5.0+k_off1.*x0.*2.0+k_off2.*x0).*2.0-rho.*exp(k_bleach.*x0.*4.0+k_off1.*x0.*2.0+k_off2.*x0)+rho.*exp(k_bleach.*x0.*5.0+k_off1.*x0.*2.0+k_off2.*x0)+w.*exp(k_bleach.*x0.*4.0+k_off1.*x0+k_off2.*x0.*2.0)-w.*exp(k_bleach.*x0.*4.0+k_off1.*x0.*2.0+k_off2.*x0)-w.*exp(k_bleach.*x0.*5.0+k_off1.*x0+k_off2.*x0.*2.0).*2.0+w.*exp(k_bleach.*x0.*5.0+k_off1.*x0.*2.0+k_off2.*x0).*2.0-rho.*w.*exp(k_bleach.*x0.*4.0+k_off1.*x0+k_off2.*x0.*2.0)+rho.*w.*exp(k_bleach.*x0.*4.0+k_off1.*x0.*2.0+k_off2.*x0)+rho.*w.*exp(k_bleach.*x0.*5.0+k_off1.*x0+k_off2.*x0.*2.0)-rho.*w.*exp(k_bleach.*x0.*5.0+k_off1.*x0.*2.0+k_off2.*x0))-(exp(k_bleach.*x.*-2.0-k_off2.*x).*(exp(k_bleach.*x0.*6.0+k_off1.*x0.*2.0+k_off2.*x0.*2.0)-rho.*exp(k_bleach.*x0.*6.0+k_off1.*x0.*2.0+k_off2.*x0.*2.0)-w.*exp(k_bleach.*x0.*6.0+k_off1.*x0.*2.0+k_off2.*x0.*2.0)+rho.*w.*exp(k_bleach.*x0.*6.0+k_off1.*x0.*2.0+k_off2.*x0.*2.0))-exp(-k_bleach.*x-k_off2.*x).*(exp(k_bleach.*x0.*6.0+k_off1.*x0.*2.0+k_off2.*x0.*2.0).*2.0-rho.*exp(k_bleach.*x0.*6.0+k_off1.*x0.*2.0+k_off2.*x0.*2.0)-w.*exp(k_bleach.*x0.*6.0+k_off1.*x0.*2.0+k_off2.*x0.*2.0).*2.0+rho.*w.*exp(k_bleach.*x0.*6.0+k_off1.*x0.*2.0+k_off2.*x0.*2.0)))./(exp(k_bleach.*x0.*4.0+k_off1.*x0.*2.0+k_off2.*x0)-exp(k_bleach.*x0.*5.0+k_off1.*x0.*2.0+k_off2.*x0).*2.0-rho.*exp(k_bleach.*x0.*4.0+k_off1.*x0.*2.0+k_off2.*x0)+rho.*exp(k_bleach.*x0.*5.0+k_off1.*x0.*2.0+k_off2.*x0)+w.*exp(k_bleach.*x0.*4.0+k_off1.*x0+k_off2.*x0.*2.0)-w.*exp(k_bleach.*x0.*4.0+k_off1.*x0.*2.0+k_off2.*x0)-w.*exp(k_bleach.*x0.*5.0+k_off1.*x0+k_off2.*x0.*2.0).*2.0+w.*exp(k_bleach.*x0.*5.0+k_off1.*x0.*2.0+k_off2.*x0).*2.0-rho.*w.*exp(k_bleach.*x0.*4.0+k_off1.*x0+k_off2.*x0.*2.0)+rho.*w.*exp(k_bleach.*x0.*4.0+k_off1.*x0.*2.0+k_off2.*x0)+rho.*w.*exp(k_bleach.*x0.*5.0+k_off1.*x0+k_off2.*x0.*2.0)-rho.*w.*exp(k_bleach.*x0.*5.0+k_off1.*x0.*2.0+k_off2.*x0))+1.0;
BleachMixPdf = @(k_bleach,rho,x,x0) ((2-rho)*k_bleach*exp(-k_bleach*x) + 2*(rho-1)*k_bleach*exp(-2*k_bleach*x))./(exp(-k_bleach*x0)*(2 - rho) - exp(-2*k_bleach*x0)*(1 - rho));
BleachMixCdf = @(k_bleach,rho,x,x0) (exp(-k_bleach.*x+k_bleach.*x0.*2.0).*(rho-2.0)-exp(k_bleach.*x.*-2.0+k_bleach.*x0.*2.0).*(rho-1.0))./(rho+exp(k_bleach.*x0).*2.0-rho.*exp(k_bleach.*x0)-1.0)+1.0;

% check if censoring for end-events is necessary
if isempty(censor)
   censor = zeros(size(vel)); 
end

% check if bleaching analysis is necessary
if isempty(bleach)
   bleach = [-1;-2];
end

% calculate cutoff for fitting in 'mle' (not used in 'lsf' because cutoff 
%is always fitted in LSF-CDF(free)
if isnan(x0(1))
    res = sort(unique(itime));
    itime_x0 = res(1) - (res(2)-res(1))/2;
else
    itime_x0 = x0(1);
end
if isnan(x0(2))
    res = sort(unique(runlen));
    runlen_x0 = res(1) - (res(2)-res(1))/2;
else
    runlen_x0 = x0(2);
end
if size(bleach,1)>2
    if isnan(x0(3))
        res = sort(unique(max(bleach,[],2)));
        bleach_x0 = res(1) - (res(2)-res(1))/2;
        if size(bleach,2)>1
            b1 = bleach(:,1);
            b2 = bleach(:,2);
            res = sort(unique([b1; b2(b2>0)]));
            bleach_x0(2) = res(1) - (res(2)-res(1))/2;
        end
    else
        bleach_x0(1) = x0(3);
        bleach_x0(2) = x0(3);
    end
else
    bleach_x0(1) = 0;
    bleach_x0(2) = 0;
end

% set options for 'mle' in order to avoid errors due to wrong evaluation of pdf
opt = statset('mlecustom');
opt.FunValCheck = 'off';
warning('off','stats:mle:IterLimit');

% set number of iterations for bootstrapping
if isempty(n) || n<10
    n = 10;
end

% prepare displaying data and results of the fitting
x_vel = 0:2*median(vel)/1000:2*median(vel);
velmat = zeros(n,length(x_vel));
tlsmat = zeros(n,length(x_vel));
x_bleach = 0:4*median(bleach)/1000:4*median(max(bleach,[],2));
bleach_cdf = zeros(n,length(x_bleach));
bleach_fitcdf = zeros(n,length(x_bleach));
x_itime = 0:5*median(itime)/1000:4*median(itime);
itime_cdf = zeros(n,length(x_itime));
itime_globalfit = zeros(n,length(x_itime));
itime_censoredcdf = zeros(n,length(x_itime));
itime_censoredfit = zeros(n,length(x_itime));
x_runlen = 0:5*median(runlen)/1000:4*median(runlen);
runlen_censoredcdf = zeros(n,length(x_runlen));
runlen_censoredfit = zeros(n,length(x_runlen));

% set mode for estimation of the motility paramters
if strcmp(mode(1:2),'ls')
    lsf = 1;
    if mode(3) == 'w'
        weighted = 1;
    else
        weighted = 0;
    end
else
    lsf = 0;
    weighted = 0;
end

% initialize vectors for bootstrapping
v = zeros(1,n); % velocity
R1 = zeros(1,n); % runlength
R2 = zeros(1,n); % runlength
wR = zeros(1,n);
tau1 = zeros(1,n); % interaction time
tau2 = zeros(1,n); % interaction time
wTau = zeros(1,n);
tau1_global = zeros(1,n); % interaction time (from global fit)
tau2_global = zeros(1,n); % interaction time (from global fit)
wTau_global = zeros(1,n);
t_bleach = zeros(1,n); % bleaching time
rho_bleach = zeros(1,n); % ratio of one and two fluorophore bleaching
num_bleach = zeros(1,n);
num_itime = zeros(1,n);
num_runlen = zeros(1,n);
hMainGui = getappdata(0,'hMainGui');
dirStatus = [FiestaDir.AppData 'fiestastatus' filesep];  
parallelprogressdlg('String','Estimating Motility Parameters','Max',n,'Parent',hMainGui.fig,'Directory',FiestaDir.AppData);

%start anaylsis with bootstrapping (with parallel distribution toolbos if available 
parfor (m=1:n,Config.NumCores)
%for m = 1:10
    % get random set of molecules for analysis (with replacement)
    pk = randi(length(vel),1,length(vel));
    
    % estimate velocity using TLS distribution
    resample = vel(pk);
    warning('off','stats:mlecov:NonPosDefHessian');
    warning('off','stats:tlsfit:IterLimit');
    
    w = mle(resample,'distribution','tlocationscale');
    v(m) = w(1);
    
    % prepare displaying of results
    [N,edges] = histcounts(resample,'BinMethod','scott','Normalization','pdf','BinLimits',[0 2*median(vel)]);
    xb = (edges(2:end)+edges(1:end-1))/2;
    velmat(m,:) = interp1(xb,N,x_vel);
    tlsmat(m,:) = pdf('tlocationscale',x_vel,w(1),w(2),w(3));
    
    pik = pk;
    pik(itime(pik)<itime_x0) = [];
    % get dataset for interaction time 
    resample = itime(pik);
    censoridx = censor(pik);
    num_itime(m) = length(pik);
    
    % check if bleaching analysis is necessary
    if numel(bleach)==2 && bleach(1,1) == -1
        
        % no censoring for bleaching
        bleachidx = zeros(size(censoridx));
    else
        
       if size(bleach,1)>1
            % get censoring for bleaching analysis
            % get random set of molecules for bleach analysis (with replacement)
            bk = randi(size(bleach,1),1,size(bleach,1));

            % esimtate the bleaching parameters using LSF-CDF(free) or MLE
            if lsf
                [rho,k_bleach,display_bleach_x0,nbleach]  = calcBleachLSF(bleach(bk,:),bleach_x0,weighted);
            else
                [rho,k_bleach,nbleach]  = calcBleachMLE(bleach(bk,:),bleach_x0);
                display_bleach_x0 = bleach_x0(1);
            end
            b = max(bleach(bk,:),[],2);
            b(b<bleach_x0(1)) = [];
            [cp,xb] = ecdf(b);
            xb=(xb(3:end)+xb(2:end-1))/2;
            cp=cp(2:end-1);
            bleach_cdf(m,:) = interp1(xb,cp,x_bleach);
        else
            k_bleach = 1/bleach(1);
            rho = bleach(2);
            nbleach = 0;
            display_bleach_x0 = bleach_x0(1);
        end
        t_bleach(m) = 1/k_bleach;
        rho_bleach(m) = rho; 
        num_bleach(m) = nbleach;

        % esimtate the interaction time using LSF-CDF(free) or MLE using the
        % estimated bleaching parameters (global fit)
        if lsf
            [k_off1,k_off2,w,display_itime_x0] = blexp2fit(resample,censoridx,k_bleach,rho,weighted);
        else
            res = mle(resample,'pdf',@(x,k_off1,k_off2,w)Exp2MixPdf(k_bleach,k_off1,k_off2,rho,w,x,itime_x0),'cdf',@(x,k_off1,k_off2,w)Exp2MixCdf(k_bleach,k_off1,k_off2,rho,w,x,itime_x0),'start',[1/(0.5*median(resample)) 1/(1.5*median(resample)) 0.5],'censoring',censoridx,'options',opt);
            k_off1 = res(1);
            k_off2 = res(2);
            w = res(3);    
            display_itime_x0 = itime_x0;
        end
        tau1_global(m) = 1/k_off1;
        tau2_global(m) = 1/k_off2;
        wTau_global(m) = w;

        if size(bleach,1)>1
            % prepare displaying of results
            bleach_fitcdf(m,:) = BleachMixCdf(k_bleach,rho,x_bleach,display_bleach_x0);
            [cp,xb] = ecdf(resample,'censoring',censoridx);
            xb=(xb(3:end)+xb(2:end-1))/2;
            cp=cp(2:end-1);
            itime_cdf(m,:) = interp1(xb,cp,x_itime);
            itime_globalfit(m,:) = Exp2MixCdf(k_bleach,k_off1,k_off2,rho,w,x_itime,display_itime_x0);
        end

        % calculate bleaching probability for each molecule and assign random
        % bleaching events
        Pbleach = 1/Exp2Pdf(k_off1,k_off2,w,itime_x0,itime_x0)*BleachMixPdf(k_bleach,rho,resample,itime_x0).*Exp2Pdf(k_off1,k_off2,w,resample,itime_x0)./Exp2MixPdf(k_bleach,k_off1,k_off2,rho,w,resample,itime_x0);
        p = rand(size(Pbleach));
        bleachidx = Pbleach>p;
    end

    % esimtate the interaction time using LSF-CDF(free) or MLE using the
    % estimated bleaching parameters with censored bleaching and end-events
    if lsf
        [k_off1,k_off2,w,display_itime_x0] = mexp2fit(resample,censoridx|bleachidx,weighted);
    else
        res = mle(resample,'pdf',@(x,k_off1,k_off2,w)Exp2Pdf(k_off1,k_off2,w,x,itime_x0),'cdf',@(x,k_off1,k_off2,w)Exp2Cdf(k_off1,k_off2,w,x,itime_x0),'start',[1/(0.5*median(resample)) 1/(1.5*median(resample)) 0.5],'censoring',censoridx|bleachidx,'options',opt);
        k_off1 = res(1);
        k_off2 = res(2);
        w = res(3);       
        display_itime_x0 = itime_x0;
    end
    tau1(m) = 1/k_off1;
    tau2(m) = 1/k_off2;
    wTau(m) = w;
    
    [cp,xb] = ecdf(resample,'censoring',censoridx|bleachidx);
    xb=(xb(3:end)+xb(2:end-1))/2;
    cp=cp(2:end-1);
    itime_censoredcdf(m,:) = interp1(xb,cp,x_itime);
    itime_censoredfit(m,:) = Exp2Cdf(k_off1,k_off2,w,x_itime,display_itime_x0);
    
    if all(bleachidx==0)
        resample = runlen(pk);
        censoridx = censor(pk);
        bleachidx = zeros(size(censoridx));
    else
        resample = runlen(pik);    
    end
    rk = resample<runlen_x0;
    resample(rk) = [];
    censoridx(rk) = [];
    bleachidx(rk) = [];
    num_runlen(m) = length(resample);
    
    % esimtate the run length using LSF-CDF(free) or MLE using the estimated 
    % bleaching parameters with censored bleaching and end-events
    if lsf
        [k_run1,k_run2,w,display_runlen_x0] = mexp2fit(resample,censoridx|bleachidx,weighted);
    else
        res = mle(resample,'pdf',@(x,k_run1,k_run2,w)Exp2Pdf(k_run1,k_run2,w,x,runlen_x0),'cdf',@(x,k_run1,k_run2,w)Exp2Cdf(k_run1,k_run2,w,x,runlen_x0),'start',[1/(0.5*median(resample)) 1/(1.5*median(resample)) 0.5],'censoring',censoridx|bleachidx,'options',opt);
        k_run1 = res(1);
        k_run2 = res(2);
        w = res(3);   
        display_runlen_x0 = runlen_x0;
    end
    R1(m) = 1/k_run1;
    R2(m) = 1/k_run2;
    wR(m) = w;

    % prepare displaying of results
    [cp,xb] = ecdf(resample,'censoring',censoridx|bleachidx);
    xb=(xb(3:end)+xb(2:end-1))/2;
    cp=cp(2:end-1);
    runlen_censoredcdf(m,:) = interp1(xb,cp,x_runlen);
    runlen_censoredfit(m,:) = Exp2Cdf(k_run1,k_run2,w,x_runlen,display_runlen_x0);
    fSave(dirStatus,m);
end
parallelprogressdlg('close');
% evaluate the bootstrapping distribution to get the motility parameters
% and their errors
velocity = [mean(v) 2*std(v) length(vel)];
bleach_time = [mean(t_bleach) 2*std(t_bleach) round(mean(num_bleach))];
bleach_rho = [mean(rho_bleach) 2*std(rho_bleach) round(mean(num_bleach))];
itime_global = [median(tau1_global) 2/1.35*iqr(tau1_global) round(mean(num_itime)); median(tau2_global) 2/1.35*iqr(tau2_global) 0];
itime_censored = [median(tau1) 2/1.35*iqr(tau1) round(mean(num_itime)); median(tau2) 2/1.35*iqr(tau2) 0];
runlength = [median(R1) 2/1.35*iqr(R1) round(mean(num_runlen)); median(R2) 2/1.35*iqr(R2) 0];
wratio = [median(wTau_global) 2/1.35*iqr(wTau_global); median(wTau) 2/1.35*iqr(wTau);median(wR) 2/1.35*iqr(wR)];

axes(hFig.aVelPlot);
cla(hFig.aVelPlot,'reset');
hold on
plot(x_vel,mean(velmat,1),'b-')
plot(x_vel,mean(velmat,1)+3*std(velmat,[],1),'b--')
plot(x_vel,mean(velmat,1)-3*std(velmat,[],1),'b--')
plot(x_vel,mean(tlsmat,1),'k-')
xlabel('velocity');
ylabel('probabilty density');
title(['velocity = ' val2str(velocity(1),velocity(2))]);
text('Units','normalized','HorizontalAlignment','right','Position',[0.9 0.9],'String',['N = ' num2str(length(vel))]);
xlim([0 2*median(vel)]);
ylim([0 Inf]);
    
% display data and results for belaching analysis
axes(hFig.aBleachPlot);
cla(hFig.aBleachPlot,'reset');
if any(bleach_time==0)  
    if all(bleach_time==0)
        text(0.5,0.5,'no photobleaching analysis','HorizontalAlignment','center');
    else
        text(0.5,0.5,'manual bleaching time used','HorizontalAlignment','center');
    end    
else
    hold on
    cp = mean(bleach_cdf,1);
    plot(x_bleach,cp,'b-');
    plot(x_bleach,cp+3*std(bleach_cdf,[],1),'b--');
    plot(x_bleach,cp-3*std(bleach_cdf,[],1),'b--');
    plot(x_bleach,mean(bleach_fitcdf,1),'k-','LineWidth',1);
    xlabel('bleaching time [s]');
    ylabel('cumulative probabilty');
    title({['bleaching time = ' val2str(bleach_time(1),bleach_time(2)) ' s'],['bleaching rho = ' val2str(bleach_rho(1),bleach_rho(2))]});
    text('Units','normalized','HorizontalAlignment','right','Position',[0.9 0.1],'String',['N = ' num2str(round(mean(num_bleach)))]);
    xlim([0 min([4*median(max(bleach,[],2)) x_bleach(find(~isnan(cp),1,'last'))])]);
    ylim([0 1]);
end
  
% display data and results for interaction (using censoring)
axes(hFig.aIntTimePlot);
cla(hFig.aIntTimePlot,'reset');
hold on
cp = mean(itime_censoredcdf,1);
h1 = plot(x_itime,cp,'b-');
plot(x_itime,cp+3*std(itime_censoredcdf,[],1),'b--');
plot(x_itime,cp-3*std(itime_censoredcdf,[],1),'b--');
h2 = plot(x_itime,mean(itime_censoredfit,1),'k-','LineWidth',1);
xlabel('interaction time [s]');
ylabel('cumulative probabilty');
title(['interaction time = ' val2str(itime_censored(1,1),itime_censored(1,2)) ' & ' val2str(itime_censored(2,1),itime_censored(2,2)) ' s']);
text('Units','normalized','HorizontalAlignment','right','Position',[0.9 0.1],'String',{['N = ' num2str(round(mean(num_itime)))],['w = ' num2str(wratio(2,1),2)]});
xlim([0 min([4*median(itime) x_itime(find(~isnan(cp),1,'last'))])]);
ylim([0 1]);
    
% display data and results for run length (using censoring)
axes(hFig.aRunlengthPlot);
cla(hFig.aRunlengthPlot,'reset');
hold on
cp = mean(runlen_censoredcdf,1);
h1 = plot(x_runlen,cp,'b-');
plot(x_runlen,cp+3*std(runlen_censoredcdf,[],1),'b--');
plot(x_runlen,cp-3*std(runlen_censoredcdf,[],1),'b--');
h2 = plot(x_runlen,mean(runlen_censoredfit,1),'k-');
xlabel('runlength');
ylabel('cumulative probabilty');
title(['run length = ' val2str(runlength(1,1),runlength(1,2)) ' & ' val2str(runlength(2,1),runlength(2,2))]);
text('Units','normalized','HorizontalAlignment','right','Position',[0.9 0.1],'String',{['N = ' num2str(round(mean(num_runlen)))],['w = ' num2str(wratio(3,1),2)]});
xlim([0 min([4*median(runlen) x_runlen(find(~isnan(cp),1,'last'))])]);
ylim([0 1]);

results{1,1} = velocity;
results{1,2} = v';
results{2,1} = itime_global;
results{2,2} = [tau1_global' tau2_global'];
results{3,1} = itime_censored;
results{3,2} = [tau1' tau2'];
results{4,1} = runlength;
results{4,2} = [R1' R2'];
if ~all(bleach_time==0) 
    results{5,1} = [bleach_time; bleach_rho];
    results{5,2} = [t_bleach' rho_bleach'];
end
results{6,1} = wratio;
results{6,2} = [wTau_global' wTau' wR'];

function [k,x0] = mexpfit(data,censor,weighted)
% LSF-CDF(free) of single exponential function (including censoring)
custcdf = @(k,x,x0)-exp(-k.*(x-x0))+1.0;
if isempty(censor)
    [cp,x] = ecdf(data);
else
    [cp,x] = ecdf(data,'censoring',censor);
end
x=(x(3:end)+x(2:end-1))/2;
cp=cp(2:end-1);
if weighted
    counts = histc(data, x);
    f = fit(x,cp,@(k,x0,x)custcdf(k,x,x0),'Startpoint',[1/median(data) min(data)],'Weights',counts);
else
    f = fit(x,cp,@(k,x0,x)custcdf(k,x,x0),'Startpoint',[1/median(data) min(data)]);
end
k = f.k;
x0 = f.x0;

function [k1,k2,w,x0] = mexp2fit(data,censor,weighted)
% LSF-CDF(free) of single exponential function (including censoring)
custcdf = @(k_off1,k_off2,w,x,x0)-(w.*exp(-k_off1.*x+k_off1.*x0+k_off2.*x0)+exp(-k_off2.*x).*(exp(k_off1.*x0+k_off2.*x0)-w.*exp(k_off1.*x0+k_off2.*x0)))./(exp(k_off1.*x0)-w.*exp(k_off1.*x0)+w.*exp(k_off2.*x0))+1.0;
if isempty(censor)
    [cp,x] = ecdf(data);
else
    [cp,x] = ecdf(data,'censoring',censor);
end
x=(x(3:end)+x(2:end-1))/2;
cp=cp(2:end-1);
if weighted
    counts = histc(data, x);
    f = fit(x,cp,@(k1,k2,w,x0,x)custcdf(k1,k2,w,x,x0),'Startpoint',[1/(0.5*median(data)) 1/(1.5*median(data)) 0.5 min(data)],'Lower',[0 0 0 0],'Upper',[Inf Inf 1 Inf],'Weights',counts);
else
    f = fit(x,cp,@(k1,k2,w,x0,x)custcdf(k1,k2,w,x,x0),'Startpoint',[1/(0.5*median(data)) 1/(1.5*median(data)) 0.5 min(data)],'Lower',[0 0 0 0],'Upper',[Inf Inf 1 Inf]);
end
k1 = f.k1;
k2 = f.k2;
w = f.w;
x0 = f.x0;

function [k1,k2,w,x0] = blexp2fit(data,censor,k_bleach,rho,weighted)
% LSF-CDF(free) of single exponential function combined with bleaching (including censoring)
custcdf = @(k_bleach,k_off1,k_off2,rho,w,x,x0)-(w.*exp(-k_bleach.*x+k_bleach.*x0.*6.0-k_off1.*x+k_off1.*x0.*2.0+k_off2.*x0.*2.0).*(rho-2.0)-w.*exp(k_bleach.*x.*-2.0+k_bleach.*x0.*6.0-k_off1.*x+k_off1.*x0.*2.0+k_off2.*x0.*2.0).*(rho-1.0))./(exp(k_bleach.*x0.*4.0+k_off1.*x0.*2.0+k_off2.*x0)-exp(k_bleach.*x0.*5.0+k_off1.*x0.*2.0+k_off2.*x0).*2.0-rho.*exp(k_bleach.*x0.*4.0+k_off1.*x0.*2.0+k_off2.*x0)+rho.*exp(k_bleach.*x0.*5.0+k_off1.*x0.*2.0+k_off2.*x0)+w.*exp(k_bleach.*x0.*4.0+k_off1.*x0+k_off2.*x0.*2.0)-w.*exp(k_bleach.*x0.*4.0+k_off1.*x0.*2.0+k_off2.*x0)-w.*exp(k_bleach.*x0.*5.0+k_off1.*x0+k_off2.*x0.*2.0).*2.0+w.*exp(k_bleach.*x0.*5.0+k_off1.*x0.*2.0+k_off2.*x0).*2.0-rho.*w.*exp(k_bleach.*x0.*4.0+k_off1.*x0+k_off2.*x0.*2.0)+rho.*w.*exp(k_bleach.*x0.*4.0+k_off1.*x0.*2.0+k_off2.*x0)+rho.*w.*exp(k_bleach.*x0.*5.0+k_off1.*x0+k_off2.*x0.*2.0)-rho.*w.*exp(k_bleach.*x0.*5.0+k_off1.*x0.*2.0+k_off2.*x0))-(exp(k_bleach.*x.*-2.0-k_off2.*x).*(exp(k_bleach.*x0.*6.0+k_off1.*x0.*2.0+k_off2.*x0.*2.0)-rho.*exp(k_bleach.*x0.*6.0+k_off1.*x0.*2.0+k_off2.*x0.*2.0)-w.*exp(k_bleach.*x0.*6.0+k_off1.*x0.*2.0+k_off2.*x0.*2.0)+rho.*w.*exp(k_bleach.*x0.*6.0+k_off1.*x0.*2.0+k_off2.*x0.*2.0))-exp(-k_bleach.*x-k_off2.*x).*(exp(k_bleach.*x0.*6.0+k_off1.*x0.*2.0+k_off2.*x0.*2.0).*2.0-rho.*exp(k_bleach.*x0.*6.0+k_off1.*x0.*2.0+k_off2.*x0.*2.0)-w.*exp(k_bleach.*x0.*6.0+k_off1.*x0.*2.0+k_off2.*x0.*2.0).*2.0+rho.*w.*exp(k_bleach.*x0.*6.0+k_off1.*x0.*2.0+k_off2.*x0.*2.0)))./(exp(k_bleach.*x0.*4.0+k_off1.*x0.*2.0+k_off2.*x0)-exp(k_bleach.*x0.*5.0+k_off1.*x0.*2.0+k_off2.*x0).*2.0-rho.*exp(k_bleach.*x0.*4.0+k_off1.*x0.*2.0+k_off2.*x0)+rho.*exp(k_bleach.*x0.*5.0+k_off1.*x0.*2.0+k_off2.*x0)+w.*exp(k_bleach.*x0.*4.0+k_off1.*x0+k_off2.*x0.*2.0)-w.*exp(k_bleach.*x0.*4.0+k_off1.*x0.*2.0+k_off2.*x0)-w.*exp(k_bleach.*x0.*5.0+k_off1.*x0+k_off2.*x0.*2.0).*2.0+w.*exp(k_bleach.*x0.*5.0+k_off1.*x0.*2.0+k_off2.*x0).*2.0-rho.*w.*exp(k_bleach.*x0.*4.0+k_off1.*x0+k_off2.*x0.*2.0)+rho.*w.*exp(k_bleach.*x0.*4.0+k_off1.*x0.*2.0+k_off2.*x0)+rho.*w.*exp(k_bleach.*x0.*5.0+k_off1.*x0+k_off2.*x0.*2.0)-rho.*w.*exp(k_bleach.*x0.*5.0+k_off1.*x0.*2.0+k_off2.*x0))+1.0;
if isempty(censor)
    [cp,x] = ecdf(data);
else
    [cp,x] = ecdf(data,'censoring',censor);
end
x=(x(3:end)+x(2:end-1))/2;
cp=cp(2:end-1);
if weighted
    counts = histc(data, x);
    f = fit(x,cp,@(k1,k2,w,x0,x)custcdf(k_bleach,k1,k2,rho,w,x,x0),'Startpoint',[1/(0.5*median(data)) 1/(1.5*median(data)) 0.5 min(data)],'Lower',[0 0 0 0],'Upper',[Inf Inf 1 Inf],'Weights',counts);
else
    f = fit(x,cp,@(k1,k2,w,x0,x)custcdf(k_bleach,k1,k2,rho,w,x,x0),'Startpoint',[1/(0.5*median(data)) 1/(1.5*median(data)) 0.5 min(data)],'Lower',[0 0 0 0],'Upper',[Inf Inf 1 Inf]);
end
k1 = f.k1;
k2 = f.k2;
w = f.w;
x0 = f.x0;

function [rho,k_bleach,x0,nbleach] = calcBleachLSF(bleach,bleach_x0,weighted)
% LSF-CDF(free) for bleaching analysis
BleachMixCdf = @(k_bleach,rho,x,x0) (exp(-k_bleach.*x+k_bleach.*x0.*2.0).*(rho-2.0)-exp(k_bleach.*x.*-2.0+k_bleach.*x0.*2.0).*(rho-1.0))./(rho+exp(k_bleach.*x0).*2.0-rho.*exp(k_bleach.*x0)-1.0)+1.0;
if size(bleach,2)>1
    b = max(bleach,[],2);
    bleach(b<bleach_x0(1),:) = [];
    
    % get bleaching times of individual fluorophores
    b1 = bleach(:,1);
    b2 = bleach(:,2);
    b = [b1; b2(b2>0)];
    
    % estimate bleaching rate using single exponential
    [k_bleach,~] = mexpfit(b,[],weighted);
    
    % estimate initial rho
    rho = sum(b2<0)/length(b2);
    
    % get mixed bleaching times of the motors
    bleach = max(bleach,[],2);
    
    % estimate bleaching rho using mixed bleaching pdf and the estimated bleaching rate
    [cp,x] = ecdf(bleach);
    x=(x(3:end)+x(2:end-1))/2;
    cp=cp(2:end-1);
    if weighted
        counts = histc(bleach, x);
        f = fit(x,cp,@(rho,x0,x)BleachMixCdf(k_bleach,rho,x,x0),'Startpoint',[rho min(bleach)],'Lower',[0 0],'Upper',[1 Inf],'Weights',counts);
    else
        f = fit(x,cp,@(rho,x0,x)BleachMixCdf(k_bleach,rho,x,x0),'Startpoint',[rho min(bleach)],'Lower',[0 0],'Upper',[1 Inf]);
    end
    rho = f.rho;
    x0 = f.x0;
else
    % estimate bleaching rate and rho using mixed bleaching pdf
    bleach(bleach<bleach_x0(1)) = [];
    [cp,x] = ecdf(bleach);
    x=(x(3:end)+x(2:end-1))/2;
    cp=cp(2:end-1);
    if weighted
        counts = histc(bleach, x);
        f = fit(x,cp,@(k_bleach,rho,x0,x)BleachMixCdf(k_bleach,rho,x,x0),'Startpoint',[1/median(bleach) 0.5 min(bleach)],'Lower',[0 0 0],'Upper',[Inf 1 Inf],'Weights',counts);
    else
        f = fit(x,cp,@(k_bleach,rho,x0,x)BleachMixCdf(k_bleach,rho,x,x0),'Startpoint',[1/median(bleach) 0.5 min(bleach)],'Lower',[0 0 0],'Upper',[Inf 1 Inf]);
    end
    rho = f.rho;
    x0 = f.x0;
    k_bleach = f.k_bleach;
end
nbleach = size(bleach,1);

function [rho,k_bleach,nbleach] = calcBleachMLE(bleach,x0)
% MLE for bleaching analysis
BleachMixPdf = @(k_bleach,rho,x,x0) ((2-rho)*k_bleach*exp(-k_bleach*x) + 2*(rho-1)*k_bleach*exp(-2*k_bleach*x))./(exp(-k_bleach*x0)*(2 - rho) - exp(-2*k_bleach*x0)*(1 - rho));
Exp1Pdf = @(k,x,x0) k*exp(-k*(x-x0));
if size(bleach,2)>1
    
    % get bleaching times of individual fluorophores
    b1 = bleach(:,1);
    b2 = bleach(:,2);
    
    % estimate bleaching rate using single exponential
    k_bleach = mle([b1; b2(b2>0)],'pdf',@(x,k)Exp1Pdf(k,x,x0(2)),'start',1/median([b1; b2(b2>0)]),'LowerBound',0,'UpperBound',Inf);
    
    % estimate initial rho
    rho = sum(b2<0)/length(b2);
    
    % get mixed bleaching times of the motors
    bleach = max(bleach,[],2);
    
    % estimate bleaching rho using mixed bleaching pdf and the estimated bleaching rate
    rho = mle(bleach,'pdf',@(x,rho)BleachMixPdf(k_bleach,rho,x,x0(1)),'start',rho,'LowerBound',0,'UpperBound',1);
else
    
    % estimate bleaching rate and rho using mixed bleaching pdf
    res = mle(bleach,'pdf',@(x,k_bleach,rho)BleachMixPdf(k_bleach,rho,x,x0(1)),'start',[1/median(bleach) 0.5],'LowerBound',[0 0],'UpperBound',[Inf 1]);
    k_bleach = res(1);
    rho = res(2);
end
nbleach = size(bleach,1);

function str = val2str(val,err)
rd = floor(log10(round(err,1,'significant')));
if rd>=0
    err = ceil(err);
    val = round(val);
    p = '%.0f';
else
    err = ceil(err*10^-rd)/10^-rd;
    val = round(val,-rd);
    p = ['%.' num2str(abs(rd)) 'f'];
end
if err<val
    str = [num2str(val,p) char([32 177 32]) num2str(err,p)];
else
    str = [num2str(val,p) char([32 177 32]) '(>' num2str(val,p) ')'];
end
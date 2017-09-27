function mle_cov = multi(y)
%Supply a initial guess values
mu=mean(y)';
var=cov(y);
var_chol=chol(var);
pvec=zeros(5,1);
pvec(1)=mu(1);
pvec(2)=mu(2);
pvec(3)=var_chol(1,1);
pvec(4)=var_chol(1,2);
pvec(5)=var_chol(2,2);

%maximize log-likelihood function
p=fminsearch(@loglikelihoodfn,pvec);
mle_cov_chol=[p(3) p(4)
		0 p(5)];
mle_cov=mle_cov_chol'*mle_cov_chol;
end

function ret = loglikelihoodfn(p)
	mu=[p(1); p(2)];
	var_chol=[p(3) p(4)
		0 p(5)];
	var=var_chol'*var_chol;
	global y;
	n=size(var,1);
	nsamples=size(y,1);
	tmp1=(2*pi)^(-0.5*n);
	tmp2=(det(var))^(-0.5);
	tmpsum=0;
	tmpmat=inv(var);
	for i=1:nsamples,
		ytmp=y(i,:)';
		test3=(ytmp-mu)'*tmpmat*(ytmp-mu);
		test=tmp1*tmp2*exp(-0.5*test3);
		tmpsum=tmpsum+log(test);
	end
	ret=-tmpsum;
end
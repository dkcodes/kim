function [gamma,s_bar,w] = bare_bones_champagne(data_pre,data_post,LF,lf, xx, yy, zz)
%function to call only the necessary functions for Champagne, additional
%data filtering, dc offset removal, and/or detrending and lead field column
%normalization could be applied prior to localization

%general idea:

%Champagne localizes sources in the post-stimulus period by suppressing
%activity present in the pre-stimulus period assuming the data is composed
%of data_post = stimulus_evoked_activity + data_pre + sensor_noise
% data_pre + sensor_noise are extimated with SEFA0, and the
% stimulus_evoked_activity is used to localize sources of interest

%inputs:

% data_pre: data before the stimulus used for estimating the background
% noise (sensors x time), if you don't have a pre-stimulus period, you can
% enter a single number (alpha) which will be used as a very simple estimate of the
% noise covariance (Sigma_e), Sigma_e = alpha*I

% data_post: data after the stimulus (sensors x time)

% LF: 2-D leadifield matrix (sensors x (voxels*lf)), so you have to
% interleave the columns of the orientation such that your 3 orientation LF is
%[v_11; v_12; v_13; v_21; v_22 v_23;........], where v_ij is the ith
%voxel's LF for orientation j

%lf - number of orientations in your LF (can be 1, 2, or 3)

%outputs:

%gamma: voxel covariance matrices (lf x lf x voxels)
% s_bar = voxel current density ((voxels*lf) x time)
% w = reconstruction filter ((voxels*lf) x sensors)


nem=100; %number of iterations for SEFA0 and CHAMP

if(size(data_pre,1)~=1 & size(data_pre,2)~=1) %detect whether there is a pre-stim pd
  nl=20; nm=25; %number of factors to estimate for SEFA0
  [a1,b,lam,alp,bet,xbar1]=sefa0(data_post,data_pre,nl,nm,nem,0);
  Sigma_e = double(b*b' + inv(lam)); %noise covariance
else
  Sigma_e=data_pre*eye(size(LF,1),size(LF,1)); %set Sigma_e to be Sigma_e = alpha*I
end

vcs=2; %a parameter that sets the complexity of the Champagne voxel covariances, can be 1 and 0 for simpler estimates
display('running Champagne on post-stimulus data')
[gamma,s_bar,w]=awsm_champ(data_post,LF,Sigma_e,nem,lf,vcs,1, xx, yy, zz); %call Champagne


%subfunctions-----------------------------------------------------------
%-----------------------------------------------------------------------

function [gamma,x,w]=awsm_champ(y,f,sigu,nem,nd,vcs,plot_on, xx, yy, zz);

if vcs==2 && nd>1
  [gamma x w l v]=champ_mat(y,f,sigu,nem,nd,plot_on, xx, yy, zz);
else
  [gamma x w l v]=champ_vec(y,f,sigu,nem,nd,vcs,plot_on, xx, yy, zz);
end

return



function [a,b,lam,alp,bet,xbar]=sefa0(y,y0,nl,n_inf,nem_init,ifplot);

% vb-em algorithm for inferring the sefa analysis model   y = a*x + b*u + v
% learn a,b,lam
%
% y(nk,nt) = data
% a(nk,nl) = mixing matrix
% lam(nk,nk) = diagonal noise precision matrix
% alp(nl,nl) = diagonal hyperparmaeter matrix
% xbar(nl,nt) = posterior means of the factors
%
% nk = number of data points
% nt = number of time points
% nl = number of factors
% nem_init = number of em iterations

nk=size(y,1);
nt=size(y,2);
nt0=size(y0,2);



disp('VBFA initialization of SEFA0');
b_init=0;
lam_init=0;
[b,lam,bet,ubar]=vbfa(y0,n_inf,nem_init,b_init,lam_init,ifplot);



a_init=0;
ryy=y*y';
ryy0=y0*y0';
if a_init==0
  %   [p d q]=svd(ryy/nt);d=diag(d);
  %   a=p*diag(sqrt(d));
  %   a=a(:,1:nl);
  sig0=b*b'+diag(1./diag(lam));
  [p0 d0 q0]=svd(sig0);d0=diag(d0);
  s=p0*diag(sqrt(d0))*p0';
  invs=p0*diag(1./sqrt(d0))*p0';
  [p d q]=svd(invs*ryy*invs/nt);d=diag(d);
  %   a=s*p(:,1:nl)*diag(sqrt(max(d(1:nl)-1,0)));
  a=s*p(:,1:nl)*diag(sqrt(abs(d(1:nl)-1)));
else
  a=a_init;
end



% initialize by svd
if 1>2
  ryy=y*y';
  [p d q]=svd(ryy/nt);d=diag(d);
  a=p*diag(sqrt(d));
  a=a(:,1:nl);
  
  ryy0=y0*y0';
  [p d q]=svd(ryy0/nt0);d=diag(d);
  b=p*diag(sqrt(d));
  b=b(:,1:n_inf);
  lam=diag(nt0./diag(ryy0));
end



alp=diag(1./diag(a'*lam*a/nk));
alp=min(diag(alp))*diag(ones(nl,1));
bet=diag(1./diag(b'*lam*b/nk));
bet=min(diag(bet))*diag(ones(n_inf,1));

ab=[a b];
alpbet=diag([diag(alp);diag(bet)]);
nlm=nl+n_inf;
psi=eye(nlm)/(nt+nt0);

% em iteration

like=zeros(nem_init,1);
alapsi=ab'*lam*ab+nk*psi;

disp('running SEFA0, part 2');
for iem=1:nem_init
  iem
  gam=alapsi+eye(nlm);
  igam=inv(gam);
  xubar=igam*ab'*lam*y;
  
  b=ab(:,nl+1:nlm);
  psib=psi(nl+1:nlm,nl+1:nlm);
  gam0=b'*lam*b+nk*psib+eye(n_inf);
  igam0=inv(gam0);
  ubar0=igam0*b'*lam*y0;
  
  ldlam=sum(log(diag(lam/(2*pi))));
  ldgam=sum(log(svd(gam)));
  ldgam0=sum(log(svd(gam0)));
  ldalpbet=sum(log(diag(alpbet)));
  ldpsi=sum(log(svd(psi)));
  like0=.5*nt0*(ldlam-ldgam0)-.5*sum(sum(y0.*(lam*y0)))+.5*sum(sum(ubar0.*(gam0*ubar0)));
  like(iem)=.5*nt*(ldlam-ldgam)-.5*sum(sum(y.*(lam*y)))+.5*sum(sum(xubar.*(gam*xubar)))+.5*nk*(ldalpbet+ldpsi)+like0;
  if(ifplot)
    subplot(3,3,1);plot((1:iem)',like(1:iem));title('SEFA0');
    subplot(3,3,4);plot([mean(ab.^2,1)' 1./diag(alpbet)]);
    subplot(3,3,7);plot(1./diag(lam));
    drawnow;
  end
  rxuxu=xubar*xubar'+nt*igam;
  ruu0=ubar0*ubar0'+nt0*igam0;
  rxuxu(nl+1:nlm,nl+1:nlm)=rxuxu(nl+1:nlm,nl+1:nlm)+ruu0;
  psi=inv(rxuxu+alpbet);
  
  ryxu=y*xubar';
  ryu0=y0*ubar0';
  ryxu(:,nl+1:nlm)=ryxu(:,nl+1:nlm)+ryu0;
  ab=ryxu*psi;
  lam=diag((nt+nt0)./diag(ryy+ryy0-ab*ryxu'));
  alapsi=ab'*lam*ab+nk*psi;
  alpbet=diag(nk./diag(alapsi));
end

a=ab(:,1:nl);
b=ab(:,nl+1:nlm);
alp=alpbet(1:nl,1:nl);
bet=alpbet(nl+1:nlm,nl+1:nlm);
xbar=xubar(1:nl,:);

return
%-----------------------------------------------------------------------



function [a,lam,alp,xbar]=vbfa(y,nl,nem_init,a_init,lam_init,ifplot);

% vb-em algorithm for inferring the factor analysis model   y = a*x + v
%
% y(nk,nt) = data
% a(nk,nl) = mixing matrix
% lam(nk,nk) = diagonal noise precision matrix
% alp(nl,nl) = diagonal hyperparmaeter matrix
% xbar(nl,nt) = posterior means of the factors
%
% nk = number of data points
% nt = number of time points
% nl = number of factors
% nem_init = number of em iterations

nk=size(y,1);
nt=size(y,2);

% initialize by svd

ryy=y*y';
if a_init==0
  [p d q]=svd(ryy/nt);d=diag(d);
  a=p*diag(sqrt(d));
  a=a(:,1:nl);
  lam=diag(nt./diag(ryy));
else
  a=a_init;
  lam=lam_init;
end

alp=diag(1./diag(a'*lam*a/nk));
alp=min(diag(alp))*diag(ones(nl,1));
psi=eye(nl)/nt;

% em iteration

like=zeros(nem_init,1);
alapsi=a'*lam*a+nk*psi;


for iem=1:nem_init
  iem
  gam=alapsi+eye(nl);
  igam=inv(gam);
  xbar=igam*a'*lam*y;
  
  %    ldlam=sum(log(diag(lam/(2*pi))));
  %    ldgam=sum(log(svd(gam)));
  %    ldalp=sum(log(diag(alp)));
  %    ldpsi=sum(log(svd(psi)));
  %    like(iem)=.5*nt*(ldlam-ldgam)-.5*sum(sum(y.*(lam*y)))+.5*sum(sum(xbar.*(gam*xbar)))+.5*nk*(ldalp+ldpsi);
  if(ifplot)
    subplot(3,3,1);plot((1:iem)',like(1:iem)/nt);title('VBFA: like');
    subplot(3,3,4);plot([mean(a.^2,1)' 1./diag(alp)]);title('1/alp');
    subplot(3,3,7);plot(1./diag(lam));title('1/lam');
    drawnow;
  end
  
  ryx=y*xbar';
  rxx=xbar*xbar'+nt*igam;
  psi=inv(rxx+alp);
  
  a=ryx*psi;
  lam=diag(nt./diag(ryy-a*ryx'));
  alapsi=a'*lam*a+nk*psi;
  alp=diag(nk./diag(alapsi));
end

return
%-----------------------------------------------------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Learn voxel covariances in Champagne
%
% � 2011 Convex Imaging
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Output:
% gamma(nd,nd,nv) = voxel covariance matrices
% x(nv*nd,nt) = voxel current density
% w(nv*nd,nk) = reconstruction filter
%
% Input:
% y(nk,nt) = sensor data
% f(nk,nv*nd) = lead field matrix
% sigu(nk,nk) = noise covariance matrix
% nd = # of orientations
% vcs = voxel covariance structure: 0 = scalar, 1 = diagonal, 2 = general
% nem = maximum # of iterations
%
% #s:
% nk = # of sensors
% nv = # of voxels
% nt = # of data time points





%-----------------------------------------------------------------------

function [gamma,x,w,like,vvec]=champ_vec(y,f,sigu,nem,nd,vcs,plot_on, xx, yy, zz);

eps1=1e-8;
[nk nvd]=size(f);
nv=nvd/nd;
nt=size(y,2);

cyy=y*y'/nt;

% Initialize voxel variances

f2=sum(f.^2,1);
invf2=zeros(1,nvd);
ff=find(f2>0);
invf2(ff)=1./f2(ff);
w=spdiags(invf2',0,nvd,nvd)*f';
%w=spdiags(1./sum(f.^2,1)',0,nvd,nvd)*f';
inu0=mean(mean((w*y).^2));
%gamma=inu0*repmat(eye(nd,nd),[1,1,nv]);
vvec=inu0*ones(nvd,1);

% Learn voxel variances
if(plot_on)
  figure;
end

like=zeros(nem,1);
for iem=1:nem
  iem
  vmat=spdiags(vvec,0,nvd,nvd);
  c=f*vmat*f'+sigu;
  %    [p d q]=svd(c);
  [p d]=eig(c);
  d=max(real(diag(d)),0);
  invd=zeros(nk,1);
  ff=find(d>=eps1);
  invd(ff)=1./d(ff);
  invc=p*spdiags(invd,0,nk,nk)*p';
  
  %    like(iem)=-.5*(sum(log(d))+nk*log(2*pi))-.5*sum(sum(y.*(invc*y)))/nt;
  like(iem)=-.5*(sum(log(max(d,eps1)))+nk*log(2*pi))-.5*sum(sum(invc.*cyy));
  
  if(plot_on)
    subplot(1,2,1);plot((1:iem),like(1:iem));
    title(['Likelihood: ' int2str(iem) ' / ' int2str(nem)]);
    xlabel('iteration');
    set(gca(),'XLim',[0 iem]);
  end
  
  fc=f'*invc;
  w=vmat*fc;
  x=w*y;
  x2=mean(x.^2,2);
  z=sum(fc.*f',2);
  
  if vcs==0
    x20=sum(reshape(x2,nd,nv),1);
    z0=sum(reshape(z,nd,nv),1);
    v0=zeros(size(z0));
    ff=find(z0>0);
    v0(ff)=sqrt(x20(ff)./z0(ff));
    vvec=reshape(ones(nd,1)*v0,nvd,1);
  else
    vvec=zeros(size(x2));
    ff=find(z>0);
    vvec(ff)=sqrt(x2(ff)./z(ff));
  end
  
  v=sum(reshape(vvec,nd,nv),1);
  
  if(plot_on)
    subplot(1,2,2);plot((1:nv),v);
    title(['Voxel power: ' num2str(nv) ' / ' num2str(nv)]);
    xlabel('voxel index');
    set(gca(),'XLim',[1 nv]);
    drawnow
  end
  
  %    lam=inv(sigu);nu=inv(vmat);
  %    gam=f'*lam*f+nu;
  %    igam=inv(gam);
  %    w1=igam*f'*lam;
  %    x1=w1*y;
  %    x2=mean(x1.^2,2)+diag(igam);
  %    disp([max(max(abs(w1-w))) max(abs(x2-v))]);
end

if nd==1
  gamma=reshape(vvec,1,1,nv);
else
  gamma=zeros(nd,nd,nv);
  for iv=1:nv
    gamma(:,:,iv)=diag(vvec((iv-1)*nd+1:iv*nd));
  end
end

return


%---------------------------------------------------------
function [gamma,x,w,like,vvec]=champ_mat(y,f,sigu,nem,nd,plot_on, xx, yy, zz);

eps1=1e-8;
[nk nvd]=size(f);
nv=nvd/nd;
nt=size(y,2);

cyy=y*y'/nt;

% Initialize voxel variances

f2=sum(f.^2,1);
invf2=zeros(1,nvd);
ff=find(f2>0);
invf2(ff)=1./f2(ff);
w=spdiags(invf2',0,nvd,nvd)*f';
%w=spdiags(1./sum(f.^2,1)',0,nvd,nvd)*f';
inu0=mean(mean((w*y).^2));
%gamma=inu0*repmat(eye(nd,nd),[1,1,nv]);
v=zeros(nv,1);
vmat=double(inu0)*speye(nvd,nvd);

% Learn voxel variances
if(plot_on)
  figure;
end

like=zeros(nem,1);
for iem=1:nem
  iem
  %    disp(full(vmat));pause
  %    vmat=spdiags(v,0,nvd,nvd);
  c=f*vmat*f'+sigu;
  %    [p d q]=svd(c);
  [p d]=eig(c);
  d=max(real(diag(d)),0);
  invd=zeros(nk,1);
  ff=find(d>=eps1);
  invd(ff)=1./d(ff);
  invc=p*spdiags(invd,0,nk,nk)*p';
  
  %    like(iem)=-.5*(sum(log(d))+nk*log(2*pi))-.5*sum(sum(y.*(invc*y)))/nt;
  like(iem)=-.5*(sum(log(max(d,eps1)))+nk*log(2*pi))-.5*sum(sum(invc.*cyy));
  
  if(plot_on)
    subplot(1,2,1);plot((1:iem),like(1:iem));
    title(['Likelihood: ' int2str(iem) ' / ' int2str(nem)]);
    xlabel('iteration');
    set(gca(),'XLim',[0 iem]);
  end
  fc=f'*invc;
  w=vmat*fc;
  %    x=w*y;
  %    x2=mean(x.^2,2);
  %    z=sum(fc.*f',2);
  
  for iv=1:nv
    jv=((iv-1)*nd+1:iv*nd);
    %        x2=x(jv,:)*x(jv,:)'/nt;
    x2=w(jv,:)*cyy*w(jv,:)';
    z=fc(jv,:)*f(:,jv);
    
    [pz dz]=eig(z);
    dz5=sqrt(max(real(diag(dz)),0));
    %        dz5=sqrt(abs(diag(dz)));
    invdz5=zeros(nd,1);
    ff=find(dz5>=eps1);
    invdz5(ff)=1./dz5(ff);
    z5=pz*diag(dz5)*pz';
    invz5=pz*diag(invdz5)*pz';
    
    [px dx]=eig(z5*x2*z5);
    dx5=sqrt(max(real(diag(dx)),0));
    %        dx5=sqrt(abs(diag(dx)));
    cx5=px*diag(dx5)*px';
    vmat(jv,jv)=invz5*cx5*invz5;
    v(iv)=sum(diag(vmat(jv,jv)));
  end
  if(plot_on)
    subplot(1,2,2);plot((1:nv),v);
    title(['Voxel power: ' num2str(nv) ' / ' num2str(nv)]);
    xlabel('voxel index');
    set(gca(),'XLim',[1 nv]);
    drawnow
    set(gcf, 'position', [-999   715   959   245])
  end
  %    lam=inv(sigu);nu=inv(vmat);
  %    gam=f'*lam*f+nu;
  %    igam=inv(gam);
  %    w1=igam*f'*lam;
  %    x1=w1*y;
  %    x2=mean(x1.^2,2)+diag(igam);
  %    disp([max(max(abs(w1-w))) max(abs(x2-v))]);
end

x=w*y;
gamma=zeros(nd,nd,nv);
for iv=1:nv
  jv=(iv-1)*nd+1:iv*nd;
  gamma(:,:,iv)=vmat(jv,jv);
end
vvec=diag(vmat);

return
%-----------------------------------------------------------------------


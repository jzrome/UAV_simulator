clc
clear all
close all

gauss= @ (x,mu,sig) exp(-((x-mu).^2.)/(2*sig^2))/(sig*sqrt(2*pi)) ;

n_t=10000;
dt=0.1;

sig_w=0.2*ones(3,1);
sig=0.01*ones(4,1);
q0=[1 5 15 3]';
w_ref=[1 5 -3]'+sig_w.*randn(3,n_t);
q0=q0/sqrt(sum(q0.^2))+sig.*randn(4,n_t);
for i=1:n_t
  q_ref(:,i)=expm(Omega(w_ref(:,i))*dt)*q0(:,i);
end

k=2;

%figure
%plot(w_ref')

figure
subplot(2,1,1)
plot(q0')
subplot(2,1,2)
hist(q0(k,:),30)

figure
subplot(2,1,1)
plot(q_ref')
subplot(2,1,2)
hist(q_ref(k,:),50)
hold on
l=min(q_ref(k,:)); u=max(q_ref(k,:)); mu=mean(q_ref(k,:)); sig=sqrt(var(q_ref(k,:)));
x=linspace(l,u,50);
step=(x(2)-x(1));
y=gauss(x,mu,sig);
plot(x(1:end),n_t*step*(y(1:end)))

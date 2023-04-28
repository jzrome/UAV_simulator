clc
clear all
close all

% Filtre de kalman pour l'estimation de l'attitude d'un drone par quaternion avec 2 capteurs redondants (gyro,acc,mag) 

% indice 1 pour capteur 1 et indice 2 pour capteur 2
% l'indice e (earth) pour le repere terrestre et b (body) le repere du drone
% indice ref pour la vrai valeur et sans indice pour les mesure.
% indice hat pour les valeur estimer.
% q pour quaternions, w pour vitesse angulaire, a pour acceleartion et m pour champs magnetique
% sig pour le vecteur d'ecart-type (sig^2=variance) de valeur de capteur
% bi pour le vecteur de bias des capteurs

%% valeur initial

dt=0.02;

tf=6;

t=0:dt:tf;

n_t=length(t);

init_data;

u=u_t0.*ones(4,n_t);
i_t=floor(1/dt)+1:floor(1.5/dt);
u(:,i_t)=u_t0(1,ones(1,length(i_t))).*[(1+0.01);(1+0.01);(1-0.02);(1-0.02)];

i_t=floor(2/dt)+1:floor(2.5/dt);
u(:,i_t)=u_t0(1,ones(1,length(i_t))).*[(1-0.01);(1-0.01);(1+0.02);(1+0.02)];
 
%% bruit du gyro, acc et mag des capteurs (bruits) 
g_w1=sig_w_1.*randn(3,n_t);
g_w2=sig_w_2.*randn(3,n_t);

g_a1_b=sig_a_1.*randn(3,n_t);
g_a2_b=sig_a_2.*randn(3,n_t);

g_m1_b=sig_m_1.*randn(3,n_t)+bi_m_1;
g_m2_b=sig_m_2.*randn(3,n_t)+bi_m_2;

%% init simulation
w=zeros(3,n_t);
w(:,1)=w_t0;

q=zeros(4,n_t);
q(:,1)=q_t0;

wr=zeros(4,n_t);
wr(:,1)=wr_t0;

a=zeros(3,n_t);
a(:,1)=[0;0;g];

v=zeros(3,n_t);
v(:,1)=v_t0;

x=zeros(3,n_t);
x(:,1)=x_t0;

%% init filtre de kalman
q_hat=zeros(4,n_t);
q_hat(:,1)=q_t0;
P_h=1e-4*eye(4);
sig2_q=[diag(P_h) zeros(4,n_t-1)];

a_e_hat=zeros(3,n_t);
a_e_hat(:,1)=[0;0;g];

%%boucle simulation

dfx = @ (t,X) fct_dynamique(X(1:3),X(4:7),X(8:11),X(12:14),u(:,min(floor(t/dt)+1,n_t)),J,m,l,Cx,Cz,J_rotor,b,d,ke,R,g);
oset=odeset('AbsTol',1e-6);
h=waitbar(0,'Progress');

for i=2:n_t

  [t_,y]=ode23(dfx,t(i-1:i),[w(:,i-1);q(:,i-1);wr(:,i-1);v(:,i-1);x(:,i-1)],oset);
  y=y';
  w(:,i)=y(1:3,end);
  q_=y(4:7,end);
  q(:,i)=q_/sqrt(sum(q_.^2));
  wr(:,i)=y(8:11,end);
  v(:,i)=y(12:14,end);
  x(:,i)=y(15:17,end);
  
  Ceb=C_e_b(q_);
  a_e=dyna_solid_trans(v(:,i),m,g,Ceb,Cx,Cz,b,wr(:,i));
  a(:,i)=a_e+gv(:,i);
  a_b=Ceb*a(:,i);
  m_b=Ceb*m_e(:,i);
  
  move_uniform=abs(a_e(3))<=0.01;
  
  [q_hat(:,i),P_h,a_e_hat(:,i),P_a]=EKF(dt,q_hat(:,i-1),P_h,w(:,i-1)+g_w1(:,i-1),w(:,i-1)+g_w2(:,i-1),sig_w_1,sig_w_2,a_b+g_a1_b(:,i),a_b+g_a2_b(:,i),sig_a_1,sig_a_2,m_b+g_m1_b(:,i),m_b+g_m2_b(:,i),sig_m_1,sig_m_2,move_uniform);
  sig2_q(:,i)=diag(P_h);
  
  %x(:,i)=Ceb'*a_b;
  
  if mod(i,floor(n_t/50))==1
    waitbar(i/n_t);
  endif
end

close(h);
%% calcule des angle d'euler
alpha = ones(3,n_t);
for i=1:n_t
  alpha=q2Euler(q(:,i));
end

%% affiche
figure 
subplot(6,1,1)
plot(t,w)
grid on; grid minor;
xlabel('temps [s]'); ylabel('rotation [rad/s]')
title('Vitesse de rotation')

subplot(6,1,2)
plot(t,q)
grid on; grid minor;
xlabel('temps [s]'); ylabel('quaternion')
%legend('q1','q2','q3','q4')
title('Quaternion')

subplot(6,1,3)
plot(t,wr)
grid on; grid minor;
xlabel('temps [s]'); ylabel('rotation [rad/s]')
title('Vitesse de rotation des moteurs')

subplot(6,1,4)
plot(t,a)
grid on; grid minor;
xlabel('temps [s]'); ylabel('acceleartion [m/s^2]')
title('Acceleartion')

subplot(6,1,5)
plot(t,v)
grid on; grid minor;
xlabel('temps [s]'); ylabel('vitesse [m/s]')
title('Vitesse')

subplot(6,1,6)
plot(t,x)
grid on; grid minor;
xlabel('temps [s]'); ylabel('position [m]')
title('Position')

figure 
subplot(3,1,1)
plot(t,q)
grid on; grid minor;
xlabel('temps [s]'); ylabel('quaternion')
legend('q1','q2','q3','q4')
title('Quaternion ref')
subplot(3,1,2)
plot(t,q_hat)
grid on; grid minor;
xlabel('temps [s]'); ylabel('quaternion')
title('Quaternion esti')
subplot(3,1,3)
plot(t,q-q_hat)
grid on; grid minor;
xlabel('temps [s]'); ylabel('erreur')
title('Quaternion erreur d''estimation')


figure
subplot(2,1,1)
plot(t,a)
title('Accelaration earth reel')

subplot(2,1,2)
plot(t,a_e_hat)
title('Accelaration earth estimer à partir du acc body')

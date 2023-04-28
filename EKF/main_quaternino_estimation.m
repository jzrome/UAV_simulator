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
dt=0.05;
dt1=0.05;
dt2=0.05;
tf=20;

t=0:dt:tf;
t1=0:dt1:tf;
t2=0:dt2:tf;

n_t=length(t);
n_t1=length(t1);
n_t2=length(t2);

idx1=1:n_t1;
idx2=1:n_t2;

init_data;


w_t = @(t) [0.0*sin(2*pi*t);0.0*sin(2*pi*0.1*t);1.0*sin(2*pi*0.5*t)];

%% derive de la rotation d'un vecteur par difference finie
%C_x = @ (qx) C_e_b(qx(1:4))*qx(5:7);

%% calcule des quaternion de reference
%q_ref=q_t0.*ones(1,n_t_ref);
%for i=1:n_t_ref-1
%  q_ref(:,i+1)=expm(Omega(w_ref(:,i))*dt)*q_ref(:,i);
%  q_ref(:,i+1)=q_ref(:,i+1)/sqrt(sum(q_ref(:,i+1).^2));
%end
fun = @(t,q) [Omega(w_t(t))*q];
[~,q_ref] = ode45(fun, t, q_t0);
[~,q1] = ode45(fun, t1, q_t0);
[~,q2] = ode45(fun, t2, q_t0);
q_ref=q_ref';q1=q1';q2=q2';

C_e_b_ref=C_e_b(q_ref);
C_e_b_1=C_e_b(q1);
C_e_b_2=C_e_b(q2);

%% calcule de l'acc et mag de reference.
a_b_ref = squeeze(sum(C_e_b_ref.*gv',2));
m_b_ref = squeeze(sum(C_e_b_ref.*m_e',2));

%% calcule du gyro, acc et mag des capteurs (bruits)
w1=w_t(t1)+sig_w_1.*randn(3,n_t1);
w2=w_t(t2)+sig_w_2.*randn(3,n_t2);

a1_b=squeeze(sum(C_e_b_1.*gv',2))+sig_a_1.*randn(3,n_t1);
a2_b=squeeze(sum(C_e_b_2.*gv',2))+sig_a_2.*randn(3,n_t2);

m1_b=squeeze(sum(C_e_b_ref.*m_e',2))+sig_m_1.*randn(3,n_t)+bi_m_1;
m2_b=squeeze(sum(C_e_b_ref.*m_e',2))+sig_m_2.*randn(3,n_t)+bi_m_2;

%% boucle filtre de kalman
q_hat=zeros(4,n_t);
q_hat(:,1)=[1 0 0 0]; %q _t0
P_h=0.0*eye(4);
P1=P_h;
P2=P_h;

sig2_q=[diag(P_h) zeros(4,n_t-1)];

for i=1:n_t-1
  %%boucle sensor 1
  buf1= (t1<t(i+1)) & (t1>=t(i));
  for j=idx1(buf1)
    % prediction et acc update
    [q1(:,j+1),P1]=quaternion_estim(dt1,q1(:,j),P1,w1(:,j),sig_w_1,a1_b(:,j+1),sig_a_1,true);
  end
  % mag update
  %[q1(:,j+1),P1]=quaternion_kalman_update(q1(:,j+1),P1,C_e_b(q1(:,j+1),m_e),m1_b(:,i),C_e_b(q1(:,j))*m_e,diag(sig_m_1.^2));

%  %%boucle sensor 2
%  buf2= (t2<t(i+1)) & (t2>=t(i));
%  for k=idx2(buf2)
%    % prediction et acc update
%    [q2(:,k+1),P2]=quaternion_estim(dt2,q2(:,k),P2,w2(:,k),sig_w_2,a2_b(:,k),sig_a_2,true);
%  end
%  % mag update
%  [q2(:,k+1),P1]=quaternion_kalman_update(q2(:,k+1),P2,C_e_b(q2(:,k+1),m_e),m2_b(:,i),C_e_b(q2(:,k))*m_e,diag(sig_m_2.^2));

  %% fusion
  %[q_hat(:,i+1),P_h]=quaternion_kalman_update(q1(:,j+1),P1,eye(4),q2(:,k+1),q1(:,j+1),P2);
  q_hat(:,i+1)=q1(:,j+1);P_H=P1;
  sig2_q(:,i+1)=sqrt(diag(P_h));
end

%% calcule des angle d'euler
alpha_ref=q2Euler(q_ref);
alpha_hat=q2Euler(q_hat);

%% affiche
figure
subplot(3,1,1)
plot(t,q_ref)
ylim([-0.5 1.5])
grid on; grid minor;
xlabel('temps [s]'); ylabel('quaternion')
%legend('q1','q2','q3','q4')
title('Quaternion ref')
subplot(3,1,2)
plot(t,q_hat)
ylim([-0.5 1.5])
grid on; grid minor;
xlabel('temps [s]'); ylabel('quaternion')
title('Quaternion esti')
subplot(3,1,3)
plot(t,q_ref-q_hat)
grid on; grid minor;
xlabel('temps [s]'); ylabel('erreur')
title('Quaternion erreur d''estimation')


figure
plot(t,abs(q_ref-q_hat))
hold on;
set(gca,'colororderindex',1);
plot(t,3*sig2_q,".-")
grid on; grid minor;

%figure
%subplot(2,1,1)
%plot(t,alpha_ref)
%grid on; grid minor;
%xlabel('temps [s]'); ylabel('angle [rad]')
%legend('alpha','phi','psi')
%title('Angles d''euler ref')
%subplot(2,1,2)
%plot(t,alpha_hat)
%grid on; grid minor;
%xlabel('temps [s]'); ylabel('angle [rad]')
%legend('alpha','phi','psi')
%title('Angles d''euler estimee')
%
%figure
%subplot(3,1,1)
%plot(t,w_ref,'--',t,w1)
%xlabel('temps [s]'); ylabel('vitesse angulaire [rad/s]'); title('Gyroscope'); grid on; grid minor;
%
%subplot(3,1,2)
%plot(t,a_b_ref,'--',t,a1_b)
%xlabel('temps [s]'); ylabel('acceleration [m/s/s]'); title('accelerometre'); grid on; grid minor;
%
%subplot(3,1,3)
%plot(t,m_b_ref,'--',t,m1_b)
%xlabel('temps [s]'); ylabel('Champs magnitque normalisˆ''); title('Magnetometre'); grid on; grid minor;


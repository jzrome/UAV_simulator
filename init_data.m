q_t0=[1 0 0 0]';
v_t0=[0 0 0]';
x_t0=[0 0 1]';
w_t0=[0 0 0]';

%capteur

gv = [0; 0; 9.81];

m_e = [22.8;0;-41.4];

sig_w_1=10*[2.2193e-03   2.1077e-03   7.2653e-03]';
sig_w_2=10.2*[2.2193e-03   2.1077e-03   7.2653e-03]';

sig_a_1=10*[0.018437   0.014537   0.024662]';
sig_a_2=10.2*[0.018437   0.014537   0.024662]';

sig_m_1=10*[0.3586   0.3306   0.4419]';
sig_m_2=10.2*[0.3586   0.3306   0.4419]';

bi_m_1=[0 0 0]';
bi_m_2=[0 0 0]';

% frame
g=9.81;

J=[0.0348 0.0459 0.0977]';
m=1.5;
l=0.3;

Cx=1;
Cz=2;

% moteur
% U= ke*w_r - Ri
% i= ke*w_r/R - U/R
% J_rotor dw_m/dt = kc * i - d*w_m^2
% dw_r/dt = -d/J_rotor*w_r^2 + kc/J_rotor*ke/R*w_r - kc/(J_rotor*R)*U

% souvent kc=ke

J_rotor=0.001;

ke=(12-1)/(1000*2*pi/60);

R=1;

d=ke*1/(1000*2*pi/60)^2;

b=m*g/4/(1000*2*pi/60)^2;
%m*g= 4*b*wr_t0^2
wr_t0=[1;1;1;1]*sqrt(m*g/(4*b));

u_t0=(d*wr_t0.^2*R/ke + ke*wr_t0);
function [q_hat,P_hat]=quaternion_prediction(dt,q,P,w,Q_w)
  % 1: prediction
  Omega=Omega(w)*dt;
  
  % 1.1 approximation des exp(Omega*dt)
  a=(-dt^2/4*sum(w.^2));
  F=eye(4)*(1+a/2)+Omega*(1+a/6);
  
  %F=expm(Omega(w)*dt);
  %q_hat=q+0.5*ksi(q)*dt*w;  
  
  q_hat=F*q;

  % 2: mise a jour de la matrice de covariance des quaternion suite ˆ? la prediction
  % 2-1: calcule de la matrice de covariance du gyro dans l'equation d'etats. (approximation d'ordre 1)
  %       dq/dt=0.5* [q ksi(q)] * [0; w+u] avec u du bruit gaussien. dq/dt=0.5*ksi(q)*w+0.5*ksi(q)*u ~ q+1= q + 0.5*ksi(q)*w*dt + 0.5*ksi(q)*u*dt 
  %       U= 0.5*ksi(q)*u*dt bruit supplˆ'mentaire sur q+1. La matrice de covaraince qui s'ajoute est alors R=(0.5*dt)^2*ksi(q)*Q_w*ksi(q)'
  Ksi=ksi(q);
  Q= (dt/2)^2*Ksi*Q_w*Ksi'; 
  P_hat=F*P*F'+Q;
endfunction
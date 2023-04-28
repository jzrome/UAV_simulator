function [q_hat,P_hat]=quaternion_kalman_update(q,P,H,v,v_hat,R)
% on s'assure que le quaternion est normaliser pour le calucle de changment de repere
  q=q/sqrt(sum(q.^2));

  a_e_hat=[0; 0; 9.81];
%  if ~(acc_on || mag_on)
%    q_hat=q;
%    P_hat=P;
%    return;
%  elseif acc_on && mag_on
%    %3 calcule de l'estimation mesure acc et mag
%    a_b_hat = C*a_e_hat;
%    m_b_hat = C*m_e_hat;
%    v=[a_b; m_b];
%    v_hat=[a_b_hat; m_b_hat];
%    %4 calcule de la jacobienne de la fonction q vers estimation des valeur acc et mag
%    H=[C_e_b(q,a_e_hat) ; C_e_b(q,m_e_hat)];
%    %5 calcule de matrice de covariance de acc et mag
%    R=[R_a zeros(size(R_a)); R_m zeros(size(R_m))];
%  elseif acc_on
%    %3 calcule de l'estimation mesure acc et mag
    a_b_hat = C_e_b(q)*a_e_hat;
    %v=a_b;
    v_hat=a_b_hat;
    %4 calcule de la jacobienne de la fonction q vers estimation des valeur acc et mag
    H=C_e_b(q,a_e_hat);
%    %5 calcule de matrice de covariance de acc et mag
%    R=R_a;
%  elseif mag_on
%    %3 calcule de l'estimation mesure acc et mag
%    m_b_hat = C*m_e_hat;
%    v=m_b;
%    v_hat=m_b_hat;
%    %4 calcule de la jacobienne de la fonction q vers estimation des valeur acc et mag
%    H=C_e_b(q,m_e_hat);
%    %5 calcule de matrice de covariance de acc et mag
%    R=R_m;
%  end

  %6 calucle du gain de kalman
  K= (P*H')/(H*P*H'+R);
  %7 estimation la moyenne des quaternions
  q_hat=q+K*(v-v_hat);
  %8 estimation de la variance des quaternions
  P_hat=P-K*H*P;

endfunction

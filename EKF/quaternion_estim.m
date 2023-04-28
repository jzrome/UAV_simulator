function [q_hat,P_hat,a_e,P_a]=quaternion_estim(dt,q_hat,P_hat,w,sig_w,a_b,sig_a,mov_uniform)
  a_e_hat=[0; 0; 9.81];
  R_a_b=diag(sig_a.^2)*1;
  %1-1: prediction
  [q_hat,P_hat]=quaternion_prediction(dt,q_hat,P_hat,w,diag(sig_w.^2));
  P_hat=P_hat+eye(4)*1e-6;

  %2-1 on s'assure que le quaternion est normaliser pour le calucle de changment de repere
  q_hat=q_hat/sqrt(sum(q_hat.^2));
  C=C_e_b(q_hat);

  %2-2 changement de repere pour acc
  a_e=C'*a_b;
  P_a=C'*R_a_b*C;

  %2-3 verifcation si drone est en deplacement a vitesse constante
  if sqrt(sum(a_e.^2))<=2.5*mean(sqrt(diag(P_a)))+9.81 && mov_uniform
    %3 kalman update
    [q_hat,P_hat]=quaternion_kalman_update(q_hat,P_hat,C_e_b(q_hat,a_e_hat),a_b,C*a_e_hat,R_a_b);
  end
endfunction

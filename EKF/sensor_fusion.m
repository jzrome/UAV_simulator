function [x_hat,P_hat]=sensor_fusion(x1,x2,P1,P2,covar)
  %K= P1./(P1+P2);
  %x_hat=x1+K.*(x1-x2);
  %P_hat=P1-K.*P1;
  P=eye(length(x1))*1e8;
  R=[P1 covar; covar P2];
  H=[eye(length(x1));eye(length(x1))];
  
  K= (P*H')/(H*P*H'+R);
  x_hat=ones(3,1)+K*([x1;x2]-H*ones(3,1));
  P_hat=P-K*H*P;
  
endfunction
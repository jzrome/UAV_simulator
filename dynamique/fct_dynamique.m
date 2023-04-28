function [df,Jx,Ju] = fct_dynamique(w,q,wr,v,u,J,m,l,Cx,Cz,J_rotor,b,d,ke,R,g)
    
  omega = wr(2)+wr(4)-wr(1)-wr(3);
  Ceb=C_e_b(q);
    
  dw =[(w(2)*w(3)*(J(2)-J(3))-J_rotor*omega*w(2)+l*b*(wr(1)^2+wr(2)^2-wr(3)^2-wr(4)^2))/J(1);
       (w(3)*w(1)*(J(3)-J(1))+J_rotor*omega*w(1)+l*b*(wr(1)^2-wr(2)^2-wr(3)^2+wr(4)^2))/J(2);
       (w(1)*w(2)*(J(1)-J(2))+l*d*(-wr(1)^2+wr(2)^2-wr(3)^2+wr(4)^2))/J(3) ];
  
  dq =Omega(w)*q;
  
  dwr=(-d*wr.^2 - ke*ke/R*wr + ke/R*u)/J_rotor;
 
  %dv =(-[0;0;m*g]+Ceb'*[0;0;b*sum(wr.^2)]-Ceb'*([Cx;Cx;Cz].*(Ceb*v)))/m;
  dv = dyna_solid_trans(v,m,g,Ceb,Cx,Cz,b,wr);
  dx = v;
  
  df =[dw;dq;dwr;dv;dx]; 
  
  Jx=[ 0 (w(3)*(J(2)-J(3))-J_rotor*omega)/J(1) (w(2)*(J(2)-J(3)))/J(1);
           (w(3)*(J(3)-J(1))-J_rotor*omega)/J(2) 0 (w(1)*(J(3)-J(1)))/J(2);
           (w(2)*(J(1)-J(2)))/J(3) (w(1)*(J(1)-J(2)))/J(3) 0];
  Ju=0;
  
endfunction

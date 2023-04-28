function a=dyna_solid_trans(v,m,g,Ceb,Cx,Cz,b,wr)
  vb=(Ceb*v);
  a =(-[0;0;m*g]+Ceb'*[0;0;b*sum(wr.^2)]-Ceb'*(sign(vb).*[Cx;Cx;Cz].*(vb.^2)))/m;
endfunction

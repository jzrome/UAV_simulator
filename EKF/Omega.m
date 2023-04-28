function O=Omega(w) 
  %dq/dt=Omega(w)*q
  O=(0.5*[  0   -w(1) -w(2) -w(3);
           w(1)  0     w(3) -w(2);
           w(2) -w(3)  0     w(1);
           w(3)  w(2) -w(1)  0]);
end
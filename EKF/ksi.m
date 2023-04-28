function k=ksi(q)
%% ksi(q) :  dq/dt=0.5* [q ksi(q)] * [0; w]
k = [-q(2) -q(3) -q(4);
     q(1) -q(4)  q(3);
     q(4)  q(1) -q(2);
     -q(3)  q(2)  q(1)];
end
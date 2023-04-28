clear
close all
clc

%% X=A\B
%% A=L*L'

%% A*X=B
%% L*L'*X=B
%% L'*X=Y
%% Y=L'\B

n=3;
m=2;

%
%A=ceil(7*diag(rand(n,1)));
%R=ceil(5*rand(n));
%A=R*A*R'
%
%eigs_A=eigs(A)
%B=ceil(10*rand(n))


A= [49 25 59;
    25 13 31;
    59 31 75]
B= [2 3 7;
    8 5 9]'

%% decompositon cholesky
L=zeros(n);
temp=0;
for j = 1:n
    sum = 0;
    for k=1:j
        sum =sum + L(k,j) * L(k,j);
    end
    L(j,j) = sqrt(A(j,j) - sum);

    for i = j+1:n 
        sum = 0;
        for k =1:j
            sum = sum +L(k,i) * L(k,j);
        end
         temp = (A(i,j) - sum)/ L(j,j);
         L(i,j) =temp;
         L(j,i) =temp;
    end
end

L
Lref = chol(A);

%% down substitution

Y=zeros(n,m);
for j=1:m
  for i=1:n
    sum=0;
    for k=1:i-1
      sum =sum + L(i,k)*Y(k,j);
    endfor
    Y(i,j)=(B(i,j)-sum)/L(i,i);
  endfor
endfor

Y
Y_ref=Lref'\B

%% up substitution

X=zeros(n,m);
for j=1:m
  for i=n:-1:1
    sum=0;
    for k=i+1:n
      sum =sum + L'(i,k)*X(k,j);
    endfor
    X(i,j)=(Y(i,j)-sum)/L(i,i);
  endfor
endfor

X
X_ref=A\B


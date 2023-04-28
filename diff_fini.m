function df = diff_fini(f,x)
  h=1e-8;
  n=length(x);
  x_h=x.*ones(1,n)+h*eye(n);
  Y=f(x);
  df=ones(length(Y),n);
  for i=1:n
    df(:,i)=(f(x_h(:,i),x)-Y)/h;  
  end
end
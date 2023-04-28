
i=0;
x=(0:0.01:10);
n=4;
p=plot(x+i,[1:n].*sin(x+i)');
while(1)
  %set(p,"xdata",x+i,"ydata",[1 2 3]*sin(x+i)');
  p=plot(x+i,[1:n].*sin(x+i)');
  i=i+1;
  drawnow;
end

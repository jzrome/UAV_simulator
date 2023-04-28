clc
clear
close all

data=load("data/70_40_1s.data");
data=data(:,2);
t=linspace(0,1,length(data));
f=zeros(length(data),1);
helice=1;
index=1;
start=10;
level=(max(data)+min(data))/2;

for i=start:length(data)
  if data(i-1)>level && data(i)<level
    f(index:i)=1/(t(i)-t(index))/helice;
    index=i+1;
  endif
endfor
f(index:end)=f(index-1);
figure
plot(t,data)
grid on; grid minor
figure
plot(t,f)
grid on; grid minor
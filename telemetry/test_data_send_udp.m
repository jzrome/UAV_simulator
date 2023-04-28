clc
clear

pkg load instrument-control
s=udpport()
tic
while true
  t=toc;
  write(s,[t sin(t) cos(t)],"double","127.0.0.1", 30000);
  %read(s,3,"double")
  pause(0.1);
end

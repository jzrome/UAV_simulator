clc
clear
close all

t=load_bin_mtx("data/data1/t_float_2_nt.mtx")';
acc=load_bin_mtx("data/data1/acc_float_3_nt.mtx")';
gyro=load_bin_mtx("data/data1/gyro_float_3_nt.mtx")';
mag=load_bin_mtx("data/data1/mag_float_3_nt.mtx")';

figure
subplot(2,1,1)
plot(t(:,1),t(:,2))
title('temps d exectuion du programe')

subplot(2,1,2)
plot(t(2:end,1),diff(t(:,1)))
title('temps d exectuion de la boucle')

figure
subplot(3,1,1)
plot(t(:,1),acc)
title('Accelerometre')

subplot(3,1,2)
plot(t(:,1),gyro)
title('gyroscope')

subplot(3,1,3)
plot(t(:,1),mag)
title('magnetometre')

b_w=mean(gyro);
Q_w=var(gyro);
R_acc=var(acc);
R_mag=var(mag);

save_bin_mtx("data/b_w_lms_1_3.mtx",b_w,"float");
save_bin_mtx("data/Q_w_lms_1_3.mtx",Q_w,"float");
save_bin_mtx("data/R_acc_lms_1_3.mtx",R_acc,"float");
save_bin_mtx("data/R_mag_lms_1_3.mtx",R_mag,"float");
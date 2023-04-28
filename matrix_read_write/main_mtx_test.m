clc
clear
close all
A=ones(4,3)
save_bin_mtx("test.mtx",A,"float");

B=load_bin_mtx("test.mtx")

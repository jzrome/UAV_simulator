function retval = load_bin_mtx (file_name,type)

file=fopen(file_name,"r");
l=fread(file,1,"uint");
c=fread(file,1,"uint");

retval=fread(file,[l,c],type);

fclose(file);
endfunction

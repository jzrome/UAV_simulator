function retval = load_bin_mtx (file_name)

file=fopen(file_name,"r");
l=fread(file,1,"uint");
c=fread(file,1,"uint");
data_size=fread(file,1,"uint");

if data_size==8
  retval=fread(file,[l,c],"double");
elseif data_size==4
  retval=fread(file,[l,c],"float");
else
  printf("Type de donnée non reconnue\n")
end

fclose(file);
endfunction

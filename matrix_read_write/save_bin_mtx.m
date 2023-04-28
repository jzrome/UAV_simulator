function save_bin_mtx (file_name,data,type)
if nargin<=2
  type="double";
end

file=fopen(file_name,"w");
[l,c]=size(data);
fwrite(file,l,"uint");
fwrite(file,c,"uint");

if strcmp(type,"double")
  fwrite(file,8,"uint");
elseif strcmp(type,"float")
  fwrite(file,4,"uint");
else
  printf("type non reconnue");
  fclose(file);
  return
end

fwrite(file,data,type);

fclose(file);
endfunction
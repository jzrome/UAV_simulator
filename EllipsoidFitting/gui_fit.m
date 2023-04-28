clc
close all
clear h

%graphics_toolkit qt

h.ax = axes ("position", [0.1 0.2 0.8 0.8]);
h.valid_data=false;
function update_plot (obj, init = false)
  ## gcbo holds the handle of the control
  h = guidata (obj);
  new_data = false;
  new_method = false;
  
  switch (gcbo)
    case {h.open_data}
      [data_file,file_path] = uigetfile ("*.mtx");
      str=strcat(file_path,data_file);
      printf(str);printf("\n");
      h.data=load_bin_mtx(str);
      new_data = true;
    case {h.minor_grid}
      v = get (gcbo, "value");
      grid ("minor", merge (v, "on", "off"));
    case {h.cab_method}
      new_method = true;
    case {h.calib_tri}
      new_method =true;
    case {h.radius_edit}
      new_method=true;
    case {h.save_calib}
      if h.valid_data
        [data_file,file_path] = uiputfile("data/*mtx","K matrix");
        str=strcat(file_path,data_file);
        save_bin_mtx(str,h.K);
        disp("K=")
        disp(h.K)
        disp(" ")
        
        [data_file,file_path] =  uiputfile("data/*mtx","biais vector");
        str=strcat(file_path,data_file);
        save_bin_mtx(str,h.center);
        disp("Center=")
        disp(h.center)
        disp(" ")
        
      end
    
  endswitch
  if init
    h.plot=plot3(0,0,0,0,0,0);
  end
  if (new_data)
    X=h.data;
    set (h.plot(1),"xdata",X(1,:), "ydata", X(2,:), "zdata", X(3,:));
    h.valid_data=true;
  end
  if h.valid_data && (new_data||new_method)
    X=h.data;
    num_meth = get (h.cab_method, "string"){get (h.cab_method, "value")};
    num_meth = strtrim (num_meth(1:2));
    tri= get (h.calib_tri,"value");
    [center, K] =ellipsoid_fit( X(1,:)',X(2,:)',X(3,:)', num_meth-48 ,tri);
    h.K=K;
    h.center=center;
    R = str2double(get (h.radius_edit, "string"));
    X=R*K*(X-center);
    set (h.plot(2),"xdata",X(1,:), "ydata", X(2,:), "zdata", X(3,:));
  end
guidata (obj, h);
endfunction

## grid
h.minor_grid = uicontrol ("style", "checkbox","units", "normalized","string", "minor grid","value", 0,"callback", @update_plot,"position", [0.0 -0.01 0.35 0.09]);

## triangular  calib matrix
h.calib_tri= uicontrol ("style", "checkbox","units", "normalized","string", "triag calib matx","value", 0,"callback", @update_plot,"position", [0.0 0.06 0.35 0.09]);

## open data
h.open_data = uicontrol ("style", "pushbutton","units", "normalized","string", "Open data","callback", @update_plot,"position", [0.64 0.0 0.15 0.08]);

## store calib matrix
h.save_calib = uicontrol ("style", "pushbutton","units", "normalized","string", "Save calib","callback", @update_plot,"position", [0.8 0.0 0.15 0.08]);

## fiting methods
h.cab_method_label = uicontrol ("style", "text", "units", "normalized", "string", "Fittng style:", "horizontalalignment", "left", "position", [0.30 0.05 0.2 0.08]);
h.cab_method = uicontrol ("style", "popupmenu", "units", "normalized", "string", {"0 ellipsoid scale rot","1 ellipsoid scale rot 2","2 ellipsoid scale","3 sphere scale"},"callback", @update_plot,"position", [0.20 0.00 0.3 0.06]);set (gcf, "color", get(0, "defaultuicontrolbackgroundcolor"))

## sphere radus
h.radius_label = uicontrol ("style", "text","units", "normalized","string", "R:","horizontalalignment", "center","position", [0.56 0.05 0.05 0.06]);
h.radius_edit = uicontrol ("style", "edit","units", "normalized","string", "47","callback", @update_plot,"position", [0.56 0.00 0.05 0.06]);


guidata (gcf, h)
update_plot (gcf, true);
clc
close all
clear h

graphics_toolkit qt
%graphics_toolkit fltk
pkg load instrument-control
figure
pause(1)
set(gcf,'position',[80 350 900 550])

function h=loop(h)
  n=h.num_curve;
  n_t=str2double(get(h.buffer_edit,"string"));
  buffer=nan(n_t,n+1);
  %buffer(:,1)=linspace(0,n_t/2,n_t);
  %buffer(:,2:n+1)=(1:n).*sin(buffer(:,1));
  udp=udpport("LocalPort",str2double(get(h.port_edit,"string")));
  set(udp,"Timeout",1);
  
  
  affiche=false(n,h.num_plot);
  scale=zeros(n,h.num_plot);
  shift=zeros(n,h.num_plot);
  Npt=zeros(1,h.num_plot);
  for i=1:h.num_plot
    [affiche(:,i),scale(:,i),shift(:,i),Npt(i)]=Read_panel(n,h.panel(i));
  end
  h.panel_change(:)=false;
  guidata(h.start,h);
  
  continu=true;
  index=1;
  tic
  while continu
    %disp(index)
    %tic
    h=guidata(h.start);
    continu= h.run;
    if any(h.panel_change)
      for i = find(h.panel_change)
        [affiche(:,i),scale(:,i),shift(:,i),Npt(i)]=Read_panel(n,h.panel(i));
      end
      h.panel_change(:)=false;
      guidata(h.start,h);
    end
    %toc
    buffer(index,:)=read(udp,n+1,"double");
    
    %tic
    if(toc>0.3)
    for i=1:h.num_plot
      if index-Npt(i)<=0
        plot(h.ax(i),[buffer(end-Npt(i)+index+1:end,1); buffer(1:index,1)],scale(affiche(:,i),i)'.*(buffer([end-Npt(i)+index+1:end 1:index],[false affiche(:,i)'])-shift(affiche(:,i),i)'))
      else
        plot(h.ax(i),buffer(index-Npt(i):index,1),scale(affiche(:,i),i)'.*(buffer(index-Npt(i):index,[false affiche(:,i)'])-shift(affiche(:,i),i)'))
      end
    end
    tic
  end
  %toc
  
  %tic
  index=index+1;
  if index>n_t
    index=1;
  end
  drawnow;
  %toc
end
h.buffer=circshift(buffer,-index+1);
end

function update_plot (obj, init = false)
## gcbo holds the handle of the control
h = guidata (obj);
new_plot = false;
new_buffer =false;
stop=false;
switch (obj)
  case {h.buffer_edit}
    n=str2double(get(h.buffer_edit,"string"));
    if isnan(n)
      set(h.buffer_edit,"string","1000");
    else
      set(h.buffer_edit,"string",num2str(min(n,10000000)));
    end
    stop=true;
  case {h.subplot_pop}
    stop=true;  
    new_plot=true;
  case {h.size_pop}
    new_plot=true;
    h.run=false;
  case {h.start}
    if h.run
      stop=true;
    else
      h.buffer=[];
      h.run=true;
      guidata(obj,h);
      set(h.start,"string","Stop","backgroundcolor",[0.8400 0.8400 0.8400]);
      h=loop(h);      
    end
    
  case {h.save_buffer}
    stop=true;
    pause(1);
    h=guidata(obj,h);
    data=h.buffer;
    [data_file,file_path] = uiputfile("data/*.mat","Save buffer");
    save("-binary",strcat(file_path,data_file),'data');
    
endswitch

if init
  h.run=false;
  h.buffer=[];
end
if stop
  h.run=false;
  guidata(obj,h);
  set(h.start,"string","Start","backgroundcolor",[0.9400 0.9400 0.9400]);
end
if new_plot || init
  if new_plot
    delete(h.ax);
    delete(h.panel);
  end
  h.ax=[];
  h.panel=[];
  h.num_plot=get(h.subplot_pop,"value");
  h.num_curve=get(h.size_pop,"value");
  h=creat_plots_panels(h);
  h.panel_change=false(h.num_plot,1);
end  
guidata (obj, h);
endfunction

function h=creat_plots_panels(h)
n_p=h.num_plot;
for i=1:n_p
  h.ax(i)=axes("position", [0.04 0.9-0.9/n_p*i+0.05 0.70 0.9/n_p-0.05],"xgrid","on","ygrid","on"); 
  h.panel(i) = creat_panel(h,i);
end
end

function p=creat_panel(h,n_i)
data.n_i=n_i;
n_p=h.num_plot;
p = uipanel ("position", [0.75 0.9-n_i*0.9/n_p 0.24 0.9/n_p]);
for i=1:h.num_curve
  data.affiche(i) = uicontrol ("parent",p,"style", "checkbox","units", "normalized","string", num2str(i),"value",1,"callback", @panel_changing,"position", [0.0 0.90-0.1*(i-1) 0.25 0.1]);
  data.scale(i) = uicontrol ("parent",p,"style", "edit","units", "normalized","string", "1","callback", @panel_changing,"position", [0.25 0.90-0.1*(i-1) 0.25 0.1]);
  data.shift(i) = uicontrol ("parent",p,"style", "edit","units", "normalized","string", "0","callback", @panel_changing,"position", [0.5 0.90-0.1*(i-1) 0.25 0.1]);
end
data.Npt = uicontrol ("parent",p,"style", "edit","units", "normalized","string", "100","callback", @panel_changing,"position", [0.75 0.90 0.25 0.1]);
data.autoscale = uicontrol ("parent",p,"style", "pushbutton","units", "normalized","string","auto-\nscale","position", [0.75 0.7 0.25 0.2]);
set(p,"userdata",data)
end
function [affiche,scale,shift,Npt]=Read_panel(num_curve,pan)
data=get(pan,"userdata");
affiche=false(num_curve,1);
scale=zeros(num_curve,1);
shift=zeros(num_curve,1);
for i=1:num_curve
  affiche(i)=get(data.affiche(i),"value")>0;
  scale(i)=str2double(get(data.scale(i),"string"));
  shift(i)=str2double(get(data.shift(i),"string"));
end
Npt=str2double(get(data.Npt,"string"));
end
function panel_changing(obj,event)
pan=get(obj,"parent");
data=get(pan,"userdata");
h=guidata(pan);
h.panel_change(data.n_i)=true;
guidata(pan,h);
end

## Buffer size
buffer_label = uicontrol ("style", "text","units", "normalized","string", "Buffer","horizontalalignment", "center","position", [0.03 0.93 0.05 0.06]);
h.buffer_edit = uicontrol ("style", "edit","units", "normalized","string", "1000","callback", @update_plot,"position", [0.09 0.93 0.07 0.06]);
h.size_pop = uicontrol ("style", "popupmenu", "units", "normalized", "string", {"1","2","3","4","5","6","7","8","9","10"},"value",2,"callback", @update_plot,"position", [0.17 0.93 0.04 0.06]);

## Port Adresse 
port_label = uicontrol ("style", "text","units", "normalized","string", "IP Port","horizontalalignment", "center","position", [0.22 0.93 0.05 0.06]);
h.port_edit = uicontrol ("style", "edit","units", "normalized","string", "30000","callback", @update_plot,"position", [0.27 0.93 0.07 0.06]);


## num subplot
subplot_label = uicontrol ("style", "text", "units", "normalized", "string", "N plot", "horizontalalignment", "left", "position", [0.35 0.93 0.1 0.06]);
h.subplot_pop = uicontrol ("style", "popupmenu", "units", "normalized", "string", {"1","2","3","4"},"callback", @update_plot,"position", [0.40 0.93 0.04 0.06]);


## start
h.start = uicontrol ("style", "pushbutton","units", "normalized","string", "Start","callback", @update_plot,"position", [0.49 0.92 0.10 0.07]);

## save_buffer
h.save_buffer = uicontrol ("style", "pushbutton","units", "normalized","string", "Save buffer","callback", @update_plot,"position", [0.60 0.92 0.15 0.07]);

# text 
uicontrol ("style", "text","units", "normalized","string", "Scale","horizontalalignment", "center","position", [0.815 0.93 0.05 0.04]);
uicontrol ("style", "text","units", "normalized","string", "Shift","horizontalalignment", "center","position", [0.875 0.93 0.05 0.04]);
uicontrol ("style", "text","units", "normalized","string", "Npt","horizontalalignment", "center","position", [0.935 0.93 0.05 0.04]);


set (gcf, "color", get(0, "defaultuicontrolbackgroundcolor"))
guidata (gcf, h);
update_plot (gcf, true);

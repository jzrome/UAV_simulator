clc
clear
%close all
%graphics_toolkit("fltk");

calibration_mode =struct('ellipsoid_scale_rotate_1',1,'ellipsoid_scale_rotate_2',2,'ellipsoid_scale_small_rotate_1',3,' ellipsoid_scale_small_rotate_2',4,' ellipsoid_scale',5);

f=1;
%G=9.81; 
G=43;
if f==0
  %% generate test data:
  [s, t]=meshgrid(-pi/2+0.3:0.3:pi/2, 0.3:0.3:2*pi);
  
  % create test data:
  a=30; b=33; c=27; ab=-5; bb=2; cb=3;
  xx=a*cos(s).*cos(t)+ab;
  yy=b*cos(s).*sin(t)+bb;
  zz=c*sin(s)+cb;
  
  % add testing noise:
  noiseIntensity = 1;
  xx=xx+randn(size(s))*noiseIntensity;
  yy=yy+randn(size(s))*noiseIntensity;
  zz=zz+randn(size(s))*noiseIntensity;
  dx=xx(:); dy=yy(:); dz=zz(:);
else
    %X=load_bin_mtx("data/data2/acc_float_3_nt.mtx")';
    X=load_bin_mtx("data/data2/mag_float_3_nt.mtx")';
    dx=X(:,1);
    dy=X(:,2);
    dz=X(:,3);
end

% fitting 
[ center0, K0, v0 ] = ellipsoid_fit( dx,dy,dz, 0 ,1);
[ center1, K1, v1 ] = ellipsoid_fit( dx,dy,dz, 1 ,1);
[ center2, K2, v2 ] = ellipsoid_fit( dx,dy,dz, 2 ,0);

%calibrated
X=[dx dy dz]';
X0=G*K0*(X-center0);
X1=G*K1*(X-center1);
X2=G*K2.*(X-center2);

##% draw fitting:
##v=v0;
##minX=min(dx);  maxX=max(dx);
##minY=min(dy);  maxY=max(dy);
##minZ=min(dz);  maxZ=max(dz);
##nStep=20;
##stepA=(maxX-minX)/2/nStep; stepB=(maxY-minY)/2/nStep; stepC=(maxZ-minZ)/2/nStep;
##[x, y, z]=meshgrid(minX:stepA:maxX, minY:stepB:maxY, minZ:stepC:maxZ);
##SolidObj=v(1)*x.*x+v(2)* y.*y+v(3)*z.*z+ 2*v(4)*y.*z + 2*v(5)*x.*z + 2*v(6)*x.*y+ 2*v(7)*x + 2*v(8)*y + 2*v(9)*z -ones(size(x));
##figure
##p = patch(isosurface(x,y,z,SolidObj, 0.0));
##isonormals(x,y,z,SolidObj, p);
##set(p, 'FaceColor', 'y', 'EdgeColor', 'none');
##daspect([1 1 1]);
##view(3);
##camlight ;
##lighting flat;
##hold on;
##plot3(dx, dy, dz, '.');% draw data

% draw corrected data
center=center0;
X=X0;
figure
hold on
plot3(dx-center(1), dy-center(2), dz-center(3), 'k--');
plot3(X(1,:),X(2,:),X(3,:),'g')
plot3(X1(1,:),X1(2,:),X1(3,:),'b')
plot3(X2(1,:),X2(2,:),X2(3,:),'r')
grid on; grid minor
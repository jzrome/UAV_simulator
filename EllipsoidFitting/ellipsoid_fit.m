function [ center, K, v ] = ellipsoid_fit( x,y,z, flag ,flag2)
  
  if (flag == 0 || flag ==1) && length( x ) < 9 
    error( 'Must have at least 9 points to fit a unique ellipsoid' );
  end
  if flag == 2 && length( x ) < 6 
    error( 'Must have at least 6 points to fit a unique oriented ellipsoid' );
  end
  if flag == 3 && length(x)<4
    error('Must have at least 4 points to fit a unique sphere');
  end
  
  if flag == 0 || flag==1
    if flag==0
      % fit ellipsoid in the form Ax^2 + By^2 + Cz^2 + 2xy + 2Exz + 2Fyz + 2Gx + 2Hy + 2Iz = 1
      D=[x.*x, y.*y,  z.*z, 2.*y.*z, 2.*x.*z, 2.*x.*y, 2.*x, 2.*y, 2.*z];
      v = ( D' * D ) \ ( D' * ones(length(x), 1 ) );
    else
      x2=x.*x; y2=y.*y; z2=z.*z;
      D = [x2+y2-2*z2, x2-2*y2+z2, 4*x.*y, 2*x.*z, 2*y.*z, 2*x, 2*y, 2*z, ones(length(x),1)];
      E = x2+y2+z2;
      b = (D'*D)\(D'*E);
      S=[3   1   1   0   0   0   0   0   0   0;
      3   1  -2   0   0   0   0   0   0   0;
      3  -2   1   0   0   0   0   0   0   0;
      0   0   0   1   0   0   0   0   0   0;
      0   0   0   0   1   0   0   0   0   0;
      0   0   0   0   0   1   0   0   0   0;
      0   0   0   0   0   0   1   0   0   0;
      0   0   0   0   0   0   0   1   0   0;
      0   0   0   0   0   0   0   0   1   0;
      0   0   0   0   0   0   0   0   0   1];
      v=S*[-1/3; b];
      v=-v/v(10);
    end
    % form the algebraic form of the ellipsoid
    A = [ v(1) v(4) v(5) v(7); ...
    v(4) v(2) v(6) v(8); ...
    v(5) v(6) v(3) v(9); ...
    v(7) v(8) v(9) -1 ];
    % find the center of the ellipsoid
    center = -A( 1:3, 1:3 ) \ [ v(7); v(8); v(9) ];
    % form the corresponding translation matrix
    T = eye( 4 );
    T( 4, 1:3 ) = center';
    % translate to the center
    R = T * A * T';
    % solve the calibration matrix
    if flag2
      K=eye(3)*chol(R( 1:3, 1:3 )/-R(4,4) );
    else
      [rotM ev]=eig(R(1:3,1:3)/-R(4,4)); 
      gain=sqrt(1./diag(ev));
      K=(rotM*diag(1./gain))';
    end
  elseif flag == 2
    % fit ellipsoid in the form Ax^2 + By^2 + Cz^2 + 2Gx + 2Hy + 2Iz = 1
    D = [ x .* x,   y .* y,  z .* z, 2 * x, 2 * y,  2 * z ]; 
    v = ( D' * D ) \ ( D' * ones(length(x), 1 ) );
    % find the ellipsoid parameters
    center=-v(4:6)./v(1:3);
    % solve the calibration matrix
    G=1+sum(v(4:6).^2./v(1:3));
    K=diag(sqrt(v(1:3)/G));
  elseif flag == 3
    % fit sphere
    D = [ x .* x + y .* y + z .* z, 2 * x, 2 * y,  2 * z ]; 
    v = ( D' * D ) \ ( D' * ones(length(x), 1 ) );
    center=-v(2:4)/v(1);
    G=1+sum(v(2:4).^2./v(1));
    K=diag(sqrt(v([1 1 1])/G));
  end
  
  

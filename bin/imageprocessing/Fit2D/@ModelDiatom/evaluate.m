function [ f, xb ] = evaluate( model, x )
  global xg yg
  
  f = zeros(size(xg));
   
  xc = x(1) + x(6)/2*cos(x(5)) - x(7)/2*cos(pi/2-x(5));
  yc = x(2) + x(6)/2*sin(x(5)) + x(7)/2*sin(pi/2-x(5));
  f = f + exp( -(x(3)*( (xg-xc)*cos(x(5)) + (yg-yc)*sin(x(5))).^2 + x(4)*( -(xg-xc)*sin(x(5)) + (yg-yc)*cos(x(5))).^2));

  xc = x(1) + x(6)/2*cos(x(5)) + x(7)/2*cos(pi/2-x(5));
  yc = x(2) + x(6)/2*sin(x(5)) - x(7)/2*sin(pi/2-x(5)); 
  f = f + exp( -(x(3)*( (xg-xc)*cos(x(5)) + (yg-yc)*sin(x(5))).^2 + x(4)*( -(xg-xc)*sin(x(5)) + (yg-yc)*cos(x(5))).^2));

  xc = x(1) - x(6)/2*cos(x(5)) + x(7)/2*cos(pi/2-x(5));
  yc = x(2) - x(6)/2*sin(x(5)) - x(7)/2*sin(pi/2-x(5));
  f = f + exp( -(x(3)*( (xg-xc)*cos(x(5)) + (yg-yc)*sin(x(5))).^2 + x(4)*( -(xg-xc)*sin(x(5)) + (yg-yc)*cos(x(5))).^2));

  xc = x(1) - x(6)/2*cos(x(5)) - x(7)/2*cos(pi/2-x(5));
  yc = x(2) - x(6)/2*sin(x(5)) + x(7)/2*sin(pi/2-x(5));
  f = f + exp( -(x(3)*( (xg-xc)*cos(x(5)) + (yg-yc)*sin(x(5))).^2 + x(4)*( -(xg-xc)*sin(x(5)) + (yg-yc)*cos(x(5))).^2));

  f = x(8) * f;
  
end
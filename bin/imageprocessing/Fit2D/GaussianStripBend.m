function [ f, xb ] = GaussianStripBend( x )
%GAUSSIANSTRIP creates an image with a gaussian wall of height 1.0 and
%same dimensions as the grids 'xg' and 'yg'
% arguments:
%   x     input variables for the ray describing the gaussian:
%            1  x-position of the start point of the ray
%            2  y-position of the start point of the ray
%            3  angle between this ray and the x-axis
%            4  curvature
%            5  width of the gaussian 
% results:
%   f     the returned grey image
%   xb        the jacobian of the image with respect to the input variable x
%             this is optional and only calculated, if requested

  global xg yg; % load roi grids from global scope

  % calculate distance on ray
  t = ( x(1) - xg ) .* cos(x(3)) - ( yg - x(2) ) .* sin(x(3));
  
  % calculate orientated distance to ray
  d = ( yg - x(2) ) .* cos(x(3)) + ( x(1) - xg ) .* sin(x(3)) + x(4) * t.^2;
  
  if nargout == 1
    % use this for gaussian
    f = exp( - d.^2 * x(5) );
  else
    xb = zeros( numel(xg), 5 ); % preallocate memory
    
    % calculate intermediate variables and value of function  
    temp = d.^2 * x(5);
    f = exp( -temp );
    db = - 2 * x(5) .* d .* f;
    tb = 2 * x(4) .* t .* db;
     
    % calculate jacobian
    xb(:,1) = sin(x(3)) .* db + cos(x(3)) .* tb;
    xb(:,2) = - cos(x(3)) .* db + + sin(x(3)).*tb;
    xb(:,3) = ( (yg-x(2)) .* sin(x(3)) - (x(1)-xg) .* cos(x(3)) ) .* db ...
            + ( (yg-x(2)) .* cos(x(3)) + (x(1)-xg) .* sin(x(3)) ) .* tb;
    xb(:,4) = - t.^2 .* db;
    xb(:,5) = f .* d.^2;
   
  end
end
function [ f, xb ] = HalfPlane( x )
%HALFPLANE calculates the values for an antialaised image of the size given in
%the global grid variables 'xg' and 'yg' covered by a half plane described by a
%startpoint 's' and an angle 'o'
% arguments
%   x         3-vector describing the origin of the ray and its orientation
%             the half plane is on the left of that ray
%             1: x-coordinate
%             2: y-coordinate
%             3: orientation
% results:
%   f         the generated grey image
%   xb        the jacobian of the image with respect to the input variable x
%             this is optional and only calculated, if requested

  global xg yg; % load global grid
  
  % calculate distance from ray
  f = ( yg - x(2) ) * cos(x(3)) + ( x(1) - xg ) * sin(x(3)) + 0.5;
  
  % check, if derivative is needed
  if nargout > 1
    xb = zeros( numel(xg), 3 ); % preallocate memory
    
    % get entries witch do not lie between 0 and 1
    %(all other values have constant derivatives)
    idx = ( f <= 1 & f >= 0 );
    % set derivatives
    xb( idx, 1 ) = sin(x(3));
    xb( idx, 2 ) = -cos(x(3));
    xb( idx, 3 ) = ( x(1) - xg(idx) ) * cos(x(3)) - ( yg(idx) - x(2) ) * sin(x(3));

  end

  % truncate values
  f( f < 0 ) = 0;
  f( f > 1 ) = 1;
  
end

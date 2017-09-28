function [ f, xb ] = evaluate( model, x )
  global xg yg
  
  if nargout == 1 % calculate value of function
    f = x(6) * exp( -(x(3)*( (xg-x(1))*cos(x(5)) + (yg-x(2))*sin(x(5))).^2 + x(4)*( -(xg-x(1))*sin(x(5)) + (yg-x(2))*cos(x(5))).^2));
                
  else % calculate value of function and jacobian 'xb'
    xb = zeros( numel( xg ), 6 ); % allocate memory
    
    % calculate temporary variables and value of function in ...
    % ... forward direction
    tempx = (xg-x(1));
    tempy = (yg-x(2));
    
    tempxr = tempx*cos(x(5)) + tempy*sin(x(5));
    tempyr = -tempx*sin(x(5)) + tempy*cos(x(5));
    
    temp = x(3) * tempxr.^2 + x(4) * tempyr.^2;
    % ... backward direction
    tempb = exp(-temp);
    f = x(6) .* tempb;
    
    % calculate derivative  
    xb(:,1) = - 2 * ( x(3) * cos(x(5)) * tempxr - x(4) * sin(x(5)) * tempyr) .* f;
    xb(:,2) = - 2 * ( x(3) * sin(x(5)) * tempxr + x(4) * cos(x(5)) * tempyr) .* f;    
    xb(:,3) = tempxr.^2 .* f;
    xb(:,4) = tempyr.^2 .* f;
    xb(:,5) = 2 * ( x(3) * tempxr .* tempyr - x(4) * tempxr .* tempyr) .*f;
    xb(:,6) = - tempb;
  end
  
end
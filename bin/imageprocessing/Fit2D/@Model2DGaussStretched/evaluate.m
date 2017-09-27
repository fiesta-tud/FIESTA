function [ f, xb ] = evaluate( model, x )
  global xg yg
  
  if nargout == 1 % calculate value of function
    f = x(6) * exp( - ( x(3) * (xg-x(1)).^2 +...
                        x(4) * (xg-x(1)) .* (yg-x(2)) +...
                        x(5) * (yg-x(2)).^2 ) );  
                
  else % calculate value of function and jacobian 'xb'
    xb = zeros( numel( xg ), 6 ); % allocate memory
    
    % calculate temporary variables and value of function in ...
    % ... forward direction
    tempx = (xg-x(1));
    tempy = (yg-x(2));
    
    temp = x(3) * tempx.^2 + x(4) * tempx .* tempy + x(5) * tempy.^2;
    % ... backward direction
    tempb = exp(-temp);
    f = x(6) .* tempb;
    
    % calculate derivative
    xb(:,1) = - (2 * tempx * x(3) + x(4) * tempy) .* f;
    xb(:,2) = - (2 * tempy * x(5) + x(4) * tempx) .* f;
    xb(:,3) = tempx.^2 .* f;
    xb(:,4) = tempy .* tempy .* f;
    xb(:,5) = tempy.^2 .* f;
    xb(:,6) = - tempb;
  end
  
end
function value = transformResult( model, x, xe, data )
  value.x = double_error( x(1:2) + data.offset, xe(1:2) );
  value.o = double_error( [] );
  
  % rearrange width parameters
  value.w(1:3) = double_error( zeros(1,3) ); % init width values
  
  if x(3)>x(4)
    value.w(1) = sqrt( 2.77258872223978 ./ double_error( x(4), xe(4) ) );
    value.w(2) = sqrt( 2.77258872223978 ./ double_error( x(3), xe(3) ) );
    if x(5) > 0
      value.w(3) = double_error( -x(5)+pi/2, xe(5) );
    else
      value.w(3) = double_error( -x(5)-pi/2, xe(5) ); 
    end
  elseif x(3)==x(4)
    value.w(1) = sqrt( 2.77258872223978 ./ double_error( x(3), xe(3) ) );
    value.w(2) = value.w(1);
  else
    value.w(1) = sqrt( 2.77258872223978 ./ double_error( x(3), xe(3) ) );
    value.w(2) = sqrt( 2.77258872223978 ./ double_error( x(4), xe(4) ) );  
    value.w(3) = double_error( -x(5), xe(5) );
  end
  
  value.h = double_error( x(6), xe(6) );
  value.r = double_error( [] );  
  value.b = data.background;
end
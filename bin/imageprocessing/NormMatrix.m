function n = NormMatrix( m, axis )
%NORMMATRIX calculates the norm of all matrix elements along a specified axis
% arguments:
%   m     the matrix
%   axis  the axis on which the norm should be evaluated
% result:
%   n     a new matrix with dimension 'axis' reduced to 1

  error( nargchk( 1, 2, nargin ) );
  
  if nargin == 1
    n = sqrt( sum( m.^2 ) );
  else
    n = sqrt( sum( m.^2, axis ) );
  end
end

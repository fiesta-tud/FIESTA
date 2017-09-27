function Log( msg, params )
%LOG handels all output of the algorithm
% arguments:
%  msg      a string representing the message that should be logged
%  params   a struct containing the parameters for the program

  narginchk( 2, 2 ) ;

  global logfile
  
  if mod( params.display, 2 ) == 1 % do logging
    c = clock;
    if logfile > 0 % save text to file
      try
        fprintf( logfile, '%02u:%02u:%02u  %s\n' , c(4), c(5), fix(c(6)), msg );
      catch
        err = lasterror();
        if strcmp( err.identifier, 'MATLAB:badfid_mx' )
          logfile = [];
        else
          rethrow( err );
        end
      end
    else % output text to console
      disp( sprintf( '%02u:%02u:%02u  %s' , c(4), c(5), fix(c(6)), msg ) );
    end
  end
end
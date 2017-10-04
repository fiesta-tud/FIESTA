function objects = InterpolateData( obj, img, params )
%INTERPOLATEDATA uses the data gained by fitting to calculate further useful
%details of the objects. The additional values are stored as new fields inside
%the 'objects' struct.
% arguments:
%   obj       the input objects array
%   img       the original grey version of the image
%   params    the parameter struct
% results:
%   objects   the output objects array

  narginchk( 3, 3 ) ;
  
  global error_events;
  
  % run through all objects
  obj_id = 1;
  while obj_id <= numel(obj)
    
    if isempty( obj(obj_id).p ) % empty objects have to be ignored
      obj(obj_id) = [];
      error_events.empty_object = error_events.empty_object + 1;
      continue
    end
    
    % pass creation time given by external caller to the struct, such that it
    % migth be used later on
    objects.time = single( params.creation_time );
    if params.include_data==1
        objects.points{obj_id} = obj(obj_id).p;
    else
        objects.points{obj_id} = [];
    end
    % estimate total length, center of object and interpolate additional data
    if numel( obj(obj_id).p ) <= 1 % point object
      
      % calculate additional data
      objects.center_x(1,obj_id) = single( double(obj(obj_id).p(1).x(1)) * params.scale );
      objects.center_y(1,obj_id) = single( double(obj(obj_id).p(1).x(2)) * params.scale );
      objects.com_x(:,obj_id) = single( [obj(obj_id).p(1).x(1).value; obj(obj_id).p(1).x(1).error] * params.scale );
      objects.com_y(:,obj_id) = single( [obj(obj_id).p(1).x(2).value; obj(obj_id).p(1).x(2).error] * params.scale );
      objects.orientation(:,obj_id) = single( [0; 0]); 
      objects.length(:,obj_id) = single( [0; 0]);
      
      if numel( obj(obj_id).p(1).w ) == 3 && numel( obj(obj_id).p(1).h ) == 1
        %stretched gaussian
        width = single( [ mean( [obj(obj_id).p(1).w(1).value obj(obj_id).p(1).w(2).value] ); mean( [obj(obj_id).p(1).w(1).error obj(obj_id).p(1).w(2).error] ) ] * params.scale );
        data = single([obj(obj_id).p(1).w(1).value; obj(obj_id).p(1).w(2).value] * params.scale );
        objects.orientation(:,obj_id) = single( [ obj(obj_id).p(1).w(3).value; obj(obj_id).p(1).w(3).error ] );
      elseif numel( obj(obj_id).p(1).w ) > 1 && numel( obj(obj_id).p(1).h ) > 1
        %gaussian with rings
        width = single( [obj(obj_id).p(1).w(1).value; obj(obj_id).p(1).w(1).error] * params.scale );
        
        data = single([obj(obj_id).p(1).r(1).value*params.scale obj(obj_id).p(1).w(1).value*params.scale obj(obj_id).p(1).h(1).value;...
                       obj(obj_id).p(1).r(2).value*params.scale obj(obj_id).p(1).w(2).value*params.scale obj(obj_id).p(1).h(2).value]);
        data(1,:) = [];
      elseif numel( obj(obj_id).p(1).w ) == 2 && numel( obj(obj_id).p(1).r ) == 2
        %diatom
        width = single( [ mean( [obj(obj_id).p(1).w(1).value obj(obj_id).p(1).w(2).value] ); mean( [obj(obj_id).p(1).w(1).error obj(obj_id).p(1).w(2).error] ) ] * params.scale );
        data = single([obj(obj_id).p(1).w(1).value obj(obj_id).p(1).w(2).value; obj(obj_id).p(1).r(1).value obj(obj_id).p(1).r(2).value] * params.scale );
        objects.orientation(:,obj_id) = single( [ obj(obj_id).p(1).o(1).value; obj(obj_id).p(1).o(1).error ] );
      else
        width = single( [obj(obj_id).p(1).w(1).value; obj(obj_id).p(1).w(1).error] * params.scale );
        data = [];
      end
      
      objects.width(:,obj_id) = width;
      objects.height(:,obj_id) = single( [obj(obj_id).p(1).h(1).value; obj(obj_id).p(1).h(1).error] );
      objects.background(:,obj_id) = single( [obj(obj_id).p(1).b(1).value; obj(obj_id).p(1).b(1).error] );
      
      % save point in final data struct
      objects.data{obj_id} = single( data );
      
    else % elongated object
        
      % init variables
      seg_length = zeros( 1, numel(obj(obj_id).p) );  %<< the length start of each segment on the filament
      x_coeff = zeros( numel(obj(obj_id).p) - 1, 3 ); %<< the 3 coefficients for the interpolation in x-direction for each segment
      y_coeff = zeros( numel(obj(obj_id).p) - 1, 3 ); %<< the 3 coefficients for the interpolation in y-direction for each segment

      % run through all sections
      k = 1;
      while k < numel( obj(obj_id).p ) % run through all points but the last one
        
        % get the two points in question
        s = obj(obj_id).p(k);
        e = obj(obj_id).p(k+1);
        
        % ignore errors for the spline interpolation (converting to double)
        s.x = double( s.x );
        s.o = double( s.o );
        e.x = double( e.x );
        e.o = double( e.o );

        % distinguish several cases of the positions of the two points
        if all( s.x == e.x ) % identical points (this should not happen though) => ignore

          error_events.degenerated_fil = error_events.degenerated_fil + 1;
          seg_length(k+1) = [];
          x_coeff(k,:) = [];
          y_coeff(k,:) = [];
          obj(obj_id).p(k) = [];          
          continue
          
        elseif abs( e.x(1) - s.x(1) ) < eps( e.x(2) ) % points directly above each other
          
          if e.x(2) > s.x(2)
            p = e.x(2) - s.x(2);
            rot = pi/2;
          else
            p = s.x(2) - e.x(2);
            rot = -pi/2;
          end
          
        else % general case

          % rotate space to get a real function
          rot = atan2( e.x(2) - s.x(2), e.x(1) - s.x(1) );
          p = ( e.x(1) - s.x(1) ) ./ cos( rot ); %<< distance between points
          
        end

        % calculate the slope for the rotated version
        if abs(mod(s.o - rot,pi)-pi/2) < 10/360*pi 
           s.o = rot; 
        end
        if abs(mod(e.o - rot,pi)-pi/2) < 10/360*pi 
           e.o = rot; 
        end
        slope1 = tan( s.o - rot );
        slope2 = tan( e.o - rot );

        % calculate cubic function coefficients (the formulas are derived in the
        % documentation (take non-matrix functions, because otherwise
        % double_error wont work
        c(1) = ( slope1 + slope2 ) ./ p.^2;
        c(2) = -( 2 * slope1 + slope2 ) ./ p;
        c(3) = slope1;

        % rotate back to get the real space cubic coefficients
        % and transform to have parameter in range [0 1]
        x_coeff(k,:) = [ -sin(rot)*c(1)*p.^3 -sin(rot)*c(2)*p.^2 (-sin(rot)*c(3)+cos(rot))*p ];
        y_coeff(k,:) = [  cos(rot)*c(1)*p.^3  cos(rot)*c(2)*p.^2 ( cos(rot)*c(3)+sin(rot))*p ];

        % calculate length segment without error - error will be determined later
        F = @(t)sqrt( (3*x_coeff(k,1)*t.^2 + 2*x_coeff(k,2)*t + x_coeff(k,3) ).^2 + ...
                      (3*y_coeff(k,1)*t.^2 + 2*y_coeff(k,2)*t + y_coeff(k,3) ).^2 );
                    
        length_integral = quad( F, 0, 1 ); %<< integrate arc length
        
        if length_integral == 0 % degenerated segment
          % delete point of object - this should happen very seldom, such that
          % it should be faster to preallocate memory for lists and delete
          % entries, if necessary.
          
          seg_length(end) = [];
          x_coeff(end,:) = [];
          y_coeff(end,:) = [];
          obj(obj_id).p(k) = [];
          
        else
          
          % add segment length to list
          seg_length(k+1) = length_integral;
          k = k + 1; % step to next point
          
        end
        
      end % of run through all sections
      
     
      % estimate length and its error
      try
        length = double_error( sum( seg_length ), ...
          norm( [ obj(obj_id).p( 1 ).x(1).error * cos( obj(obj_id).p( 1 ).o.value ), ...
                  obj(obj_id).p( 1 ).x(1).error * sin( obj(obj_id).p( 1 ).o.value ) ] ) + ...
          norm( [ obj(obj_id).p(end).x(1).error * cos( obj(obj_id).p(end).o.value ), ...
                  obj(obj_id).p(end).x(1).error * sin( obj(obj_id).p(end).o.value ) ] ) + ...
                  0.5 * obj(obj_id).p( 1 ).w.error + ...
                  0.5 * obj(obj_id).p(end).w.error   ...
        );
      catch %#ok<CTCH>
        warning( 'MPICBG:FIESTA:PointNotFitted', 'one point has not been fitted!' );
        error_events.point_not_fitted = error_events.point_not_fitted + 1;
        length.value = sum( seg_length );
        length.error = 0;
      end

      % determine center of object
      middle = double( length.value ) * 0.5;
      len = 0;
      for k = 2:numel( seg_length )
        len = len + seg_length(k);
        if len > middle
          break
        end
      end
      % => k stores the index of the middle section
      
      t = 1 - ( len - middle ) ./ seg_length(k);
      x_c = x_coeff( k-1, 1:3 );
      y_c = y_coeff( k-1, 1:3 );      
      
      objects.center_x(1,obj_id) = single( ( x_c(1) * t.^3 + x_c(2) * t.^2 + x_c(3) * t + obj(obj_id).p(k-1).x(1).value ) * params.scale );
      objects.center_y(1,obj_id) = single( ( y_c(1) * t.^3 + y_c(2) * t.^2 + y_c(3) * t + obj(obj_id).p(k-1).x(2).value ) * params.scale );
      
      % determine center of mass of object
      weigth = seg_length + [ seg_length(2:end) 0];
      weigth_sum = sum( weigth );
      p = transpose( reshape( [ obj(obj_id).p.x ], 2, [] ) );
      com_x = sum( weigth' .* p(:,1) ) ./ weigth_sum * params.scale;
      com_y = sum( weigth' .* p(:,2) ) ./ weigth_sum * params.scale;   
      objects.com_x(:,obj_id)  = single( [com_x.value; com_x.error] );
      objects.com_y(:,obj_id)  = single( [com_y.value; com_y.error] );

      % estimate orientation
      orientation = atan2( obj(obj_id).p(end).x(2) - obj(obj_id).p(1).x(2), ...
                    obj(obj_id).p(end).x(1) - obj(obj_id).p(1).x(1) );
      objects.orientation(:,obj_id) =  single( [orientation.value; orientation.error] );
      
      if params.focus_correction
        % add 0.5*FWHM for both filament end points to correct length for focus drift 
        length = length + 0.5 * obj(obj_id).p(1).w + 0.5 * obj(obj_id).p(end).w;
      end
      objects.length(:,obj_id) = single( [length.value; length.error] * params.scale );
        
      width = sum( weigth .* [ obj(obj_id).p.w ] ) ./ weigth_sum * params.scale;    
      objects.width(:,obj_id) = single( [width.value; width.error] );
      
      height = sum( weigth .* [ obj(obj_id).p.h ] ) ./ weigth_sum;
      objects.height(:,obj_id)  = single( [height.value; height.error] );

      background = sum( weigth .* [ obj(obj_id).p.b ] ) ./ weigth_sum;
      objects.background(:,obj_id)  = single( [background.value; background.error] );
      % interpolate additional data:

      % preallocating
      l = 0;
      x = double( obj(obj_id).p(1).x(1) ); %<< array containing the x-positions
      y = double( obj(obj_id).p(1).x(2) ); %<< array containing the y-positions
      i_s = 2;
      
      % spatial interpolation
      for j = 1 : size( x_coeff, 1 ) % run through all object chunks
        t = linspace( 0, 1, ceil( seg_length(j+1) ) );
        t = t(2:end); % remove first point, because its the same as the last one of the last chunk
        i_e = i_s + numel(t) - 1;
        l(i_s:i_e) = sum( seg_length(1:j) ) + t * seg_length(j+1);

        % calculate positions using the spline interpolation data
        x_c = x_coeff(j,1:3);
        y_c = y_coeff(j,1:3);
        x(i_s:i_e) = x_c(1)*t.^3 + x_c(2)*t.^2 + x_c(3)*t + obj(obj_id).p(j).x(1).value ;
        y(i_s:i_e) = y_c(1)*t.^3 + y_c(2)*t.^2 + y_c(3)*t + obj(obj_id).p(j).x(2).value ;
        i_s = i_e + 1;
      end

      % interpolate background, amplitude and width
      back = interp1( cumsum( double( seg_length ) ), double( [ obj(obj_id).p.b ] ), l, 'pchip' );
      ampli = interp1( cumsum( double( seg_length ) ), double( [ obj(obj_id).p.h ] ), l, 'pchip' );
      sigma = interp1( cumsum( double( seg_length ) ), double( [ obj(obj_id).p.w ] ), l, 'pchip' );

      % save points in final data struct
      objects.data{obj_id} = single( [x'*params.scale y'*params.scale l'*params.scale sigma'*params.scale ampli' back'] );
      
      if params.focus_correction
          
          % add 0.5*FWHM for both filament end points to correct length for focus drift 
          s_add = [(obj(obj_id).p( 1 ).x(1).value - 0.5 * obj(obj_id).p( 1 ).w(1).value * cos( obj(obj_id).p( 1 ).o.value ))*params.scale,...
                   (obj(obj_id).p( 1 ).x(2).value - 0.5 * obj(obj_id).p( 1 ).w(1).value * sin( obj(obj_id).p( 1 ).o.value ))*params.scale,... 
                   NaN sigma(1)'*params.scale ampli(1)' back(1)'];

          e_add = [(obj(obj_id).p( end ).x(1).value + 0.5 * obj(obj_id).p( end ).w(1).value * cos( obj(obj_id).p( end ).o.value ))*params.scale,...
                   (obj(obj_id).p( end ).x(2).value + 0.5 * obj(obj_id).p( end ).w(1).value * sin( obj(obj_id).p( end ).o.value ))*params.scale,... 
                   NaN sigma(end)'*params.scale ampli(end)' back(end)'];
      else
          s_add = [];
          e_add = [];
      end
           
      objects.data{obj_id} = single( [s_add; objects.data{obj_id}; e_add] );
      
    end % if object is pointlike or elongated

    % step to the next object
    obj_id = obj_id + 1;
    
  end % of running through all objects
  
  % make sure the structure is created, even if no object exists
  if numel( obj ) == 0
    objects = struct( 'center_x', {}, 'center_y', {}, 'com_x', {}, ...
      'com_y', {}, 'height', {}, 'width', {}, 'orientation', {}, ...
      'length', {}, 'data', {}, 'time', {}, 'radius', {});
  end
  
end

function [ model, x0, dx, lb, ub ] = getParameter( model, data )
  global fit_pic
  
  % calculate position in region of interest
  c = double( model.guess.x - data.offset );
  if isempty(data.center) || all(model.guess.x == data.center)
    clb = [1 1];
    cub = data.rect(3:4);
  else
    dx = model.guess.x(1)-data.center(:,1);
    dy = model.guess.x(2)-data.center(:,2);
    r = min(sqrt(dx.^2+dy.^2))/2;
    clb = ceil(c-r);
    cub = fix(c+r);
  end
  % fill in missing parameters
  if isempty( model.guess.w )
%     [ width, height ] = GuessObjectData( c, [0 pi/2 pi 3*pi/2], data );
%     width = 2*width^2;
%     model.guess.w = width
%     
%     if isempty( model.guess.h )
%       model.guess.h = height;
%     end
%   else
    model.guess.w = 1/5;
  end
  if isempty( model.guess.h ) || isnan( model.guess.h )
    hx = min(max(round(c(1)),1),data.rect(3));
    hy = min(max(round(c(2)),1),data.rect(4));
    model.guess.h = abs(fit_pic(hy,hx) - double( data.background ));
  else
    model.guess.h = abs(model.guess.h - double( data.background ));
  end
%   end

  % setup parameter array
  %    [ X  Y           Width             Height           ]
  x0 = [ c(1:2)         model.guess.w     model.guess.h    ];
  dx = [ 1  1           model.guess.w/10  model.guess.h/10 ];
  lb = [ clb            0                 model.guess.h/10 ];
  ub = [ cub            10*model.guess.w  model.guess.h*10+0.1];

end
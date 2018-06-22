function [ model, x0, dx, lb, ub ] = getParameter( model, data )

  global fit_pic
  
  % fill in missing parameters
  if isempty( model.guess.w )
    model.guess.w = 1/5;
  end
  if isempty( model.guess.h ) || isnan( model.guess.h )
    hx = min(max(round(c(1)),1),data.rect(3));
    hy = min(max(round(c(2)),1),data.rect(4));
    model.guess.h = abs(fit_pic(hy,hx) - double( data.background ));
  else     
    model.guess.h = abs(model.guess.h - data.background);
  end
  
  model.img_size = data.img_size;
  
  % calculated orientated distance from center to line
  d = (   model.guess.x(1) - data.offset(1) - model.img_size(1) / 2 - 0.5 ) * -sin( model.guess.o ) + ...
      (   model.guess.x(2) - data.offset(2) - model.img_size(2) / 2 - 0.5 ) *  cos( model.guess.o );

  dlb = d - max( data.img_size - 1 )/2;
  dub = d + max( data.img_size - 1 )/2;

  % setup parameter array
  %    [ Dist    Orientation           Curvature  Width             Height           ]
  x0 = [ d       model.guess.o         0          model.guess.w     model.guess.h    ];
  dx = [ 0.1     0.1                   0.01       model.guess.w/10  model.guess.h/10 ];
  lb = [ dlb     model.guess.o - pi/2  -0.1       0                 model.guess.h/10 ];
  ub = [ dub     model.guess.o + pi/2  +0.1       10*model.guess.w  model.guess.h*10 ];

end
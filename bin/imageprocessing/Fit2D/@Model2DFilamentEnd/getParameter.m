function [ model, x0, dx, lb, ub ] = getParameter( model, data )
  global fit_pic
  % calculate position in region of interest
  c = double( model.guess.x - data.offset );

  % fill in missing parameters
  if isempty( model.guess.w )
    model.guess.w = 1/5;
  end
  if isempty( model.guess.h ) || isnan( model.guess.h )
    hx = min(max(round(c(1)),1),data.rect(3));
    hy = min(max(round(c(2)),1),data.rect(4));
    model.guess.h = abs(fit_pic(hy,hx) - double( data.background ));
  else
    model.guess.h = abs(model.guess.h - double( data.background ));
  end
   
  % setup parameter array
  %    [ X  Y           Orientation           Width             Height           ]
  x0 = [ c(1:2)         model.guess.o         model.guess.w     model.guess.h    ];
  dx = [ 1  1           0.1                   model.guess.w/10  model.guess.h/10 ];
  lb = [ 1  1           model.guess.o - pi/2  0                 model.guess.h/10 ];
  ub = [ data.rect(3:4) model.guess.o + pi/2  10*model.guess.w  model.guess.h*10 ];

end
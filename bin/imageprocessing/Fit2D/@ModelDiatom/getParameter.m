function [ model, x0, dx, lb, ub ] = getParameter( model, data )
  global fit_pic
  
  % calculate position in region of interest
  c = double( model.guess.x - data.offset );

  % fill in missing parameters
  if isempty( model.guess.w )
%     [ width, height ] = GuessObjectData( c, [0 pi/2 pi 3*pi/2], data );
%     width = 2*width^2;
%     model.guess.w =  [ width width 0 ];
%     
%     if isempty( model.guess.h )
%       model.guess.h = height;
%     end
    model.guess.w = 1/5;
  end
      
%   else
  if isempty( model.guess.h ) || isnan( model.guess.h )
      hx = min(max(round(c(1)),1),data.rect(3));
      hy = min(max(round(c(2)),1),data.rect(4));
      model.guess.h = abs(fit_pic(hy,hx) - double( data.background ));
  else
    model.guess.h = abs(model.guess.h - double( data.background ));
  end
  if isempty( model.guess.o )
    model.guess.o = 0;  
  else
    model.guess.o =  -model.guess.o/360*2*pi;
  end
  
  % setup parameter array
  %    [ X  Y           A                   B                   C                   D1                  D2                  H                ]
  x0 = [ c(1:2)         model.guess.w*1.5     model.guess.w*5     model.guess.o       1.5*model.guess.r       model.guess.r/5     model.guess.h*2/3    ];
  dx = [ 1  1           model.guess.w/10    model.guess.w/10     pi/100              model.guess.r/10   model.guess.r/100    model.guess.h/10 ];
  lb = [ 1  1           0                   0                   -pi/2               0                  model.guess.r/10   model.guess.h/10 ];
  ub = [ data.rect(3:4) 100*model.guess.w   50*model.guess.w  pi/2                15*model.guess.r    2*model.guess.r     model.guess.h*10 ];
end
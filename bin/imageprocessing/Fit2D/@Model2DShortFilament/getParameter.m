function [ model, x0, dx, lb, ub ] = getParameter( model, data )
  global fit_pic
  
  % calculate positions in region of interest
  c = double( model.guess.x(1:2,1:2) - repmat( data.offset, 2, 1 ) );
  
  % fill in missing parameters
  if isempty( model.guess.w )
    model.guess.w = 1/5;
  end
  if isempty( model.guess.h ) || isnan( model.guess.h )
    I = zeros(1,2);
    hx = min(max(round(c(1,1)),1),data.rect(3));
    hy = min(max(round(c(1,2)),1),data.rect(4));
    I(1) = abs(fit_pic(hy,hx) - double( data.background ));
    
    hx = min(max(round(c(2,1)),1),data.rect(3));
    hy = min(max(round(c(2,2)),1),data.rect(4));
    I(2) = abs(fit_pic(hy,hx) - double( data.background ));
    
    model.guess.h = mean(abs(I));
  else
    model.guess.h = abs(model.guess.h - double( data.background ));
  end
  
  % setup parameter array
  %    [ X1  Y1          X2  Y2          Width             Height           ]
  x0 = [ c(1,1:2)        c(2,1:2)        model.guess.w     model.guess.h    ];
  dx = [ 1   1           1   1           model.guess.w/10  model.guess.h/10  ];
  lb = [ 1   1           1   1           0                 model.guess.h/10 ];
  ub = [ data.rect(3:4)  data.rect(3:4)  10*model.guess.w  model.guess.h*10 ];

end
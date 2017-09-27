function f = Likelihood2D(s,XData,YData)
%l =  sum( log( 2*pi*param^2) + ( ( (XData).^2 + (YData).^2 ) / (2*param^2)));
f =  sum( 2/s - ( (XData).^2 + (YData).^2 ) / (s^3));
function sd = sampson_dist(F, x1_pixel, x2_pixel)
% Diese Funktion berechnet die Sampson Distanz basierend auf der
% Fundamentalmatrix F

% hat matrix of vector e3=[0;0;1]
e3_d=[0 -1 0;1 0 0;0 0 0];
denominator1=vecnorm(e3_d*F*x1_pixel,2,1).^2;
denominator2=vecnorm(e3_d*F'*x2_pixel,2,1).^2;
numerator=(x2_pixel'*F)'.*x1_pixel;
% dimensions: (nx3)*(3x3)=(nx3), transposed: 3xn than elementwise multiplication with x1_pixel (3xn) gives (3xn) matrix
numerator=sum(numerator).^2;
sd=numerator./(denominator1+denominator2);

end

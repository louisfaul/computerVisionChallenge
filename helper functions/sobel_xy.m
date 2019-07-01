function [Fx, Fy] = sobel_xy(input_image)
% In dieser Funktion soll das Sobel-Filter implementiert werden, welches
% ein Graustufenbild einliest und den Bildgradienten in x- sowie in
% y-Richtung zurueckgibt.

abFilter=[1 0 -1];
intFilter=[1 2 1];
Fx=conv2(intFilter,abFilter,input_image,'same');
Fy=conv2(abFilter,intFilter,input_image,'same');

end

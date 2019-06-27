function h=hat(v)
% given a 3x1 vector the function calculates the corresponding skew-symmetric matrix
h=[0 -v(3) v(2);v(3) 0 -v(1);-v(2) v(1) 0];
end
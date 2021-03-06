function [ v_out ] = rot_vec_axis_angle( v_in, alpha, n )
% call as: rot_vec_axis_angle(v_in, alpha, n )
% v_in - (row) vector to rotate
% alpha - angle to rotate
% n - around which should be rotated (right-handed system, positive sense)
alpha = deg2rad(alpha); % umrechnen von Grad aus Argument auf Radianten für cos und sin
n = n / norm(n);

% Kreuzproduktmatrix
nk = [ 0 -n(3) n(2); n(3) 0 -n(1); -n(2) n(1) 0 ];
v_out = ( eye(3) *cos(alpha) +  ( 1 - cos(alpha))*(n'*n) + nk* sin(alpha) )   *  v_in'

% or equally writing v_in in each term respectively
%v_out2 = v_in*cos(alpha)  +  ( 1 - cos(alpha))* n*dot(n,v_in)  + cross( n , v_in ) * sin(alpha);
end

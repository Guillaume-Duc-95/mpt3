function test_polyhedron_affinemap_14_pass
% affine map applied to an affine set
% reported on Aug 17 2016 by Magnus Nilsson

n = 2; % Any other higher dimension can be chosen as well
% The following set represents the origin, {x | x=0}.
D = Polyhedron('Ae', eye(n), 'be', zeros(n, 1));
E = eye(n); % A simple linear map, the identity operator.
% The direct mapping operator EoD
EoD = E * D;
assert(EoD==D);

% map must be square
T = [1 0];
Q = T*D;
He_exp = [1 0];
assert(norm(Q.He-He_exp)<1e-6);
assert(isempty(Q.H));

% square map, not invertible
T = [1 0; 0 0];
Q = T*D;
assert(Q.Dim==2);
assert(isempty(Q.H));
He_exp = [1 0 0; 0 1 0];
assert(norm(Q.He-He_exp)<1e-6);

% square invertible map
T = [2 0; 0 0.5];
Q = T*D;
He_exp = [0 2 0;0.5 0 0];
assert(isempty(Q.H));
assert(norm(sortrows(Q.He)-He_exp) < 1e-6);

end

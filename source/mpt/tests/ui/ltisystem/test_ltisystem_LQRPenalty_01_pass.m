function test_ltisystem_LQRPenalty_01_pass
% tests LTISystem/LQRPenalty()

nu = 2; nx = 3; ny = 4;

A = randn(nx); B = randn(nx, nu); 
C = randn(ny, nx); D = 0*randn(ny, nu); 
f = randn(nx, 1); g = randn(ny, 1);
Q = eye(nx); R = 10*eye(nu);
[~, Pgood] = dlqr(A, B, Q, R);

L = LTISystem('A', A, 'B', B, 'C', C, 'D', D);
% L.x.with('penalty');
L.x.penalty = QuadFunction(Q);
% L.u.with('penalty');
L.u.penalty = QuadFunction(R);

P = L.LQRPenalty();
assert(isa(P, 'QuadFunction'));
assert(isequal(P.weight, Pgood));

end

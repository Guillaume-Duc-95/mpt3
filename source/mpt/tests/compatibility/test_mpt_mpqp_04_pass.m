function test_mpt_mpqp_04_pass

sdpvar x u
O = Opt([-1 <= x+u <= 1; -5<=x<=5; -5<=u<=5], u'*u+x'*x, x, u);
% force the MPQP solver
O.solver = 'mpqp';

T = evalc('sol = O.solve;');
disp(T);
% make sure mpt_mpqp_26 was really called
assert(~isempty(findstr(T, 'mpt_mpqp:')));

assert(length(sol.xopt.Set)==3);
assert(isa(sol.xopt.Set, 'Polyhedron'));

end

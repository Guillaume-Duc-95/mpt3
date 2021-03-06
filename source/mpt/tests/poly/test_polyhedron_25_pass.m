function test_polyhedron_25_pass
%
% polyhedron constructor test
% 
% 

% do not accept NaN in R-representation
V = randn(3,5);
V(1,1) = NaN;
[worked, msg] = run_in_caller('Polyhedron(''R'',V); ');
assert(~worked);
asserterrmsg(msg,'Input argument must be a real matrix.');

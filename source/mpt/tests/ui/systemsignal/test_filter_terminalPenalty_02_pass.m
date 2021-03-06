function test_filter_terminalPenalty_02_pass
% tests SystemSignal/filter_terminalPenalty

u = SystemSignal(2);
u.userData.kind = 'u';

x = SystemSignal(2);
x.userData.kind = 'x';

% terminal penalties can only be added on state variables
[worked, msg] = run_in_caller('u.with(''terminalPenalty'');');
assert(~worked);
assert(~isempty(strfind(msg, 'Filter "terminalPenalty" can only be added to state variables.')));

% adding the penalty for state variables should work
x.with('terminalPenalty');

% penalty matrix must have correct number of columns
P = OneNormFunction([1 0 1]);
[worked, msg] = run_in_caller('x.terminalPenalty = P;');
assert(~worked);
assert(~isempty(strfind(msg, 'The weighting matrix must have 2 column(s).')));

% state penalties must be positive semi-definite (2-norm):
P = QuadFunction([1 0; 0 -1]);
[worked, msg] = run_in_caller('x.terminalPenalty = P;');
assert(~worked);
assert(~isempty(strfind(msg, 'The weighting matrix must be positive semi-definite.')));

end

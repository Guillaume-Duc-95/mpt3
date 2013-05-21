function filter = filter_softMin(obj)
% Soft lower bound constraint

global MPTOPTIONS
if isempty(MPTOPTIONS)
	MPTOPTIONS = mptopt;
end

% set up the filter
filter = FilterSetup;
filter.addField('penalty', Penalty(MPTOPTIONS.infbound*ones(1, obj.n), 0), @(x) isa(x, 'Penalty'));
filter.addField('maximalViolation', 1e3*ones(obj.n, 1), @isnumeric);

% this filter depends on the "min" filter
filter.dependsOn('min') = true;

% the filter impacts the following calls:
filter.callback('constraints') = @on_constraints;
filter.callback('objective') = @on_objective;
filter.callback('instantiate') = @on_instantiate;
filter.callback('uninstantiate') = @on_uninstantiate;
filter.callback('addFilter') = @on_addFilter;
filter.callback('removeFilter') = @on_removeFilter;
filter.callback('getVariables') = @on_variables;

end

%------------------------------------------------
function out = on_variables(obj, varargin)
% called when filter's variables are requested

out = obj.internal_properties.soft_min;

end

%------------------------------------------------
function out = on_instantiate(obj, varargin)
% called after the object was instantiated

% soft constraint require introducing new variables
obj.internal_properties.soft_min = sdpvar(obj.n, obj.N);
out = [];

end

%------------------------------------------------
function out = on_uninstantiate(obj, varargin)
% called when the YALMIP representation of variables is removed

% soft constraint require introducing new variables
obj.internal_properties.soft_min = [];
out = [];

end

%------------------------------------------------
function out = on_constraints(obj, varargin)
% called when creating constraints

s = obj.internal_properties.soft_min;
out = [];
for i = 1:obj.n
	out = out + [ obj.min(i, :) - s(i, :) <= obj.var(i, :) ];
	out = out + [ 0 <= s(i, :) <= obj.softMin.maximalViolation(i, :) ];
end

end

%------------------------------------------------
function out = on_objective(obj, varargin)
% called when creating the objective function

s = obj.internal_properties.soft_min;
out = 0;
for k = 1:obj.N
	out = out + obj.softMin.penalty.evaluate(s(:, k));
end
        
end


%------------------------------------------------
function obj = on_addFilter(obj)
% called after the filter was added

% we need to deactivate the "min" filter
obj.disableFilter('min');

end

%------------------------------------------------
function obj = on_removeFilter(obj)
% called prior to the filter is removed

% we need to re-activate the "min" filter
obj.enableFilter('min');

end

classdef AbstractSystem < FilterBehavior & ComponentBehavior & IterableBehavior
	% Class representing an abstract dynamical system.
	%
	% It serves as a storage for signals
	
	properties(SetAccess=protected, Hidden)
		% Domain of the system in the x-u space (can be changed by setDomain)
		domain 

		% Domain of the system in the x-space
		domainx 
	end
	
	properties(SetAccess=protected)
        Ts % Sampling time
        nx % Number of states
        nu % Number of inputs
        ny % Number of outputs
	end

	methods(Abstract, Hidden)
		% Methods which all derived classes must implement.
		
		% State-update equation.
		%
		% Mandatory inputs:
		%   obj: the system object
		%     x: the state vector
		%     u: the input vector
		% Mandatory outputs:
		%    xn: the successor state
		%     y: system's output
		% Optional outputs:
		%    as many as you wish
		[xn, y, z, d] = update_equation(obj, x, u)

		% Output equation.
		%
		% Mandatory inputs:
		%   obj: the system object
		%     x: the state vector
		%     u: the input vector
		% Mandatory outputs:
		%     y: system's output
		y = output_equation(obj, x, u)
		
		% Feedthrough indication. Must return true if the system has direct
		% feedthrough, false otherwise
		out = has_feedthrough(obj)		
	end
	
	methods
		
		function obj = AbstractSystem()
			% Constructor
			
			obj.internal_properties.system.instantiated = false;
			obj.internal_properties.system.N = [];
		end
		
		function display(obj)
			% display method

			plural = @(s, n) [num2str(n) ' ' s repmat('s', 1, double(n~=1))];
			if numel(obj)>1
				fprintf('Array of %d %ss\n', numel(obj), class(obj));
			elseif isempty(obj.nx)
				fprintf('Empty %s\n', class(obj));
			else
				fprintf('%s with %s, %s, %s', class(obj), ...
					plural('state', obj.nx), ...
					plural('input', obj.nu), ...
					plural('output', obj.ny));
				if isequal(class(obj), 'PWASystem')
					fprintf(', %d modes', obj.ndyn);
				end
				fprintf('\n');
			end
		end

		function x = getStates(obj)
			%
			% Returns value of the state vector
			%
			
			x = obj.getValues('x');
		end
		
		function obj = initialize(obj, xinit)
			%
			% Initialize state variables to given values
			%
			
			xinit = xinit(:);
			error(validate_vector(xinit, obj.nx, 'initial state'));

			x = obj.getComponents('x');
			cx = 1;
			for i = 1:length(x)
				if isempty(xinit)
					x.initialize([]);
				else
					x.initialize(xinit(cx:cx+x.n-1));
					cx = cx+x.n;
				end
			end
		end
				
		function plot(obj)
			% plots all objects' signals

			% plot each component
			components = obj.getComponents();
			
			% first determine number of non-empty SystemSignal components,
			% such that we can open curresponding number of subplots
			%
			% TODO: modify ComponentBehavior/getComponents to only return
			% a specified type of components
			nsignals = 0;
			for i = 1:length(components)
				if isa(components(i), 'SystemSignal') && components(i).n>0
					nsignals = nsignals + 1;
				end
			end
			
			idx = 0;
			for i = 1:length(components)
				if isa(components(i), 'SystemSignal') && components(i).n>0
					idx = idx + 1;
					subplot(1, nsignals, idx);
					if components(i).n>0
						components(i).plot();
					else
						grid on
					end
					ylabel(components(i).name);
					xlabel('t');
				end
			end
		end
		
		function out = simulate(obj, U)
			%
			% Simulates the system using a given sequence of inputs
			%
			
			nu = obj.nu;
			if nu>0 && nargin==1
				error('System is not autonomous, you must provide sequence of inputs as well.');
			end
			Nsim = size(U, 2);
			
			X = obj.getStates(); Y = [];
			if isempty(X)
				error('Set the initial condition first.');
			end
			if size(U, 1) ~= nu
				error('The input sequence must have %d rows.', nu);
			end
			
			for k = 1:Nsim
				[x, y] = obj.update(U(:, k));
				X = [X x];
				Y = [Y y];
			end
			out.X = X;
			out.U = U;
			out.Y = Y;
		end

		function C = constraints(obj)
			%
			% Creates YALMIP constraints of the object
			%
			
			obj.assert_is_instantiated();
			
			C = obj.applyFilters('constraints');
			
			% use getComponents() here
			vars = properties(obj);
			for i = 1:length(vars)
				var = obj.(vars{i});
				if ismethod(var, 'constraints')
					for j = 1:length(var)
						C = C + var(j).constraints();
					end
				end
			end
		end
		
		function out = objective(obj)
			%
			% Creates YALMIP objective for the object
			%
			
			obj.assert_is_instantiated();
			
			% apply constraints
			out = obj.applyFilters('objective');
			
			vars = properties(obj);
			for i = 1:length(vars)
				var = obj.(vars{i});
				if ismethod(var, 'objective')
					for j = 1:length(var)
						out = out + var(j).objective();
					end
				end
			end
		end

		function new = saveobj(obj)
			% save method

			% make a copy before saving (because SystemSignal/saveobj will
			% remove YALMIP variables), and save filters/components
			%
			% note that saving of signals is performed by
			% SystemSignal/saveobj
			new = copy(obj);
			new.saveAllFilters();
			new.saveAllComponents();
		end

		function varargout = update(obj, u)
            % Evaluates the state-update and output equations and updates
            % the internal state of the system
            %
			% xn = obj.update(u)
			% [xn, y] = obj.update(u)
			% [xn, y, z, d] = obj.update(u)
			
			if nargin<2
				u = [];
			end
			u = obj.validateInput(u);
			
			x = obj.getValues('x');
			if isempty(x)
				error('Internal state not set, use "sys.initialize(x0)".');
			end

			varargout = cell(1, nargout);
			if nargout>2
				% MLD systems return [xn, y, z, d]
				[varargout{:}] = obj.update_equation(x, u);
			else
				varargout{1} = obj.update_equation(x, u);
				if nargout>1
					varargout{2} = obj.output_equation(x, u);
				end
			end
			xn = varargout{1};
			
			% update the internal state
            obj.initialize(xn);
		end
		
		function y = output(obj, u)
			% Evaluates the output equation
			
			x = obj.getValues('x');
			if isempty(x)
				error('Internal state not set, use "sys.initialize(x0)".');
			end
			
			if nargin==1 && obj.has_feedthrough
				error('Input is required for systems with direct feed-through.')
			end
			if nargin<2
				u = zeros(obj.nu, 1);
			end
			u = obj.validateInput(u);
			
			y = obj.output_equation(x, u);
		end
		
	end
	
	
	methods(Hidden)
		% Private APIs, subject to change, do not use unless absolutely
		% necessary

		function [optcost, sol] = optimize(obj, xinit, N)
			%
			% Performs on-line optimization starting from a given initial
			% state
			%
			
			obj.instantiate(N);
			obj.assert_is_instantiated()
			C = obj.constraints();
			cost = obj.objective();
			
			% include initial state
			x = obj.getComponents('x');
			cx = 1;
			for i = 1:length(x)
				C = C + [ x.var(:, 1) == xinit(cx:cx+x.n-1) ];
				cx = cx+x.n;
			end
			
			[optcost, sol] = obj.solve(C, cost);
		end

		function obj = prepareForControl(obj)
			% Prepares the model for control purposes by adding the min/max
			% and penalty filters if they are not present
			
			components = obj.getComponents;
			for i = 1:length(components)
				c = components(i);
				if isa(c, 'SystemSignal')
					if ~hasFilter(c, 'min')
						c.with('min');
					end
					if ~hasFilter(c, 'max')
						c.with('max');
					end
					if ~hasFilter(c, 'penalty')
						c.with('penalty');
					end					
				end
			end
		end

		function x0 = getValues(obj, kind, index)
			%
			% Returns values of a given vector ('x', 'u', 'y', 'd', ...)
			%
			
			x = obj.getComponents(kind);
			x0 = [];
			for i = 1:length(x)
				if kind == 'x'
					x0 = [x0; x(i).init];
				elseif nargin==3
					x0 = [x0; x(i).value(index)];
				else
					x0 = [x0; x(i).value()];
				end
			end
		end
		

		function initializeFromRecord(obj, data)
			%
			% Initialize state variables from a given record
			%
			
			vars = properties(obj);
			for i = 1:length(vars)
				var = obj.(vars{i});
				if length(var) == 1
					var.initializeFromRecord(data.(vars{i}));
				else
					for j = 1:length(var)
						var(j).initializeFromRecord(data.(vars{i}){j});
					end
				end
			end
		end
		
		function data = record(obj, data)
			%
			% Records values of all variables of the object
			%
			
			vars = properties(obj);
			if nargin == 1
				data = struct;
				for i = 1:length(vars)
					var = obj.(vars{i});
					data.(vars{i}) = {};
					if length(var) == 1
						data.(vars{i}) = obj.(vars{i}).record();
					else
						for j = 1:length(var)
							data.(vars{i}){j} = obj.(vars{i})(j).record();
						end
					end
				end
			else
				for i = 1:length(vars)
					var = obj.(vars{i});
					if length(var) == 1
						data.(vars{i}) = var.record(data.(vars{i}));
					else
						for j = 1:length(var)
							data.(vars{i}){j} = var(j).record(data.(vars{i}){j});
						end
					end
				end
			end
		end

		function obj = instantiate(obj, N)
			%
			% Creates YALMIP variables representing individual variables
			%
			
			obj.internal_properties.system.N = N;
			obj.applyFilters('instantiate');
			
			vars = properties(obj);
			for i = 1:length(vars)
				var = obj.(vars{i});
				if ismethod(var, 'instantiate')
					for j = 1:length(var)
						var(j).instantiate(N);
					end
				end
			end
			obj.internal_properties.system.instantiated = true;
		end
		
		function obj = uninstantiate(obj)
			%
			% Removes the YALMIP's representation of signals
			%
			
			obj.internal_properties.system.N = [];
			obj.applyFilters('uninstantiate');
		
			vars = properties(obj);
			for i = 1:length(vars)
				var = obj.(vars{i});
				if ismethod(var, 'uninstantiate')
					for j = 1:length(var)
						var(j).uninstantiate();
					end
				end
			end
			obj.internal_properties.system.instantiated = false;
		end
		
		function out = isInstantiated(obj)
			% Returns true if all variables have been instantiated
			
			out = obj.internal_properties.system.instantiated;
			
		end
		
		
		function plotSignals(obj, vars, figtitle)
			%
			% Plots values of object's signals over the prediction horizon
			%
			
			T = 0:obj.internal_properties.system.N-1;
			D = []; L = {};
			styles = { 'r-', 'g--', 'b-.', 'm:', 'c-' };
			styles = { styles{:} styles{:} styles{:} styles{:} };
			styles = { styles{:} styles{:} styles{:} styles{:} };
			
			idx = 1;
			for i = 1:length(vars)
				var = obj.(vars{i});
				if ~ismethod(var, 'plot'), continue, end
				for j = 1:length(var)
					d = obj.(vars{i})(j).value;
					stairs(T, d(:, 1:obj.internal_properties.system.N)', ...
						styles{idx}, 'LineWidth', 2);
					hold('on');
					if length(var) > 1
						L{end+1} = sprintf('%s(%d)', obj.(vars{i})(j).name, j);
					else
						L{end+1} = obj.(vars{i}).name;
					end
					idx = idx + 1;
				end
			end
			legend(L{:});
			hold('off');
			axis('auto'); grid('on');
			title(figtitle);
		end

		function z = getVariables(obj, kind, index)
			%
			% Returns YALMIP variables representing given components
			%
			
			x = obj.getComponents(kind);
			z = [];
			for i = 1:length(x)
				if nargin==3
					z = [z; x.var(:, index)];
				else
					z = [z; x.var];
				end
			end
		end
	end
	
	methods(Access = protected)
		
		function assert_is_instantiated(obj)
			if ~obj.internal_properties.system.instantiated
				error('Call obj.instantiate(N) first.');
			end
		end
				
		function msg = assert_has_xu_penalties(obj)
			
			if ~obj.x.hasFilter('penalty')
				msg = 'The state signal must have penalty defined.';
			elseif ~obj.u.hasFilter('penalty')
				msg = 'The input signal must have penalty defined.';
			elseif ~isobject(obj.u.penalty)
				msg = 'Input penalty is required.';
			elseif ~isobject(obj.x.penalty)
				msg = 'State penalty is required.';
			else
				msg = '';
			end
		end

		function u = validateInput(obj, u)
			% checks that the control vector has correct dimension
			
			if isempty(u) && obj.nu>0
				error('System is not autonomous, please provide the input.');
			elseif isempty(u)
                u = zeros(obj.nu, 1);
			end
			error(validate_vector(u, obj.nu, 'input'));
		end
		
		function obj = importSysStructConstraints(obj, sysStruct)
			%
			% Imports state/input/output constraints from sysStruct
			%
			
			if isfield(sysStruct, 'xmin')
				obj.x.min = sysStruct.xmin;
			end
			if isfield(sysStruct, 'xmax')
				obj.x.max = sysStruct.xmax;
			end
			if isfield(sysStruct, 'ymin')
				obj.y.min = sysStruct.ymin;
			end
			if isfield(sysStruct, 'ymax')
				obj.y.max = sysStruct.ymax;
			end
			if isfield(sysStruct, 'umin')
				obj.u.min = sysStruct.umin;
			end
			if isfield(sysStruct, 'umax')
				obj.u.max = sysStruct.umax;
			end
		end
		
	end
	
	methods(Static, Hidden)

		function [optcost, sol] = solve(con, cost)
			
			sol = solvesdp(con, cost, ...
				sdpsettings('verbose', 0, ...
				'glpk.objll', -1e16, 'glpk.objul', 1e16, 'glpk.itlim', 1e5));
			optcost = double(cost);
			if sol.problem == 1 && nargout == 0
				error('Problem is infeasible.');
			elseif sol.problem == 1
				warning('Problem is infeasible.');
				optcost = Inf;
			elseif sol.problem == 12
				warning(sol.info);
			elseif sol.problem ~= 0
				warning('Numerical problems.');
			end
			% fprintf('Cost: %f\n', optcost);
		end
		
		function assert_is_called_from(from, desired)
			
			if ~isequal(from, desired)
				error('This property must be called from %s.', from)
			end
		end
		
	end
	
end

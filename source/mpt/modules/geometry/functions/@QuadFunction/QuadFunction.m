classdef QuadFunction < Function
	%
	% class for representing quadratic functions x'*H*x + F*x + g
	%
	% syntax: Q = QuadFunction(H,F,g)
	%         Q = QuadFunction(H,F)
	%         Q = QuadFunction(H)
	%         Q = QuadFunction(H,F,g,Data)
	
	properties (SetAccess=private)
		H % quadratic term
		F % linear term
		g % affine term
		D=0; % dimension of the domain
		R=0; % dimension of the range
	end
	properties(Dependent=true, SetAccess=private, Transient=true)
		weight % used to access the leading term in penalties
	end
	
	methods
		
		function weight = get.weight(obj)
			% QuadFunction.weight getter
			%
			% Returns the leading term of x'*H*x+F*x+g, i.e., H, when the
			% function is employed to represent a penalty
			weight = obj.H;
		end
		
		% Constructor
		function obj = QuadFunction(varargin)
			%
			% sets data for QuadFunction object
			% syntax: Q = QuadFunction(H,F,g)
			%         Q = QuadFunction(H,F)
			%         Q = QuadFunction(H)
			%         Q = QuadFunction(H,F,g,Data)
			%
			% for more details, type "help QuadFunction"
			
			global MPTOPTIONS
			if isempty(MPTOPTIONS)
				MPTOPTIONS = mptopt;
			end
			
			error(nargchk(1,4,nargin));
			
			% check H
			Hm = varargin{1};
			if ~isa(Hm, 'sdpvar')
				validate_realmatrix(Hm);
			end
			if size(Hm,1)~=size(Hm,2)
				error('The matrix "H" must be square.');
			end
			
			% assign H
			obj.H = full(Hm);
			
			% get the dimension of the domain
			obj.D = size(Hm,1);
			
			% get the dimension of the range
			obj.R = 1;
			
			% only H provided
			if nargin==1
				obj.F = zeros(obj.R,obj.D);
				obj.g = zeros(obj.R,1);
			end
			
			% H, F provided
			if nargin>1
				% F is provided, check
				Fm = varargin{2};
				if ~isa(Fm, 'sdpvar')
					validate_realmatrix(Fm);
				end
				if size(Fm,1)~=obj.R
					error('The number of rows for matrix "F" must be %d.',obj.R);
				end
				if size(Fm,2)~=obj.D
					error('The number of columns for matrix "F" must be %d.',obj.D);
				end
				obj.F = full(Fm);
				obj.g = zeros(obj.R,1);
			end
			
			% H, F, g provided
			if nargin>2
				% g is provided, check
				gm = varargin{3};
				if ~isa(gm, 'sdpvar')
					validate_realvector(gm);
				end
				% make column vector
				gm = full(gm(:));
				if length(gm)~=obj.R
					error('The vector "g" must be of the size %d.',obj.R);
				end
				obj.g = gm;
			end
			
			% Data provided
			if nargin>3
				obj.Data = varargin{4};
			end
			
			% full syntax
			obj.Handle = @obj.qf;
			
		end
		
		function status = eq(f, g)
			% Returns true if the functions are identical
			
			global MPTOPTIONS
			if isempty(MPTOPTIONS)
				MPTOPTIONS = mptopt;
			end
			
			if numel(f)~=numel(g)
				error('Matrix dimensions must agree.');
			elseif numel(f)>1
				% for arrays
				status = false(size(f));
				for i = 1:numel(f)
					status(i) = (f(i)==g(i));
				end
			else
				% for scalars
				
				% TODO: maybe we could alllow comparing AffF with QuadF that
				% has zero quadratic term
				status = isa(f, 'QuadFunction') && isa(g, 'QuadFunction') && ...
					(f.R==g.R) && (f.D==g.D) && ...
					norm(f.H-g.H)<MPTOPTIONS.zero_tol && ...
					norm(f.F-g.F)<MPTOPTIONS.zero_tol && ...
					norm(f.g-g.g)<MPTOPTIONS.zero_tol && ...
					isequal(f.Data, g.Data);
			end
		end
		
		function status = ne(f, g)
			% Returns true if two functions are not identical
			
			status = ~eq(f, g);
		end
		
		
	end
	methods (Hidden)
		function y=qf(obj,x)
			
			if ~isequal(size(x), [obj.D, 1])
				error('The input must be a %dx1 vector.', obj.D);
			end
			% output
			y = x'*obj.H*x + obj.F*x + obj.g;
		end
	end
end

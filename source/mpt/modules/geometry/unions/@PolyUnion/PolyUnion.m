classdef PolyUnion < Union
  %%
  % ConvexSet
  %
  % Represents an union of polyhedra.
  properties (SetAccess=protected)
      Dim % Dimension of the union
  end
  
  methods
      function obj = PolyUnion(varargin)
          % 
          % Union(regions)
          % Union('Set',regions,'convexity',true,'overlaps',false);
          % Union('Set',regions,'convexity',true,'overlaps',false);
          
          % short syntax
          if nargin==1
              arg{1} = 'Set';
              arg{2} = varargin{1};
          else
              arg = varargin;
          end
          
          % full syntax
          ip = inputParser;
          ip.KeepUnmatched = false;
          ip.addParamValue('Set', [], @(x) isa(x, 'Polyhedron'));
          ip.addParamValue('Convex',[], @(x) islogical(x) || x==1 || x==0);
          ip.addParamValue('Overlaps',[], @(x) islogical(x) || x==1 || x==0);
          ip.addParamValue('Connected',[], @(x) islogical(x) || x==1 || x==0);
          ip.addParamValue('Bounded',[], @(x) islogical(x) || x==1 || x==0);
          ip.addParamValue('FullDim',[], @(x) islogical(x) || x==1 || x==0);
          ip.addParamValue('Data', [], @(x) true);
          ip.parse(arg{:});
          p = ip.Results;
                                 
          % remove empty sets
          if ~builtin('isempty',p.Set)
              C = p.Set(:);
              c = isEmptySet(C);
              C = C(~c);
          else
              C = p.Set;
          end
                    
          nC = numel(C);
          if nC>0
              if ~isEmptySet(C)
                  % check dimension
                  D = [C.Dim];
                  if any(D(1)~=D)
                      error('All polyhedra must be in the same dimension.');
                  end
                  obj.Dim = D(1);
              end
              
              % assign properties
              obj.Set = C;
              %obj.Num = length(obj.Set);
              
              
              % check attached functions, if they are the same in all sets
			  if numel(C)>0
				  funs = C(1).listFunctions();
				  for i = 2:numel(C)
					  if any(~C(i).hasFunction(funs))
						  error('All sets must have associated the same number of functions.');
					  end
				  end
			  end
          end
          
          obj.Internal.Convex = p.Convex;
          obj.Internal.Overlaps = p.Overlaps;
          % convex union implies connected
          if p.Convex
              obj.Internal.Connected = true;
          else
              obj.Internal.Connected = p.Connected;
          end
          obj.Internal.Bounded = p.Bounded; 
          obj.Internal.FullDim = p.FullDim; % full dimensionality
          obj.Data = p.Data;

          
	  end
	  
	  function out = findSaturated(obj, function_name, varargin)
		  % Determines saturation properties of unions
		  %
		  % Syntax:
		  %   out = obj.findSaturated(myfun, 'min', min_value, ...
		  %                          'max', max_value, 'range', range)
		  %
		  % Inputs:
		  %         obj: Union object
		  %       myfun: string name of the function to check
		  %              (the function must be affine)
		  %   min_value: lower saturation limit (mandatory)
		  %   max_value: upper saturation limit (mandatory)
		  %       range: range of function's outputs (optional)
		  %
		  % Output:
		  %     out.min: lower saturation limits
		  %     out.max: upper saturation limits
		  %    out.Imin: indices of regions where all RANGE elements of
		  %              MYFUN are saturated at the lower limit
		  %    out.Imax: indices of regions where all RANGE elements of
		  %              MYFUN are saturated at the upper limit
		  %  out.Iunsat: indices of unsaturated regions
		  %       out.S: saturation indicators:
		  %              out.S(i, j) = 1  if in the i-th region the j-th
		  %                     element of MYFUN attains the upper limit
		  %              out.S(i, j) = -1 if in the i-th region the j-th
		  %                     element of MYFUN attains the upper limit
		  %              out.S(i, j) = 0  if in the i-th region the j-th
		  %                     element of MYFUN is not saturated
		  
		  global MPTOPTIONS
		  
		  %% validation
		  error(obj.rejectArray());
		  error(nargchk(2, Inf, nargin));
		  if ~ischar(function_name)
			  error('The function name must be a string.');
		  elseif ~obj.hasFunction(function_name)
			  error('No such function "%s" in the object.', function_name);
		  elseif ~isa(obj.index_Set(1).Functions(function_name), 'AffFunction')
			  error('Function "%s" must be affine.', function_name);
		  end
		  
		  %% parsing
		  ip = inputParser;
		  ip.addParamValue('range', 1:obj.index_Set(1).Functions(function_name).R, ...
			  @validate_indexset);
		  ip.addParamValue('min', [], @validate_realvector);
		  ip.addParamValue('max', [], @validate_realvector);
		  ip.parse(varargin{:});
		  options = ip.Results;
		  R = numel(options.range);
		  error(validate_vector(options.min, R, 'min value'));
		  error(validate_vector(options.max, R, 'max value'));
		  % TODO: determine lower/upper saturations automatically
		  
		  %% processing
		  S = zeros(numel(options.range), obj.Num);
		  for i = 1:obj.Num
			  fun = obj.index_Set(i).Functions(function_name);
			  for j = 1:numel(options.range)
				  jr = options.range(j);
				  % saturated function must have a zero affine term
				  if norm(fun.F(jr, :)) <= MPTOPTIONS.zero_tol
					  if abs(fun.g(jr) - options.min(j)) <= MPTOPTIONS.abs_tol
						  % region saturated at minimum
						  S(j, i) = -1;
					  elseif abs(fun.g(jr) - options.max(j)) <= MPTOPTIONS.abs_tol
						  % region saturated at maximum
						  S(j, i) = 1;
					  end
				  end
			  end
		  end
		  
		  %% create the output structure
		  out.S = S;
		  out.min = options.min;
		  out.max = options.max;
		  satmax = false(1, obj.Num);
		  satmin = false(1, obj.Num);
		  for i = 1:obj.Num
			  % which regions are saturated?
			  satmax(i) = all(S(:, i)==1);
			  satmin(i) = all(S(:, i)==-1);
		  end
		  out.Imin = find(satmin);
		  out.Imax = find(satmax);
		  out.Iunsat = setdiff(1:obj.Num, [out.Imin, out.Imax]);
	  end
	  
  end  
end


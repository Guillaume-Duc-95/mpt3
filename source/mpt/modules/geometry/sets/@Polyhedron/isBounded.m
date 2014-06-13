function tf = isBounded(P)
% ISBOUNDED Test if polyhedron is bounded.
%
% ------------------------------------------------------------------
% tf = P.isBounded
%
% Returns: true if bounded, false otherwise
%
% Notes:
% - Infeasible (or empty) is bounded
%

global MPTOPTIONS
if isempty(MPTOPTIONS)
    MPTOPTIONS = mptopt;
end

% only vectors please
if ~isvector(P)
    error('Input argument must be vector.')
end

% deal with arrays of polyhedra
tf = false(size(P));
for i=1:length(P)
    % compute ChebyCenter only if P(i).Empty property has not been set
    if builtin('isempty',P(i).Internal.Bounded)        
        if P(i).isEmptySet
            % empty polyhedron is considered as bounded
            P(i).Internal.Bounded = true;
        elseif P(i).hasVRep
            P(i).Internal.Bounded = size(P(i).R,1) == 0;
        elseif P(i).hasHRep && ~P(i).isFullDim()
            % project the lower-dimensional polyhedron onto its affine hull
            % and check boundedness there (issue #112)
            P(i).Internal.Bounded = P(i).projectOnAffineHull().isBounded();
        elseif P(i).hasHRep
            sol = P(i).chebyCenter;
            %P(i).Internal.Bounded = true;
            if sol.exitflag == MPTOPTIONS.UNBOUNDED
                P(i).Internal.Bounded = false;
                continue;
            elseif norm(sol.r,Inf)>=MPTOPTIONS.infbound || isinf(sol.r)
                % check if the value function equals infbound or inf
                % (relax the infbound due to isbounded_09_pass test)
                P(i).Internal.Bounded = false;
                continue;
            end
            % we cannot rely only on the Chebyshev center due to possible coplanar hyperplanes
            [n,m] = size(P(i).A);
            if m >= n,     % we have more variables than constraints: unbounded
                P(i).Internal.Bounded = false;
                continue;
            end
            nullA = null(P(i).A');
            colsNullA = size(nullA,2);
            rankA = n - colsNullA;
            
            if rankA < m,  % linearly dependant constraints
                P(i).Internal.Bounded = false;
                continue;
            end

            % we're using the Minkowski's theorem on polytopes:
            % Given a_1, ..., a_m unit vectors, and x_1, ... x_m > 0, there
            % exists a polytope having a_1,...,a_m as facets and x_1, ... x_m as
            % facet areas iff:
            %
            %  a_1 x_1 + ... + a_m x_m = 0
            %
            % Hence, checking boundedness of a polytope boils down to feasibility
            % LP.
            
            S.A = -nullA;
            S.b = -ones(n,1);
            S.f = zeros(1,colsNullA);
			S.Ae = []; S.be = []; S.lb = []; S.ub = []; S.quicklp = true;
            res = mpt_solve(S);
            
            if res.exitflag == MPTOPTIONS.OK % problem is feasible (unconstrained case)
                P(i).Internal.Bounded = true;
                % cannot actually happen (a_i are
                % not co-planar and sum(a_i x_i) =
                % 0 with x_i > 0)
                %  => polyhedron is bounded
            else
                % problem is infeasible => polyhedron is unbounded
                P(i).Internal.Bounded = false;
            end
            
        end
    end
    tf(i) = P(i).Internal.Bounded;
end
end

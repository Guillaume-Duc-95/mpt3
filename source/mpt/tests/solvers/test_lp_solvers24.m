function test_lp_solvers24(solver,tol)
%
%  NaNs in the equality constraints
%

global MPTOPTIONS

fname = mfilename;
check_LPsolvers;

S.A = [1.1540   -0.0895   -1.9494    0.2769    0.0354   -0.6005   -1.5406    0.9038    1.7500    1.3222
   -0.8835   -0.1210    2.0175   -0.3251   -1.0434   -0.8933    0.1166    0.6480   -0.7598    0.8320
   -1.2629   -1.5221   -0.5138    1.2192   -1.9875    0.7627   -0.3722   -0.4897   -1.3178    1.7883
   -0.2206    0.2370    0.1516    0.9674    0.4847   -3.0336    0.3241   -0.3938   -0.9429    1.1400
    0.7373    0.5506   -0.1517    0.5008    0.7191    0.5116   -1.3654   -0.0460    2.1654    1.0484
    1.3819    2.1720   -0.3177   -0.6295   -0.8446    1.4084   -0.8483   -1.0571   -0.0529   -0.3007
   -0.3917    0.0595   -0.1069    2.1739   -1.2543    0.3397   -1.0033   -0.1188   -0.5702   -1.4407
   -1.4061   -0.1535    1.3887    0.4376   -0.4687    0.5497   -0.6476    1.1697    0.0586    0.2461
    0.5178   -0.1792    0.1132   -0.4655    0.5906    0.7904   -0.1407    0.9081   -1.5377    1.8913
    0.7554   -1.4823    0.3224   -0.5058   -1.8580   -0.6938   -1.5864   -0.0702    1.4099    1.5710
   -0.9434   -0.0331    0.4034   -0.4478    0.9041    0.9317   -0.8453   -0.3720    1.5735   -0.4762
    1.1669    0.6447   -1.7011    0.1717   -0.5838   -1.4203    0.7716    1.3037   -0.9771   -1.5133
    0.0823   -0.8256    0.0038   -1.1611    1.3256    1.3552    0.3048    0.3050   -0.8207   -1.5898
    1.1624   -0.2964   -0.7952   -0.0797   -0.8571    0.4400    0.1140   -0.7576    1.7251   -0.8319
    1.4286    0.2523    0.7651    0.6307    0.4339   -0.8715   -0.0579   -0.9306    1.9238    1.9682];

S.b = [4.1400
    2.3429
    4.8348
    0.2207
    0.8171
    4.8803
    0.3732
    2.4975
    0.6011
    0.5086
    4.9382
    4.0500
    0.0515
    1.9714
    2.4485];

S.Ae = [ rand(1,4) NaN rand(1,5); % rows must be removed
         linspace(-3,5,10);
         ones(1,10);
         linspace(-1,2,10)];
S.be = [ 1;
         0;
         NaN; % must be removed;
         0.5];
S.lb = [];
S.ub = [];
     
S.f = [zeros(9,1); -1];
S.solver = solver;
S.quicklp = true;

r = mpt_solve(S);

if r.exitflag==MPTOPTIONS.INFEASIBLE
    error('Must be feasible here.');
end

S.quicklp = false;
r = mpt_solve(S);

if r.exitflag==MPTOPTIONS.INFEASIBLE
    error('Must be feasible here.');
end

end
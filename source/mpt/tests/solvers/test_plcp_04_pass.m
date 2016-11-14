function test_plcp_04_pass
%  random LCP solution

%% input data
% w - M*z = q + Q*th

global MPTOPTIONS

M0 = randn(5);
M = 1/sqrt(2)*(M0'*M0);
q = randn(5,1);
Q = randn(5,2);

Ath = [eye(2);-eye(2)];
bth = 5*ones(4,1);

[~,~,~,exfl] = lcp(M,q);

% if not feasible, generate feasible LCP
while exfl~=MPTOPTIONS.OK
    M0 = randn(5);
    M = 1/sqrt(2)*(M0'*M0);
    q = randn(5,1);
    Q = randn(5,2);
    [~,~,~,exfl] = lcp(M,q);
end


% define problem
problem = Opt('M',M,'q',q,'Q',Q,'Ath',Ath,'bth',bth);

% solve
res = problem.solve;
%plot(res.regions)

for i=1:res.xopt.Num
    
    xc = chebyCenter(res.xopt.Set(i));
    
    zopt = feval(res.xopt.Set(i),xc.x,'z') ;
    wopt = feval(res.xopt.Set(i),xc.x,'w') ;
    
    [z,w] = lcp(M, q+Q*xc.x);
    
    nz = norm(zopt-z,1);
    nw = norm(wopt-w,1);
    
    if nz>MPTOPTIONS.abs_tol || nw>MPTOPTIONS.abs_tol
        error('PLCP solution does not hold.');
    end      
    
    
end
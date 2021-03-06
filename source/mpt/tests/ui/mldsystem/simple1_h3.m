S = [];
S.nu = 1;
S.nx = 1;
S.ny = 1;
S.nw = 0;
S.InputName = {'u'};
S.InputKind = {'r'};
S.InputLength = {1};
S.StateName = {'x'};
S.StateKind = {'r'};
S.StateLength = {1};
S.OutputName = {'y'};
S.OutputKind = {'r'};
S.OutputLength = {1};
S.AuxName = {};
S.AuxKind = {};
S.AuxLength = {};
S.ParameterName = {};
S.ParameterKind = {};
S.ParameterLength = {};
S.xl = -0.05;
S.xu = 0.05;
S.ul = -10;
S.uu = 10;
S.yl = -Inf;
S.yu = Inf;
S.wl = zeros(0,1);
S.wu = zeros(0,1);
S.j.xr = 1;
S.j.xb = [];
S.j.ur = 1;
S.j.ub = [];
S.j.yr = 1;
S.j.yb = [];
S.j.d = zeros(1,0);
S.j.z = zeros(1,0);
S.j.w_auto_bin = zeros(1,0);
S.j.eq = zeros(1,0);
S.j.ineq = zeros(1,0);
S.J.X = 'r';
S.J.U = 'r';
S.J.Y = 'r';
S.J.W = '';
S.nxb = 0;
S.nxr = 1;
S.nub = 0;
S.nur = 1;
S.nyb = 0;
S.nyr = 1;
S.nd = 0;
S.nz = 0;
S.A = 0.7;
S.Bu = 2;
S.Baux = zeros(1,0);
S.Baff = 0;
S.C = 24;
S.Du = 3;
S.Daux = zeros(1,0);
S.Daff = 0;
S.Ex = zeros(0,1);
S.Eu = zeros(0,1);
S.Eaux = [];
S.Eaff = zeros(0,1);
S.nc = 0;
S.symtable = {struct('name', 'C', 'orig_type', 'parameter', 'type', 'parameter', 'kind', 'real'), struct('name', 'A', 'orig_type', 'parameter', 'type', 'parameter', 'kind', 'real'), struct('name', 'x', 'orig_type', 'state', 'type', 'state', 'kind', 'real'), struct('name', 'u', 'orig_type', 'input', 'type', 'input', 'kind', 'real'), struct('name', 'y', 'orig_type', 'output', 'type', 'output', 'kind', 'real'), struct('name', 'xsign', 'orig_type', 'aux', 'type', 'aux', 'kind', 'bool'), struct('name', 'usign', 'orig_type', 'aux', 'type', 'aux', 'kind', 'bool')};
S.MLDisvalid = 1;
S.connections.variables = {'u(1)'};
S.connections.table = zeros(0,1);
S.name = 'simple1_hd3';

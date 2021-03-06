function test_polyhedron_plus_13_pass
%
% array of (H-V) + vector
%

P(1) = ExamplePoly.randHrep('d',5,'ne',1);
P(2) = Polyhedron('V',25*randn(15,5),'R',randn(2,5));

while any(~P.contains([0;0;0;0;0]))
    P(1) = ExamplePoly.randHrep('d',5,'ne',1);
    P(2) = Polyhedron('V',25*randn(15,5),'R',randn(2,5));
end
x = 10*randn(5, 1);

R = P+x;

if any(~R.contains(x))
    error('R must contain x.');
end
end

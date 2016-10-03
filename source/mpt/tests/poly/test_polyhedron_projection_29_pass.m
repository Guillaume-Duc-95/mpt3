function test_polyhedron_projection_29_pass
% test for issue #136

A=sparse([1;5;14;15;16;17;19;20;21;21;22;2;6;9;10;11;12;21;3;7;9;10;11;12;4;8;13;14;15;16;17;18;22], [1;1;1;1;1;1;1;1;1;2;2;3;3;3;3;3;3;3;4;4;4;4;4;4;5;5;5;5;5;5;5;5;5], [1;-1;-2;2;1;-1;-1;1;1;-1;1;1;-1;1;-1;1;-1;1;1;-1;-0.217233478541704;-0.999328802037941;0.999328802035941;0.217233478539704;1;-1;1;-1;-1;-1;-1;-1;1], 22, 5);
b=sparse([1;2;3;4;5;6;7;8;9;10;11;12;13;14;15;16;17;19;20;22], [1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1], [1;1;3.14159265358979;1;1;1;3.14159265358979;1;0.682459100300373;3.13948402300308;3.1394840229968;0.68245910029409;1;1;1;0.25;0.25;1;1;4], 22, 1);
Ae=sparse([1 1], [1 4], [3.14159265358979 -1], 1, 5);
be=sparse([], [], [], 1, 1);

P = Polyhedron('A',A,'b',b,'Ae',full(Ae),'be',full(be));
Q = projection(P, 1:2);

Hexp = [0.8596214093252 -0.510931534190009 0.348689875135192;-0.905927550693907 -0.423432725345761 1.32936027603967;0.707106781186547 -0.707106781186548 0.707106781186547;1 0 1;-1 0 1;0 1 4;-0.707106781186547 0.707106781186548 3.00520382004283;0.707106781186547 0.707106781186548 3.00520382004283;0.894427190999916 0.447213595499958 2.23606797749979;-0.894427190999916 0.447213595499958 2.23606797749979;1 0 1;-1 0 1];
assert(Q==Polyhedron('H', Hexp));

end
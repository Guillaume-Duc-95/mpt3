function test_polyhedron_affinemap_06_pass
%
% polyhedron array, projection
%

H1 = [   0.7996    0.0235    0.3690    5.8502
    0.6600    0.1992    0.3208    8.9283
    0.7852    0.9096    0.4801    7.0532
    0.3049    0.9701    0.1711    4.8807
    0.5807    0.5132    0.5344    8.0052
    0.2546    0.8819    0.0331    2.7420
    0.4232    0.6061    0.7235    6.0126
    0.7940    0.6815    0.3719    6.6885
    0.6463    0.5595    0.3263    2.1679
    0.4247    0.3493    0.1561    7.9903];
H2 = [   -0.6273    0.2011    0.4963    1.3641
   -0.4098   -1.2799   -0.1979    2.7537
    0.3878    0.0697    0.1130    2.8251
    1.3849    0.0783    0.3826    1.8262
   -0.0438    0.9474   -1.0907    1.2577
    1.6869   -1.3377    0.0860    1.1169
    0.9180   -0.0194   -0.8640    2.0939
    0.6140    0.6124    2.1501    0.8244
    0.4274   -0.7602   -1.0182    2.3183
    0.6112   -0.5625   -0.2412    3.6166
    2.1339   -0.0314    1.4289    1.9946
    2.4002   -1.5738    1.1546    2.2598
    0.2434    0.7124    0.4756    1.2511
    2.0368   -0.9730    1.4551    3.0669
   -2.0563    1.0333    0.8859    2.9381
    2.0486    0.3702   -1.0374    1.5441
    0.1249    0.6189    1.8373    1.4322
   -0.6613    0.5070    0.4488    0.2350];
He2 = [-0.0269    1.0539   -0.6899         0
        -0.8362   -1.5876    0.1462    0.1000];
V = [ -19.5624   19.8058  -17.8405
  -16.8076   27.1014   21.7385
    1.8006    5.0913   -2.5276
    1.0917   -1.1113   -3.2236
   -3.1347  -13.7711   -8.5349
   -5.3413   10.7317   13.3029
   20.1607    1.3978   14.0598
   18.2068  -11.2433  -13.3995
  -19.5999   -8.5259    0.1681
   14.3785   20.7414   13.5083
  -11.7405   -1.9951    6.1583
   19.5133   -3.4468  -10.8381
   21.0516   -6.3818    1.5120
  -20.6503    5.9575   -1.6982];

% first polyhedron is unbounded, and its projection can be the whole space
P(1) = Polyhedron('H',H1);
P(2) = Polyhedron('H',H2,'He',He2);
P(3) = Polyhedron(V);

% projection
A = [-1.1259   -0.2674    0.7569
    0.1452   -0.0581    1.0430];
Q = P.affineMap(A);

if any(Q.isEmptySet)
    error('Any of Q should not be empty.');
end

for i=1:3
    % test the map via gridding of bounded subset
    if ~isBounded(P(i))
        Pn = Polyhedron('H',P(i).H,'lb',-10*ones(3,1),'ub',10*ones(3,1));
    else
        Pn = P(i);
    end
    x = Pn.grid(10);
    
    y = zeros(size(x,1),2);
    for j=1:size(x,1)
        y(j,:) = transpose(A*x(j,:)');
        if ~Q(i).contains(y(j,:)')
            error('Point outside of the affine map.');
        end
    end
end



end

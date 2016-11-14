function test_polyhedron_contains_11_pass
%
% [H-V]-V in 5D
%

P(1) = Polyhedron('H',[
      -4.3256       -1.364       -14.41      -10.565       3.8034       21.357
      -16.656       1.1393       5.7115       14.151      -10.091       11.562
       1.2533       10.668      -3.9989      -8.0509     -0.19511       16.001
       2.8768      0.59281          6.9       5.2874     -0.48221        20.59
      -11.465     -0.95648       8.1562       2.1932   0.00043192       23.967
       11.909      -8.3235       7.1191       -9.219      -3.1786       19.193
       11.892       2.9441       12.902      -21.707        10.95       4.5829
     -0.37633      -13.362        6.686     -0.59188       -18.74       10.548
       3.2729       7.1432       11.908      -10.106       4.2818       24.322
       1.7464       16.236      -12.025       6.1446       8.9564        23.84
      -1.8671      -6.9178      -0.1979       5.0774       7.3096       10.667
       7.2579         8.58      -1.5672       16.924       5.7786       23.235
      -5.8832        12.54      -16.041       5.9128      0.40314       1.5052
       21.832      -15.937        2.573       -6.436       6.7709       9.1746]);
P(2) = Polyhedron([
      -26.128       53.634      -5.8059       16.277       110.63
       5.1712      -35.604       53.206      -55.952       75.426
      -40.382     -0.56428      -12.269       31.018      -97.254
       34.022    -0.040851      -75.877       63.489      -84.027
      -118.23      -12.472      0.48671      -44.802      -28.677
       49.506       19.829       3.5686       6.7588      -9.2908
       10.945      -13.201       15.827       -6.952      0.44671
       13.083      -83.201       24.991       -58.17       41.847
       60.672      -51.449       63.904       59.186      -36.114
      -13.733       12.155      -27.391     -0.77148      -36.075
      -6.6567       -62.83        13.04       26.811      -10.059
      -63.525      -17.359     -0.65883      -35.821      -1.0232
       -83.18      -47.069      -29.013      -32.778       13.944
      -35.178      -58.728       106.82       15.718       52.915
       14.044      -51.057      -12.881       5.3407       31.084
       -27.06      -20.083      -70.476       92.411      -87.531
      -66.677       8.6833       88.505      -13.755       34.867 ]);

% intersect and make low-dim
R = intersect(P(1),P(2));

% R must be in P
if ~P.contains(R)
    error('R must be contained in P.');
end

S = Polyhedron('He',[randn(1,5) 0],'H',R.H,'V',R.V);

% S must be in R
if ~R.contains(S)
    error('R must be contained in S.');
end

% S must be contained in both P
if ~P.contains(S)
    error('S must contained in both P.')
end


end
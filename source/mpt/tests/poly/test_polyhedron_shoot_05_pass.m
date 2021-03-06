function test_polyhedron_shoot_05_pass
%
% [H,V]-polyhedron array
%
global MPTOPTIONS

H = [ 0.4569       2.1492      -1.7549       1.0457     -0.11242       0.7293      0.38798     -0.48037            1
       -1.585     -0.55541     -0.54245      -1.2246       0.2029      0.11098       0.8042       0.2232            1
      0.80487        1.024       2.0444    -0.094971     -0.10763     -0.94262      0.12064      -1.2581            1
      0.57887      -1.6413     -0.17752      -0.9689      0.86687      0.34826      0.73183      -0.7328            1
     -0.27773     -0.65099       2.5418     -0.67552      -1.8412      0.49165     -0.34006      -1.9944            1
       0.4819       -1.238      0.46425      0.18373       1.3676      0.97558      0.89252      0.24975            1
       1.4272      0.51432     -0.30045      -1.2512     -0.47711      0.38019    -0.096636      -2.0521            1
     -0.21534      -1.5239       2.1782       1.2629      0.83621     -0.65701   -0.0015488       2.3073            1
     -0.68826      -1.0815      0.94649       1.4723      -1.2542       1.0989      0.80383      0.80442            1
        1.589    -0.096238      0.71367      -1.7085     -0.13006      -2.7968      0.19188      0.17061            1];
He=[0.37256     0.099485     -0.33095      0.49896     -0.24328     -0.39515     -0.48072     -0.21541            0
     -0.12278      0.15839     -0.88799     -0.11361    -0.082372      0.12239      0.36959     0.005614            0
       0.2754       -0.259     -0.26012     -0.52286      0.47205      0.13204     -0.52069    -0.068104            0
     -0.46001     -0.73719     -0.13152      0.29521     -0.17078      0.25407     -0.18258     -0.11593            0];
V = [-0.146      0.29503       1.5668      -1.9918     -0.19382      -1.6277     -0.40619      0.24672
      0.60805      0.35057     -0.58065      -1.3703     -0.16312     -0.23466      -1.7075      0.62765
      -2.9299     -0.32443       1.0456      0.65682     -0.78139      -1.0442      -1.8929      -1.7769
      0.63154     -0.50163       0.8238      -0.5151   -0.0034636       0.1258     -0.66567      0.94973
     -0.37664     -0.53835      0.32198      0.58647      0.58573      0.72899      0.70397     -0.77462
      0.57158      0.67227       1.4152     0.074349      0.89048     -0.14223       1.5525      -1.1761
     -0.73478      0.91122      -0.5169       1.4803       1.1685       0.5135      0.66537      -0.3239
      -1.6802      -1.0651     -0.67588      -1.0032      0.86728      0.18723     -0.35185       -0.616
      -0.4078       1.7056     -0.45976      -0.5262       1.0395   -0.0049895      0.37202      0.68762
      0.19413    -0.089129      -1.2396      0.34853      0.51081     -0.50575     -0.84867      -1.0742];
R = [ -1.2812      -1.0069      0.67958      -0.6647      -1.4021       1.7142      0.99034     -0.21779
      0.50707      -1.0452      -2.6646     -0.45507      0.58989      -1.0996      0.73859     -0.13922];

 
P(1) = Polyhedron('H',H,'He',He);
P(2) = Polyhedron('R',R,'V',V);

x =  [0.2, -0.2, -0.3, 0, -2.5, -0.2, 0.3, -1.2];
r = P.shoot(x);

for i=1:2
    if r(i).exitflag~=MPTOPTIONS.OK
        error('Must be ok handle here.');
    end
end


end

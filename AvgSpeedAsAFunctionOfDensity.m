function speed=AvgSpeedAsAFunctionOfDensity(density)

% relationship between density and velocity is obtained from the van-aerde
% figure

dens=[10 15 20 30 40 45 60 80 90];
vel=[114.8 102.2 89.6 70 54.6 49 35 23.8 19.6];

x=find(dens==density);
speed=vel(x);

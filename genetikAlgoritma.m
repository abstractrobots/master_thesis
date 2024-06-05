clc
dt = 0.001;
popsize = 4;
MaxGenerations = 2;
rng(1,'twister') % for reproducibility
initial = [100 20];
% population = rand(popsize,2);
% load randpop.mat
lb = [0 0];
ub = [1000 1000];
fcn=@tunning;
options = optimoptions(@ga,'PopulationSize',popsize,'PlotFcn',@gaplotbestf,'MaxGenerations', ...
    MaxGenerations,'OutputFcn',@myfun,'InitialPopulationMatrix',initial,'Display','iter', ...
    'UseParallel', false);
[x,fval,exitflag,output,population,scores] = ga(fcn,2,[],[],[],[],lb,ub,[],[],options);
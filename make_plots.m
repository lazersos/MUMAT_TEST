%% load data
x = importdata('points.dat');
B = importdata('B.dat');
B_act = importdata('Bexact.dat');

rho = sqrt(sum(x.^2,2));
modB = sqrt(sum(B.^2,2));
modBact = sqrt(sum(B_act.^2,2));

colors={'r','g','b','c','m'};

for i = 1:5
    plot(rho(i:5:1500),modB(i:5:1500),'o','Color',colors{i});
    hold on;
    plot(rho(i:5:1500),modBact(i:5:1500),'-','Color',colors{i});
end
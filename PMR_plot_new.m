x = [2.91, 3.42, 3.93, 4.46, 4.99];
opt1 = 1 - [0.50, 0.44, 0.34, 0.28, 0.20]; % c = 0.5
%loc1 = 1 - [0.56, 0.42, 0.38];
opt2 = 1 - [0.60, 0.58, 0.48, 0.44, 0.42]; % c = 1
%loc2 = 1 - [0.56, 0.42, 0.38];
opt3 = 1 - [0.78, 0.76, 0.72, 0.70, 0.66]; % c = 2
%loc3 = 1 - [0.73, 0.66, 0.58];
opt4 = 1 - [0.80, 0.78, 0.72]; % c = 4
%loc4 = 1 - [0.76, 0.72, 0.66];

figure;
%plot(x,opt3,'ks-',x,loc3,'bo-',x,opt2,'ks--',x,loc2,'bo--',x,opt1,'ks:',x,loc1,'bo:')
plot(x,opt1,'ks-',x,opt2,'ks--',x,opt3,'ks-.')
xlabel('Peak-to-Mean ratio');
ylabel('Optimal solar ratio');
ylim([0,1.15]);
xlim([min(x),max(x)]);
legend('c=0.5','c=1','c=2','Location','Northwest');
set (gcf, 'PaperUnits', 'inches', 'PaperPosition', [0.1 0 2.8 2.1]);
print ('-depsc', 'figs/PMR2.eps');


x = [1.53, 1.68, 1.83, 2.00, 2.16];
opt1 = 1 - [0.74, 0.73, 0.72, 0.68, 0.66]; % c = 0.5
%loc1 = 1 - [0.80, 0.74, 0.68];
opt2 = 1 - [0.82, 0.81, 0.78, 0.75, 0.70]; % c = 1
%loc2 = 1 - [0.64, 0.60, 0.58];
opt3 = 1 - [0.84, 0.83, 0.82, 0.81, 0.80]; % c = 2
%opt3 = 1 - [0.60, 0.46, 0.42];
%loc3 = 1 - [0.56, 0.42, 0.38];

figure;
plot(x,opt1,'ks-',x,opt2,'ks--',x,opt3,'ks-.')
xlabel('Peak-to-Mean ratio');
ylabel('Optimal solar ratio');
ylim([0,0.5]);
xlim([min(x),max(x)]);
legend('c=0.5','c=1','c=2','Location','Northwest');
set (gcf, 'PaperUnits', 'inches', 'PaperPosition', [0.1 0 2.8 2.1]);
print ('-depsc', 'figs/PMR1.eps');

trace1 = [    1.0000
    0.9815
    0.9632
    0.9450
    0.9271
    0.9096
    0.8927
    0.8765
    0.8610
    0.8462
    0.8323
    0.8195
    0.8080
    0.7983
    0.7907
    0.7858
    0.7839
    0.7850
    0.7887
    0.7943
    0.8021];
trace2 = [1.0000
    0.9884
    0.9774
    0.9670
    0.9576
    0.9491
    0.9417
    0.9356
    0.9305
    0.9267
    0.9241
    0.9228
    0.9229
    0.9242
    0.9266
    0.9302
    0.9348
    0.9405
    0.9473
    0.9550
    0.9635];

figure;
plot(0:0.05:1,trace1,'k-',0:0.05:1,trace2,'k--')
xlabel('wind ratio');
ylabel('relative cost');
%ylim([0,1]);
set(gca,'XTick',[0:0.2:1]);
legend('Trace 1','Trace 2','Location','SouthWest');
set (gcf, 'PaperUnits', 'inches', 'PaperPosition', [0.1 0 2.8 2.1]);
print ('-depsc', 'figs/portfolio2.eps');
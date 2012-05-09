clc;
clear;

a = 10;
b = 48;
I = ones(a,1);
J = ones(b,1);

length = 288;
scale = 100;
L0 = load('traces/sapTrace.tab');
L = L0(:,4)/scale;

for i = 1:1:length*2
    x1(i) = i/6;
    load1(i) = (L(2*i-1) + L(2*i)) / 2;
end


figure;
plot(1/6:1/6:48,load1(1:1:288),'b')
xlabel('time (hour)');
ylabel('workload (normalized)');
ylim([0,1]);
xlim([0,48]);
set(gca,'XTick',[0:6:48], 'FontSize', 10);
%legend('GLB','LOCAL');
set (gcf, 'PaperUnits', 'inches', 'PaperPosition', [0.1 0 3.6 2.8]);
print ('-depsc', 'figs/HP2.eps');
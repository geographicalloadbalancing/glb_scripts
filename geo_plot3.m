% renewable supplies
clear;
length = 288;
a = 10;
W1 = load('traces/wind_supply_week.csv');
S1 = load('traces/solar_supply_week.csv');
for i = 1:1:length
    S(i,:) = max(0,S1(2*i-1,:));
    W(i,:) = W1(i,:);
end
s_mean = mean(S(1:length,:));
w_mean = mean(W(1:length,:));
for i = 1:1:a
    S(:,i) = S(:,i)/s_mean(i);
    W(:,i) = W(:,i)/w_mean(i);
    W2(:,i) = W1(:,i)/max(W1(:,i))*30;
end


figure;
plot(1/6:1/6:288/6,S(:,1),'k',1/6:1/6:288/6,S(:,7),'r',1/6:1/6:288/6,S(:,4),'m',1/6:1/6:288/6,S(:,9),'b');
hold on
plot(1/6:1/6:288/6,mean(S(:,:)'),'b','LineWidth',3)
xlabel('hour');
ylabel('normalized GHI');
xlim([0,576/12]);
ylim([0,15]);
%set(gca,'YTick',[0:1:16]);
set(gca,'XTick',[0:6:576/12]);
set (gcf, 'PaperUnits', 'inches', 'PaperPosition', [0.1 0 3.6 2.8]);
legend('CA', 'TX', 'IL', 'NC','Average')
print ('-depsc', 'figs/solarTwoDay.eps');

figure;
h1 = plot(1/6:1/6:288/6,S(:,1),'k',1/6:1/6:288/6,S(:,7),'r',1/6:1/6:288/6,S(:,4),'m',1/6:1/6:288/6,S(:,9),'b');
hold on
h2 = plot(1/6:1/6:288/6,mean(S(:,:)'),'b','LineWidth',3)
xlabel('hour');
ylabel('normalized GHI');
xlim([0,576/12]);
ylim([0,15]);
set(gca,'XTick',[0:6:576/12]);
ah1 = gca;
l1 = legend(ah1,h1,'CA', 'TX', 'IL', 'NC', 2);
ah2=axes('position',get(gca,'position'), 'visible','off');
l2 = legend(ah2,h2,'Average',1);
LEG = findobj(l1,'type','text');
%set(LEG,'FontSize',10)
LEG = findobj(l2,'type','text');
%set(LEG,'FontSize',10)
set (gcf, 'PaperUnits', 'inches', 'PaperPosition', [0.1 0 2.8 2.1]);
print ('-depsc', 'figs/solarTwoDay.eps');


figure;
plot(1/6:1/6:288/6,W2(1:length,1),'k',1/6:1/6:288/6,W2(1:length,7),'r',1/6:1/6:288/6,W2(1:length,4),'m',1/6:1/6:288/6,W2(1:length,9),'b');
hold on
plot(1/6:1/6:288/6,mean(W2(1:length,:)'),'b','LineWidth',3)
xlabel('hour');
ylabel('wind power (kW)');
xlim([0,576/12]);
ylim([0,60]);
%set(gca,'YTick',[0:1:16]);
set(gca,'XTick',[0:6:576/12]);
set (gcf, 'PaperUnits', 'inches', 'PaperPosition', [0.1 0 3.6 2.8]);
legend('CA', 'TX', 'IL', 'NC','Average')
print ('-depsc', 'figs/windTwoDay.eps');

figure;
h1 = plot(1/6:1/6:288/6,W2(1:length,1),'k',1/6:1/6:288/6,W2(1:length,7),'r',1/6:1/6:288/6,W2(1:length,4),'m',1/6:1/6:288/6,W2(1:length,9),'b');
hold on
h2 = plot(1/6:1/6:288/6,mean(W2(1:length,:)'),'b','LineWidth',3);
xlabel('hour');
ylabel('wind power (kW)');
xlim([0,576/12]);
ylim([0,60]);
set(gca,'XTick',[0:6:576/12]);
ah1 = gca;
l1 = legend(ah1,h1,'CA', 'TX', 'IL', 'NC', 2);
ah2=axes('position',get(gca,'position'), 'visible','off');
l2 = legend(ah2,h2,'Average',1);
LEG = findobj(l1,'type','text');
%set(LEG,'FontSize',10)
LEG = findobj(l2,'type','text');
%set(LEG,'FontSize',10)

set (gcf, 'PaperUnits', 'inches', 'PaperPosition', [0.1 0 2.8 2.1]);
print ('-depsc', 'figs/windTwoDay.eps');







% load data input
has_quadprog = exist( 'quadprog' );
has_quadprog = has_quadprog == 2 | has_quadprog == 3;
has_linprog  = exist( 'linprog' );
has_linprog  = has_linprog == 2 | has_linprog == 3;
rnstate = randn( 'state' ); randn( 'state', 1 );
s_quiet = cvx_quiet(true);
s_pause = cvx_pause(false);
cvx_solver sdpt3;
cvx_clear;
clc;
clear;

a = 10;
b = 48;
I = ones(a,1);
J = ones(b,1);
scale = 10000;
length = 288;
L0 = load('traces/sapTrace.tab');
L = L0(:,4)/scale;

for i = 1:1:6*24*8
    x1(i) = i/6;
    load1(i) = (L(2*i-1) + L(2*i)) / 2;
end


geography = [930 1536 585 8614 1354 931 213 4921 2261 330 3137 1498 767 700 960 875 352 1443 1710 2334 1407 523 1344 241 455 654 399 2252 441 4596 2015 162 2702 762 1031 3038 278 976 197 1333 5040 623 181 2049 1091 369 1556 132];

time_zone = [2 1 2 0 1 3 3 3 3 1 2 3 2 2 3 2 3 3 3 3 2 2 2 1 2 0 3 3 1 3 3 2 3 2 0 3 3 3 2 2 2 1 3 3 0 3 2 1];

for i=1:1:48  
    load2(i,:) = geography(i)*load1(time_zone(i)*6+1:time_zone(i)*6+144*7);
end

datacenter_location = [37 120; 47 120; 44 120; 40 90; 31 83; 38 78; 31 99; 28 81; 35 79; 33 81];
state_location = [32 87; 34 119; 35 92; 37 120; 39 105; 41 73; 39 76; 28 81; 31 83; 44 114; 40 89; 40 86; 41 93; 38 98; 38 85; 31 92; 45 69; 39 77; 42 72; 43 84; 45 93; 33 90; 38 92; 47 110; 41 99; 39 116; 43 71; 40 74; 34 106; 43 76; 35 79; 47 100; 40 83; 35 97; 44 120; 41 78; 42 71; 32 80; 44 100; 35 86; 31 99; 40 112; 44 73; 38 79; 47 121; 39 81; 44 89; 43 107];

for i = 1:1:10
    for j = 1:1:48
        delay(i,j)=sqrt((datacenter_location(i,1)-state_location(j,1))^2+(datacenter_location(i,2)-state_location(j,2))^2);
    end
end

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
end


S = S';
W = W';

step = 0.01;


[Y DCM] = min(delay);
DCL = zeros(a,144*7);
delay_DC = zeros(a,144*7);
for jo = 1:1:b
    DCL(DCM(jo),:) = DCL(DCM(jo),:) + load2(jo,:);
    delay_DC(DCM(jo),:) = delay_DC(DCM(jo),:) +  load2(jo,:)*delay(DCM(jo),jo);
end
prop_delay_loc = sum(delay_DC')./sum(DCL');


for i = 1:1:1
    i
    beta0 = 6;
    energy = 1;
    factor = diag(1+1./sqrt(energy*[10.41 3.73 5.87 7.48 5.86 6.67 6.44 8.6 6.03 5.49]'));
    DCL = factor * DCL;
    M = ceil(2*max(DCL'))';
    capacity = i * mean(DCL');
    
    DCL_total = ones(1,10)*DCL;    
    for j = 1:1:21
        j
        wi = (0+0.05*(j-1))*i;
        %wi = 0.1*(j-1)*i;
        so = i - wi;
        %re(j) = 0.5*(j-1);
        Re = (S.*(so*capacity'*ones(1,length)) + W.*(wi*capacity'*ones(1,length)));
        x0 = 0;
        lambda_t = load2';
        mu = ones(a,1);
        energy_cost = energy*[10.41 3.73 5.87 7.48 5.86 6.67 6.44 8.6 6.03 5.49]';
        delay_cost = ones(a,1);
        beta = beta0*ones(a,1);
        prop_delay = delay;
        caps = M;
        w = 3;
        [x_opt(:,:,j,i) cost_opt(j,i) delay_opt(j,i)] = hetero_opt(x0, lambda_t(1:length,:), mu, energy_cost, delay_cost, beta, prop_delay, caps, Re(:,1:length)');
        brown_opt(j,i) = sum(sum(max(0,x_opt(:,:,j,i)-Re(:,1:length)')))
        %csvwrite('results/portfolio-opt-x.csv',[x_opt],0,0);
        
               

        for k = 1:1:a
            [x_loc(:,k,j,i) cost_local(k) delay_local(k)] = hetero_opt(x0, DCL(k,1:length)', mu(k), energy_cost(k), delay_cost(k), beta(k), prop_delay_loc(1,k), caps(k), Re(k,1:length)');
        end
        brown_loc(j,i) = sum(sum(max(0,x_loc(:,:,j,i)-Re(:,1:length)')))
        delay_loc(j,i) = sum(DCL(:,1:length)')*delay_local(:)/sum(sum(DCL(:,1:length)));
        cost_loc(j,i) = sum(cost_local(:));
        %csvwrite('results/portfolio-loc-x.csv',[x_loc],0,0);
        
        csvwrite('results/portfolio2-compare.csv',[cost_opt, brown_opt, delay_opt, cost_loc, brown_loc, delay_loc],0,0); 
        %csvwrite('results/portfolio-compare.csv',[cost_opt, brown_opt, delay_opt, cost_rhc, brown_rhc, delay_rhc, cost_afhc, brown_afhc, delay_afhc, cost_loc, brown_loc, delay_loc],0,0); 
            
    end
end


figure;
plot(0:0.05:1,brown_opt(1:1:21),'k',0:0.05:1,brown_loc(1:1:21),'b')
xlabel('% of wind');
ylabel('brown energy consumption');
%ylim([0,1]);
legend('GLB','LOCAL');
set (gcf, 'PaperUnits', 'inches', 'PaperPosition', [0.1 0 3.6 2.8]);
print ('-depsc', 'figs\brownWind2.eps');

figure;
plot(0:0.05:1,cost_opt(1:1:21),'k',0:0.05:1,cost_loc(1:1:21),'b')
xlabel('% of wind');
ylabel('total cost');
%ylim([0,1]);
legend('GLB','LOCAL');
set (gcf, 'PaperUnits', 'inches', 'PaperPosition', [0.1 0 3.6 2.8]);
print ('-depsc', 'figs\costWind2.eps');

figure;
plot(0:0.05:1,delay_opt(1:1:21),'k',0:0.05:1,delay_loc(1:1:21),'b')
xlabel('% of wind');
ylabel('average delay');
%ylim([0,1]);
legend('GLB','LOCAL');
set (gcf, 'PaperUnits', 'inches', 'PaperPosition', [0.1 0 3.6 2.8]);
print ('-depsc', 'figs\delayWind2.eps');



%{
figure;
plot(75:1:85,brown(:,1),75:1:85,brown(:,2),75:1:85,brown(:,3))
xlabel('% of wind');
ylabel('brown energy consumption');
legend('capacity = 1','capacity = 2','capacity = 3');
set (gcf, 'PaperUnits', 'inches', 'PaperPosition', [0.1 0 3.6 2.8]);
print ('-depsc', 'windBrownNo1.eps');
saveas(gcf,'windBrownNo1.fig')

figure;
plot(75:1:85,brown_s(:,1),75:1:85,brown_s(:,2),75:1:85,brown_s(:,3))
xlabel('% of wind');
ylabel('brown energy consumption');
legend('capacity = 1','capacity = 2','capacity = 3');
set (gcf, 'PaperUnits', 'inches', 'PaperPosition', [0.1 0 3.6 2.8]);
print ('-depsc', 'windBrown1.eps');
saveas(gcf,'windBrown1.fig')

figure;
plot(75:1:85,cost(:,1),75:1:85,cost(:,2),75:1:85,cost(:,3))
xlabel('% of wind');
ylabel('cost');
legend('capacity = 1','capacity = 2','capacity = 3');
set (gcf, 'PaperUnits', 'inches', 'PaperPosition', [0.1 0 3.6 2.8]);
print ('-depsc', 'windCostNo1.eps');
saveas(gcf,'windCostNo1.fig')

figure;
plot(75:1:85,cost_s(:,1),75:1:85,cost_s(:,2),75:1:85,cost_s(:,3))
xlabel('% of wind');
ylabel('cost');
legend('capacity = 1','capacity = 2','capacity = 3');
set (gcf, 'PaperUnits', 'inches', 'PaperPosition', [0.1 0 3.6 2.8]);
print ('-depsc', 'windCost1.eps');
saveas(gcf,'windCost1.fig')

figure;
plot(75:1:85,aver_delay(:,1),75:1:85,aver_delay(:,2),75:1:85,aver_delay(:,3))
xlabel('% of wind');
ylabel('average delay');
legend('capacity = 1','capacity = 2','capacity = 3');
set (gcf, 'PaperUnits', 'inches', 'PaperPosition', [0.1 0 3.6 2.8]);
print ('-depsc', 'windDelay1.eps');
saveas(gcf,'windDelay1.fig')


figure;
    %plot(0:0.1:1,lo9*step,':',0:0.1:1,up9*step,'-',0:0.1:1,lo8*step,':',0:0.1:1,up8*step,'-',0:0.1:1,lo7*step,':',0:0.1:1,up7*step,'-',0:0.1:1,lo6*step,':',0:0.1:1,up6*step,'-',0:0.1:1,lo5*step,':',0:0.1:1,up5*step,'-')
    plot(re,brown,re,brown_s)
    xlabel('capacity');
    ylabel('brown energy consumption');
    ylim([0,1]);
    %set(gca,'YTick',[0:0.5:4]);
    %set(gca,'XTick',[0:1:10]);
    legend('without storage','perfect storage');
    set (gcf, 'PaperUnits', 'inches', 'PaperPosition', [0.1 0 3.6 2.8]);
    print ('-depsc', 'brownCapacity.eps');
%}
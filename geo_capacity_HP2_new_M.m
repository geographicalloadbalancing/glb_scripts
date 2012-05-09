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

length = 288;
scale = 10000;
L0 = load('traces/sapTrace.tab');
L = L0(:,4)/scale;

for i = 1:1:length*2
    x1(i) = i/6;
    load1(i) = (L(2*i-1) + L(2*i)) / 2;
end


geography = [930 1536 585 8614 1354 931 213 4921 2261 330 3137 1498 767 700 960 875 352 1443 1710 2334 1407 523 1344 241 455 654 399 2252 441 4596 2015 162 2702 762 1031 3038 278 976 197 1333 5040 623 181 2049 1091 369 1556 132];

time_zone = [2 1 2 0 1 3 3 3 3 1 2 3 2 2 3 2 3 3 3 3 2 2 2 1 2 0 3 3 1 3 3 2 3 2 0 3 3 3 2 2 2 1 3 3 0 3 2 1];

for i=1:1:48  
    load2(i,:) = geography(i)*load1(time_zone(i)*6+1:time_zone(i)*6+length);
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
    W(i,:) = W1(i,:);
    S(i,:) = max(0,S1(2*i-1,:));
end
s_mean = mean(S(1:length,:));
w_mean = mean(W(1:length,:));
for i = 1:1:a
    S(:,i) = S(:,i)/s_mean(i);
    W(:,i) = W(:,i)/w_mean(i);
end


S = S';
W = W';


[Y DCM] = min(delay);
DCL = zeros(a,length);
delay_DC = zeros(a,length);
for jo = 1:1:b
    DCL(DCM(jo),:) = DCL(DCM(jo),:) + load2(jo,:);
    delay_DC(DCM(jo),:) = delay_DC(DCM(jo),:) +  load2(jo,:)*delay(DCM(jo),jo);
end
prop_delay_loc = sum(delay_DC')./sum(DCL');

ca = [0,0.5,1,1.5,2,2.5,3,4,5];
for i = 1:1:9
    i  
    for j = 1:1:1
        beta0 = 6;
        DCL = DCL;
        %M = 2 * (1+1./sqrt([10.41 3.73 5.87 7.48 5.86 6.67 6.44 8.6 6.03 5.49]')).*floor(max(DCL'))';
        M = 2 *floor(max(DCL'))';
        %capacity = ca(i) * mean((diag(1+1./sqrt([10.41 3.73 5.87 7.48 5.86 6.67 6.44 8.6 6.03 5.49]'))*DCL)');
        capacity = ca(i) * mean(DCL');
        DCL_total = ones(1,10)*DCL;
        j;
        %wi = (0.75+0.01*(j-1))*i;
        wi = 0.8;
        so = 1 - wi;
        %re(j) = 0.5*(j-1);
        Re = (S.*(so*capacity'*ones(1,length)) + W.*(wi*capacity'*ones(1,length)));
        x0 = 0;
        lambda_t = load2';
        mu = ones(a,1);
        energy_cost = [10.41 3.73 5.87 7.48 5.86 6.67 6.44 8.6 6.03 5.49]';
        delay_cost = ones(a,1);
        beta = beta0*ones(a,1);
        prop_delay = delay;
        caps = M;
        w = 3;
        [x_opt(:,:,j,i) cost_opt(j,i) delay_opt(j,i)] = hetero_opt(x0, lambda_t(1:length,:), mu, energy_cost, delay_cost, beta, prop_delay, caps, Re(:,1:length)');
        brown_opt(j,i) = sum(sum(max(0,x_opt(:,:,j,i)-Re(:,1:length)')))
        %csvwrite('results/beta-opt-x.csv',[x_opt],0,0);
        
        x_rhc(:,:,j,i) = rhc(lambda_t(1:length,:), mu, energy_cost, delay_cost, beta, prop_delay, caps, Re(:,1:length)',w);
        [cost_rhc(j,i) delay_rhc(j,i)] = cost (x_rhc(:,:,j,i), x0, lambda_t(1:length,:), mu, energy_cost, delay_cost, beta, prop_delay, caps, Re(:,1:length)');
        brown_rhc(j,i) = sum(sum(max(0,x_rhc(:,:,j,i)-Re(:,1:length)')))
        %csvwrite('results/betarhc-x.csv',[x_rhc],0,0);
        
        x_afhc(:,:,j,i) = afhc(lambda_t(1:length,:), mu, energy_cost, delay_cost, beta, prop_delay, caps, Re(:,1:length)',w);
        [cost_afhc(j,i) delay_afhc(j,i)] = cost (x_afhc(:,:,j,i), x0, lambda_t(1:length,:), mu, energy_cost, delay_cost, beta, prop_delay, caps, Re(:,1:length)');
        brown_afhc(j,i) = sum(sum(max(0,x_afhc(:,:,j,i)-Re(:,1:length)')))
        %csvwrite('results/beta-afhc-x.csv',[x_afhc],0,0);        

        for k = 1:1:a
            [x_loc(:,k,j,i) cost_local(k) delay_local(k)] = hetero_opt(x0, DCL(k,1:length)', mu(k), energy_cost(k), delay_cost(k), beta(k), prop_delay_loc(1,k), caps(k), Re(k,1:length)');
        end
        brown_loc(j,i) = sum(sum(max(0,x_loc(:,:,j,i)-Re(:,1:length)')))
        delay_loc(j,i) = sum(DCL(:,1:length)')*delay_local(:)/sum(sum(DCL(:,1:length)));
        cost_loc(j,i) = sum(cost_local(:));
        %csvwrite('results/beta-loc-x.csv',[x_loc],0,0);
        
        csvwrite('results/capacity-compare2.csv',[cost_opt, brown_opt, delay_opt, cost_loc, brown_loc, delay_loc],0,0); 
        %csvwrite('results/portfolio-compare.csv',[cost_opt, brown_opt, delay_opt, cost_rhc, brown_rhc, delay_rhc, cost_afhc, brown_afhc, delay_afhc, cost_loc, brown_loc, delay_loc],0,0); 
         
    end
end
figure;
plot(ca,brown_opt/brown_opt(1),'k-',...
    ca,brown_rhc/brown_opt(1),'r--',...
    ca,brown_afhc/brown_opt(1),'m-.',...
    ca,brown_loc/brown_opt(1),'b--',...
    0:1:10,0.2*ones(11,1),'k:',0:1:10,0.1*ones(11,1),'k:')
xlabel('capacity c');
ylabel('relative brown energy usage');
xlim([0,5]);
ylim([0,0.5]);
legend('GLB','RHC','AFHC','LOCAL');
set(gca,'XTick',[0:0.5:5], 'FontSize', 10);
set(gca,'YTick',[0:0.05:0.5], 'FontSize', 10);
set (gcf, 'PaperUnits', 'inches', 'PaperPosition', [0.1 0 2.8 2.1]);
print ('-depsc', 'figs/brownCapacity2.eps');

%{
figure;
plot([0:0.5:2.5,3:1:10],[brown_opt(1),1e4*5.2255,brown_opt(2),1e4*0.3179, brown_opt(3),1e4*0.0498,brown_opt(4:1:11)]/brown_opt(1),'k-',...
    [0:0.5:2.5,3:1:10],[brown_rhc(1),1e4*5.1919,brown_rhc(2),1e4*0.2960, brown_rhc(3),1e4*0.0534,brown_rhc(4:1:11)]/brown_rhc(1),'r--',...
    [0:0.5:2.5,3:1:10],[brown_afhc(1),1e4*5.0784,brown_afhc(2),1e4*0.2563, brown_afhc(3),1e4*0.0474,brown_afhc(4:1:11)]/brown_afhc(1),'m-.',...
    [0:0.5:2.5,3:1:10],[brown_loc(1),1e4*5.2974,brown_loc(2),1e4*0.8400, brown_loc(3),1e4*0.2303,brown_loc(4:1:11)]/brown_loc(1),'b--',...
    0:1:10,0.1*ones(11,1),'k:',0:1:10,0.05*ones(11,1),'k:')
xlabel('capacity');
ylabel('brown energy usage (normalized)');
xlim([0,5]);
ylim([0,0.5]);
legend('GLB','RHC','AFHC','LOCAL');
set(gca,'XTick',[0:0.5:5], 'FontSize', 10);
set(gca,'YTick',[0:0.05:0.5], 'FontSize', 10);
set (gcf, 'PaperUnits', 'inches', 'PaperPosition', [0.1 0 3.6 2.8]);
print ('-depsc', 'figs/brownCapacity2.eps');

figure;
plot(1:1:10,cost_opt(1:1:10),'k',1:1:10,cost_rhc(1:1:10),'r',1:1:10,cost_afhc(1:1:10),'g',1:1:10,cost_loc(1:1:10),'b')
xlabel('beta');
ylabel('total cost');
xlim([1,10]);
%ylim([0,1]);
legend('GLB','RHC','AFHC','LOCAL');
set (gcf, 'PaperUnits', 'inches', 'PaperPosition', [0.1 0 3.6 2.8]);
print ('-depsc', 'figs/costCapacity2.eps');

figure;
plot(1:1:10,delay_opt(1:1:10),'k',1:1:10,delay_rhc(1:1:10),'r',1:1:10,delay_afhc(1:1:10),'g',1:1:10,delay_loc(1:1:10),'b')
xlabel('beta');
ylabel('average delay');
xlim([1,10]);
%ylim([0,1]);
legend('GLB','RHC','AFHC','LOCAL');
set (gcf, 'PaperUnits', 'inches', 'PaperPosition', [0.1 0 3.6 2.8]);
print ('-depsc', 'figs/delayCapacity2.eps');
%}
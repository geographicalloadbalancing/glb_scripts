clear;
cvx_clear;
T=50;
w=5;

%generating random workloads
varrange=5;
vardata=rand(T,1)*varrange-varrange/2;
lambda=vardata;
for i=2:T
    lambda(i)=lambda(i)+lambda(i-1);
end
lambda=lambda-min(lambda)+0.1;

J=3;    %three types of workloads
lambda=[lambda,lambda/2,(max(lambda)-lambda)]; 

lambda = kron(lambda, ones(2*w,1));
T = T*2*w;


S=2;    %two types of servers


%assume cost(rho)=a*rho/(1-rho)+b
a=[0.3; 0.3];
b=[1.0; 0.9];
beta=[2; 30];
mu=[1; 1];

prop_delay=[1 2 3
            4 5 6];
%trick, duplicating c to match the shape of ldtmn so that we can use .*
%mumu=repmat(reshape(mu,1,S,1),[T,1,J]);

%initial number of servers, x0 is a scalar or a vector with m enties.
x0=0;

%x = hetero_opt (lambda, cc, x0, b, a, beta);
% x_afhc = afhc (lambda, c, b, a, beta, w);
% x_rhc  = rhc  (lambda, c, b, a, beta, w);
x_opt  = hetero_opt(lambda, mu, x0, b, a, beta,prop_delay);
plot(x_opt);
legend('Type-1 opt', 'Type-2 opt');
figure;
plot(1:T,lambda);
legend('Type-1 workload','Type-2 workload','Type-3 workload');
% 
% figure;
% plot(1:T,x_rhc, 1:T, x_afhc, 1:T, x_opt);
% legend('Type-1 rhc','Type-2 rhc', 'Type-1 afhc', 'Type-2 afhc', 'Type-1 opt', 'Type-2 opt');
% 
% 
% figure;
% plot(1:T,lambda);
% legend('Type-1 workload','Type-2 workload','Type-3 workload');



% Breakdown of costs under load lambda  for provisioning x with optimal dispatching
function [total delay switching running ld_TSJ] = cost (x, x0, lambda, mu, energy_cost, delay_cost, beta, prop_delay, caps, renewable)

[T J S] = validate_params(lambda, mu, energy_cost, delay_cost, beta, prop_delay, caps, renewable);

%trick, duplicating mu to match the shape of ld_TSJ so that we can use ./
mumu=repmat(reshape(mu,1,S,1),[T,1,J]);
dd=repmat(reshape(prop_delay,1,S,J),[T,1,1])...
    .* repmat(reshape(delay_cost,1,S,1),[T,1,J]);




cvx_precision high;
cvx_begin quiet
    variables ld_TSJ(T,S,J);
    ld=sum(ld_TSJ./mumu,3);
    size(sum(ld_TSJ,1))
   minimize(sum((ld+quad_over_lin(ld,x-ld,0))*delay_cost + pos(x-renewable)*energy_cost)...
      + sum(sum(sum(ld_TSJ.*dd))));% ...  %adding propagation dealy
%      + sum( pos(x(2:T,:)-x(1:(T-1),:))*beta) + pos(x(1,:)-x0)*beta);
    subject to
        sum(ld_TSJ,2) >= reshape(lambda, [T, 1, J]);
        ld_TSJ>=0;
cvx_end
%cvx_status
%qol=quad_over_lin(ld,x-ld,0)
if (strcmp(cvx_status,'Solved')==0 && strcmp(cvx_status,'Inaccurate/Solved')==0)
    cvx_status
end
% calculate costs given provisioning and dispatching
running = sum((ld+quad_over_lin(ld,x-ld,0))*delay_cost + pos(x-renewable)*energy_cost)...
      + sum(sum(sum(ld_TSJ.*dd)));
switching = sum( pos(x(2:T,:)-x(1:(T-1),:))*beta) + pos(x(1,:)-x0)*beta;
total = running + switching;
delay = ( sum((ld+quad_over_lin(ld,x-ld,0))*delay_cost) + sum(sum(sum(ld_TSJ.*dd))) )/sum(sum(sum(ld_TSJ)));
total
cvx_optval
assert(abs(running/cvx_optval-1)<0.06);



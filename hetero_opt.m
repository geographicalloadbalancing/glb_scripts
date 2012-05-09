function [x cvx_optval delay] = hetero_opt(x0, lambda, mu, energy_cost, delay_cost, beta, prop_delay, caps, renewable)

[S J] = size(prop_delay);
w = size(renewable,1);

%trick, duplicating mu to match the shape of ld_TSJ so that we can use ./
mumu=repmat(reshape(mu,1,S,1),[w,1,J]);
dd=repmat(reshape(prop_delay,1,S,J),[w,1,1])...
    .* repmat(reshape(delay_cost,1,S,1),[w,1,J]);
capcap=repmat(reshape(caps,1,S,1),[w,1,1]);

cvx_precision default;
cvx_begin quiet
    variables x(w,S) ld_TSJ(w,S,J);
    ld=sum(ld_TSJ./mumu,3);
    size(sum(ld_TSJ,1));
    if w > 1
       minimize(sum((ld+quad_over_lin(ld,x-ld,0))*delay_cost + pos(x-renewable)*energy_cost)...
          + sum(sum(sum(ld_TSJ.*dd))) ...  %adding propagation dealy
	      + sum( pos(x(2:w,:)-x(1:(w-1),:))*beta) + pos(x(1,:)-x0)*beta);
    else
       minimize(sum((ld+quad_over_lin(ld,x-ld,0))*delay_cost + pos(x-renewable)*energy_cost)...
          + sum(sum(sum(ld_TSJ.*dd))) ...  %adding propagation dealy
	      + pos(x(1,:)-x0)*beta);
    end
    subject to
	%squeeze(sum(ld_TSJ,2))==lambda;	% fails for w=1
	sum(ld_TSJ,2)==reshape(lambda, [w, 1, J]);
        ld_TSJ>=0;
        x<=capcap;
        %x>=capcap/100;
        x>=10;
cvx_end
delay = (sum(sum(sum(ld_TSJ.*dd)))+sum((ld+quad_over_lin(ld,x-ld,0))*delay_cost))/(sum(sum(sum(ld_TSJ))));
if (strcmp(cvx_status,'Solved')==0 && strcmp(cvx_status,'Inaccurate/Solved')==0)
    cvx_status
end
%ld_TSJ
%x

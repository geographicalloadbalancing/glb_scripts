function x = afhc (lambda, mu, energy_cost, delay_cost, beta, prop_delay, caps, renewable, w)

[T J S] = validate_params(lambda, mu, energy_cost, delay_cost, beta, prop_delay, caps, renewable);

%pad end so that final stages can "look ahead"
lambda = [zeros(w, J); lambda; zeros(w, J)];
renewable = [zeros(w, S); renewable; zeros(w, S)];
x_full = zeros(T, S, w+1);

for j = 1:w+1
    fprintf ('AFHC %d [1, %d]\n', j, w+1);
    %initial number of servers, x0 is a scalar or a vector with m enties.
    x0=0;
    for i = j:w+1:T+w
	x_T = hetero_opt(x0, lambda(i:i+w,:),mu, energy_cost, delay_cost, beta, prop_delay, caps, renewable(i:i+w,:));
	x_full(i:i+w,:,j)= x_T;
	x0 = x_full(i+w,:,j);
    end
end

x = sum(x_full(w+1:T+w,:,:), 3)/(w+1);

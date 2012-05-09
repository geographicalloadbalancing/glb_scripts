function x = rhc (lambda, mu, energy_cost, delay_cost, beta, prop_delay, caps, renewable, w)

[T J S] = validate_params(lambda, mu, energy_cost, delay_cost, beta, prop_delay, caps, renewable);

%pad end so that final stages can "look ahead"
lambda = [lambda; zeros(w, J)];
renewable = [renewable; zeros(w, S)];
x = zeros(T, S);

%initial number of servers, x0 is a scalar or a vector with m enties.
x0=0;
for i = 1:T
    %fprintf ('RHC %d [1, %d]\n', i, T);
    i;
    x_T = hetero_opt (x0, lambda(i:i+w,:), mu, energy_cost, delay_cost, beta, prop_delay, caps, renewable(i:i+w,:));
    x(i,:)= x_T(1,:);
    x0 = x(i,:);
end

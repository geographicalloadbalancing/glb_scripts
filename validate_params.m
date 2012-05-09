function [T J S] = validate_params(lambda, mu, energy_cost, delay_cost, beta, prop_delay, caps, renewable)
% Check the following dimensional consistency:
% size(prop_delay) = [S J]
% size(lambda) = [T, J]
% size(mu) = [S, 1]
% size(energy_cost) = [S, 1]
% size(delay_cost) = [S, 1]
% size(beta) = [S, 1]
% size(caps) = [S, 1]
% size(renewable) = [T, S]

[S J] = size(prop_delay);	% S machines, J job types
[T JJ] = size(lambda);	% T timesteps,  JJ should match J
if (J ~= JJ)
    error('dimension of lambda %d must match that of prop_delay %d\n', J, JJ);
end
[a b] = size(mu);
if any([a b] ~= [ S 1 ])
    error('dimension of mu (%d, %d) should be (%d, %d)\n', a, b, S, 1);
end
[a b] = size(energy_cost);
if any([a b] ~= [ S 1 ])
    error('dimension of energy_cost (%d, %d) should be (%d, %d)\n', a, b, S, 1);
end
[a b] = size(delay_cost);
if any([a b] ~= [ S 1 ])
    error('dimension of delay_cost (%d, %d) should be (%d, %d)\n', a, b, S, 1);
end
[a b] = size(beta);
if any([a b] ~= [ S 1 ])
    error('dimension of beta (%d, %d) should be (%d, %d)\n', a, b, S, 1);
end
[a b] = size(caps);
if any([a b] ~= [ S 1 ])
    error('dimension of caps (%d, %d) should be (%d, %d)\n', a, b, S, 1);
end
[a b] = size(renewable);
if any([a b] ~= [ T S ])
    error('dimension of renewable (%d, %d) should be (%d, %d)\n', a, b, T, S);
end 
if T < 2
    error ('total load must have more than one sample')
end
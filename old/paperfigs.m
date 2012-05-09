todo_list = [1 2];
screen_only = 0;

todo = zeros(1,100);
todo(todo_list) = 1;

% enumeration for  costs(.,.)
FHC = 1;
RHC = 2;
OPT = 3;
debug = 4;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Cost of example where RHC performs badly
if (todo(1))
    figure(1)

    maxWindow = 24;
    costs = zeros(maxWindow, 4);

    eps = 0.1 * maxWindow^(-3);
    beta_max = 10 + 2*maxWindow^2 *maxWindow * eps;
    f_0_min = 1;
    for w = 1:maxWindow
    %for w = 2:2

	%w = 2;
	S = 2*w^2;
	J = S;
	T = w+S;
	N = 100;
	%beta = 1 + 2*(1:S)'*w*eps;
	beta = beta_max - 2*(S:-1:1)'*w*eps;
	C = 2*max(beta);
	worktype = [ones(1,w), 1:S];
	lambda = zeros(T,J);
	lambda(1:w+1,1) = N;
	lambda(w+1:w+S, 1:S) = N*eye(S);

	energy_cost = f_0_min + (S:-1:1)'*eps;

	f_of_lambda = C*triu(ones(S), 1)';

	% OPT uses N servers of type S
	costs(w,OPT) = N*beta(S) + sum(lambda * f_of_lambda(:,S)) + N*T*(energy_cost(S));

	% RHC uses N servers of type 1 for t=1:w, and then types t-w for times t=w+1:w+S, then N of type S
	% for times S+1 to S+w

	% type of server used at time  t.  (Only one type used at a time.)
	rhc_servers = [1:S, S*ones(1,w)];
	costs(w,RHC) = N*(sum(beta) + w*beta(S))...
		+ N*sum(energy_cost(rhc_servers));
	for t = 1:T
	    costs(w,RHC) = costs(w,RHC) + N*f_of_lambda(worktype(t),rhc_servers(t));
	end

	%costs(w,debug)= N*(T)*f_0_min + N*S*beta_max;	% RHC simple
	%costs(w,debug)= N*(T)*f_0_min + N*beta(S);

	% SFHC: each class j uses N/(w+1) servers of type max(worktype([t,t:w]))
	% at each instant when any of the servers is on.
	% (This could probably be more efficient with vector operations,
	% but that takes more thought.)

	% type of server used at time  t.  (One type used at a time per class.)
	sfhc_srv = zeros(T,w+1);
	for t = 1-w:T
	    st = max(t,1);
	    en = min(t+w,S+w);
	    type = max(worktype(st:en));
	    sfhc_srv(st:en,mod(t,(w+1))+1) = type;
	end

	% switching costs (for one server per class)
	sw = sum(beta(sfhc_srv(1,:)));	% all turn on at time 1
	for t = 2:T
	    	% If the server type changes, charge for turn-on of new type
	    %costs(w,FHC) = costs(w,FHC) ...

	    sw = sw ...
	       +  (sfhc_srv(t,:)~=sfhc_srv(t-1,:) ) * beta(sfhc_srv(t,:));
	end

	%keyboard

	%running costs (for one server per class)
	run = 0;
	for t = 1:T
	    %costs(w,FHC) = costs(w,FHC) ...

	    run = run ...
	        + sum(energy_cost(sfhc_srv(t,:))) ...
		+ sum(f_of_lambda(worktype(t),sfhc_srv(t,:)));
	end

	%keyboard

	% scale for load-per-class
	costs(w,FHC) = (sw + run) * N/(w+1);
    end


    plot((1:maxWindow), costs(:,RHC)./costs(:,OPT),'--' ...
        ,(1:maxWindow), costs(:,FHC)./costs(:,OPT), '-.' ...
        ,(1:maxWindow), ones(1,maxWindow)*(1+beta_max/f_0_min), '-' ...
        ,(3:maxWindow), (1+beta_max/f_0_min./((3:maxWindow)+1)), 'r-' ...
	 );
         %(1:maxWindow), costs(:,debug)./costs(:,OPT),'-.');
	 %(1:maxWindow), costs(:,OPT), '-.')

    % (magic [x1 x2], [y1 y2] work in  eps; slightly off on the screen)
    annotation('textarrow', [0.35 0.27], [0.6 0.68], 'String', '1+\beta/f_0');
    annotation('textarrow', [0.35 0.27], [0.4 0.35], 'String', '1+\beta/((w+1)f_0)');

    xlabel('window, w');
    ylabel('Normalized cost');
    % ticks every 6 hours
    %set(gca, 'xtick', 0:6:(T/hourSamples));
    %set (gcf, 'PaperUnits', 'centimeters', 'PaperPosition', [0.1 0 9 7]);
    set (gcf, 'PaperUnits', 'inches', 'PaperPosition', [0.1 0 2.8 2]);
    legend('RHC','SFHC', 'Location', 'NorthEast');
    ax = axis; ax(4) = 17; axis(ax);
    if ~screen_only
        print ('-depsc', sprintf('cost_RHCbad.eps',0));
    end
end
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% HP traces cost as function of lookahead window
if (todo(2))
    figure(2)

    load HP_load.txt;

    % 42-day trace, 5-min intervals
    hourSamples = 12;
    daily = reshape (HP_load, [length(HP_load)/42, 42]);
    % Use business day followed by Sunday for one type of load
    % and Sunday followed by business day for the other.
    % Avoid Day 8 since it is a holiday.

    lambda = [[ daily(:,1), daily(:,14)]; [daily(:,7), daily(:,15)]];

%lambda = lambda(1:10:size(lambda,1), :);

    T = size(lambda,1);

    S=2;    %two types of servers
    J=2;	%two types of workload

    %assume cost(rho)=a*rho/(1-rho)+b
    a=[0.3; 0.3];
    b=[1; 1];
    beta= b * hourSamples;	% switching cost = 1 hour running

    %weighted job sizes, c is an S x J matrix.
    c=[0.1 3
       3   0.1];

    %trick, duplicating c to match the shape of ldtmn so that we can use .*
    cc=repmat(reshape(c,1,S,J),[T,1,1]);


    maxWindow = 1*hourSamples - 1;

    costs = zeros(maxWindow, 3);
    sw    = zeros(maxWindow, 3);
    run   = zeros(maxWindow, 3);


    cvx_clear;
    %initial number of servers, x0 is a scalar or a vector with m enties.
    x0=0;

    fprintf('OPT\n');
%    x_opt  = hetero_opt(lambda, cc, x0, b, a, beta);
    [costs(1,OPT) sw(1,OPT) run(1,OPT) ld_TKM_opt] ...
    			= cost(x_opt,  x0, lambda, c, b, a, beta);
    costs(:,OPT) = costs(1,OPT);
    sw(:,OPT)    = sw(1,OPT);
    run(:,OPT)   = run(1,OPT);

%    load('fig2')
%    maxWindow = 1*hourSamples - 1;
%    costs = [zeros(1,size(costs,2)); costs(1:maxWindow,:)];
%    for w=0:0

    for w=0:maxWindow
	fprintf('AFHC, w=%d\n', w);
	[x_afhc costs(w+1,FHC)] = afhc (lambda, c, b, a, beta, w);
	%[costs(w,FHC) sw(w,FHC) run(w,FHC) ld_TKM_afhc] = cost(x_afhc, x0, lambda, c, b, a, beta);

	fprintf('RHC, w=%d\n', w);
	x_rhc  = rhc  (lambda, c, b, a, beta, w);
	[costs(w+1,RHC) sw(w+1,RHC) run(w+1,RHC) ld_TKM_rhc] = cost(x_rhc,  x0, lambda, c, b, a, beta);

    end

    plot((1:maxWindow+1)/hourSamples*60, costs(:,RHC)./costs(:,OPT), '--', ...
         (1:maxWindow+1)/hourSamples*60, costs(:,FHC)./costs(:,OPT), '-.', ...
	 (1:maxWindow+1)/hourSamples*60, costs(:,OPT)./costs(:,OPT),  '-');
    legend('RHC', 'SFHC', ' OPT', 'Location', 'SouthEast');

    xlabel('window (minutes)');
    ylabel('Normalized cost');
    %set (gcf, 'PaperUnits', 'centimeters', 'PaperPosition', [0.1 0 9 7]);
    set (gcf, 'PaperUnits', 'inches', 'PaperPosition', [0.1 0 2.8 2]);
    %axis([0 20 0 6]);
    ax = axis; ax(3) = 0; axis(ax);
    if ~screen_only
        print ('-depsc', sprintf('cost_v_w.eps',0));
    end

end

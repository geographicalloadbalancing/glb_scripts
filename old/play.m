todo_list = [3];
screen_only = 1;

todo = zeros(1,100);
todo(todo_list) = 1;


    load HP_load.txt;

    % 42-day trace, 5-min intervals
    hourSamples = 12;
    daily = reshape (HP_load, [length(HP_load)/42, 42]);
    % Use business day followed by Sunday for one type of load
    % and Sunday followed by business day for the other.
    % Avoid Day 8 since it is a holiday.

    lambda = [[ daily(:,1), daily(:,14)]; [daily(:,7), daily(:,15)]];

    % subsample to increase variablility
    lambda = [[ daily(:,1), daily(:,14)]
	      [ daily(:,1), daily(:,14)]
    	      [ daily(:,7), daily(:,15)]];
    T = size(lambda,1);
    sub = 3;
    lambda = reshape(sum(reshape(lambda, [T/sub, sub, 2])), [sub, 2]);
    T = size(lambda,1);
    figure(101);
    plot(1:T,lambda);
    legend('Type-1 workload','Type-2 workload');
    

%%% Testing hack
%lambda = lambda(1:20, :);
%hourSamples = 3;

    T = size(lambda,1);

    %%generating random workloads
    %varrange=5;
    %vardata=rand(T,1)*varrange-varrange/2;
    %lambda=vardata;
    %for i=2:T
    %    lambda(i)=lambda(i)+lambda(i-1);
    %end
    %lambda=lambda-min(lambda)+0.1;
    %
    %n=3;    %three types of workloads
    %lambda=[lambda,lambda/2,(max(lambda)-lambda)]; 
    %
    %lambda = kron(lambda, ones(2*w,1));
    %T = T*2*w;

    S=2;    %two types of servers
    J=2;	%two types of workload

    %assume cost(rho)=a*rho/(1-rho)+b
    a=[0.3; 0.3];
    b=[1; 1];
    beta= [1.9; 2];	% switching cost = 1 hour running

    %weighted job sizes, c is an S x J matrix.
    c=[0.1 3
       0.1 0.1];

    %trick, duplicating c to match the shape of ldtmn so that we can use .*
    cc=repmat(reshape(c,1,S,J),[T,1,1]);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% cost as function of peak-to-mean ratio
if (todo(1))
    figure(1)

    w=floor(hourSamples/2);	% half hour look ahead
    w = 1;

    cvx_clear;
    %initial number of servers, x0 is a scalar or a vector with m enties.
    x0=0;

    x_afhc = afhc (lambda, c, b, a, beta, w);
    x_rhc  = rhc  (lambda, c, b, a, beta, w);
    [x_opt cost_opt]  = hetero_opt(lambda, cc, x0, b, a, beta);

    % sanity checks
    if any(any(1.001*x_opt < x_rhc)) || any(any(1.001*x_opt < x_afhc))
       error ('Monotonicity failed');
    end
    if abs(cost_opt - cost(x_opt,  x0, lambda, c, b, a, beta)) / cost_opt > 1e-3
        error('Cost mismatch')
    end





    plot((1:T)/hourSamples, x_afhc, '-', ...
         (1:T)/hourSamples, x_rhc,'--', ...
	 (1:T)/hourSamples, x_opt, '-.');
	 %, ...
	 %(1:T)/hourSamples, lambda/10, ':');
    legend('Type-1 afhc','Type-2 afhc', 'Type-1 rhc', 'Type-2 rhc', 'Type-1 opt', 'Type-2 opt');

    %legend('Optimal', 'always on', 'prediction', 'history', 'both', ...
    %    'Location', 'NorthEast');
     
    xlabel('time (hours)');
    ylabel('active servers, x');
    % ticks every 6 hours
    set(gca, 'xtick', 0:6:(T/hourSamples));
    %set (gcf, 'PaperUnits', 'centimeters', 'PaperPosition', [0.1 0 9 7]);
    set (gcf, 'PaperUnits', 'inches', 'PaperPosition', [0.1 0 7 5]);
    ax = axis; ax(2) = 55; axis(ax);
    if ~screen_only
        print ('-depsc', sprintf('active_v_time.eps',0));
    end

    figure(101);
    plot(1:T,lambda);
    legend('Type-1','Type-2');
     
    xlabel('time (hours)');
    ylabel('workload');
    % ticks every 6 hours
    set(gca, 'xtick', 0:6:(T/hourSamples));
    %set (gcf, 'PaperUnits', 'centimeters', 'PaperPosition', [0.1 0 9 7]);
    set (gcf, 'PaperUnits', 'inches', 'PaperPosition', [0.1 0 3.5 2.5]);
    ax = axis; ax(2) = 55; axis(ax);
    if ~screen_only
        print ('-depsc', sprintf('load_v_time.eps',0));
    end
end
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% cost as function of peak-to-mean ratio
if (todo(2))
    figure(2)

    maxWindow = 2*hourSamples;

    costs = zeros(maxWindow, 3);
    sw    = zeros(maxWindow, 3);
    run   = zeros(maxWindow, 3);


    cvx_clear;
    %initial number of servers, x0 is a scalar or a vector with m enties.
    x0=0;

    fprintf('OPT\n');
    [x_opt cost_opt]  = hetero_opt(lambda, cc, x0, b, a, beta);
    [costs(1,3) sw(1,3) run(1,3) ld_TKM_opt] = cost(x_opt,  x0, lambda, c, b, a, beta);
    costs(:,3) = costs(1,3);
    sw(:,3) = sw(1,3);
    run(:,3) = run(1,3);

    %for w=1:floor((maxWindow-1)/4):maxWindow
    for w=1:maxWindow

	fprintf('AFHC, w=%d\n', w);
	x_afhc = afhc (lambda, c, b, a, beta, w);
	[costs(w,1) sw(w,1) run(w,1) ld_TKM_afhc] = cost(x_afhc, x0, lambda, c, b, a, beta);

	fprintf('RHC, w=%d\n', w);
	x_rhc  = rhc  (lambda, c, b, a, beta, w);
	[costs(w,2) sw(w,2) run(w,2) ld_TKM_rhc] = cost(x_rhc,  x0, lambda, c, b, a, beta);

    end

    plot((1:maxWindow)/hourSamples, costs(:,1), '--', ...
         (1:maxWindow)/hourSamples, costs(:,2),  '-', ...
	 (1:maxWindow)/hourSamples, costs(:,3),  '-.');
    legend('afhc', 'rhc', ' opt');

    xlabel('w (hours)');
    ylabel('total cost');
    %set (gcf, 'PaperUnits', 'centimeters', 'PaperPosition', [0.1 0 9 7]);
    set (gcf, 'PaperUnits', 'inches', 'PaperPosition', [0.1 0 3.6 2.5]);
    %axis([0 20 0 6]);
    if ~screen_only
        print ('-depsc', sprintf('cost_v_w.eps',0));
    end

    figure(201)
    plot((1:maxWindow)/hourSamples, sw(:,1), '--', ...
         (1:maxWindow)/hourSamples, sw(:,2),  '-', ...
	 (1:maxWindow)/hourSamples, sw(:,3),  '-.');
    legend('afhc', 'rhc', ' opt');

    xlabel('w (hours)');
    ylabel('switching cost');
    %set (gcf, 'PaperUnits', 'centimeters', 'PaperPosition', [0.1 0 9 7]);
    set (gcf, 'PaperUnits', 'inches', 'PaperPosition', [0.1 0 3.6 2.5]);
    %axis([0 20 0 6]);
    if ~screen_only
        print ('-depsc', sprintf('sw_v_w.eps',0));
    end

    figure(202)
    plot((1:maxWindow)/hourSamples, run(:,1), '--', ...
         (1:maxWindow)/hourSamples, run(:,2),  '-', ...
	 (1:maxWindow)/hourSamples, run(:,3),  '-.');
    legend('afhc', 'rhc', ' opt');

    xlabel('w (hours)');
    ylabel('running cost');
    %set (gcf, 'PaperUnits', 'centimeters', 'PaperPosition', [0.1 0 9 7]);
    set (gcf, 'PaperUnits', 'inches', 'PaperPosition', [0.1 0 3.6 2.5]);
    %axis([0 20 0 6]);
    if ~screen_only
        print ('-depsc', sprintf('run_v_w.eps',0));
    end

    figure(203)
    plot (x_rhc)

    figure(204)
    plot (x_afhc)

end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (todo(3))
    figure(3)

    dayMean = dailymean (HP_trace, 42, [8 31]);
    w = floor(hourSamples/2);
    lambda = daily(:,1);	% One business day

    T = size(lambda,1);
    S=1;    %two types of servers
    J=1;	%two types of workload
    %assume cost(rho)=a*rho/(1-rho)+b
    a=0.3
    b=1;
    beta= b * hourSamples;	% switching cost = 1 hour running
    %weighted job sizes, c is an S x J matrix.
    c=1;
    %trick, duplicating c to match the shape of ldtmn so that we can use .*
    cc=repmat(reshape(c,1,S,J),[T,1,1]);

    x0 = 0;

    maxAcc = 10;
    costs = zeros(maxAcc, 3);

    x_opt = hetero_opt(lambda, cc, x0, b, a, beta);

    for accuracy = 1:maxAcc

	fprintf('AFHC, w=%d\n', w);
	[x_afhc meanErr] = afhc_pred (lambda, c, b, a, beta, w, dayMean, accuracy);
	costs(accuracy,1) = cost(x_afhc, x0, lambda, c, b, a, beta);

	fprintf('RHC, w=%d\n', w);
	x_rhc  = rhc_pred  (lambda, c, b, a, beta, w, dayMean, accuracy);
	costs(accuracy,2) = cost(x_rhc,  x0, lambda, c, b, a, beta);
    end


    legend('afhc', 'rhc', ' opt');

    xlabel('prediction accuracy');
    ylabel('competitive ratio');
    %set (gcf, 'PaperUnits', 'centimeters', 'PaperPosition', [0.1 0 9 7]);
    set (gcf, 'PaperUnits', 'inches', 'PaperPosition', [0.1 0 3.6 2.5]);
    %axis([0 20 0 6]);
    if ~screen_only
        print ('-depsc', sprintf('prediction.eps',0));
    end


end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Example where RHC (much) worse than AFHC
% (With  larger S it often causes  cvx  to fail)
% RHC doesn't turn all servers of a given type off at once, since running
% cost uses M/M/1 formula, not what is in Theorem 3.
if (todo(4))
    figure(4)

    eps = 0.01;
    w = 2;
    f0 = 1;
    S = 3;
    J = S;
    T = w+S;
    N = 100;
    energy_cost = f0 - (1:S)'*eps;	b = energy_cost;
    delay_cost = ones(S,1);		a = delay_cost;
    c = eps^2 + triu(ones(S), 1);
    beta = 10 + 2*(1:S)'*w*eps;
    lambda = zeros(T,J);
    lambda(1:w+1,1) = N;
    lambda(w+1:w+S, 1:S) = N*eye(S);


    %trick, duplicating c to match the shape of ldtmn so that we can use .*
    cc=repmat(reshape(c,1,S,J),[T,1,1]);

    maxWindow = 1;

    costs = zeros(maxWindow, 3);
    sw    = zeros(maxWindow, 3);
    run   = zeros(maxWindow, 3);


    cvx_clear;
    %initial number of servers, x0 is a scalar or a vector with m enties.
    x0=0;

    fprintf('OPT\n');
    cvxp = cvx_precision('best');
    [x_opt cost_opt]  = hetero_opt(lambda, cc, x0, b, a, beta);
    [costs(1,3) sw(1,3) run(1,3) ld_TKM_opt] = cost(x_opt,  x0, lambda, c, b, a, beta);
    cvx_precision(cvxp)

    fprintf('AFHC, w=%d\n', w);
    x_afhc = afhc (lambda, c, b, a, beta, w);
    [costs(1,1) sw(1,1) run(1,1) ld_TKM_afhc] = cost(x_afhc, x0, lambda, c, b, a, beta);

    fprintf('RHC, w=%d\n', w);
    x_rhc  = rhc  (lambda, c, b, a, beta, w);
    [costs(1,2) sw(1,2) run(1,2) ld_TKM_rhc] = cost(x_rhc,  x0, lambda, c, b, a, beta);


    fprintf('OPT: cost %g switch %g run %g\n', costs(1,3), sw(1,3), run(1,3));
    fprintf('RHC: cost %g switch %g run %g\n', costs(1,2), sw(1,2), run(1,2));
    fprintf('AFHC: cost %g switch %g run %g\n', costs(1,1), sw(1,1), run(1,1));

    plot((1:T), x_afhc, '-', ...
         (1:T), x_rhc,'--', ...
	 (1:T), x_opt, '-.');
	 %, ...
	 %(1:T)/hourSamples, lambda/10, ':');
    %legend('Type-1 afhc','Type-2 afhc', 'Type-1 rhc', 'Type-2 rhc', 'Type-1 opt', 'Type-2 opt');

    %legend('Optimal', 'always on', 'prediction', 'history', 'both', ...
    %    'Location', 'NorthEast');
     
    xlabel('time');
    ylabel('active servers, x');
    % ticks every 6 hours
    %set(gca, 'xtick', 0:6:(T/hourSamples));
    %set (gcf, 'PaperUnits', 'centimeters', 'PaperPosition', [0.1 0 9 7]);
    set (gcf, 'PaperUnits', 'inches', 'PaperPosition', [0.1 0 7 5]);
    %ax = axis; ax(2) = 55; axis(ax);
    if ~screen_only
        print ('-depsc', sprintf('active_v_time_RHCbad.eps',0));
    end

    figure(401);
    plot(1:T,lambda);
    legend('Type-1','Type-2', 'Location', 'NorthWest');
     
    xlabel('time');
    ylabel('workload');
    % ticks every 6 hours
    %set(gca, 'xtick', 0:6:(T/hourSamples));
    %set (gcf, 'PaperUnits', 'centimeters', 'PaperPosition', [0.1 0 9 7]);
    set (gcf, 'PaperUnits', 'inches', 'PaperPosition', [0.1 0 3.5 2.5]);
    %ax = axis; ax(2) = 55; axis(ax);
    if ~screen_only
        print ('-depsc', sprintf('load_v_time_RHCbad.eps',0));
    end
end

% lambda = dailymean (trace, days, holidays, startDay)
% Calculate mean load of a regular business day
% trace:  vector of load samples
% days: number of days in the trace
% holidays: vector of week-days that seem to be holidays
% (For HP trace, holidays = [8,31])
% startDay: day-of-week of the first day of the trace:  1 for Monday

function lambda = dailymean (trace, days, holidays, startDay)

if nargin < 4
    startDay = 1;	% Start on Monday
end

if nargin < 3
    holidays = [];
end

week = [1 1 1 1 1 0 0]; % only work days
week = [week(startDay:7), week(1:startDay-1)];	% Start week on right day

business = [kron(ones(1,days/7),week), week(1:mod(days,7))];
business( holidays ) = 0;  % remove public holidays

DailySamples = length(trace)/days;
DailyTraces = reshape(trace, [DailySamples, days]);


%test_business = DailyTraces;
%test_business(:,find(1-business)) = 0;
%
%test_holiday = DailyTraces;
%test_holiday(:,find(business)) = 0;
%
%figure (1)
%plot (1:length(trace), test_business(:), 1:length(trace), test_holiday(:))

lambda = sum(DailyTraces(:,find(business)), 2) / sum(business);

function [series_cons] = find_consecutive(series)

t = [1 diff(series)];

it = find(t > 1);

if numel(it) > 0
    t2 = series(1 : (it-1) );
else
    t2 = series;
end

series_cons = t2;
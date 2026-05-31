function minY = calcola_min_Y(mask)

[il, jl] = find(edge(mask) == 1);
C = [jl il];

minY = min(C(:,2));
function N = cluster_size(required_N)
    % Generate valid cluster sizes using N = i^2 + j^2 + i*j
    valid_N = [];
    for i = 0:10
        for j = 0:10
            N_val = i^2 + j^2 + i*j;
            if N_val > 0 && ~ismember(N_val, valid_N)
                valid_N(end+1) = N_val;
            end
        end
    end
    valid_N = unique(valid_N);
    % Select the smallest valid N >= required_N
    N_candidates = valid_N(valid_N >= required_N);
    if isempty(N_candidates)
        error('No valid cluster size found for required N = %.2f', required_N);
    end
    N = min(N_candidates);
end


function A = erlangB_inverse(GOS, C)
    % Read and clean the Erlang B table
    data = readtable('Erlang B Table.xls', 'Range', 'A5:R185');
    all_nan_rows = all(ismissing(data), 2);
    data_clean = data(~all_nan_rows, :);

    % Extract GOS values from the first row (columns 2:end)
    gos_columns = data_clean{1, 2:end};
    if iscell(gos_columns)
        gos_values = cellfun(@(x) str2double(erase(num2str(x), '%'))/100, gos_columns);
    else
        gos_values = gos_columns / 100; % If already numeric, assume it's in percent
    end

    % Extract channel list and traffic values
    channels_list = data_clean{2:end, 1};
    traffic_list = data_clean{2:end, 2:end};

    % Find the closest GOS column
    [~, colIdx] = min(abs(gos_values - GOS/100)); % GOS as percentage input

    % Find the row for the given number of channels (C)
    if iscell(channels_list)
        channel_numbers = cellfun(@(x) double(x), channels_list);
    else
        channel_numbers = channels_list;
    end
    rowIdx = find(channel_numbers == C, 1);
    if isempty(rowIdx)
        error('Number of channels (%d) not found in the Erlang B table.', C);
    end

    % Return the value
    if iscell(traffic_list)
        A = traffic_list{rowIdx, colIdx};
    else
        A = traffic_list(rowIdx, colIdx);
    end
end
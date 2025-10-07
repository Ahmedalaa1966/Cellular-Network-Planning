function wireless_network_gui
    % Create the main figure
    fig = uifigure('Name', 'Wireless Network Design Inputs', 'Position', [100 100 400 400]);

    % Input labels and fields
    uilabel(fig, 'Position', [30 340 180 22], 'Text', 'Grade of Service (e.g., 0.02):');
    gosField = uieditfield(fig, 'numeric', 'Position', [220 340 120 22], 'Value', 0.02);

    uilabel(fig, 'Position', [30 300 180 22], 'Text', 'Total Urban Area (km²):');
    areaField = uieditfield(fig, 'numeric', 'Position', [220 300 120 22], 'Value', 100);

    uilabel(fig, 'Position', [30 260 180 22], 'Text', 'Subscriber Density (users/km²):');
    densityField = uieditfield(fig, 'numeric', 'Position', [220 260 120 22], 'Value', 2000);

    uilabel(fig, 'Position', [30 220 180 22], 'Text', 'Minimum SIR (dB):');
    sirField = uieditfield(fig, 'numeric', 'Position', [220 220 120 22], 'Value', 18);

    uilabel(fig, 'Position', [30 180 180 22], 'Text', 'Sector Type:');
    sectorDropdown = uidropdown(fig, 'Position', [220 180 120 22], ...
        'Items', {'Omnidirectional', '120', '60'}, 'ItemsData', [1 2 3], 'Value', 2);

    % Results area
    resultsArea = uitextarea(fig, 'Position', [30 40 310 120], 'Editable', 'off', ...
        'Value', {'--- Wireless Network Design Results ---'});

    % Calculate button
    calcBtn = uibutton(fig, 'push', 'Text', 'Calculate', 'Position', [140 10 120 30], ...
        'ButtonPushedFcn', @(btn,event) calculateCallback());

    function calculateCallback()
        % Get user inputs
        GOS = gosField.Value;
        city_area = areaField.Value;
        user_density = densityField.Value;
        SIR_min_dB = sirField.Value;
        sector_choice = sectorDropdown.Value;

        % Constants
        total_channels = 340;
        A_user = 0.025;
        f = 900;
        hb = 20;
        hm = 1.5;
        Ms_sensitivity = -95;
        path_loss_exp = 4;

        % Set sectorization parameters
        switch sector_choice
            case 1
                sectors = 1; io = 6;
            case 2
                sectors = 3; io = 2;
            case 3
                sectors = 6; io = 1;
        end

        % Cluster size calculation
        SIR = 10^(SIR_min_dB/10);
        required_N = (1/3)*((io*SIR)^(1/path_loss_exp) + 1)^2;
        N = cluster_size(required_N);

        % Channels per cell and sector
        ch_per_cell = floor(total_channels / N);
        ch_per_sector = floor(ch_per_cell / sectors);

        % Traffic per sector and cell
        A_sector = erlangB_inverse(GOS, ch_per_sector);
        A_cell = A_sector * sectors;

        % Cell radius
        users_per_sector = A_sector / A_user;
        area_sector = users_per_sector / user_density;
        area_cell = area_sector * sectors;
        radius = sqrt(area_cell / (1.5*sqrt(3)));

        % Total number of cells
        total_cells = ceil(city_area / area_cell);

        % Transmit power
        P_tx = calculate_tx_power(radius, f, hb, hm, Ms_sensitivity);

        % Display results
        results = {
            '--- Wireless Network Design Results ---';
            sprintf('Cluster Size (N): %d', N);
            sprintf('Total Cells Required: %d', total_cells);
            sprintf('Cell Radius: %.2f km', radius);
            sprintf('Traffic per Cell: %.2f Erlangs', A_cell);
            sprintf('Traffic per Sector: %.2f Erlangs', A_sector);
            sprintf('Estimated Transmit Power: %.2f dBm', P_tx)
            };
        resultsArea.Value = results;
    end
end 
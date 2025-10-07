function [cells, traffic] = Calculate_cells_and_traffic(SIR_min, GOS, user_density, sector_choice)
    % Constants
    total_channels = 340;
    A_user = 0.025; % Erlangs
    city_area = 100; % km^2
    path_loss_exp = 4;
    
    % Set sectorization parameters
    switch sector_choice
        case 1 % Omni-directional
            sectors = 1;
            io = 6;
        case 2 % 120° sectorization
            sectors = 3;
            io = 2;
        case 3 % 60° sectorization
            sectors = 6;
            io = 1;
    end
    
    % Calculate cluster size
    SIR = 10^(SIR_min/10);
    N = cluster_size((1/3)*((io*SIR)^(1/path_loss_exp) + 1)^2);
    
    % Calculate channels per cell and sector
    ch_per_cell = floor(total_channels / N);
    ch_per_sector = floor(ch_per_cell / sectors);
    
    % Calculate traffic
    A_sector = erlangB_inverse(GOS, ch_per_sector);
    traffic = A_sector * sectors;
    
    % Calculate number of cells
    users_per_sector = A_sector / A_user;
    area_sector = users_per_sector / user_density;
    area_cell = area_sector * sectors;
    cells = ceil(city_area / area_cell);
end
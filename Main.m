clear all;
clc;

%(Part A)
%% Constants 
total_channels = 340;
A_user = 0.025; % Erlangs
f = 900; % MHz
hb = 20; % BS height (m)
hm = 1.5; % MS height (m)
Ms_sensitivity = -95; % dBm
path_loss_exp = 4;
%Inputs
city_area = input('Enter city area (km^2): ');
user_density = input('Enter user density (users/km^2): ');
SIR_min_dB = input('Enter SIR_min (in dB): ');
GOS = input('Enter GOS (as a decimal, e.g., 0.02): ');
fprintf('select sectorization:\n1) omnidirectional \n2) 3-sector(120°) \n3) 6-sector(60°)\n')
sector_choice = input('Enter choice (1/2/3): ');

switch (sector_choice)
  case 1
    sectors=1;
    io=6;
  case 2
    sectors=3;
    io=2;
  case 3
    sectors=6;
    io=1;
  otherwise
    error('Invalid sectorization option.');
end

%1.cluster size calculation
SIR=10^(SIR_min_dB/10);
%Compute theoretical N
required_N=(1/3)*((io* SIR)^(1/path_loss_exp) + 1)^2  ;
N = cluster_size(required_N);



%2.no of channels in  per cell and per sector
ch_per_cell = floor(total_channels / N);
ch_per_sector = floor(ch_per_cell / sectors);


%3.Traffic per Cell and Sector
A_total = user_density * city_area * A_user;
A_sector = erlangB_inverse(GOS, ch_per_sector);  % Traffic intensity per sector
A_cell = A_sector * sectors;  % Traffic intensity per full cell



%4.Cell Radius
%Calculating cell radius using user traffic and density
    A_user = 0.025;                                     %Traffic intensity per user in Erlangs
    users_per_sector = A_sector / A_user;               %number of users per sector
    area_sector = users_per_sector / user_density;      %Area of sector
    area_cell = area_sector * sectors;                  %Area of cell
    radius = sqrt(area_cell / (1.5*sqrt(3))); % hexagonal cell area formula


%5.Total number of cells in city
    total_cells = ceil(city_area/ area_cell);


%6.Transmit Power Calculation
    P_tx = calculate_tx_power(radius, f, hb, hm, Ms_sensitivity);


%7.A plot for the MS received power in dBm versus its distance from the BS.
    received_power_plot(P_tx, f, hb, hm, radius);

%Display results
fprintf('Cluster Size (N): %d (nearest valid)\n', N);
fprintf('Total Number of Cells: %d\n', total_cells);
fprintf('Cell Radius (km): %.3f\n', radius);
fprintf('Traffic per Cell: %.3f Erlang\n', A_cell);
fprintf('Traffic per Sector: %.3f Erlang\n', A_sector);
fprintf('Required Transmit Power: %.2f dBm\n', P_tx);


%%%%%%%%%%%%%%%%%%%%%%%%%% Part B   %%%%%%%%%%%%%%%%%%%%%%%%%%


%%1 plot for Cluster Size 
SIR_min_range = 1:30; % dB
N_omni = zeros(size(SIR_min_range));
N_120 = zeros(size(SIR_min_range));
N_60 = zeros(size(SIR_min_range));


for i = 1:length(SIR_min_range)
    SIR = 10^(SIR_min_range(i)/10);
    % Omni-directional
    N_omni(i) = cluster_size((1/3)*((6*SIR)^(1/path_loss_exp) + 1)^2);
    % 120° sectorization
    N_120(i) = cluster_size((1/3)*((2*SIR)^(1/path_loss_exp) + 1)^2);
    % 60° sectorization
    N_60(i) = cluster_size((1/3)*((1*SIR)^(1/path_loss_exp) + 1)^2);
end

%%%%%%%%%%% Plot figrue(1)  %%%%%%%%%%%%%%%%%%%%%%%%%

%%1 plot for Cluster Size 
SIR_min_range = 1:30; % dB
N_omni = zeros(size(SIR_min_range));
N_120 = zeros(size(SIR_min_range));
N_60 = zeros(size(SIR_min_range));


for i = 1:length(SIR_min_range)
    SIR = 10^(SIR_min_range(i)/10);
    % Omni-directional
    N_omni(i) = cluster_size((1/3)*((6*SIR)^(1/path_loss_exp) + 1)^2);
    % 120° sectorization
    N_120(i) = cluster_size((1/3)*((2*SIR)^(1/path_loss_exp) + 1)^2);
    % 60° sectorization
    N_60(i) = cluster_size((1/3)*((1*SIR)^(1/path_loss_exp) + 1)^2);
end

%%%%%%%%%%% Plot figrue(1)  %%%%%%%%%%%%%%%%%%%%%%%%%
figure(1);
plot(SIR_min_range, N_omni, 'b', 'LineWidth', 2);
hold on;
plot(SIR_min_range, N_120, 'r', 'LineWidth', 2);
plot(SIR_min_range, N_60, 'g', 'LineWidth', 2);
grid on;
xlabel('SIR_{min} (dB)');
ylabel('Cluster Size (N)');
title('Cluster Size vs SIR_{min} for Different Sectorization Methods');
legend('Omni-directional', '120° Sectorization', '60° Sectorization');
hold off ;


% 2. Plots for SIRmin = 19dB and user density = 1400 users/km^2
SIR_min = 19;
user_density = 1400;
GOS_range = 0.01:0.01:0.30;

% Initialize arrays for storing results
cells_omni = zeros(size(GOS_range));
cells_120 = zeros(size(GOS_range));
cells_60 = zeros(size(GOS_range));
traffic_omni = zeros(size(GOS_range));
traffic_120 = zeros(size(GOS_range));
traffic_60 = zeros(size(GOS_range));

for i = 1:length(GOS_range)
    % Calculate for each sectorization method (smooth version)
    [cells_omni(i), traffic_omni(i)] = Calculate_cells_and_traffic(SIR_min, GOS_range(i), user_density, 1);
    [cells_120(i), traffic_120(i)] = Calculate_cells_and_traffic(SIR_min, GOS_range(i), user_density, 2);
    [cells_60(i), traffic_60(i)] = Calculate_cells_and_traffic(SIR_min, GOS_range(i), user_density, 3);
end

% Plot number of cells vs GOS
figure(2);
plot(GOS_range*100, cells_omni, 'b', 'LineWidth', 2);
hold on;
plot(GOS_range*100, cells_120, 'r', 'LineWidth', 2);
plot(GOS_range*100, cells_60, 'g', 'LineWidth', 2);
grid on;
xlabel('GOS (%)');
ylabel('Number of Cells');
title('Number of Cells vs GOS (SIR_{min} = 19dB)');
legend('Omni-directional', '120° Sectorization', '60° Sectorization');
hold off;

% Plot traffic intensity vs GOS
figure(3);
plot(GOS_range*100, traffic_omni, 'b', 'LineWidth', 2);
hold on;
plot(GOS_range*100, traffic_120, 'r', 'LineWidth', 2);
plot(GOS_range*100, traffic_60, 'g', 'LineWidth', 2);
grid on;
xlabel('GOS (%)');
ylabel('Traffic Intensity per Cell (Erlang)');
title('Traffic Intensity vs GOS (SIR_{min} = 19dB)');
legend('Omni-directional', '120° Sectorization', '60° Sectorization');
hold off;

% 3. Plots for SIRmin = 14dB and user density = 1400 users/km^2
SIR_min = 14;
user_density = 1400;

% Initialize arrays for storing results
cells_omni = zeros(size(GOS_range));
cells_120 = zeros(size(GOS_range));
cells_60 = zeros(size(GOS_range));
traffic_omni = zeros(size(GOS_range));
traffic_120 = zeros(size(GOS_range));
traffic_60 = zeros(size(GOS_range));

for i = 1:length(GOS_range)
    % Calculate for each sectorization method (smooth version)
    [cells_omni(i), traffic_omni(i)] = Calculate_cells_and_traffic(SIR_min, GOS_range(i), user_density, 1);
    [cells_120(i), traffic_120(i)] = Calculate_cells_and_traffic(SIR_min, GOS_range(i), user_density, 2);
    [cells_60(i), traffic_60(i)] = Calculate_cells_and_traffic(SIR_min, GOS_range(i), user_density, 3);
end

% Plot number of cells vs GOS
figure(4);
plot(GOS_range*100, cells_omni, 'b', 'LineWidth', 2);
hold on;
plot(GOS_range*100, cells_120, 'r', 'LineWidth', 2);
plot(GOS_range*100, cells_60, 'g', 'LineWidth', 2);
grid on;
xlabel('GOS (%)');
ylabel('Number of Cells');
title('Number of Cells vs GOS (SIR_{min} = 14dB)');
legend('Omni-directional', '120° Sectorization', '60° Sectorization');
hold off;

% Plot traffic intensity vs GOS
figure(5);
plot(GOS_range*100, traffic_omni, 'b', 'LineWidth', 2);
hold on;
plot(GOS_range*100, traffic_120, 'r', 'LineWidth', 2);
plot(GOS_range*100, traffic_60, 'g', 'LineWidth', 2);
grid on;
xlabel('GOS (%)');
ylabel('Traffic Intensity per Cell (Erlang)');
title('Traffic Intensity vs GOS (SIR_{min} = 14dB)');
legend('Omni-directional', '120° Sectorization', '60° Sectorization');
hold off;

% 4 & 5. Plots for different SIRmin values with GOS = 2%
GOS = 0.02;
user_density_range = 100:100:2000;

% Initialize arrays for storing results
cells_omni_14 = zeros(size(user_density_range));
cells_120_14 = zeros(size(user_density_range));
cells_60_14 = zeros(size(user_density_range));
radius_omni_14 = zeros(size(user_density_range));
radius_120_14 = zeros(size(user_density_range));
radius_60_14 = zeros(size(user_density_range));

cells_omni_19 = zeros(size(user_density_range));
cells_120_19 = zeros(size(user_density_range));
cells_60_19 = zeros(size(user_density_range));
radius_omni_19 = zeros(size(user_density_range));
radius_120_19 = zeros(size(user_density_range));
radius_60_19 = zeros(size(user_density_range));

for i = 1:length(user_density_range)
    % For SIRmin = 14dB (smooth version)
    [cells_omni_14(i), radius_omni_14(i)] = Calculate_cells_and_radius(14, GOS, user_density_range(i), 1);
    [cells_120_14(i), radius_120_14(i)] = Calculate_cells_and_radius(14, GOS, user_density_range(i), 2);
    [cells_60_14(i), radius_60_14(i)] = Calculate_cells_and_radius(14, GOS, user_density_range(i), 3);
    
    % For SIRmin = 19dB (smooth version)
    [cells_omni_19(i), radius_omni_19(i)] = Calculate_cells_and_radius(19, GOS, user_density_range(i), 1);
    [cells_120_19(i), radius_120_19(i)] = Calculate_cells_and_radius(19, GOS, user_density_range(i), 2);
    [cells_60_19(i), radius_60_19(i)] = Calculate_cells_and_radius(19, GOS, user_density_range(i), 3);
end

% Plot number of cells vs user density for SIRmin = 14dB
figure(6);
plot(user_density_range, cells_omni_14, 'b', 'LineWidth', 2);
hold on;
plot(user_density_range, cells_120_14, 'r', 'LineWidth', 2);
plot(user_density_range, cells_60_14, 'g', 'LineWidth', 2);
grid on;
xlabel('User Density (users/km^2)');
ylabel('Number of Cells');
title('Number of Cells vs User Density (SIR_{min} = 14dB, GOS = 2%)');
legend('Omni-directional', '120° Sectorization', '60° Sectorization');
hold off;

% Plot cell radius vs user density for SIRmin = 14dB
figure(7);
plot(user_density_range, radius_omni_14, 'b', 'LineWidth', 2);
hold on;
plot(user_density_range, radius_120_14, 'r', 'LineWidth', 2);
plot(user_density_range, radius_60_14, 'g', 'LineWidth', 2);
grid on;
xlabel('User Density (users/km^2)');
ylabel('Cell Radius (km)');
title('Cell Radius vs User Density (SIR_{min} = 14dB, GOS = 2%)');
legend('Omni-directional', '120° Sectorization', '60° Sectorization');
hold off;

% Plot number of cells vs user density for SIRmin = 19dB
figure(8);
plot(user_density_range, cells_omni_19, 'b', 'LineWidth', 2);
hold on;
plot(user_density_range, cells_120_19, 'r', 'LineWidth', 2);
plot(user_density_range, cells_60_19, 'g', 'LineWidth', 2);
grid on;
xlabel('User Density (users/km^2)');
ylabel('Number of Cells');
title('Number of Cells vs User Density (SIR_{min} = 19dB, GOS = 2%)');
legend('Omni-directional', '120° Sectorization', '60° Sectorization');
hold off;

% Plot cell radius vs user density for SIRmin = 19dB
figure(9);
plot(user_density_range, radius_omni_19, 'b', 'LineWidth', 2);
hold on;
plot(user_density_range, radius_120_19, 'r', 'LineWidth', 2);
plot(user_density_range, radius_60_19, 'g', 'LineWidth', 2);
grid on;
xlabel('User Density (users/km^2)');
ylabel('Cell Radius (km)');
title('Cell Radius vs User Density (SIR_{min} = 19dB, GOS = 2%)');
legend('Omni-directional', '120° Sectorization', '60° Sectorization');
hold off;
function received_power_plot(P_tx, f, hb, hm, R_km)
    % Plot MS received power (in dBm) vs. distance (km) using Hata model

    % Distance range (avoid 0 to prevent log(0))
    d_vals = linspace(0.1, R_km, 100);  % in km

    % Hata urban correction for MS
    a_hm = (1.1 * log10(f) - 0.7) * hm - (1.56 * log10(f) - 0.8);

    % Path loss for each distance
    L_vals = 69.55 + 26.16 * log10(f) - 13.82 * log10(hb) - a_hm ...
             + (44.9 - 6.55 * log10(hb)) * log10(d_vals);

    % Received power
    P_rx = P_tx - L_vals;

    % Plot
    figure;
    plot(d_vals, P_rx, 'r', 'LineWidth', 2);
    grid on;
    xlabel('Distance from BS (km)');
    ylabel('Received Power (dBm)');
    title('Mobile Station Received Power vs. Distance');
end


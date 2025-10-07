function P_tx = calculate_tx_power(R_km, f, hb, hm, Ms_sensitivity)
    % Calculates required transmit power in dBm using Hata model
    d = R_km ;  
    a_hm = (1.1 * log10(f) - 0.7) * hm - (1.56 * log10(f) - 0.8);
    L = 69.55 + 26.16 * log10(f) - 13.82 * log10(hb) - a_hm ...
        + (44.9 - 6.55 * log10(hb)) * log10(d);  % Hata model in km
    P_tx = Ms_sensitivity + L;
end


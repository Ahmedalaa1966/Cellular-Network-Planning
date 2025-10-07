# Wireless Network Planning Tool  

This project designs a simple planning tool using **MATLAB/Python** for a service provider that owns **340 channels in the 900 MHz band**.  

The tool asks for the following input parameters:  
- Grade of Service (GOS)  
- City area  
- User density  
- Minimum required Signal-to-Interference Ratio (SIRmin)  
- Sectorization method  

Blocked calls are assumed to be cleared in this system.  

---

## Output Design Parameters  
The tool produces the following outputs:  
1. Cluster Size  
2. Total number of cells in the city  
3. Cell radius  
4. Traffic intensity per cell and per sector  
5. Base station transmitted power  
6. A plot of MS received power in dBm versus its distance from the BS  

---

## Assumptions and Models  
- **Propagation Model:** Hata model (urban, medium city)  
- **Traffic per user:** 0.025 Erlang  
- **Base Station height (hBS):** 20 m  
- **Mobile Station height (hMS):** 1.5 m  
- **MS sensitivity:** −95 dB  
- **Path loss exponent:** 4  

---

## Validation and Analysis  
To validate the tool and analyze trade-offs, simulations are provided for a city of area **100 km²** with the following figures (each containing curves for omni-directional, 120° sectorization, and 60° sectorization designs):  

1. **Cluster size vs. SIRmin** (1 dB to 30 dB).  
2. At **SIRmin = 19 dB** and **user density = 1400 users/km²**:  
   - Number of cells vs. GOS (1% to 30%)  
   - Traffic intensity per cell vs. GOS (1% to 30%)  
3. At **SIRmin = 14 dB** and **user density = 1400 users/km²**:  
   - Number of cells vs. GOS (1% to 30%)  
   - Traffic intensity per cell vs. GOS (1% to 30%)  
4. At **SIRmin = 14 dB** and **GOS = 2%**:  
   - Number of cells vs. user density (100 to 2000 users/km²)  
   - Cell radius vs. user density (100 to 2000 users/km²)  
5. At **SIRmin = 19 dB** and **GOS = 2%**:  
   - Number of cells vs. user density (100 to 2000 users/km²)  
   - Cell radius vs. user density (100 to 2000 users/km²)  

---

## Notes  
- The design criteria and optimization parameters must be clearly defined.  
- The code is generic and works for different input values as specified.  

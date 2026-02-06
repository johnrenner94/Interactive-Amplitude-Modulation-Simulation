# Interactive AM Radio Simulation (MATLAB)

This project is an interactive MATLAB simulation of an amplitude-modulated (AM) radio transmission and reception system. It allows a user to record an audio message, modulate it onto a carrier, demodulate it, and evaluate the quality of the recovered signal using both visual and quantitative metrics.

The goal of the project is to demonstrate core AM concepts in both the time and frequency domains while providing hands-on control over system parameters such as carrier frequency, modulation index, and noise level.

## Features
- Real-time audio recording and playback
- Double-sideband amplitude modulation and coherent demodulation
- Adjustable carrier frequency, message bandwidth, amplitude, and noise
- Time-domain visualization of message, carrier, modulated, and demodulated signals
- Frequency-domain analysis showing sidebands and spectral recovery
- Quantitative performance metrics:
  - Signal-to-Noise Ratio (SNR)
  - Peak Signal-to-Noise Ratio (PSNR)
  - Mean Squared Error (MSE)
  - Correlation coefficient
- Interactive playback controls embedded in MATLAB figures

## Files
- `AM_Simulation.m` — Main MATLAB script
- `RennerJohn_InteractiveAMSimulation.pdf` — Project paper describing theory, methodology, and results
- `figures/` — Example output plots from various simulation scenarios

## How to Run
1. Open MATLAB
2. Open `AM_Simulation.m`
3. Adjust user-defined parameters at the top of the script if desired
4. Run the script
5. Record a short audio message when prompted
6. View plots and use on-screen buttons to play original and demodulated audio

## Notes
This version implements coherent (synchronous) demodulation using an ideal carrier reference. As a result, some distortion effects (e.g., overmodulation or sideband overlap) are less audible than in practical envelope-detected receivers.

Future iterations may explore:
- Envelope detection
- Carrier frequency/phase offset
- Non-ideal receiver behavior
- Comparative demodulation strategies

## Author
John Renner

clc
clear all
close all

%% _____________USER DEFINED PARAMETERS_______________________________
messageLength = 3;          % Message time in seconds
fc = 50000;                 % Carrier Frequency
message_flimit = 5000;
message_amp = .75;
carrier_amp = 1;
noise_factor = 0;

%% ________________AXES, CREATE CARRIER/NOISE_______________________
fs = 2*(fc*2+message_flimit)*1.2;         % Sampling frequency
n = fs * messageLength;         % Number of samples

t = (0:n-1)*(1/fs);             % time axis
w = fs * (-n/2:(n/2)-1) / n;    % 2-sided freq axis

carrier = carrier_amp * cos(fc*2*pi*t);    % Create Carrier signal
noise = noise_factor*randn(1, n)/100;      % Create Noise Signal

%% ___________Audio Recording__________________________________________
recObj = audiorecorder(12000, 16, 1);   % 12kHz, 16 bit, 1 channel
disp("Begin recording.")
recordblocking(recObj, messageLength);
disp("End of recording.")
disp("Processing audio...")
audio = getaudiodata(recObj);

audio = (resample(audio, fs, 12000))';          % Resample audio at fs
audio = audio * message_amp / max(audio);       % normalize signal based on user-defined modulation index

message = bandpass(audio, [100 message_flimit], fs); % Audio Signal

%% ________________Modulation Function_________________________________
disp("Performing Amplitude Modulation/Demodulation...")

mod_signal = (message).*carrier + noise;           % Modulate Carrier signal
mod_signal = bandpass(mod_signal, [(fc-message_flimit), (fc+message_flimit)], fs);
mod_signal_fourier =  fftshift(abs(fft(mod_signal))/n);

demod_signal = 2*mod_signal.*carrier;      % Demodulate
demod_signal_fourier = fftshift(abs(fft(demod_signal))/n);
demod_signal = bandpass(demod_signal, [100 message_flimit], fs); % Retrieve original signal

disp("Calculating FFTs...")
in_fourier = fftshift(abs(fft(message))/n);          % Input FFT
in_fourier = smoothdata(in_fourier, "movmean", 20); % smooth data
in_fourier = 20*log(in_fourier);

out_fourier = fftshift(abs(fft(demod_signal))/n);        % Output FFT
out_fourier = smoothdata(out_fourier, "movmean", 20);   % smooth data
out_fourier = 20*log(out_fourier);

%% _______________PLAYBACK______________________________
message_downsample = resample(message, 12000, fs);
demod_signal_downsample = resample(demod_signal, 12000, fs);

disp("Playing Original Message...")
soundsc(message_downsample, 12000)

pause(messageLength + 2)

disp("Playing Demodulated Message...")
soundsc(demod_signal_downsample, 12000)

%% ____________________ANALYSIS________________________________
disp('***********************************************')
message_power = mean(message.^2);
noise_power = mean((message - demod_signal).^2);
snr_value = 10 * log10(message_power / noise_power);
disp(['SNR (Demodulated Signal): ', num2str(snr_value), ' dB']);

mse_value = mean((message - demod_signal).^2);
disp(['MSE: ', num2str(mse_value)]);

correlation = corrcoef(message, demod_signal);
correlation_value = correlation(1,2);
disp(['Correlation Coefficient: ', correlation_value]);

peak_amplitude = max(abs(message));
psnr_value = 10 * log10(peak_amplitude^2 / mse_value);
disp(['PSNR: ', num2str(psnr_value), ' dB']);

mod_index = max(abs(message))/max(abs(carrier+noise));
disp(['Modulation Index: ', num2str(mod_index)]);

%% ____________TIME PLOTS_________________________________________
myFigure = figure('Name', 'Waveforms', 'NumberTitle', 'off', 'WindowState', 'Maximized');

subplot(4,2,2);        % Plot message x(t)
    plot(t, message);
        title('Message Signal m(t)')
            grid on;
        xlabel('Time (seconds)')
            xlim([-0.2, messageLength*1.05])
        ylabel('Amplitude')
            ylim([-1.2 1.2])

subplot(4,2,4)          % Plot demodulated output signal z(t)
    plot(t, demod_signal, 'r')
       title('Demodulated Output Signal')
           grid on;
       xlabel('Time (seconds)')
           xlim([-0.2, messageLength*1.05])
       ylabel('Amplitude')
           ylim([-1.2 1.2])

% _______________ FREQUENCY PLOTS____________________________________
 subplot(4,2,6)  % Plot 1-sided fft of modulated carrier Y(w)       
     plot(w, in_fourier, 'LineWidth', 1)
         title('Fourier Tranform of Original Message signal')
            grid on;
         xlabel('Frequency (Hz)')
            xlim([20 10000])
            xscale log
            xticks ([60 125 250 500 1000 2000 4000 8000])
         ylabel('Amplitude')      
     hold on;
     plot(w, out_fourier, 'r--') 
        legend('Original','Demodulated', Location='south', Orientation='Horizontal')
     hold off;

 subplot(4,2,8);         % Input and Ouput Freq Plots
     plot(w, mod_signal_fourier)
         title('Fourier Tranform of Modulated Carrier Signal')
            grid on;
         xlabel('Frequency (Hz)')
            xlim([-(2*fc + 10000), 2*fc + 10000])
            xticks ([-2*fc, -3*fc/2, -fc, -fc/2, ...
                      0, fc/2, fc, 3*fc/2, 2*fc ])
         ylabel('Amplitude')
    hold on;               
    plot(w, demod_signal_fourier/2, 'r')
            legend('Modulated','Demodulated')
    hold off;

% _______________ TIME PLOTS - ZOOMS_________________________
subplot(4,2,1)         % Plot message x(t)
    plot(t, message);
        title('Message Signal m(t)')
            grid on;
        xlabel('Time (seconds)')
            xlim([messageLength/2, (messageLength/2)+0.005])
        ylabel('Amplitude')

    
subplot(4,2,3)        % Plot carrier m(t)
    plot(t, carrier+noise, 'g');
        title('Carrier Signal c(t)')
            grid on;
        xlabel('Time (seconds)')
            xlim([messageLength/2, (messageLength/2)+0.005])
        ylabel('Amplitude')

subplot(4,2,5)         % Plot modulated signal y(t)
    plot(t, mod_signal, 'g');
        title('Modulated Signal x(t)')
            grid on;
        xlabel('Time (seconds)')
            xlim([messageLength/2, (messageLength/2)+0.005])
        ylabel('Amplitude (dB)')
        hold on;
        plot(t, message, 'bl');
        plot(t, demod_signal, 'r');
            legend('Modulated','Original','Demodulated', ...
                Orientation='horizontal', Location='south')
        hold off;

 subplot(4,2,7)          % Plot demodulated output signal z(t)
     plot(t, demod_signal, 'r')
        title('Demodulated Signal')
            grid on;
        xlabel('Time (seconds)')
            xlim([messageLength/2, (messageLength/2)+0.005])
        ylabel('Amplitude')
     
    % Add Play Original Button
    uicontrol('Style', 'pushbutton', ...
        'String', 'Play Original', ...
        'Position', [20, 20, 120, 40], ...
        'Callback', @(src, event) soundsc(message_downsample, 12000));

% Add Play Demodulated Button
    uicontrol('Style', 'pushbutton', ...
        'String', 'Play Demodulated', ...
        'Position', [150, 20, 120, 40], ...
        'Callback', @(src, event) soundsc(demod_signal_downsample, 12000));

%   Display SNR, MSE, Correlation, PSNR
    param_text_ui = sprintf(['Correlation Coefficient: \n%.2f\n\n' ...
                         'Mean Square Error: \n%.4f\n\n' ...
                         'SNR (dB): \n%.2f\n\n' ...
                         'PSNR (dB): \n%2f\n\n' ...
                         'Mod Index: \n%2f\n\n' ...
                         'Message Amplitude: \n%2f\n\n' ...
                         'Message Length: \n%2f\n\n' ...
                         'Carrier Amplitude: \n%2f\n\n' ...
                         'Carrier Frequency: \n%d\n\n' ...
                         'Noise Factor: \n%d\n\n' ...
                         'Message Upper Freq Limit: \n%d\n\n'], ...
                          correlation_value, mse_value, snr_value, ...
                          psnr_value, mod_index, message_amp, ...
                          messageLength, carrier_amp, fc, ...
                          noise_factor, message_flimit);

uicontrol('Style', 'text', ...
    'String', param_text_ui, ...
    'Position', [10, 150, 140, 420], ... % [x, y, width, height]
    'FontSize', 8, ...
    'HorizontalAlignment', 'left', ...
    'BackgroundColor', 'white', ...
    'ForegroundColor', 'black');

%% _____ SAVE FILES________________________________
% Save the audio file
audiowrite('original_message.wav', message, fs);
audiowrite('demodulated_message.wav', demod_signal, fs);
saveas(myFigure, 'waveforms.png');
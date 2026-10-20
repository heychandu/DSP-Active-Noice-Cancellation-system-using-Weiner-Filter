%% Wiener Noise Reduction - V0.5
% Offline audio-file processing. No microphone input.

clc; clear; close all;

%% Load audio
[file, path] = uigetfile( ...
    {'*.wav;*.flac;*.mp3;*.m4a', 'Audio Files'}, 'Select Noisy Audio');
if isequal(file, 0)
    disp('No file selected.');
    return;
end

sourcePath = fullfile(path, file);
try
    [x, Fs] = audioread(sourcePath);
catch ME
    errordlg(sprintf('Could not read the selected audio file:\n%s', ...
        ME.message), 'Audio Read Error');
    rethrow(ME);
end
if isempty(x) || any(~isfinite(x(:)))
    error('Invalid audio file.');
end

if size(x, 2) > 1
    xMono = mean(x, 2);
else
    xMono = x(:);
end
xMono = double(xMono);
xMono = xMono - mean(xMono);
original = xMono;

fprintf('Sample rate: %d Hz\n', Fs);
fprintf('Duration: %.2f seconds\n', length(original) / Fs);
fprintf('Version: V0.5 - Fixed 5-second noise profile\n');

%% High-pass filter
hpCutoff = 55;
if hpCutoff < Fs / 2
    [bHP, aHP] = butter(3, hpCutoff / (Fs / 2), 'high');
    x = filtfilt(bHP, aHP, xMono);
else
    x = xMono;
end

%% Mains-hum notch filters
removeHum = true;
if removeHum
    mainsHz = 50;
    Q = 35;
    for f0 = mainsHz:mainsHz:200
        if f0 >= Fs / 2 - 1
            break;
        end
        w0 = 2 * pi * f0 / Fs;
        r = exp(-pi * f0 / (Q * Fs));
        bN = [1, -2 * cos(w0), 1];
        aN = [1, -2 * r * cos(w0), r^2];
        bN = bN * sum(aN) / sum(bN);
        x = filtfilt(bN, aN, x);
    end
end
filteredInput = x;

%% STFT and fixed noise profile
noiseDuration = 5;
if length(filteredInput) / Fs < noiseDuration
    error(['Audio must be at least 5 seconds long. ', ...
        'Reduce noiseDuration in the script for shorter recordings.']);
end

winLength = 1024;
overlap = 768;
nfft = 1024;
win = hamming(winLength, 'periodic');

%% Wiener-filter settings
initialSuppression = 1.8;
initialGateThreshold = 0.25;
initialMinimumGain = 0.10;
refilterSuppression = 1.25;
refilterGateThreshold = 0.12;
refilterMinimumGain = 0.25;

%% Initial processing pass
fprintf('\nRunning initial Wiener filter...\n');
currentInput = filteredInput;
processedAudio = runWienerPass(currentInput, Fs, win, overlap, nfft, ...
    noiseDuration, initialSuppression, initialGateThreshold, initialMinimumGain);
passNumber = 1;
previewInput = original;

%% Preview and decision loop
while true
    if isempty(processedAudio) || any(~isfinite(processedAudio)) || ...
            max(abs(processedAudio)) < 1e-8
        errordlg('Processed audio is silent or invalid.', 'Processing Error');
        break;
    end

    comparisonPeak = max([abs(previewInput(:)); abs(processedAudio(:))]);
    playbackGain = 1;
    if comparisonPeak > 0.98
        playbackGain = 0.98 / comparisonPeak;
    end

    if passNumber == 1
        disp('Playing original audio...');
    else
        fprintf('Playing previously denoised audio before pass %d...\n', passNumber);
    end
    sound(previewInput * playbackGain, Fs);
    pause(length(previewInput) / Fs + 0.8);

    fprintf('Playing noise-reduced audio after pass %d...\n', passNumber);
    sound(processedAudio * playbackGain, Fs);
    pause(length(processedAudio) / Fs + 0.8);

    choice = questdlg( ...
        sprintf(['Preview completed after pass %d.\n\n', ...
        'You have heard the comparison input and processed audio.\n\n', ...
        'Save: Save the current result\n', ...
        'Refilter: Apply another Wiener pass\n', ...
        'Cancel: Exit without saving'], passNumber), ...
        'Compare Audio Results', 'Save', 'Refilter', 'Cancel', 'Save');
    if isempty(choice)
        choice = 'Cancel';
    end

    switch choice
        case 'Save'
            [saveFile, savePath] = uiputfile( ...
                {'*.wav', 'WAV Audio (*.wav)'; ...
                 '*.mp3', 'MP3 Audio (*.mp3)'}, ...
                'Save Noise-Reduced Audio', 'Advanced_Noise_Reduced.wav');
            if isequal(saveFile, 0)
                disp('Save dialog cancelled. Returning to preview.');
                continue;
            end

            outputFile = fullfile(savePath, saveFile);
            if strcmpi(outputFile, sourcePath)
                errordlg(['Choose a different output path; the original ', ...
                    'source file cannot be overwritten.'], 'Source File Protected');
                continue;
            end

            try
                audiowrite(outputFile, processedAudio, Fs);
                fprintf('\nAudio saved successfully:\n%s\n', outputFile);
                msgbox(sprintf('Noise-reduced audio saved successfully!\n\n%s', ...
                    outputFile), 'Save Complete', 'help');
                disp('Processing finished.');
                break;
            catch ME
                errordlg(sprintf('Could not save the audio:\n%s', ME.message), ...
                    'Save Error');
                continue;
            end

        case 'Refilter'
            previewInput = processedAudio;
            currentInput = processedAudio;
            passNumber = passNumber + 1;
            fprintf('\nStarting Wiener refilter pass %d...\n', passNumber);
            processedAudio = runWienerPass(currentInput, Fs, win, overlap, nfft, ...
                noiseDuration, refilterSuppression, refilterGateThreshold, ...
                refilterMinimumGain);
            fprintf('Refilter pass %d completed.\n', passNumber);
            continue;

        otherwise
            disp('Cancelled. Audio was not saved.');
            break;
    end
end

%% Final waveform and spectrogram comparisons
if exist('processedAudio', 'var') && ~isempty(processedAudio)
    L = min(length(original), length(processedAudio));
    figure('Color', 'w', 'Name', 'Noise Reduction Comparison');
    subplot(2, 1, 1);
    plot((0:L-1) / Fs, original(1:L));
    title('Original Audio'); xlabel('Time (seconds)'); ylabel('Amplitude'); grid on;
    subplot(2, 1, 2);
    plot((0:L-1) / Fs, processedAudio(1:L));
    title(sprintf('Noise-Reduced Audio - Pass %d', passNumber));
    xlabel('Time (seconds)'); ylabel('Amplitude'); grid on;

    figure('Color', 'w', 'Name', 'Spectrogram Comparison');
    subplot(2, 1, 1);
    spectrogram(original, win, overlap, nfft, Fs, 'yaxis');
    title('Original Audio');
    subplot(2, 1, 2);
    spectrogram(processedAudio, win, overlap, nfft, Fs, 'yaxis');
    title(sprintf('Processed Audio - Pass %d', passNumber));
end

disp('Finished.');

function y = runWienerPass(inputSignal, Fs, win, overlap, nfft, ...
    noiseDuration, suppressionStrength, gateThreshold, minimumGain)

inputSignal = double(inputSignal(:));
inputSignal(~isfinite(inputSignal)) = 0;
if length(inputSignal) / Fs < noiseDuration
    error(['Audio is shorter than noiseDuration. ', ...
        'Reduce noiseDuration in the script.']);
end

noiseLength = min(round(noiseDuration * Fs), length(inputSignal));
noiseSegment = inputSignal(1:noiseLength);
[S, ~, ~] = stft(inputSignal, Fs, 'Window', win, ...
    'OverlapLength', overlap, 'FFTLength', nfft);
N = stft(noiseSegment, Fs, 'Window', win, ...
    'OverlapLength', overlap, 'FFTLength', nfft);

noisePower = median(abs(N).^2, 2);
noisePower = max(noisePower, 1e-12);
noisePowerMatrix = repmat(noisePower, 1, size(S, 2));
signalPower = abs(S).^2;
cleanPower = max(signalPower - suppressionStrength * noisePowerMatrix, 0);
wienerGain = cleanPower ./ ...
    (cleanPower + suppressionStrength * noisePowerMatrix + eps);
wienerGain = movmean(wienerGain, 3, 1);
wienerGain = movmean(wienerGain, 5, 2);
gate = max(wienerGain - gateThreshold, 0) / (1 - gateThreshold);
gate = min(max(gate, 0), 1);
combinedGain = min(max(wienerGain .* gate, minimumGain), 1);

y = istft(combinedGain .* S, Fs, 'Window', win, ...
    'OverlapLength', overlap, 'FFTLength', nfft);
y = real(y(:));
y(~isfinite(y)) = 0;
L = min(length(y), length(inputSignal));
y = y(1:L);
inputSignal = inputSignal(1:L);
if isempty(y) || max(abs(y)) < 1e-8
    error('Output is nearly silent. Check the input audio.');
end

rmsIn = sqrt(mean(inputSignal.^2));
rmsOut = sqrt(mean(y.^2));
if rmsIn > 1e-8 && rmsOut > 1e-8
    levelGain = min(rmsIn / rmsOut, 1.5);
    y = y * levelGain;
end
peak = max(abs(y));
if peak > 0.98
    y = y * (0.98 / peak);
end
end

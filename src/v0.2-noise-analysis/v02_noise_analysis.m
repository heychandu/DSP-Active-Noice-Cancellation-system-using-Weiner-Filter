%% Active Noise Cancellation Using a Wiener Filter
% Version 0.2: Time-domain and frequency-domain audio analysis.

clc;
clear;
close all;

%% 1. Select an audio file
[fileName, folderPath] = uigetfile( ...
    {'*.wav;*.flac;*.mp3;*.m4a;*.aac', ...
     'Supported audio files (*.wav, *.flac, *.mp3, *.m4a, *.aac)'; ...
     '*.*', 'All files (*.*)'}, ...
    'Select a noisy audio file for analysis');

if isequal(fileName, 0)
    disp('No file selected. Program cancelled.');
    return;
end

fullFilePath = fullfile(folderPath, fileName);

%% 2. Read the audio
try
    [audioIn, sampleRate] = audioread(fullFilePath);
catch ME
    errordlg(sprintf('Could not read the selected audio file:\n%s', ...
        ME.message), 'Audio Read Error');
    rethrow(ME);
end

if isempty(audioIn)
    errordlg('The selected audio file contains no samples.', ...
        'Empty Audio File');
    return;
end

[numSamples, numChannels] = size(audioIn);

if numSamples < 2
    errordlg('The selected audio file must contain at least two samples.', ...
        'Audio Too Short');
    return;
end

durationSeconds = numSamples / sampleRate;

%% 3. Print basic measurements
fprintf('\n====================================================\n');
fprintf(' Active Noise Cancellation Using a Wiener Filter\n');
fprintf(' Version 0.2 — Noise Analysis\n');
fprintf('====================================================\n');
fprintf('File           : %s\n', fileName);
fprintf('Sample rate    : %d Hz\n', sampleRate);
fprintf('Channels       : %d\n', numChannels);
fprintf('Samples        : %d\n', numSamples);
fprintf('Duration       : %.3f seconds\n', durationSeconds);
fprintf('Analysis       : waveform + averaged amplitude spectrum\n');
fprintf('Noise reduction: NOT applied in V0.2\n\n');

for channel = 1:numChannels
    channelSignal = audioIn(:, channel);
    peakAmplitude = max(abs(channelSignal));
    rmsAmplitude = sqrt(mean(channelSignal.^2));

    fprintf('Channel %d: peak = %.5f, RMS = %.5f\n', ...
        channel, peakAmplitude, rmsAmplitude);
end

%% 4. Prepare the waveform plot
maxPlotPoints = 200000;
displayStride = max(1, ceil(numSamples / maxPlotPoints));
sampleIndices = 1:displayStride:numSamples;
timePlot = (sampleIndices - 1)' / sampleRate;

channelLabels = cell(1, numChannels);
for channel = 1:numChannels
    channelLabels{channel} = sprintf('Channel %d', channel);
end

%% 5. Estimate average single-sided amplitude spectrum

frameLength = min(8192, numSamples);
nfft = 2^nextpow2(frameLength);
hopLength = max(1, floor(frameLength / 2));

if frameLength > 1
    window = 0.5 - 0.5 * cos(2 * pi * (0:frameLength-1)' / ...
        (frameLength - 1));
else
    window = ones(frameLength, 1);
end

windowSum = sum(window);
if windowSum <= 0
    window = ones(frameLength, 1);
    windowSum = sum(window);
end

lastFrameStart = numSamples - frameLength + 1;
frameStarts = 1:hopLength:lastFrameStart;
if frameStarts(end) ~= lastFrameStart
    frameStarts(end + 1) = lastFrameStart;
end

numFrames = numel(frameStarts);
numFrequencyBins = floor(nfft / 2) + 1;
frequencyHz = (0:numFrequencyBins-1)' * sampleRate / nfft;
averageSpectrum = zeros(numFrequencyBins, numChannels);

for channel = 1:numChannels
    accumulatedSpectrum = zeros(numFrequencyBins, 1);

    for frameIndex = 1:numFrames
        firstSample = frameStarts(frameIndex);
        lastSample = firstSample + frameLength - 1;
        frame = audioIn(firstSample:lastSample, channel);

        frame = frame - mean(frame);
        windowedFrame = frame .* window;

        transformedFrame = fft(windowedFrame, nfft);
        singleSided = abs(transformedFrame(1:numFrequencyBins)) / windowSum;

        if rem(nfft, 2) == 0
            if numFrequencyBins > 2
                singleSided(2:end-1) = 2 * singleSided(2:end-1);
            end
        else
            singleSided(2:end) = 2 * singleSided(2:end);
        end

        accumulatedSpectrum = accumulatedSpectrum + singleSided;
    end

    averageSpectrum(:, channel) = accumulatedSpectrum / numFrames;

    if numFrequencyBins > 1
        [~, relativePeakIndex] = max(averageSpectrum(2:end, channel));
        peakIndex = relativePeakIndex + 1;
        fprintf('Channel %d: strongest non-DC spectrum bin ~ %.2f Hz\n', ...
            channel, frequencyHz(peakIndex));
    end
end

fprintf('Frames analyzed per channel: %d (frame length: %d samples)\n', ...
    numFrames, frameLength);
fprintf('The strongest spectral bin is not automatically a noise frequency.\n\n');

%% 6. Plot waveform and spectrum
figure('Name', 'V0.2 - Audio Noise Analysis', ...
       'NumberTitle', 'off', 'Color', 'w');

subplot(2, 1, 1);
hold on;
for channel = 1:numChannels
    plot(timePlot, audioIn(sampleIndices, channel), 'LineWidth', 0.8);
end
hold off;
grid on;
xlabel('Time (seconds)');
ylabel('Amplitude');
title(sprintf('Input Waveform: %s', fileName), 'Interpreter', 'none');
legend(channelLabels, 'Location', 'best');

subplot(2, 1, 2);
hold on;
for channel = 1:numChannels
    spectrumDb = 20 * log10(max(averageSpectrum(:, channel), eps));
    plot(frequencyHz, spectrumDb, 'LineWidth', 1.0);
end
hold off;
grid on;
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB re: unit amplitude)');
title('Average Single-Sided Amplitude Spectrum');
xlim([0, sampleRate / 2]);
legend(channelLabels, 'Location', 'best');

%% 7. Play the original input for listening reference
fprintf('Playing the original audio for reference...\n');
soundsc(audioIn, sampleRate);

disp('V0.2 complete. No filtering was applied and the source file was not modified.');

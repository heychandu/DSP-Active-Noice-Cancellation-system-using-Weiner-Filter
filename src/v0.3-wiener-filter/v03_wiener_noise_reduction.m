%% Active Noise Cancellation Using a Wiener Filter
% Version 0.3: Offline spectral Wiener noise reduction.
%
% Important:
% - Select a segment that contains ONLY unwanted background noise.
% - This is single-recording noise reduction, not adaptive ANC with a
%   separate reference-noise input.
% - This script does not save or overwrite the input file.

clc;
clear;
close all;

%% 1. Select input audio
[fileName, folderPath] = uigetfile( ...
    {'*.wav;*.flac;*.mp3;*.m4a;*.aac', ...
     'Supported audio files (*.wav, *.flac, *.mp3, *.m4a, *.aac)'; ...
     '*.*', 'All files (*.*)'}, ...
    'Select a noisy audio file');

if isequal(fileName, 0)
    disp('No file selected. Program cancelled.');
    return;
end

fullFilePath = fullfile(folderPath, fileName);

try
    [audioIn, sampleRate] = audioread(fullFilePath);
catch ME
    errordlg(sprintf('Could not read the selected audio file:\n%s', ...
        ME.message), 'Audio Read Error');
    rethrow(ME);
end

if isempty(audioIn) || size(audioIn, 1) < 64
    errordlg('Choose an audio file containing at least 64 samples.', ...
        'Audio Too Short');
    return;
end

[numSamples, numChannels] = size(audioIn);
durationSeconds = numSamples / sampleRate;

%% 2. Configure frame and hop lengths
% Target about 25 ms per frame, rounded to a power of two. Cap the frame
% size so short recordings can still be processed.
frameLength = 2^round(log2(0.025 * sampleRate));
frameLength = max(128, min(2048, frameLength));

% Keep at least about two frames in the recording.
largestAllowedFrame = 2^floor(log2(floor(numSamples / 2)));
frameLength = min(frameLength, largestAllowedFrame);

if frameLength < 32
    errordlg('The audio recording is too short for this filter.', ...
        'Audio Too Short');
    return;
end

hopLength = max(1, floor(frameLength / 2));
window = 0.54 - 0.46 * cos(2 * pi * (0:frameLength-1)' / ...
    (frameLength - 1));  % Hamming window; nonzero at edges
windowSum = sum(window);

%% 3. Ask for a noise-only segment and a gain floor
% The noise estimate is only meaningful when this segment excludes the
% wanted speech/music. Defaults are suggestions, not automatic detection.
defaultNoiseDuration = min(0.5, max(frameLength / sampleRate, ...
    durationSeconds / 4));
defaultNoiseDuration = min(defaultNoiseDuration, durationSeconds / 2);

prompt = { ...
    'Noise-only segment start time (seconds):', ...
    'Noise-only segment duration (seconds):', ...
    'Minimum Wiener gain (0 to 1):'};
defaults = {'0', sprintf('%.4f', defaultNoiseDuration), '0.05'};

answers = inputdlg(prompt, 'V0.3 Wiener Filter Parameters', ...
    [1 52; 1 52; 1 52], defaults);

if isempty(answers)
    disp('Parameter entry cancelled. No audio was changed.');
    return;
end

parameters = zeros(1, numel(answers));
for parameterIndex = 1:numel(answers)
    parameters(parameterIndex) = str2double(answers{parameterIndex});
end

if any(isnan(parameters)) || any(isinf(parameters))
    errordlg('Enter valid numeric values for all parameters.', ...
        'Invalid Parameters');
    return;
end

noiseStartSeconds = parameters(1);
noiseDurationSeconds = parameters(2);
minimumGain = parameters(3);

if noiseStartSeconds < 0 || noiseDurationSeconds <= 0 || ...
        minimumGain < 0 || minimumGain > 1
    errordlg(['Start time and duration must be nonnegative (duration > 0), ' ...
        'and minimum gain must be between 0 and 1.'], 'Invalid Parameters');
    return;
end

noiseStartIndex = floor(noiseStartSeconds * sampleRate) + 1;
noiseEndIndex = floor((noiseStartSeconds + noiseDurationSeconds) * sampleRate);

if noiseStartIndex < 1 || noiseEndIndex > numSamples || ...
        noiseEndIndex < noiseStartIndex
    errordlg('The selected noise-only segment is outside the audio file.', ...
        'Invalid Noise Segment');
    return;
end

noiseSamples = noiseEndIndex - noiseStartIndex + 1;
if noiseSamples < frameLength
    errordlg(sprintf(['The noise-only segment must be at least %.3f seconds ' ...
        'long for the current frame size.'], frameLength / sampleRate), ...
        'Noise Segment Too Short');
    return;
end

noiseOnly = audioIn(noiseStartIndex:noiseEndIndex, :);

%% 4. Estimate noise power spectrum for each channel
noiseFrameStarts = 1:hopLength:(noiseSamples - frameLength + 1);
numNoiseFrames = numel(noiseFrameStarts);
noisePower = zeros(frameLength, numChannels);

for channel = 1:numChannels
    accumulatedNoisePower = zeros(frameLength, 1);

    for frameIndex = 1:numNoiseFrames
        firstSample = noiseFrameStarts(frameIndex);
        lastSample = firstSample + frameLength - 1;
        noiseFrame = noiseOnly(firstSample:lastSample, channel);
        noiseFFT = fft(noiseFrame .* window);
        accumulatedNoisePower = accumulatedNoisePower + abs(noiseFFT).^2;
    end

    noisePower(:, channel) = accumulatedNoisePower / numNoiseFrames;
end

%% 5. Apply the frame-based Wiener gain and weighted overlap-add
% Frames begin before sample 1 and continue through the end of the signal.
% Zero padding at the boundaries plus weighted overlap-add prevents length
% changes and reduces edge artifacts. Hamming window endpoints are nonzero.

frameStarts = (-frameLength + 1):hopLength:numSamples;
numFrames = numel(frameStarts);

outputAccumulation = zeros(numSamples, numChannels);
weightAccumulation = zeros(numSamples, 1);
previousGain = ones(frameLength, numChannels);

% Average windowed magnitude spectra for a before/after plot.
numSpectrumBins = floor(frameLength / 2) + 1;
inputMagnitudeSum = zeros(numSpectrumBins, numChannels);
outputMagnitudeSum = zeros(numSpectrumBins, numChannels);

gainSmoothing = 0.70;

for frameIndex = 1:numFrames
    frameStart = frameStarts(frameIndex);
    sourceIndices = frameStart + (0:frameLength-1);
    validMask = sourceIndices >= 1 & sourceIndices <= numSamples;
    validSourceIndices = sourceIndices(validMask);
    validWindowPositions = find(validMask);

    for channel = 1:numChannels
        inputFrame = zeros(frameLength, 1);
        inputFrame(validMask) = audioIn(validSourceIndices, channel);

        windowedFrame = inputFrame .* window;
        inputFFT = fft(windowedFrame);
        observedPower = abs(inputFFT).^2;

        % Estimate desired-signal power and form a Wiener-like gain.
        estimatedSignalPower = max(observedPower - noisePower(:, channel), 0);
        rawGain = estimatedSignalPower ./ max(observedPower, eps);
        rawGain = max(min(rawGain, 1), minimumGain);

        % Smooth gains over time to reduce rapid frame-to-frame changes.
        if frameIndex == 1
            smoothedGain = rawGain;
        else
            smoothedGain = gainSmoothing * previousGain(:, channel) + ...
                (1 - gainSmoothing) * rawGain;
        end
        previousGain(:, channel) = smoothedGain;

        filteredFFT = smoothedGain .* inputFFT;
        filteredFrame = real(ifft(filteredFFT));
        synthesisFrame = filteredFrame .* window;

        outputAccumulation(validSourceIndices, channel) = ...
            outputAccumulation(validSourceIndices, channel) + ...
            synthesisFrame(validWindowPositions);

        inputMagnitudeSum(:, channel) = inputMagnitudeSum(:, channel) + ...
            abs(inputFFT(1:numSpectrumBins));
        outputMagnitudeSum(:, channel) = outputMagnitudeSum(:, channel) + ...
            abs(filteredFFT(1:numSpectrumBins));
    end

    weightAccumulation(validSourceIndices) = ...
        weightAccumulation(validSourceIndices) + ...
        window(validWindowPositions).^2;
end

audioOut = bsxfun(@rdivide, outputAccumulation, ...
    max(weightAccumulation, eps));

%% 6. Print input/output measurements
fprintf('\n====================================================\n');
fprintf(' Active Noise Cancellation Using a Wiener Filter\n');
fprintf(' Version 0.3 — Offline Wiener Noise Reduction\n');
fprintf('====================================================\n');
fprintf('File             : %s\n', fileName);
fprintf('Sample rate      : %d Hz\n', sampleRate);
fprintf('Channels         : %d\n', numChannels);
fprintf('Duration         : %.3f seconds\n', durationSeconds);
fprintf('Frame length     : %d samples (%.2f ms)\n', ...
    frameLength, 1000 * frameLength / sampleRate);
fprintf('Noise-only region: %.3f to %.3f seconds\n', ...
    noiseStartSeconds, noiseStartSeconds + noiseDurationSeconds);
fprintf('Minimum gain     : %.3f\n\n', minimumGain);

for channel = 1:numChannels
    inputPeak = max(abs(audioIn(:, channel)));
    outputPeak = max(abs(audioOut(:, channel)));
    inputRMS = sqrt(mean(audioIn(:, channel).^2));
    outputRMS = sqrt(mean(audioOut(:, channel).^2));

    fprintf('Channel %d:\n', channel);
    fprintf('  Input    peak = %.5f, RMS = %.5f\n', inputPeak, inputRMS);
    fprintf('  Filtered peak = %.5f, RMS = %.5f\n', outputPeak, outputRMS);
end
fprintf('\nNo output file was saved; source audio remains unchanged.\n');

%% 7. Prepare average spectra for plotting
inputSpectrum = inputMagnitudeSum / (numFrames * windowSum);
outputSpectrum = outputMagnitudeSum / (numFrames * windowSum);

if rem(frameLength, 2) == 0
    if numSpectrumBins > 2
        inputSpectrum(2:end-1, :) = 2 * inputSpectrum(2:end-1, :);
        outputSpectrum(2:end-1, :) = 2 * outputSpectrum(2:end-1, :);
    end
else
    inputSpectrum(2:end, :) = 2 * inputSpectrum(2:end, :);
    outputSpectrum(2:end, :) = 2 * outputSpectrum(2:end, :);
end

frequencyHz = (0:numSpectrumBins-1)' * sampleRate / frameLength;

maxPlotPoints = 200000;
displayStride = max(1, ceil(numSamples / maxPlotPoints));
sampleIndices = (1:displayStride:numSamples)';
timeSeconds = (sampleIndices - 1) / sampleRate;

channelLabels = cell(1, numChannels);
spectrumLabels = cell(1, 2 * numChannels);
for channel = 1:numChannels
    channelLabels{channel} = sprintf('Channel %d', channel);
    spectrumLabels{2*channel-1} = sprintf('Input Ch %d', channel);
    spectrumLabels{2*channel} = sprintf('Filtered Ch %d', channel);
end

%% 8. Plot input/filtered waveforms and spectra
figure('Name', 'V0.3 - Wiener Filter Comparison', ...
    'NumberTitle', 'off', 'Color', 'w');

subplot(3, 1, 1);
hold on;
for channel = 1:numChannels
    plot(timeSeconds, audioIn(sampleIndices, channel), 'LineWidth', 0.8);
end
hold off;
grid on;
xlabel('Time (seconds)');
ylabel('Amplitude');
title('Original Noisy Audio');
legend(channelLabels, 'Location', 'best');

subplot(3, 1, 2);
hold on;
for channel = 1:numChannels
    plot(timeSeconds, audioOut(sampleIndices, channel), 'LineWidth', 0.8);
end
hold off;
grid on;
xlabel('Time (seconds)');
ylabel('Amplitude');
title('Wiener-Filtered Audio');
legend(channelLabels, 'Location', 'best');

subplot(3, 1, 3);
hold on;
for channel = 1:numChannels
    inputDb = 20 * log10(max(inputSpectrum(:, channel), eps));
    outputDb = 20 * log10(max(outputSpectrum(:, channel), eps));
    plot(frequencyHz, inputDb, 'LineWidth', 0.9);
    plot(frequencyHz, outputDb, '--', 'LineWidth', 0.9);
end
hold off;
grid on;
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB re: unit amplitude)');
title('Average Single-Sided Spectrum: Input vs Filtered');
xlim([0, sampleRate / 2]);
legend(spectrumLabels, 'Location', 'best');

%% 9. Optional sequential playback comparison
playChoice = questdlg( ...
    'Play the original audio first, followed by the Wiener-filtered audio?', ...
    'V0.3 Audio Comparison', 'Play Both', 'Skip Playback', 'Play Both');

if strcmp(playChoice, 'Play Both')
    disp('Playing original audio...');
    originalPlayer = audioplayer(audioIn, sampleRate);
    playblocking(originalPlayer);

    disp('Playing Wiener-filtered audio...');
    filteredPlayer = audioplayer(audioOut, sampleRate);
    playblocking(filteredPlayer);
else
    disp('Playback skipped. Use the waveform and spectrum plots for review.');
end

disp('V0.3 complete. The source recording was not modified or overwritten.');

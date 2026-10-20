%% Active Noise Cancellation Using a Wiener Filter
% Version 0.4: Preview, Refilter, Save, or Cancel.
%
% This is offline, single-recording spectral noise reduction, not adaptive
% ANC with a separate reference-noise input.
%
% Workflow:
%   1. Select noisy audio.
%   2. Estimate noise from a chosen noise-only segment.
%   3. Play the current input, then play the filtered result.
%   4. Save, Refilter, or Cancel.
%   5. Refilter starts from the PREVIOUSLY FILTERED signal, never the
%      original recording.
%
% The source file is never overwritten.

clc;
clear;
close all;

%% 1. Select the input audio
[fileName, folderPath] = uigetfile( ...
    {'*.wav;*.flac;*.mp3;*.m4a;*.aac', ...
     'Supported audio files (*.wav, *.flac, *.mp3, *.m4a, *.aac)'; ...
     '*.*', 'All files (*.*)'}, ...
    'Select a noisy audio file');

if isequal(fileName, 0)
    disp('No file selected. Program cancelled.');
    return;
end

sourcePath = fullfile(folderPath, fileName);

try
    [originalAudio, sampleRate] = audioread(sourcePath);
catch ME
    errordlg(sprintf('Could not read the selected audio file:\n%s', ...
        ME.message), 'Audio Read Error');
    rethrow(ME);
end

if isempty(originalAudio) || size(originalAudio, 1) < 64
    errordlg('Choose an audio file containing at least 64 samples.', ...
        'Audio Too Short');
    return;
end

[numSamples, numChannels] = size(originalAudio);
durationSeconds = numSamples / sampleRate;
[~, sourceBaseName, ~] = fileparts(fileName);

%% 2. Choose analysis frame size
% Approximately 25 ms frames, with bounds for unusual sample rates and
% short recordings. Keep the frame no longer than half the full recording
% so there is room for a noise-only region.
frameLength = 2^round(log2(0.025 * sampleRate));
frameLength = max(64, min(2048, frameLength));
largestAllowedFrame = 2^floor(log2(floor(numSamples / 2)));
frameLength = min(frameLength, largestAllowedFrame);

if frameLength < 32 || numSamples < frameLength
    errordlg('The recording is too short for the selected filter.', ...
        'Audio Too Short');
    return;
end

hopLength = max(1, floor(frameLength / 2));
window = 0.54 - 0.46 * cos(2 * pi * (0:frameLength-1)' / ...
    (frameLength - 1));  % Hamming window
windowSum = sum(window);

%% 3. Iterative preview/refilter loop
% The first pass input is the original. After Refilter, currentInput is
% replaced with the latest filtered result. Source duration stays constant.
currentInput = originalAudio;
passNumber = 1;
plotFigure = [];

while true
    %% 3a. Get and validate parameters for this pass
    defaultNoiseDuration = min(0.5, max(frameLength / sampleRate, ...
        durationSeconds / 4));
    defaultNoiseDuration = min(defaultNoiseDuration, durationSeconds * 0.75);

    prompt = { ...
        'Noise-only segment start time (seconds):', ...
        'Noise-only segment duration (seconds):', ...
        'Minimum Wiener gain (0 to 1):'};
    defaults = {'0', sprintf('%.4f', defaultNoiseDuration), '0.05'};

    parametersValid = false;
    while ~parametersValid
        answers = inputdlg(prompt, ...
            sprintf('V0.4 Wiener Filter Parameters - Pass %d', passNumber), ...
            [1 52; 1 52; 1 52], defaults);

        if isempty(answers)
            disp('Parameter entry cancelled. No output has been saved.');
            return;
        end

        parameters = zeros(1, numel(answers));
        for k = 1:numel(answers)
            parameters(k) = str2double(answers{k});
        end

        if any(isnan(parameters)) || any(isinf(parameters))
            errordlg('Enter valid numeric values for all parameters.', ...
                'Invalid Parameters');
            defaults = answers;
            continue;
        end

        noiseStartSeconds = parameters(1);
        noiseDurationSeconds = parameters(2);
        minimumGain = parameters(3);

        if noiseStartSeconds < 0 || noiseDurationSeconds <= 0 || ...
                minimumGain < 0 || minimumGain > 1
            errordlg(['Start time must be >= 0, duration must be > 0, ' ...
                'and minimum gain must be between 0 and 1.'], ...
                'Invalid Parameters');
            defaults = answers;
            continue;
        end

        noiseStartIndex = floor(noiseStartSeconds * sampleRate) + 1;
        noiseEndIndex = floor((noiseStartSeconds + noiseDurationSeconds) ...
            * sampleRate);

        if noiseStartIndex < 1 || noiseEndIndex > numSamples || ...
                noiseEndIndex < noiseStartIndex
            errordlg('The noise-only segment is outside the audio file.', ...
                'Invalid Noise Segment');
            defaults = answers;
            continue;
        end

        noiseSamples = noiseEndIndex - noiseStartIndex + 1;
        if noiseSamples < frameLength
            errordlg(sprintf(['The noise-only segment must be at least ' ...
                '%.3f seconds long for the current frame size.'], ...
                frameLength / sampleRate), 'Noise Segment Too Short');
            defaults = answers;
            continue;
        end

        parametersValid = true;
    end

    noiseOnly = currentInput(noiseStartIndex:noiseEndIndex, :);

    %% 3b. Estimate the noise power for each channel
    noiseFrameStarts = 1:hopLength:(noiseSamples - frameLength + 1);
    numNoiseFrames = numel(noiseFrameStarts);
    noisePower = zeros(frameLength, numChannels);

    for channel = 1:numChannels
        accumulatedNoisePower = zeros(frameLength, 1);

        for noiseFrameIndex = 1:numNoiseFrames
            firstSample = noiseFrameStarts(noiseFrameIndex);
            lastSample = firstSample + frameLength - 1;
            noiseFrame = noiseOnly(firstSample:lastSample, channel);
            noiseFFT = fft(noiseFrame .* window);
            accumulatedNoisePower = accumulatedNoisePower + abs(noiseFFT).^2;
        end

        noisePower(:, channel) = accumulatedNoisePower / numNoiseFrames;
    end

    %% 3c. Apply Wiener gain to the current input and overlap-add
    frameStarts = (-frameLength + 1):hopLength:numSamples;
    numFrames = numel(frameStarts);

    outputAccumulation = zeros(numSamples, numChannels);
    weightAccumulation = zeros(numSamples, 1);
    previousGain = ones(frameLength, numChannels);

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
            inputFrame(validWindowPositions) = ...
                currentInput(validSourceIndices, channel);

            windowedFrame = inputFrame .* window;
            inputFFT = fft(windowedFrame);
            observedPower = abs(inputFFT).^2;

            estimatedSignalPower = max( ...
                observedPower - noisePower(:, channel), 0);
            rawGain = estimatedSignalPower ./ max(observedPower, eps);
            rawGain = max(min(rawGain, 1), minimumGain);

            if frameIndex == 1
                smoothedGain = rawGain;
            else
                smoothedGain = gainSmoothing * ...
                    previousGain(:, channel) + ...
                    (1 - gainSmoothing) * rawGain;
            end
            previousGain(:, channel) = smoothedGain;

            filteredFFT = smoothedGain .* inputFFT;
            filteredFrame = real(ifft(filteredFFT));
            synthesisFrame = filteredFrame .* window;

            outputAccumulation(validSourceIndices, channel) = ...
                outputAccumulation(validSourceIndices, channel) + ...
                synthesisFrame(validWindowPositions);

            inputMagnitudeSum(:, channel) = ...
                inputMagnitudeSum(:, channel) + ...
                abs(inputFFT(1:numSpectrumBins));
            outputMagnitudeSum(:, channel) = ...
                outputMagnitudeSum(:, channel) + ...
                abs(filteredFFT(1:numSpectrumBins));
        end

        weightAccumulation(validSourceIndices) = ...
            weightAccumulation(validSourceIndices) + ...
            window(validWindowPositions).^2;
    end

    filteredAudio = bsxfun(@rdivide, outputAccumulation, ...
        max(weightAccumulation, eps));

    %% 3d. Summarize this pass
    fprintf('\n====================================================\n');
    fprintf(' Wiener Noise Reduction - V0.4, Pass %d\n', passNumber);
    fprintf('====================================================\n');
    fprintf('Current input duration: %.3f seconds\n', durationSeconds);
    fprintf('Sample rate           : %d Hz\n', sampleRate);
    fprintf('Channels              : %d\n', numChannels);
    fprintf('Frame length          : %d samples (%.2f ms)\n', ...
        frameLength, 1000 * frameLength / sampleRate);
    fprintf('Noise-only segment    : %.3f to %.3f seconds\n', ...
        noiseStartSeconds, noiseStartSeconds + noiseDurationSeconds);
    fprintf('Minimum gain          : %.3f\n', minimumGain);

    for channel = 1:numChannels
        inputRMS = sqrt(mean(currentInput(:, channel).^2));
        outputRMS = sqrt(mean(filteredAudio(:, channel).^2));
        fprintf('Channel %d RMS: current input %.5f | filtered %.5f\n', ...
            channel, inputRMS, outputRMS);
    end

    %% 3e. Plot this pass input, output, and average spectra
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
        channelLabels{channel} = sprintf('Current Ch %d', channel);
        spectrumLabels{2*channel-1} = sprintf('Current Ch %d', channel);
        spectrumLabels{2*channel} = sprintf('Filtered Ch %d', channel);
    end

    if ~isempty(plotFigure) && isgraphics(plotFigure)
        close(plotFigure);
    end
    plotFigure = figure('Name', ...
        sprintf('V0.4 - Wiener Filter Pass %d', passNumber), ...
        'NumberTitle', 'off', 'Color', 'w');

    subplot(3, 1, 1);
    hold on;
    for channel = 1:numChannels
        plot(timeSeconds, currentInput(sampleIndices, channel), ...
            'LineWidth', 0.8);
    end
    hold off;
    grid on;
    xlabel('Time (seconds)');
    ylabel('Amplitude');
    title(sprintf('Current Input Before Pass %d', passNumber));
    legend(channelLabels, 'Location', 'best');

    subplot(3, 1, 2);
    hold on;
    for channel = 1:numChannels
        plot(timeSeconds, filteredAudio(sampleIndices, channel), ...
            'LineWidth', 0.8);
    end
    hold off;
    grid on;
    xlabel('Time (seconds)');
    ylabel('Amplitude');
    title(sprintf('Filtered Result After Pass %d', passNumber));
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
    title('Average Single-Sided Spectrum: Current Input vs Filtered');
    xlim([0, sampleRate / 2]);
    legend(spectrumLabels, 'Location', 'best');

    %% 3f. Audition current input first, then filtered output
    % A single shared playback gain is used for both clips on this pass.
    % This avoids independently normalizing them and preserves their level
    % difference for fair listening. Playback gain never affects saved data.
    playbackPeak = max(abs(currentInput(:)));
    playbackGain = 1;
    if playbackPeak > 0 && playbackPeak < 0.08
        playbackGain = min(8, 0.8 / playbackPeak);
    end

    try
        fprintf('Playing current input before pass %d...\n', passNumber);
        inputPlayer = audioplayer(currentInput * playbackGain, sampleRate);
        playblocking(inputPlayer);

        fprintf('Playing filtered output after pass %d...\n', passNumber);
        outputPlayer = audioplayer(filteredAudio * playbackGain, sampleRate);
        playblocking(outputPlayer);
    catch playbackError
        warning('Playback could not complete: %s', playbackError.message);
        warndlg(['Audio playback encountered a problem. Review the plots ' ...
            'before choosing an action.'], 'Playback Warning');
    end

    %% 3g. After preview, choose Save, Refilter, or Cancel
    actionCompleted = false;
    while ~actionCompleted
        action = questdlg( ...
            sprintf(['Pass %d preview finished.\n\n' ...
            'Save: write this filtered result to a new WAV file.\n' ...
            'Refilter: process this filtered result again.\n' ...
            'Cancel: exit without saving this result.'], passNumber), ...
            'V0.4 - Save, Refilter, or Cancel', ...
            'Save', 'Refilter', 'Cancel', 'Save');

        if isempty(action) || strcmp(action, 'Cancel')
            disp('Cancelled. No new output file was saved.');
            return;
        elseif strcmp(action, 'Refilter')
            % Critical behavior: next pass uses the PREVIOUS filtered signal.
            currentInput = filteredAudio;
            passNumber = passNumber + 1;
            fprintf(['Refilter selected: pass %d will start from the ' ...
                'previously filtered audio, not the original.\n'], passNumber);
            actionCompleted = true;
        elseif strcmp(action, 'Save')
            suggestedName = sprintf('%s_wiener_denoised.wav', sourceBaseName);
            [saveName, saveFolder] = uiputfile( ...
                {'*.wav', 'WAV audio (*.wav)'}, ...
                'Save the current filtered audio', suggestedName);

            if isequal(saveName, 0)
                disp('Save dialog closed. Choose Save, Refilter, or Cancel.');
                continue;
            end

            outputPath = fullfile(saveFolder, saveName);
            if strcmpi(outputPath, sourcePath)
                errordlg(['The output path matches the source audio. ' ...
                    'Choose a different filename to protect the original.'], ...
                    'Source File Protected');
                continue;
            end

            audioToSave = filteredAudio;
            if any(abs(audioToSave(:)) > 1)
                warning(['Filtered samples exceeded the WAV full-scale range. ' ...
                    'Values outside [-1, 1] will be clipped when saved.']);
                audioToSave = min(max(audioToSave, -1), 1);
            end

            try
                audiowrite(outputPath, audioToSave, sampleRate);
            catch saveError
                errordlg(sprintf('Could not save the filtered audio:\n%s', ...
                    saveError.message), 'Save Error');
                continue;
            end

            fprintf('Filtered audio saved to: %s\n', outputPath);
            msgbox(sprintf('Filtered audio saved successfully:\n%s', ...
                outputPath), 'Save Complete', 'modal');
            return;
        end
    end

    % Continue the main loop only when the user selected Refilter.
    % The assigned currentInput above is the last filtered output.
end

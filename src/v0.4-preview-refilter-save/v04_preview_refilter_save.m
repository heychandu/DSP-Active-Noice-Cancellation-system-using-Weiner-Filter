clc;
clear;
close all;

%% V0.4: Wiener Noise Reduction with Preview / Refilter / Save / Cancel
% This is offline, single-recording noise reduction. It is not adaptive
% feedforward ANC with a separate reference-noise input.
%
% The first pass previews the original audio, then the filtered result.
% After Refilter, it previews the previously denoised signal, then the
% newly processed signal. Refilter always starts from the latest output.
% The source audio file is never overwritten.

%% 1. LOAD AUDIO
<<<<<<< HEAD

=======
>>>>>>> 6b3fb5d25e63d8158c6d67cf7c84081b65a7deb8
[file, path] = uigetfile( ...
    {'*.wav;*.flac;*.mp3;*.m4a', 'Audio Files'}, ...
    'Select Noisy Audio');

if isequal(file, 0)
    disp('No file selected.');
    return;
end

sourcePath = fullfile(path, file);
<<<<<<< HEAD

=======
>>>>>>> 6b3fb5d25e63d8158c6d67cf7c84081b65a7deb8
try
    [x, Fs] = audioread(sourcePath);
catch ME
    errordlg(sprintf('Could not read the selected audio:\n%s', ME.message), ...
        'Audio Read Error');
    rethrow(ME);
end

if isempty(x) || any(~isfinite(x(:)))
    error('Invalid audio file.');
end

% Convert stereo audio to mono
if size(x, 2) > 1
    xMono = mean(x, 2);
else
    xMono = x(:);
<<<<<<< HEAD
end

xMono = double(xMono);
xMono = xMono - mean(xMono);
original = xMono;

fprintf('Sample rate: %d Hz\n', Fs);
fprintf('Duration: %.2f seconds\n', length(original) / Fs);

%% 2. HIGH-PASS FILTER

hpCutoff = 55;

if hpCutoff < Fs / 2
    [bHP, aHP] = butter(3, hpCutoff / (Fs / 2), 'high');
    x = filtfilt(bHP, aHP, xMono);
else
    x = xMono;
end

%% 3. MANUAL HUM NOTCH FILTERS

removeHum = true;

if removeHum
    mainsHz = 50;
    Q = 35;

=======
end
xMono = double(xMono);
xMono = xMono - mean(xMono);
original = xMono;

fprintf('Sample rate: %d Hz\n', Fs);
fprintf('Duration: %.2f seconds\n', length(original) / Fs);

%% 2. HIGH-PASS FILTER
hpCutoff = 55;
if hpCutoff < Fs / 2
    [bHP, aHP] = butter(3, hpCutoff / (Fs / 2), 'high');
    x = filtfilt(bHP, aHP, xMono);
else
    x = xMono;
end

%% 3. MANUAL HUM NOTCH FILTERS
removeHum = true;
if removeHum
    mainsHz = 50;
    Q = 35;
>>>>>>> 6b3fb5d25e63d8158c6d67cf7c84081b65a7deb8
    for f0 = mainsHz:mainsHz:200
        if f0 >= Fs / 2 - 1
            break;
        end
<<<<<<< HEAD

        w0 = 2 * pi * f0 / Fs;
        r = exp(-pi * f0 / (Q * Fs));

        bN = [1, -2 * cos(w0), 1];
        aN = [1, -2 * r * cos(w0), r^2];

        bN = bN * sum(aN) / sum(bN);

        x = filtfilt(bN, aN, x);
    end
end

filteredInput = x;

%% 4. NOISE PROFILE SETTINGS
% The first 5 seconds should ideally contain background noise with little
% or no desired speech/music. This profile is re-estimated for each pass.

noiseDuration = 5;

if length(filteredInput) / Fs < noiseDuration
    error(['Audio must be at least 5 seconds long. ', ...
        'Reduce noiseDuration for shorter recordings.']);
end

%% 5. STFT SETTINGS

winLength = 1024;
overlap = 768;
nfft = 1024;

win = hamming(winLength, 'periodic');

%% 6. WIENER FILTER SETTINGS

% Initial pass settings
initialSuppression = 1.8;
initialGateThreshold = 0.25;
initialMinimumGain = 0.10;

% Refilter settings (gentler to preserve speech)
refilterSuppression = 1.25;
refilterGateThreshold = 0.12;
refilterMinimumGain = 0.25;

%% 7. INITIAL WIENER FILTER PASS

fprintf('\nRunning initial Wiener filter...\n');

currentInput = filteredInput;

processedAudio = runWienerPass( ...
    currentInput, Fs, win, overlap, nfft, ...
    noiseDuration, initialSuppression, ...
    initialGateThreshold, initialMinimumGain);

passNumber = 1;

% First preview compares the raw original with the first filtered result.
% On each Refilter choice this variable is replaced with the previous
% filtered output, so the next preview does not return to the original.
previewInput = original;

%% 8. PREVIEW AND USER DECISION LOOP
=======
        w0 = 2 * pi * f0 / Fs;
        r = exp(-pi * f0 / (Q * Fs));
        bN = [1, -2 * cos(w0), 1];
        aN = [1, -2 * r * cos(w0), r^2];
        bN = bN * sum(aN) / sum(bN);
        x = filtfilt(bN, aN, x);
    end
end
filteredInput = x;

%% 4. NOISE PROFILE SETTINGS
% The first 5 seconds should ideally contain background noise with little
% or no desired speech/music. The profile is re-estimated for each pass.
noiseDuration = 5;
if length(filteredInput) / Fs < noiseDuration
    error(['Audio must be at least 5 seconds long. ', ...
        'Reduce noiseDuration for shorter recordings.']);
end

%% 5. STFT SETTINGS
winLength = 1024;
overlap = 768;
nfft = 1024;
win = hamming(winLength, 'periodic');

%% 6. WIENER FILTER SETTINGS
% Initial pass settings
initialSuppression = 1.8;
initialGateThreshold = 0.25;
initialMinimumGain = 0.10;

% Refilter settings (gentler to preserve speech)
refilterSuppression = 1.25;
refilterGateThreshold = 0.12;
refilterMinimumGain = 0.25;

%% 7. INITIAL WIENER FILTER PASS
fprintf('\nRunning initial Wiener filter...\n');
currentInput = filteredInput;
processedAudio = runWienerPass( ...
    currentInput, Fs, win, overlap, nfft, ...
    noiseDuration, initialSuppression, ...
    initialGateThreshold, initialMinimumGain);
passNumber = 1;
>>>>>>> 6b3fb5d25e63d8158c6d67cf7c84081b65a7deb8

% First comparison: original -> first filtered result.
% After Refilter, previewInput becomes the previous denoised result.
previewInput = original;

%% 8. PREVIEW AND USER DECISION LOOP
while true
<<<<<<< HEAD

    % Ensure playback audio is finite and nonempty
    if isempty(processedAudio) || ...
            any(~isfinite(processedAudio)) || ...
            max(abs(processedAudio)) < 1e-8

=======
    if isempty(processedAudio) || ...
            any(~isfinite(processedAudio)) || ...
            max(abs(processedAudio)) < 1e-8
>>>>>>> 6b3fb5d25e63d8158c6d67cf7c84081b65a7deb8
        errordlg('Processed audio is silent or invalid.', ...
            'Processing Error');
        break;
    end

<<<<<<< HEAD
    %% Play the input for this comparison

    % Use one shared playback scale for both clips. soundsc normalizes
    % each clip separately and can make a quiet output sound misleadingly
    % loud, so sound() is used with the same attenuation for both.
    comparisonPeak = max([abs(previewInput(:)); abs(processedAudio(:))]);
    playbackGain = 1;

=======
    %% Play input for this comparison
    % Use one shared playback scale. soundsc independently normalizes each
    % clip and can make level differences misleading.
    comparisonPeak = max([abs(previewInput(:)); abs(processedAudio(:))]);
    playbackGain = 1;
>>>>>>> 6b3fb5d25e63d8158c6d67cf7c84081b65a7deb8
    if comparisonPeak > 0.98
        playbackGain = 0.98 / comparisonPeak;
    end

    if passNumber == 1
        disp('Playing original audio...');
    else
        fprintf('Playing previously denoised audio before pass %d...\n', ...
            passNumber);
<<<<<<< HEAD
    end

    sound(previewInput * playbackGain, Fs);
    pause(length(previewInput) / Fs + 0.8);

    %% Play latest noise-reduced audio

    fprintf('Playing noise-reduced audio after pass %d...\n', passNumber);

    sound(processedAudio * playbackGain, Fs);
    pause(length(processedAudio) / Fs + 0.8);

    %% Popup AFTER both audio previews

    choice = questdlg( ...
        sprintf(['Preview completed after pass %d.\n\n', ...
        'You have heard the comparison signals.\n\n', ...
        'Save: Save the current result\n', ...
        'Refilter: Apply another Wiener pass\n', ...
        'Cancel: Exit without saving'], passNumber), ...
        'Compare Audio Results', ...
        'Save', 'Refilter', 'Cancel', 'Save');

    if isempty(choice)
        choice = 'Cancel';
    end

    %% HANDLE USER CHOICE

    switch choice

        case 'Save'

            %% Ask where to save the output

            [saveFile, savePath] = uiputfile( ...
                {'*.wav', 'WAV Audio (*.wav)'; ...
                 '*.mp3', 'MP3 Audio (*.mp3)'}, ...
                'Save Noise-Reduced Audio', ...
                'Advanced_Noise_Reduced.wav');

            if isequal(saveFile, 0)
                % Return to preview and decision popup
=======
    end
    sound(previewInput * playbackGain, Fs);
    pause(length(previewInput) / Fs + 0.8);

    %% Play latest noise-reduced audio
    fprintf('Playing noise-reduced audio after pass %d...\n', passNumber);
    sound(processedAudio * playbackGain, Fs);
    pause(length(processedAudio) / Fs + 0.8);

    %% Popup AFTER both previews
    choice = questdlg( ...
        sprintf(['Preview completed after pass %d.\n\n', ...
        'You have heard the comparison signals.\n\n', ...
        'Save: Save the current result\n', ...
        'Refilter: Apply another Wiener pass\n', ...
        'Cancel: Exit without saving'], passNumber), ...
        'Compare Audio Results', ...
        'Save', 'Refilter', 'Cancel', 'Save');

    if isempty(choice)
        choice = 'Cancel';
    end

    switch choice
        case 'Save'
            [saveFile, savePath] = uiputfile( ...
                {'*.wav', 'WAV Audio (*.wav)'; ...
                 '*.mp3', 'MP3 Audio (*.mp3)'}, ...
                'Save Noise-Reduced Audio', ...
                'Advanced_Noise_Reduced.wav');

            if isequal(saveFile, 0)
>>>>>>> 6b3fb5d25e63d8158c6d67cf7c84081b65a7deb8
                disp('Save dialog cancelled. Returning to preview.');
                continue;
            end

            outputFile = fullfile(savePath, saveFile);

<<<<<<< HEAD
            % Protect the selected source file against accidental overwrite.
=======
            % Protect the selected source against accidental overwrite.
>>>>>>> 6b3fb5d25e63d8158c6d67cf7c84081b65a7deb8
            if strcmpi(outputFile, sourcePath)
                errordlg(['The output path matches the original input file. ', ...
                    'Choose a different filename.'], ...
                    'Source File Protected');
                continue;
            end

            try
                audiowrite(outputFile, processedAudio, Fs);
<<<<<<< HEAD

                fprintf('\nAudio saved successfully:\n%s\n', outputFile);

                msgbox(sprintf( ...
                    'Noise-reduced audio saved successfully!\n\n%s', ...
                    outputFile), ...
                    'Save Complete', 'help');

                disp('Processing finished.');
                break;

            catch ME

                errordlg(sprintf( ...
                    'Could not save the audio:\n%s', ME.message), ...
                    'Save Error');

                % Return to preview if saving failed
=======
                fprintf('\nAudio saved successfully:\n%s\n', outputFile);
                msgbox(sprintf( ...
                    'Noise-reduced audio saved successfully!\n\n%s', ...
                    outputFile), 'Save Complete', 'help');
                disp('Processing finished.');
                break;
            catch ME
                errordlg(sprintf('Could not save the audio:\n%s', ...
                    ME.message), 'Save Error');
>>>>>>> 6b3fb5d25e63d8158c6d67cf7c84081b65a7deb8
                continue;
            end

        case 'Refilter'
<<<<<<< HEAD

            %% Use previous output as the new input and preview baseline

            previewInput = processedAudio;
            currentInput = processedAudio;

            passNumber = passNumber + 1;

            fprintf('\nStarting Wiener refilter pass %d...\n', passNumber);

=======
            % Refilter and next preview use the previously filtered output.
            previewInput = processedAudio;
            currentInput = processedAudio;
            passNumber = passNumber + 1;

            fprintf('\nStarting Wiener refilter pass %d...\n', passNumber);
>>>>>>> 6b3fb5d25e63d8158c6d67cf7c84081b65a7deb8
            processedAudio = runWienerPass( ...
                currentInput, Fs, win, overlap, nfft, ...
                noiseDuration, refilterSuppression, ...
                refilterGateThreshold, refilterMinimumGain);
<<<<<<< HEAD

            fprintf('Refilter pass %d completed.\n', passNumber);

            % Loop repeats: play previous denoised audio, play new output,
            % then display the decision popup again.
            continue;

        otherwise

            %% Cancel

            disp('Cancelled. Audio was not saved.');
            break;

    end

    % Exit after Save or Cancel
    break;

end

%% 9. FINAL WAVEFORM AND SPECTROGRAM COMPARISON

if exist('processedAudio', 'var') && ~isempty(processedAudio)

    % Compare the first-pass raw original and the latest filtered result.
    L = min(length(original), length(processedAudio));

    figure('Color', 'w', 'Name', 'Noise Reduction Comparison');

=======
            fprintf('Refilter pass %d completed.\n', passNumber);
            continue;

        otherwise
            disp('Cancelled. Audio was not saved.');
            break;
    end
    break;
end

%% 9. FINAL WAVEFORM AND SPECTROGRAM COMPARISON
if exist('processedAudio', 'var') && ~isempty(processedAudio)
    L = min(length(original), length(processedAudio));

    figure('Color', 'w', 'Name', 'Noise Reduction Comparison');
>>>>>>> 6b3fb5d25e63d8158c6d67cf7c84081b65a7deb8
    subplot(2, 1, 1);
    plot((0:L-1) / Fs, original(1:L));
    title('Original Audio');
    xlabel('Time (seconds)');
    ylabel('Amplitude');
    grid on;

    subplot(2, 1, 2);
    plot((0:L-1) / Fs, processedAudio(1:L));
    title(sprintf('Noise-Reduced Audio - Pass %d', passNumber));
    xlabel('Time (seconds)');
    ylabel('Amplitude');
    grid on;

<<<<<<< HEAD
    %% Spectrogram comparison

    figure('Color', 'w', 'Name', 'Spectrogram Comparison');

=======
    figure('Color', 'w', 'Name', 'Spectrogram Comparison');
>>>>>>> 6b3fb5d25e63d8158c6d67cf7c84081b65a7deb8
    subplot(2, 1, 1);
    spectrogram(original, win, overlap, nfft, Fs, 'yaxis');
    title('Original Audio');

    subplot(2, 1, 2);
    spectrogram(processedAudio, win, overlap, nfft, Fs, 'yaxis');
    title(sprintf('Processed Audio - Pass %d', passNumber));
<<<<<<< HEAD

end

disp('Finished.');

%% ============================================================
% LOCAL FUNCTION: ONE WIENER FILTER PASS
%% ============================================================

=======
end
disp('Finished.');

%% LOCAL FUNCTION: ONE WIENER FILTER PASS
>>>>>>> 6b3fb5d25e63d8158c6d67cf7c84081b65a7deb8
function y = runWienerPass( ...
    inputSignal, Fs, win, overlap, nfft, ...
    noiseDuration, suppressionStrength, ...
    gateThreshold, minimumGain)

    inputSignal = double(inputSignal(:));
    inputSignal(~isfinite(inputSignal)) = 0;

    if length(inputSignal) / Fs < noiseDuration
        error(['Audio is shorter than noiseDuration. ', ...
            'Reduce noiseDuration in the main script.']);
<<<<<<< HEAD
    end

    %% Estimate noise from the first noiseDuration seconds

    noiseLength = min(round(noiseDuration * Fs), length(inputSignal));
    noiseSegment = inputSignal(1:noiseLength);

    %% STFT

    [S, ~, ~] = stft(inputSignal, Fs, ...
        'Window', win, ...
        'OverlapLength', overlap, ...
        'FFTLength', nfft);

    N = stft(noiseSegment, Fs, ...
        'Window', win, ...
        'OverlapLength', overlap, ...
        'FFTLength', nfft);

    %% Estimate noise power

    noisePower = median(abs(N).^2, 2);
    noisePower = max(noisePower, 1e-12);

    noisePowerMatrix = repmat(noisePower, 1, size(S, 2));
    signalPower = abs(S).^2;

    %% Wiener gain

    cleanPower = max( ...
        signalPower - suppressionStrength * noisePowerMatrix, 0);

    wienerGain = cleanPower ./ ...
        (cleanPower + suppressionStrength * noisePowerMatrix + eps);

    %% Smooth gain

    wienerGain = movmean(wienerGain, 3, 1);
    wienerGain = movmean(wienerGain, 5, 2);

    %% Spectral gate

    gate = max(wienerGain - gateThreshold, 0) ./ ...
        (1 - gateThreshold);

    gate = min(max(gate, 0), 1);

    combinedGain = wienerGain .* gate;
    combinedGain = max(combinedGain, minimumGain);
    combinedGain = min(combinedGain, 1);

    %% Apply Wiener gain

    enhancedSTFT = combinedGain .* S;

    %% Reconstruct audio

    y = istft(enhancedSTFT, Fs, ...
        'Window', win, ...
        'OverlapLength', overlap, ...
        'FFTLength', nfft);

    y = real(y(:));
    y(~isfinite(y)) = 0;

    %% Align lengths

    L = min(length(y), length(inputSignal));
    y = y(1:L);
    inputSignal = inputSignal(1:L);

    if isempty(y) || max(abs(y)) < 1e-8
        error('Output is nearly silent. Check the input audio.');
    end

    %% Loudness control

    rmsIn = sqrt(mean(inputSignal.^2));
    rmsOut = sqrt(mean(y.^2));

    if rmsIn > 1e-8 && rmsOut > 1e-8
        levelGain = rmsIn / rmsOut;

        % Limit amplification to avoid boosting residual noise
        levelGain = min(levelGain, 1.5);
        y = y * levelGain;
    end

    %% Prevent clipping

    peak = max(abs(y));

    if peak > 0.98
        y = y * (0.98 / peak);
    end

=======
    end

    %% Estimate noise from the first noiseDuration seconds
    noiseLength = min(round(noiseDuration * Fs), length(inputSignal));
    noiseSegment = inputSignal(1:noiseLength);

    %% STFT
    [S, ~, ~] = stft(inputSignal, Fs, ...
        'Window', win, ...
        'OverlapLength', overlap, ...
        'FFTLength', nfft);
    N = stft(noiseSegment, Fs, ...
        'Window', win, ...
        'OverlapLength', overlap, ...
        'FFTLength', nfft);

    %% Estimate noise power
    noisePower = median(abs(N).^2, 2);
    noisePower = max(noisePower, 1e-12);
    noisePowerMatrix = repmat(noisePower, 1, size(S, 2));
    signalPower = abs(S).^2;

    %% Wiener gain
    cleanPower = max( ...
        signalPower - suppressionStrength * noisePowerMatrix, 0);
    wienerGain = cleanPower ./ ...
        (cleanPower + suppressionStrength * noisePowerMatrix + eps);

    %% Smooth gain
    wienerGain = movmean(wienerGain, 3, 1);
    wienerGain = movmean(wienerGain, 5, 2);

    %% Spectral gate
    gate = max(wienerGain - gateThreshold, 0) ./ ...
        (1 - gateThreshold);
    gate = min(max(gate, 0), 1);
    combinedGain = wienerGain .* gate;
    combinedGain = max(combinedGain, minimumGain);
    combinedGain = min(combinedGain, 1);

    %% Apply Wiener gain and reconstruct
    enhancedSTFT = combinedGain .* S;
    y = istft(enhancedSTFT, Fs, ...
        'Window', win, ...
        'OverlapLength', overlap, ...
        'FFTLength', nfft);

    y = real(y(:));
    y(~isfinite(y)) = 0;

    %% Align lengths
    L = min(length(y), length(inputSignal));
    y = y(1:L);
    inputSignal = inputSignal(1:L);
    if isempty(y) || max(abs(y)) < 1e-8
        error('Output is nearly silent. Check the input audio.');
    end

    %% Loudness control
    rmsIn = sqrt(mean(inputSignal.^2));
    rmsOut = sqrt(mean(y.^2));
    if rmsIn > 1e-8 && rmsOut > 1e-8
        levelGain = rmsIn / rmsOut;
        levelGain = min(levelGain, 1.5);
        y = y * levelGain;
    end

    %% Prevent clipping
    peak = max(abs(y));
    if peak > 0.98
        y = y * (0.98 / peak);
    end
>>>>>>> 6b3fb5d25e63d8158c6d67cf7c84081b65a7deb8
end

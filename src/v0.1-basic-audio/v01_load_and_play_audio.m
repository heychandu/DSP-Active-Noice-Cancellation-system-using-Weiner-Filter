%% Active Noise Cancellation Using a Wiener Filter
% Version 0.1: Load, inspect, plot, and play the original noisy audio.
% This version establishes the baseline. It does NOT filter or modify audio.

clc;
clear;
close all;

%% 1. Select an audio file
[fileName, folderPath] = uigetfile( ...
    {'*.wav;*.flac;*.mp3;*.m4a;*.aac', ...
     'Supported audio files (*.wav, *.flac, *.mp3, *.m4a, *.aac)'; ...
     '*.*', 'All files (*.*)'}, ...
    'Select a noisy audio file');

% Stop safely if the user cancels the file picker.
if isequal(fileName, 0)
    disp('No file selected. Program cancelled.');
    return;
end

fullFilePath = fullfile(folderPath, fileName);

%% 2. Load audio
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

%% 3. Report basic properties
[numSamples, numChannels] = size(audioIn);
durationSeconds = numSamples / sampleRate;

fprintf('\n=============================================\n');
fprintf(' Active Noise Cancellation Using Wiener Filter\n');
fprintf(' Version 0.1 — Basic Audio Input\n');
fprintf('=============================================\n');
fprintf('File          : %s\n', fileName);
fprintf('Sample rate   : %d Hz\n', sampleRate);
fprintf('Channels      : %d\n', numChannels);
fprintf('Samples       : %d\n', numSamples);
fprintf('Duration      : %.2f seconds\n', durationSeconds);
fprintf('Peak amplitude: %.4f\n', max(abs(audioIn(:))));
fprintf('RMS amplitude : %.4f\n', sqrt(mean(audioIn(:).^2)));
fprintf('No filtering is applied in V0.1.\n\n');

%% 4. Plot the original waveform
time = (0:numSamples-1) / sampleRate;

figure('Name', 'V0.1 - Original Audio Waveform', ...
       'NumberTitle', 'off', 'Color', 'w');

plot(time, audioIn, 'LineWidth', 0.8);
grid on;
xlabel('Time (seconds)');
ylabel('Amplitude');
title(sprintf('Original Audio Waveform: %s', fileName), ...
    'Interpreter', 'none');

if numChannels > 1
    channelLabels = cell(1, numChannels);
    for channel = 1:numChannels
        channelLabels{channel} = sprintf('Channel %d', channel);
    end
    legend(channelLabels, 'Location', 'best');
end

%% 5. Play the original audio
fprintf('Playing original audio...\n');
soundsc(audioIn, sampleRate);
fprintf('Playback started. Wait until playback finishes before running again.\n');

%% 6. Keep the source unchanged
disp('V0.1 complete. The selected source file was not modified.');

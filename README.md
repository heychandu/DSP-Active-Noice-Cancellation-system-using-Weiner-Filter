# Active Noise Cancellation Using a Wiener Filter

A MATLAB DSP project developed incrementally, version by version.

## Current milestone: V0.2 — Noise Analysis

V0.2 extends the V0.1 audio-input baseline with waveform inspection and average single-sided frequency-spectrum analysis. It does not denoise or modify the source audio; the purpose is to understand the input before designing the filter.

## Version roadmap

| Version | Milestone | Status |
|---|---|---|
| V0.1 | Load, inspect, plot, and play original audio | Implemented |
| V0.2 | Waveform and frequency-spectrum analysis | Implemented |
| V0.3 | First Wiener-filter noise-reduction implementation | Planned |
| V0.4 | Preview original and processed audio; Save / Refilter / Cancel | Planned |
| V0.5 | Live microphone processing experiment | Planned |
| V1.0 | Tested and documented project release | Planned |

## Requirements

- MATLAB with `audioread`, `audioplayer`/`soundsc`, and standard plotting functions (no extra Signal Processing Toolbox functions are intentionally used by V0.2).
- A local audio recording you are permitted to use.
- Git and GitHub Desktop for version management.

## Run V0.2

1. Open the repository in MATLAB.
2. Set the Current Folder to `src/v0.2-noise-analysis`.
3. Run `v02_noise_analysis.m`.
4. Choose an audio file in the file picker.
5. Inspect the waveform and frequency plot, then listen to the original recording.

The script only reads the selected file. It does not overwrite the source or save a processed output.

## V0.2 analysis details

- Prints sample rate, channel count, duration, peak amplitude, and RMS amplitude.
- Displays the waveform for each audio channel.
- Estimates an average single-sided amplitude spectrum using windowed frames with 50% overlap.
- Reports the strongest non-DC frequency bin for each channel.
- Uses a short-time frame size (up to 8192 samples) to avoid allocating a huge full-file FFT for long recordings.

### Interpreting the plots

- The waveform shows amplitude over time.
- The spectrum shows how signal amplitude is distributed across frequency.
- A prominent frequency peak is not necessarily noise; it can be part of speech, music, or the desired signal.
- V0.2 does not calculate SNR or identify noise automatically. A clean reference signal or a defined noise-only segment is needed for meaningful quantitative comparisons.

## Repository structure

```text
DSP-Active-Noice-Cancellation-system-using-Weiner-Filter/
├── README.md
├── LICENSE
├── .gitignore
├── docs/
│   └── version-history.md
└── src/
    ├── v0.1-basic-audio/
    │   └── v01_load_and_play_audio.m
    └── v0.2-noise-analysis/
        └── v02_noise_analysis.m
```

## DSP terminology note

Wiener filtering a noisy recording is commonly used for noise reduction. Active noise cancellation in the adaptive-filter sense usually uses a reference noise input and an adaptive controller. Later versions should describe the exact approach implemented and tested rather than using the terms interchangeably.

## Version history

See [`docs/version-history.md`](docs/version-history.md).

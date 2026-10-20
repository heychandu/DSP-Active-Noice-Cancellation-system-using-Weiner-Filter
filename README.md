# Active Noise Cancellation Using a Wiener Filter

A MATLAB DSP project developed incrementally, version by version.

## Current milestone: V0.2 — Noise Analysis

V0.2 extends the V0.1 audio-input baseline with waveform inspection and average single-sided frequency-spectrum analysis. It does not denoise or modify the source audio; the purpose is to understand the input before designing the filter.

## Project status

- **Current version:** `v0.2.0`
- **Language:** MATLAB
- **Input:** An audio recording supported by MATLAB `audioread`
- **V0.2 output:** Basic measurements, waveform plot, frequency-spectrum plot, and original audio playback
- **Source audio:** Read only; not overwritten

## Requirements

- MATLAB
- A local audio recording you are permitted to use
- Git and GitHub Desktop for version control

## Run V0.2

1. Open the repository in MATLAB.
2. Set MATLAB's Current Folder to `src/v0.2-noise-analysis`.
3. Run `v02_noise_analysis.m`.
4. Select an audio file in the file picker.
5. Inspect the waveform and frequency-spectrum plots, then listen to the original recording.

To run the V0.1 baseline instead, open `src/v0.1-basic-audio` and run `v01_load_and_play_audio.m`.

## What V0.2 analyzes

- Sample rate, duration, sample count, and channel count
- Peak and RMS amplitude for each channel
- Waveform for each input channel
- Average single-sided amplitude spectrum computed with a Hann window and overlapping frames
- Strongest non-DC spectrum bin for each channel

V0.2 uses standard MATLAB operations and does not intentionally require Signal Processing Toolbox functions.

### Interpreting the spectrum

A strong frequency peak is not necessarily noise: it could be part of speech, music, or the desired signal. V0.2 does not automatically identify noise and does not calculate SNR. Meaningful quantitative denoising measurements require a suitable clean reference or a known noise-only region.

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

## Version roadmap

| Version | Milestone | Status |
|---|---|---|
| V0.1 | Load, inspect, plot, and play original audio | Implemented |
| V0.2 | Waveform and frequency-spectrum analysis | Implemented |
| V0.3 | First Wiener-filter noise-reduction implementation | Planned |
| V0.4 | Original/processed preview; Save / Refilter / Cancel | Planned |
| V0.5 | Live microphone processing experiment | Planned |
| V1.0 | Tested and documented project release | Planned |

## DSP terminology note

Wiener filtering a noisy recording is commonly used for noise reduction. Adaptive active noise cancellation typically uses a reference noise signal and an adaptive controller. Later versions will document the exact method that is implemented and tested.

## Troubleshooting

- If `audioread` cannot open a file, try a WAV file first.
- If audio playback is too quiet or loud, adjust your system volume; V0.2 does not normalize the source.
- Large audio files should generally not be committed to Git. Use small, permitted test samples or document where sample audio can be obtained.

## Version history

See [`docs/version-history.md`](docs/version-history.md).

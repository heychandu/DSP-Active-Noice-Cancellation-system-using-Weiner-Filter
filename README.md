# Active Noise Cancellation Using a Wiener Filter

A MATLAB DSP project developed version by version for **offline noise reduction of audio files**. The current version combines preprocessing filters, an STFT-based Wiener filter, and an interactive preview workflow.

## Current version: V0.5

V0.5 keeps a fixed 5-second noise profile and removes the noise-duration selection popup. It includes mono conversion, DC removal, a high-pass filter, optional hum notches, Wiener filtering, gain smoothing, spectral gating, level correction, and preview/save/refilter controls.

After the first pass, the program plays the original audio followed by the filtered result. After **Refilter**, it plays the last filtered result followed by the newly filtered signal. The next pass starts from the previous filtered output.

## Requirements

- MATLAB with Signal Processing Toolbox functions such as `butter`, `filtfilt`, `stft`, `istft`, `hamming`, and `spectrogram`.
- An audio file supported by `audioread` and at least 5 seconds long by default.
- The first five seconds should contain background noise with little or no wanted speech/music.

## Run V0.5

1. Open MATLAB and set the Current Folder to `src/v0.5-configurable-noise-profile`.
2. Run `v05_wiener_noise_reduction.m`.
3. Select an audio file.
4. Listen to the original and filtered results.
5. Choose **Save**, **Refilter**, or **Cancel**.

- **Save:** export the current processed result to a chosen file.
- **Refilter:** run another filter pass on the latest filtered output.
- **Cancel:** exit without saving the current result.

The save workflow prevents choosing the exact source path as the output path. WAV is the most portable format; MP3 writing support depends on the installed MATLAB version and platform.

## Processing steps

1. Convert audio to mono and remove its mean.
2. Apply a 55 Hz high-pass filter and optional 50 Hz hum/harmonic notch filters.
3. Estimate noise power from the first five seconds of the current input.
4. Apply an STFT-based Wiener gain, smooth it, apply a spectral gate, and enforce a minimum gain.
5. Reconstruct with inverse STFT, apply limited RMS level correction, and prevent peaks above the configured limit.
6. Preview and let the user save, refilter, or cancel.

## Limitations

This is offline, single-recording noise reduction, not real-time adaptive ANC with a separate reference-noise input. The noise profile is always taken from the first five seconds of the current input; if speech or music is present there, the filter may suppress wanted content. Repeated filtering can progressively damage the signal. Listen to each pass before saving. A lower RMS level alone does not prove better denoising.

## Version roadmap

| Version | Milestone | Status |
|---|---|---|
| V0.1 | Basic audio loading and playback | Implemented |
| V0.2 | Waveform and frequency-spectrum analysis | Implemented |
| V0.3 | Initial Wiener-filter baseline | Implemented |
| V0.4 | Preprocessing and preview/save/refilter workflow | Implemented |
| V0.5 | Cleaned preview workflow with fixed 5-second noise profile | Implemented; test locally |
| V0.6 | Filter tuning and repeatable quality evaluation | Planned |
| V1.0 | Tested and documented release | Planned |

## Project structure

```text
src/
├── v0.1-basic-audio/
├── v0.2-noise-analysis/
├── v0.3-wiener-filter/
├── v0.4-preview-refilter-save/
└── v0.5-configurable-noise-profile/
    └── v05_wiener_noise_reduction.m
```

See [`docs/version-history.md`](docs/version-history.md) for milestone details.

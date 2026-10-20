# Active Noise Cancellation Using a Wiener Filter

A MATLAB digital signal processing (DSP) project developed incrementally, version by version. The project focuses on **offline noise reduction for audio files** using preprocessing filters and an STFT-based Wiener-filter pipeline.

> **Current milestone: V0.5 — Configurable Noise Profile and Improved Preview Workflow**

V0.5 builds on the V0.4 processing pipeline and adds a dialog for setting the noise-profile duration. It also makes Refilter comparisons more meaningful: the initial preview compares the original recording with the first processed result; after Refilter, the previous processed signal is compared with the new result. Each Refilter pass starts from the latest filtered output.

## Features

- Load audio files supported by MATLAB's `audioread`.
- Convert multichannel audio to mono.
- Remove DC offset and apply a 55 Hz high-pass filter.
- Optionally reduce mains hum and selected harmonics at 50 Hz, 100 Hz, 150 Hz, and 200 Hz when below Nyquist.
- Configure the duration of the noise-profile prefix through a dialog.
- Apply STFT-based Wiener filtering, gain smoothing, a spectral gate, and a minimum gain.
- Apply limited RMS level correction and peak protection.
- Preview the input and processed result before choosing Save, Refilter, or Cancel.
- Refilter the latest processed output instead of returning to the original.
- Protect the selected source path from direct overwrite.
- Plot waveform and spectrogram comparisons.

## Requirements

- MATLAB with Signal Processing Toolbox functions used by the script, including `butter`, `filtfilt`, `stft`, `istft`, `hamming`, and `spectrogram`.
- An audio recording long enough for the selected STFT window and noise-profile duration.
- Git and GitHub Desktop for version control, if desired.

## Run V0.5

1. Open the repository in MATLAB.
2. Set MATLAB's Current Folder to `src/v0.5-configurable-noise-profile`.
3. Run `v05_wiener_noise_reduction.m`.
4. Select your noisy recording.
5. Enter the duration, in seconds, of the **noise-only prefix** used to estimate the noise profile.
6. Listen to the first comparison (original, then processed). After Refilter, listen to the previous processed result, then the new result.
7. Choose **Save**, **Refilter**, or **Cancel** after the comparison.

- **Save:** choose an output filename for the current processed result. The program checks that this is not the selected source path.
- **Refilter:** apply another pass to the latest processed signal using the gentler refilter settings.
- **Cancel:** exit without saving the current result.

If the Save dialog is cancelled or a save attempt fails, the program returns to the preview/decision workflow.

## Processing pipeline

1. Read and validate the selected recording.
2. Convert the input to mono and remove its mean.
3. Apply a third-order Butterworth high-pass filter at 55 Hz.
4. Optionally apply notch filters for mains hum and selected harmonics.
5. Ask for the duration of the noise-profile prefix at the start of the current input (5 seconds by default, shortened for shorter recordings).
6. Estimate noise power from that prefix using the STFT.
7. Apply a Wiener gain, smooth it across frequency and time, apply a spectral gate, and enforce a minimum gain.
8. Reconstruct with inverse STFT, apply limited RMS level correction, and protect against clipping.
9. Preview the comparison, then let the user save, refilter, or cancel.

## Important tuning notes

- The noise-profile prefix always starts at the **beginning of the current input**. V0.5 lets you configure its duration, not its start offset.
- The prefix should contain background noise with little or no wanted speech/music. If speech or music starts immediately, the noise estimate may include wanted sound.
- `initialSuppression`, `initialGateThreshold`, and `initialMinimumGain` control the first pass. Refilter uses the gentler `refilter...` settings.
- A shared playback gain is used for each comparison so the two clips are not independently normalized.
- Repeated filtering can progressively damage wanted audio. Listen to every pass and stop when the result is acceptable.
- Stereo input is averaged to mono, so stereo spatial information is not retained.
- Lower RMS alone does not prove better denoising. Quantitative SNR evaluation requires clean reference audio or another defined evaluation setup.
- WAV is the most portable output format; support for other output formats depends on MATLAB and platform.
- This project is file-based/offline noise reduction.

## Version roadmap

| Version | Milestone | Status |
|---|---|---|
| V0.1 | Load, inspect, plot, and play original audio | Implemented |
| V0.2 | Waveform and frequency-spectrum analysis | Implemented |
| V0.3 | Initial offline Wiener-filter baseline | Implemented |
| V0.4 | Preprocessing, Wiener filtering, preview, refilter, and saving | Implemented |
| V0.5 | Configurable noise-profile duration and improved comparison behavior | Implemented; validate locally |
| V0.6 | Filter parameter tuning and repeatable quality evaluation | Planned |
| V1.0 | Tested and documented project release | Planned |

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
    ├── v0.2-noise-analysis/
    ├── v0.3-wiener-filter/
    ├── v0.4-preview-refilter-save/
    └── v0.5-configurable-noise-profile/
        └── v05_wiener_noise_reduction.m
```

## Version history

See [`docs/version-history.md`](docs/version-history.md).

# Active Noise Cancellation Using a Wiener Filter

A MATLAB digital signal processing (DSP) project developed incrementally, version by version. The project focuses on **offline noise reduction for audio files** using preprocessing filters and an STFT-based Wiener-filter pipeline.

> **Current milestone: V0.5 — Configurable Noise Profile and Improved Preview Workflow**

V0.5 builds on the full V0.4 processing pipeline and adds a dialog for setting the noise-profile duration. It also ensures that each Refilter pass compares the **previously processed signal** with the newly processed result, uses a shared playback gain for the comparison, and prevents saving over the selected source file.

## Features

- Load supported WAV, FLAC, MP3, or M4A audio files.
- Convert multichannel audio to mono for processing.
- Remove DC offset and apply a 55 Hz high-pass filter.
- Optionally reduce mains hum and harmonics at 50 Hz, 100 Hz, 150 Hz, and 200 Hz when below Nyquist.
- Configure the duration of the noise-profile prefix through a dialog.
- Apply STFT-based Wiener filtering, gain smoothing, a spectral gate, and a minimum gain.
- Apply limited RMS level correction and peak protection.
- Preview the original/current input, then the filtered result.
- Choose Save, Refilter, or Cancel after preview.
- On Refilter, process the latest filtered output instead of returning to the original.
- Compare waveforms and spectrograms.

## Requirements

- MATLAB.
- Signal Processing Toolbox functions used by the script, including `butter`, `filtfilt`, `stft`, `istft`, `hamming`, and `spectrogram`.
- A recording long enough for the selected STFT window and noise-profile duration.
- GitHub Desktop for visual version control, if desired.

## Run V0.5

1. Open the repository in MATLAB.
2. Set MATLAB's Current Folder to `src/v0.5-configurable-noise-profile`.
3. Run `v05_wiener_noise_reduction.m`.
4. Select your noisy recording.
5. Enter the duration, in seconds, of the **noise-only prefix** to use for estimating the noise profile.
6. Review the playback: the initial comparison is original then first-pass output; subsequent comparisons use previous-pass output then new output.
7. Choose **Save**, **Refilter**, or **Cancel** after each comparison.

### Decision dialog

- **Save:** Choose an output filename for the current result. The selected source file is protected against direct overwrite.
- **Refilter:** Apply another pass to the latest processed signal, using the gentler refilter settings.
- **Cancel:** Exit without saving the current result.

If the Save dialog is cancelled or a save attempt fails, the program returns to the preview/decision workflow.

## Processing pipeline

1. Read and validate the selected recording.
2. Convert multichannel audio to mono and remove its mean.
3. Apply a third-order Butterworth high-pass filter at 55 Hz.
4. Optionally apply notch filters for mains hum and selected harmonics.
5. Ask for the duration of the noise-profile prefix at the start of the current input (5 seconds by default, shortened automatically for shorter recordings).
6. Estimate noise power from the chosen prefix using the STFT.
7. Apply a Wiener gain, smooth it across frequency and time, apply a spectral gate, and enforce a minimum gain.
8. Reconstruct the audio with inverse STFT, apply limited RMS level correction, and protect against clipping.
9. Preview the comparison, then let the user save, refilter, or cancel.

## Important tuning notes

- The selected noise-profile prefix always starts at the **beginning of the current input**. This version allows changing its duration, not its start offset.
- That prefix should contain background noise with little or no wanted speech/music. If the recording starts with speech, the noise estimate can include desired sound and cause it to be attenuated.
- `initialSuppression`, `initialGateThreshold`, and `initialMinimumGain` control the first pass. Refilter uses the gentler `refilter...` settings.
- The same playback gain is used for both clips in each comparison, so playback does not independently normalize the processed clip to sound louder.
- Repeated filtering can progressively damage desired audio. Listen to every pass and stop when the result is acceptable.
- Stereo input is averaged to mono; stereo spatial information is not retained.
- Lower RMS alone does not prove better denoising. Quantitative SNR evaluation requires clean reference audio or another clearly defined evaluation setup.
- WAV is the most portable output format. MP3 output support depends on the MATLAB version and platform.
- This is offline file-based noise reduction, not adaptive feedforward ANC with a separate reference-noise input.

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

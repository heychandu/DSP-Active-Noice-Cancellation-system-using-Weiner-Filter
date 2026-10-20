# Active Noise Cancellation Using a Wiener Filter

A MATLAB digital signal processing (DSP) project developed incrementally, version by version. The current implementation processes a noisy audio file offline using preprocessing filters and an STFT-based Wiener noise-reduction algorithm.

> **Current milestone: V0.4 — Preview, Refilter, Save, or Cancel**

V0.4 includes mono conversion, high-pass filtering, optional mains-hum notch filters, Wiener gain estimation, gain smoothing, spectral gating, limited loudness correction, and an interactive review workflow.

The first pass compares the original recording with the processed result. After choosing **Refilter**, the program uses the latest filtered output as the next pass input and previews that signal against the new result. The Save action is designed to write a separate output file rather than overwrite the chosen source file.

## Features

- Load WAV, FLAC, MP3, or M4A audio files supported by the installed MATLAB version.
- Convert stereo input to mono for processing.
- Remove DC offset and apply a 55 Hz high-pass filter.
- Optionally reduce mains hum and harmonics at 50 Hz, 100 Hz, 150 Hz, and 200 Hz when below Nyquist.
- Estimate a noise profile from the beginning of the current input.
- Apply STFT-based Wiener filtering, gain smoothing, and a spectral gate.
- Apply limited RMS level correction and peak protection.
- Preview the current input and processed result before choosing an action.
- Save, refilter, or cancel from the decision dialog.
- View waveform and spectrogram comparisons.

## Requirements

- MATLAB.
- Signal Processing Toolbox functions used by the script, including `butter`, `filtfilt`, `stft`, `istft`, `hamming`, and `spectrogram`.
- A noisy audio recording long enough for the configured noise-profile duration.
- GitHub Desktop (optional, for version control through a visual interface).

## Run V0.4

1. Open the repository in MATLAB.
2. Set MATLAB's Current Folder to `src/v0.4-preview-refilter-save`.
3. Run `v04_preview_refilter_save.m`.
4. Select the noisy audio file.
5. Wait for the original/current input preview, followed by the processed preview.
6. After both previews, choose **Save**, **Refilter**, or **Cancel**.

### Decision dialog

- **Save:** Choose an output filename for the current result.
- **Refilter:** Apply another pass to the most recently filtered signal, using the gentler refilter settings.
- **Cancel:** Exit without saving the current result.

If the Save dialog is cancelled or a save attempt fails, the program returns to the review workflow. It checks that the output path is not the same as the selected input path.

## Processing pipeline

1. Read the selected audio file and validate the samples.
2. Convert the audio to mono and remove its mean.
3. Apply a third-order Butterworth high-pass filter at 55 Hz.
4. Optionally apply notch filters for mains hum and selected harmonics.
5. Estimate noise power using the first `noiseDuration` seconds of the current input (5 seconds by default).
6. Apply STFT-based Wiener gain, smooth the gain, apply a spectral gate, and enforce a minimum gain.
7. Reconstruct the waveform with inverse STFT, then apply limited RMS level correction and peak protection.
8. Play the comparison and ask the user whether to save, refilter, or cancel.

## Important parameter notes

- **Noise profile:** By default, the first five seconds of the current input are used to estimate noise. This region should contain background noise with little or no wanted speech or music. The current script exposes `noiseDuration` as a code setting; it does not provide a dialog for choosing a start offset.
- **Initial pass settings:** `initialSuppression`, `initialGateThreshold`, and `initialMinimumGain` control the first Wiener pass.
- **Refilter settings:** `refilterSuppression`, `refilterGateThreshold`, and `refilterMinimumGain` control subsequent passes. Refilter passes are configured to be gentler, but repeated filtering can still damage wanted content.
- **Playback comparison:** The script uses one shared playback scale for both signals in a comparison. Playback scaling does not alter the samples written to disk.
- **Stereo audio:** Stereo input is averaged into mono, so spatial stereo information is not retained.
- **Output format:** WAV is the most portable choice. MP3 writing support depends on the installed MATLAB version and platform.

## Limitations

This is an offline Wiener-filter noise-reduction project. A reduction in RMS level alone does not prove that the noise has been reduced while preserving the desired signal. Listen to each result before saving. Quantitative SNR evaluation requires a clean reference signal or another clearly defined evaluation setup.

Noise estimation is sensitive to the chosen noise-profile region. If the beginning of the recording contains speech or music, the filter may suppress desired content. Adjust the source recording or the `noiseDuration` setting accordingly.

## Version roadmap

| Version | Milestone | Status |
|---|---|---|
| V0.1 | Load, inspect, plot, and play original audio | Implemented |
| V0.2 | Waveform and frequency-spectrum analysis | Implemented |
| V0.3 | Initial offline Wiener-filter baseline | Implemented |
| V0.4 | Preprocessing, Wiener filtering, preview, refilter, and saving workflow | Implemented; validate locally |
| V0.5 | Filter parameter tuning and repeatable quality evaluation | Planned |
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
    │   └── v01_load_and_play_audio.m
    ├── v0.2-noise-analysis/
    │   └── v02_noise_analysis.m
    ├── v0.3-wiener-filter/
    │   └── v03_wiener_noise_reduction.m
    └── v0.4-preview-refilter-save/
        └── v04_preview_refilter_save.m
```

## Version history

See [`docs/version-history.md`](docs/version-history.md).

# Active Noise Cancellation Using a Wiener Filter

**Author:** [heychandur](https://github.com/heychandu)  
**Language:** MATLAB  
**Current version:** [V0.5](VERSION.md)

Offline audio-file noise reduction using an STFT-based Wiener-filter pipeline. The project evolves from basic audio inspection to configurable noise reduction with preview, refilter, and save controls.

> **Scope:** This project processes a recorded audio file. It is not real-time active noise cancellation with a separate reference microphone.

## Versions

| Version | Purpose | Script |
|---|---|---|
| V0.1 | Load, inspect, plot, and play audio | [v01_load_and_play_audio.m](src/v0.1-basic-audio/v01_load_and_play_audio.m) |
| V0.2 | Analyze waveform and average spectrum | [v02_noise_analysis.m](src/v0.2-noise-analysis/v02_noise_analysis.m) |
| V0.3 | Initial frame-based Wiener-filter experiment | [v03_wiener_noise_reduction.m](src/v0.3-wiener-filter/v03_wiener_noise_reduction.m) |
| V0.4 | Filtering with preview/save/refilter workflow | [v04_preview_refilter_save.m](src/v0.4-preview-refilter-save/v04_preview_refilter_save.m) |
| V0.5 | Current version: fixed five-second noise profile | [v05_wiener_noise_reduction.m](src/v0.5-configurable-noise-profile/v05_wiener_noise_reduction.m) |

## Features in V0.5

- Load supported audio files with MATLAB's `audioread`.
- Convert multichannel input to mono and remove DC offset.
- Apply a 55 Hz high-pass filter and optional 50 Hz mains-hum harmonic notch filters.
- Estimate a noise profile from the first five seconds of the current input.
- Apply STFT-based Wiener filtering, gain smoothing, spectral gating, level correction, and peak protection.
- Play the input and filtered output in sequence before asking what to do.
- Choose **Save**, **Refilter**, or **Cancel** after preview.
- Refilter the most recently processed output, not the original recording.
- Display waveform and spectrogram comparisons.
- Prevent saving over the selected source file.

## Requirements

- MATLAB with Signal Processing Toolbox functions used by the scripts, including `butter`, `filtfilt`, `stft`, `istft`, `hamming`, and `spectrogram`.
- An audio recording supported by MATLAB's `audioread`.
- For V0.5's default settings, an input of at least five seconds.

## Run V0.5

1. Clone or download this repository.
2. Open MATLAB and set the Current Folder to `src/v0.5-configurable-noise-profile`.
3. Run `v05_wiener_noise_reduction.m`.
4. Select the noisy audio file.
5. Listen to the original and processed previews.
6. Choose **Save** to export the result, **Refilter** to run another pass, or **Cancel** to exit without saving.

The save dialog supports WAV and MP3 choices; actual encoding support depends on the MATLAB version and system. WAV is a good default for compatibility.

## Processing overview

1. Read and validate the selected recording.
2. Convert the input to mono and remove its mean.
3. Apply high-pass filtering and optional mains-hum notch filters.
4. Estimate noise from the first five seconds of the current pass.
5. Apply the STFT-based Wiener gain and spectral gate.
6. Reconstruct the output, apply limited level correction, and prevent excessive peaks.
7. Play the comparison, then save, refilter, or cancel.

## Important limitations

- The first five seconds are used as the noise estimate and should contain mostly background noise. Speech or music in this segment may be suppressed.
- Repeated refiltering can damage desired audio. Listen to each pass before saving.
- Stereo input is reduced to mono, so stereo spatial information is not retained.
- Lower output volume alone does not prove better noise reduction. Evaluate both by listening and, where possible, against a clean reference.
- Performance has not been claimed as validated on every MATLAB release. Run the script in your target MATLAB environment.

## Project structure

```text
.
├── docs/
│   └── version-history.md
├── src/
│   ├── v0.1-basic-audio/
│   ├── v0.2-noise-analysis/
│   ├── v0.3-wiener-filter/
│   ├── v0.4-preview-refilter-save/
│   └── v0.5-configurable-noise-profile/
├── .gitignore
├── LICENSE
└── README.md
```

See [VERSION.md](VERSION.md) for the current version and [docs/version-history.md](docs/version-history.md) for the milestone-by-milestone history.

## Author

**heychandur** — [GitHub profile](https://github.com/heychandu)

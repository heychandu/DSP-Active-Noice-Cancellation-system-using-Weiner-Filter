# Active Noise Cancellation Using a Wiener Filter

**Author:** [heychandur](https://github.com/heychandu)  
**Language:** MATLAB  
**Current version:** V0.5 — Final version for the current project

This project demonstrates offline audio-file noise reduction using preprocessing filters and an STFT-based Wiener-filter pipeline. V0.5 is the final version for now; no live-microphone feature is included.

## Features

- Load an audio file supported by MATLAB's `audioread`.
- Convert stereo input to mono and remove its DC offset.
- Apply a 55 Hz high-pass filter.
- Optionally reduce 50 Hz mains hum and selected harmonics using notch filters.
- Estimate noise power from the first five seconds of the current input.
- Apply STFT-based Wiener filtering with gain smoothing, spectral gating, and a minimum-gain floor.
- Apply limited RMS level correction and peak protection.
- Preview the comparison audio, then choose **Save**, **Refilter**, or **Cancel**.
- Refilter from the most recently processed signal rather than restarting from the original.
- Display waveform and spectrogram comparisons.

## Requirements

- MATLAB with Signal Processing Toolbox functions used by the script, including `butter`, `filtfilt`, `stft`, `istft`, `hamming`, and `spectrogram`.
- An audio file supported by `audioread`.
- At least five seconds of audio with the default `noiseDuration = 5` setting.

## Run the project

1. Open the repository in MATLAB.
2. Set the Current Folder to `src/v0.5-configurable-noise-profile`.
3. Run `v05_wiener_noise_reduction.m`.
4. Select the noisy audio file.
5. Listen to the input and processed audio previews.
6. Choose **Save**, **Refilter**, or **Cancel** in the popup.

### Popup choices

- **Save:** select a destination and write the current filtered result.
- **Refilter:** process the latest filtered result with the gentler refilter parameters.
- **Cancel:** exit without saving the current result.

The save workflow checks that the output path is different from the selected source path. WAV is the most portable output format; MP3 writing support depends on the installed MATLAB version and platform.

## Processing pipeline

1. Read and validate the audio.
2. Convert multichannel audio to mono and remove its mean.
3. Apply a third-order Butterworth high-pass filter at 55 Hz.
4. Optionally apply notch filters at 50 Hz and selected harmonics below the Nyquist frequency.
5. Estimate the noise profile from the first five seconds of the current input.
6. Apply the STFT-based Wiener gain, smooth it across frequency and time, apply a spectral gate, and enforce the minimum gain.
7. Reconstruct the audio with inverse STFT, apply limited RMS level correction, and prevent excessive peaks.
8. Preview, then let the user save, refilter, or cancel.

## Important notes and limitations

- The first five seconds of the current input are used for noise estimation. This segment should contain background noise with little or no desired speech or music. If desired audio is present, the filter may suppress it.
- Refilter passes use the previous filtered result as their input. Repeated filtering can progressively degrade wanted audio, so listen to each pass before saving.
- The program converts stereo audio to mono, so stereo spatial information is not retained.
- A lower RMS level alone does not prove better noise reduction. Use listening tests and, when available, a suitable clean reference for quantitative evaluation.
- This is offline, single-recording noise reduction. It is not real-time adaptive ANC using a separate reference-noise input.
- The MATLAB code should be run and checked in the target MATLAB installation before claiming measured performance.

## Development history

| Version | Work completed |
|---|---|
| V0.1 | Basic audio loading, waveform plotting, and playback |
| V0.2 | Waveform and frequency-spectrum analysis |
| V0.3 | Initial Wiener-filter baseline |
| V0.4 | Preprocessing and preview/save/refilter workflow |
| V0.5 | Cleaned preview workflow, fixed five-second noise profile, and source-path protection |

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

For details on each milestone, see [`docs/version-history.md`](docs/version-history.md).

## Author

**heychandur** — [GitHub profile](https://github.com/heychandu)

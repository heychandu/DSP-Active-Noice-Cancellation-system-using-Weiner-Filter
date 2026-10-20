# Active Noise Cancellation Using a Wiener Filter

A MATLAB DSP project developed incrementally, version by version.

## Current milestone: V0.3 — First Wiener Noise-Reduction Filter

V0.3 adds an offline, frame-based spectral Wiener filter for a noisy audio recording. The filter estimates noise power from a user-selected **noise-only** part of the same recording, then attenuates frequency components estimated to be noise-dominated.

This version is a single-recording noise-reduction experiment. It is not adaptive feedforward ANC with a separate reference microphone/input.

## Version roadmap

| Version | Milestone | Status |
|---|---|---|
| V0.1 | Load, inspect, plot, and play original audio | Implemented |
| V0.2 | Waveform and frequency-spectrum analysis | Implemented |
| V0.3 | First Wiener-filter noise-reduction implementation | Implemented; test locally |
| V0.4 | Preview original/processed audio; Save / Refilter / Cancel | Planned |
| V0.5 | Live microphone processing experiment | Planned |
| V1.0 | Tested and documented project release | Planned |

## Requirements

- MATLAB with standard audio and plotting functions (`audioread`, `audioplayer`, `playblocking`, `fft`, `ifft`, and `inputdlg`).
- A noisy recording that you are permitted to use.
- A short section of the recording that contains **noise only** (no desired speech/music) for estimating the noise spectrum.
- Git and GitHub Desktop for version management.

No separate Signal Processing Toolbox function is intentionally used in V0.3.

## Run V0.3

1. Open the repository in MATLAB.
2. Set MATLAB's Current Folder to `src/v0.3-wiener-filter`.
3. Run `v03_wiener_noise_reduction.m`.
4. Select your noisy audio file.
5. In the parameter dialog, enter the start time and duration of a noise-only segment and a minimum Wiener gain.
6. Inspect the input/filtered waveform and spectrum plots, compare the RMS levels, then choose whether to play the original followed by the filtered audio.

The script does **not** save or overwrite any audio file. Saving, refiltering, and cancel/save decisions will be added in V0.4.

## How the V0.3 filter works

1. Reads the input recording.
2. Estimates noise power per frequency bin from the selected noise-only segment.
3. Processes the recording in overlapping, windowed frames.
4. Estimates signal power as `max(observed power - noise power, 0)`.
5. Forms a Wiener gain from the estimated signal and observed power, applies a configurable gain floor, and smooths the gain between adjacent frames.
6. Reconstructs the filtered signal using inverse FFT and weighted overlap-add.
7. Plots and reports a basic before/after comparison.

### Parameters

- **Noise-only segment start (seconds):** offset from the start of the recording.
- **Noise-only segment duration (seconds):** enough samples for at least one analysis frame are required.
- **Minimum gain (0 to 1):** raising this preserves more of the desired signal but usually leaves more noise; lowering it can suppress more noise but may damage speech/music.

The default time values are examples only. Choose a section where the desired signal is absent. If the selected section contains speech or music, that content may be treated as noise and removed elsewhere.

## Important limitations

- The result depends on the chosen noise-only segment.
- The spectral Wiener estimate can attenuate desired components that overlap the noise spectrum.
- A smoother-sounding result is not guaranteed; listen and compare at a sensible playback level.
- Peak/RMS changes alone do not prove better denoising. Quantitative SNR evaluation requires clean reference audio or another defensible test setup.
- The script is an offline file-based filter, not real-time ANC.

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
    └── v0.3-wiener-filter/
        └── v03_wiener_noise_reduction.m
```

## Version history

See [`docs/version-history.md`](docs/version-history.md).

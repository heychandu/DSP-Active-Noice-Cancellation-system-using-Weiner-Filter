# Active Noise Cancellation Using a Wiener Filter

A MATLAB DSP project developed version by version, using an offline Wiener noise-reduction pipeline.

## Current implementation: V0.4 — Preview, Refilter, Save, or Cancel

V0.4 incorporates the project's full file-based processing pipeline: mono conversion, a high-pass filter, optional mains-hum notch filters, STFT-based Wiener filtering, gain smoothing, a spectral gate, loudness control, and an interactive preview/save workflow.

**Refilter behavior:** the first preview compares the original recording with the first filtered output. After choosing **Refilter**, the program previews the previously denoised signal and the new result. The next Wiener pass starts with the previous output, not the original recording.

The source audio is protected from being overwritten by the Save action.

## Requirements

- MATLAB with Signal Processing Toolbox functions used by the script, including `butter`, `filtfilt`, `stft`, `istft`, `hamming`, and `spectrogram`.
- Audio file at least 5 seconds long by default. Adjust `noiseDuration` for shorter recordings.
- A noise-only or mostly-noise section in the first `noiseDuration` seconds.
- Git and GitHub Desktop for version control.

## Run V0.4

1. Open the repository in MATLAB.
2. Set Current Folder to `src/v0.4-preview-refilter-save`.
3. Run `v04_preview_refilter_save.m`.
4. Select a noisy audio recording.
5. Listen to the first comparison: original, then filtered output.
6. Choose **Save**, **Refilter**, or **Cancel** when the popup appears.

- **Save:** write the latest result to a new WAV or MP3 output file.
- **Refilter:** use the latest filtered output as the next pass input, with gentler second-pass settings.
- **Cancel:** exit without saving the current result.

If the Save dialog is cancelled or saving fails, the script returns to the preview/decision loop. It prevents writing over the selected source file.

## Signal-processing stages

1. Convert multichannel input to mono and remove its mean.
2. Apply a 3rd-order Butterworth high-pass filter at 55 Hz.
3. Optionally apply notch filters at 50, 100, 150, and 200 Hz when below Nyquist.
4. Estimate noise power from the first `noiseDuration` seconds (default 5 seconds).
5. Calculate an STFT-based Wiener gain, smooth it, apply a spectral gate, and enforce a minimum gain.
6. Reconstruct the time signal with `istft`.
7. Apply limited RMS level correction and peak protection.
8. Preview and ask the user whether to save, refilter, or cancel.

## Important tuning notes

- The first five seconds should ideally contain background noise with little or no speech/music. The code estimates noise from the start of the current input for each pass, so a speech-heavy first segment can damage the result.
- `initialSuppression`, `initialGateThreshold`, and `initialMinimumGain` control the first pass. Refilter uses gentler settings.
- The preview uses a shared playback scale for both compared signals rather than normalizing them separately.
- Repeated filtering can progressively damage wanted audio. Compare each pass and stop when the result is acceptable.
- Mono conversion discards stereo spatial information.
- A reduced RMS level does not, by itself, prove noise reduction quality. Listen to the result and use clean reference audio for quantitative SNR evaluation where available.
- This is file-based noise reduction, not real-time adaptive ANC with a separate reference-noise microphone/input.
- WAV is the most portable output choice. MP3 writing support depends on MATLAB version and platform.

## Version roadmap

| Version | Milestone | Status |
|---|---|---|
| V0.1 | Load, inspect, plot, and play original audio | Implemented |
| V0.2 | Waveform and frequency-spectrum analysis | Implemented |
| V0.3 | Initial offline Wiener-filter baseline | Implemented |
| V0.4 | Full filter pipeline and preview/save/refilter loop | Implemented; test locally |
| V0.5 | Live microphone processing experiment | Planned |
| V1.0 | Tested, documented project release | Planned |

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
    └── v0.4-preview-refilter-save/
        └── v04_preview_refilter_save.m
```

## Version history

See [`docs/version-history.md`](docs/version-history.md).

# Active Noise Cancellation Using a Wiener Filter

A MATLAB DSP project developed incrementally, version by version.

## Current milestone: V0.4 — Preview, Refilter, Save, or Cancel

V0.4 adds a review loop around the offline spectral Wiener noise-reduction filter. The script plays the input for the current pass, then the filtered result, and presents **Save**, **Refilter**, or **Cancel**.

When you choose **Refilter**, the latest filtered result becomes the input to the next pass. It does not return to the original recording. Saving exports only the currently previewed result to a new WAV file; the selected source audio is not overwritten.

## Version roadmap

| Version | Milestone | Status |
|---|---|---|
| V0.1 | Load, inspect, plot, and play original audio | Implemented |
| V0.2 | Waveform and frequency-spectrum analysis | Implemented |
| V0.3 | First Wiener-filter noise-reduction implementation | Implemented |
| V0.4 | Preview; Save / Refilter / Cancel | Implemented; test locally |
| V0.5 | Live microphone processing experiment | Planned |
| V1.0 | Tested and documented project release | Planned |

## Requirements

- MATLAB with `audioread`, `audiowrite`, `audioplayer`, `playblocking`, `fft`, `ifft`, `inputdlg`, and `questdlg`.
- A noisy recording you are permitted to use.
- A segment containing **noise only** (no wanted speech/music) for estimating the noise spectrum.
- Git and GitHub Desktop for version management.

No separate Signal Processing Toolbox function is intentionally used in V0.4.

## Run V0.4

1. Open the repository in MATLAB.
2. Set MATLAB's Current Folder to `src/v0.4-preview-refilter-save`.
3. Run `v04_preview_refilter_save.m`.
4. Select the noisy audio file.
5. Enter the start and duration of a noise-only segment, plus the minimum Wiener gain.
6. Listen to the input for the current pass and then its filtered result.
7. Choose one of the popup actions:
   - **Save** — choose a new WAV filename for the current filtered result.
   - **Refilter** — run another Wiener pass on the latest filtered signal. You will be prompted for parameters again.
   - **Cancel** — exit without saving the current result.

The save dialog proposes a name ending in `_wiener_denoised.wav`. The program explicitly blocks saving over the selected source file.

## How the filter works

For each pass, V0.4:
1. Estimates per-channel noise power from the selected noise-only segment.
2. Processes overlapped Hamming-windowed frames.
3. Estimates desired-signal power as `max(observed power - noise power, 0)`.
4. Forms a Wiener-like gain with a user-defined minimum gain and temporal gain smoothing.
5. Reconstructs the filtered signal using inverse FFT and weighted overlap-add.
6. Plots the current input, filtered result, and average spectra.
7. Plays the current input followed by the result before presenting the decision popup.

### Parameters

- **Noise-only segment start (seconds):** time offset in the current signal. The signal duration is unchanged between refilter passes, so the segment time remains aligned.
- **Noise-only segment duration (seconds):** must contain at least one analysis frame.
- **Minimum Wiener gain (0 to 1):** a higher floor tends to preserve more desired content but leaves more noise; a lower floor can suppress more noise but can also damage speech/music.

Choose a segment that contains only unwanted noise. If it contains desired speech or music, that content can be attenuated throughout the recording.

## Important limitations

- The estimated noise section must be genuinely noise-only.
- Multiple Refilter passes can progressively damage wanted sound. Compare every pass carefully and save only when satisfied.
- The algorithm may attenuate wanted sound that overlaps the estimated noise spectrum.
- Peak/RMS differences alone do not prove better denoising. Quantitative SNR assessment requires clean reference audio or another defensible evaluation setup.
- This is offline, single-recording noise reduction, not real-time adaptive ANC with a separate reference-noise input.
- The MATLAB script must be tested on your own audio and MATLAB installation before this milestone is considered validated.

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

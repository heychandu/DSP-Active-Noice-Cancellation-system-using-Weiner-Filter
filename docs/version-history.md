# Version History

This file records the project's implemented milestones. Planned work is listed separately and is not presented as completed.

## V0.1.0 — Basic audio input

- Load an audio file and report basic properties.
- Plot and play the source waveform.
- Do not filter or overwrite the source.

## V0.2.0 — Noise analysis

- Plot the waveform and averaged single-sided amplitude spectrum.
- Report peak and RMS amplitude and the strongest non-DC spectral bin.
- Keep this version analysis-only.

## V0.3.0 — Initial Wiener-filter baseline

- Estimate noise power from a user-selected noise-only segment.
- Apply a frame-based Wiener-like gain and reconstruct the signal.
- Compare the input and processed audio.
- No save workflow in this milestone.

## V0.4.0 — Preprocessing and preview workflow

- Convert input to mono and remove its DC offset.
- Apply a 55 Hz high-pass filter and optional mains-hum notch filters.
- Apply STFT-based Wiener filtering, gain smoothing, spectral gating, level correction, and peak protection.
- Add a preview followed by Save / Refilter / Cancel.
- Refilter from the latest processed output and display waveform/spectrogram comparisons.

## V0.5.0 — Fixed noise profile and cleaned workflow

### Changes

- Remove the noise-duration selection popup and use a fixed five-second profile.
- Retain the existing processing settings and pass-specific Wiener parameters.
- Play the original and first filtered result before showing the decision popup.
- On Refilter, play the previous filtered result before the new result.
- Refilter from the latest processed output.
- Prevent saving directly over the selected source path.
- Remove redundant comments and unreachable control-flow statements where identified.

### Requirements and limitations

- Requires MATLAB functions including `butter`, `filtfilt`, `stft`, `istft`, and `spectrogram`.
- The first five seconds of each pass are used for noise estimation and should contain little or no desired speech or music.
- The default script requires an input of at least five seconds.
- Repeated filtering can degrade desired audio; preview each result before saving.
- This is offline audio-file noise reduction, not real-time reference-input ANC.

### Validation checklist

- [ ] Script runs in the target MATLAB version.
- [ ] No noise-duration selection popup appears.
- [ ] Original and first filtered result play in sequence.
- [ ] Refilter plays the previous output and then the new result.
- [ ] Each refilter pass uses the previous processed signal.
- [ ] Save writes the selected output without overwriting the source.
- [ ] Cancel exits without saving.
- [ ] Waveform and spectrogram plots appear.

These checks are a test plan, not a claim that the script has been run in MATLAB during this documentation update.

## Planned work

### V0.6.0 — Filter tuning and quality evaluation

- Evaluate noise suppression and desired-signal preservation with repeatable test recordings.
- Document parameter trade-offs and known limitations.
- Add measured results only after running tests.

### V1.0.0 — Stable release

- Run and document the validation checklist.
- Publish the tested release with final instructions and known limitations.

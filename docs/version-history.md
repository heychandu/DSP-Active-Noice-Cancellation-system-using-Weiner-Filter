# Version History

## V0.1.0 — Basic audio input
- Load an audio file, display basic properties, plot and play the original.
- Leave the source file unchanged.

## V0.2.0 — Noise analysis
- Plot waveform and average single-sided amplitude spectrum.
- Report peak/RMS amplitude and strongest non-DC spectrum bin.
- No filtering or source-file changes.

## V0.3.0 — Initial Wiener-filter baseline
- Estimate noise power from a noise-only region.
- Apply a frame-based Wiener-like gain and reconstruct the signal.
- Compare input and processed audio; no saving workflow yet.

## V0.4.0 — Preprocessing and preview workflow
- Convert to mono; remove DC offset.
- Apply a 55 Hz high-pass filter and optional mains-hum notch filters.
- Apply STFT Wiener filtering, gain smoothing, spectral gating, level correction, and peak protection.
- Add preview followed by Save / Refilter / Cancel.
- Refilter from the latest processed output and compare waveforms/spectrograms.

## V0.5.0 — Cleaned preview workflow with fixed noise profile

### Changes
- Remove the noise-duration selection popup; use a fixed noiseDuration = 5 seconds.
- Keep the processing settings and pass-specific Wiener parameters.
- Keep shared-gain playback comparisons.
- On the first pass, preview original then filtered audio.
- On Refilter, preview the previous filtered output then the new output.
- Refilter from the latest processed output.
- Prevent direct overwrite of the selected source path.
- Remove redundant comments and the unreachable break after the switch statement.

### Requirements and limitations
- Requires MATLAB Signal Processing Toolbox functions including butter, filtfilt, stft, istft, and spectrogram.
- The first five seconds of each pass are used as the noise profile and should contain little or no desired speech/music.
- Files shorter than five seconds stop with an error unless noiseDuration is changed in the script.
- Repeated filtering can damage wanted content; listen before saving.
- This is offline file-based noise reduction, not live-microphone or reference-input ANC.

### Validation checklist
- [ ] MATLAB script runs on the target MATLAB version.
- [ ] No noise-duration selection popup appears.
- [ ] Original and first filtered result play in sequence.
- [ ] Refilter plays the prior output followed by the new result.
- [ ] Refilter begins from the previous processed signal.
- [ ] Save writes the chosen output and does not overwrite the source.
- [ ] Cancel exits without saving.
- [ ] Waveform and spectrogram plots appear.

## V0.6.0 — Filter tuning and quality evaluation (planned)
- Evaluate suppression and desired-signal preservation using repeatable tests.
- Document parameter trade-offs and known limitations.

## V1.0.0 — Stable release (planned)
- Publish a tested release with final instructions and documented validation results.

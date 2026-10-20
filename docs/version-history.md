# Version History

This document records the implemented milestones and the planned next steps for the file-based Wiener-filter project.

## V0.1.0 — Basic audio input
- Select and load an audio file.
- Display basic audio properties.
- Plot and play the original recording.
- Leave the source file unchanged.

## V0.2.0 — Waveform and frequency-spectrum analysis
- Plot the input waveform.
- Estimate and plot an average single-sided amplitude spectrum.
- Report peak/RMS amplitude and the strongest non-DC spectrum bin.
- Play the original audio; do not modify the source file.
- A strong spectral peak is not necessarily noise, and spectrum magnitude alone is not an SNR measurement.

## V0.3.0 — Initial Wiener-filter baseline
- Estimate noise power from a noise-only section.
- Apply a frame-based Wiener-like gain with smoothing.
- Reconstruct the processed waveform and plot input/output comparisons.
- Report input and processed peak/RMS measurements.
- Do not save or overwrite the source file.

## V0.4.0 — Preprocessing and preview workflow
- Convert multichannel audio to mono and remove mean.
- Apply a 55 Hz Butterworth high-pass filter.
- Optionally apply manual mains-hum notch filters at 50 Hz and selected harmonics.
- Estimate noise from the first five seconds by default.
- Apply STFT-based Wiener gain, gain smoothing, spectral gating, minimum gain, RMS level correction, and peak protection.
- Preview input and processed audio, then offer Save / Refilter / Cancel.
- Refilter from the previous processed output.
- Plot final waveforms and spectrograms.
- Source-file overwrite protection is required for the Save action.

## V0.5.0 — Configurable noise profile and improved comparison workflow

**Goal:** Make noise-profile duration configurable and improve each Refilter comparison.

### Changes
- Retain the uploaded project pipeline: mono conversion, DC removal, high-pass, optional hum notches, STFT Wiener filtering, gain smoothing, spectral gate, level correction, and clipping protection.
- Ask for the duration of the noise-profile prefix rather than requiring exactly five seconds.
- Use the first N seconds of the current input as the noise profile; the start offset remains zero.
- On the first pass, play the original and then the first processed result.
- After Refilter, play the previous processed result and then the newly processed result.
- Refilter from the latest processed output.
- Use a shared playback gain for both clips in a comparison.
- Prevent direct overwrite of the selected source file.
- Keep waveform and spectrogram comparison plots.

### Requirements and limitations
- Uses Signal Processing Toolbox functions including `butter`, `filtfilt`, `stft`, `istft`, and `spectrogram`.
- Noise-profile prefix should contain noise with little or no wanted speech/music.
- Repeated filtering can progressively damage wanted content.
- File-based/offline processing only.

### Validation checklist
- [ ] Runs on the target MATLAB version.
- [ ] Noise-profile duration dialog accepts valid values and rejects invalid values.
- [ ] Initial preview plays original then processed audio.
- [ ] Refilter preview plays previous processed audio then the new result.
- [ ] Refilter uses the latest processed output as its input.
- [ ] Save writes the chosen output successfully.
- [ ] Source file cannot be overwritten via the Save path check.
- [ ] Cancel exits without saving the current result.
- [ ] Waveform and spectrogram plots appear.

## V0.6.0 — Filter tuning and repeatable quality evaluation (planned)
- Improve selection of the noise-profile start time and duration.
- Compare parameter settings in repeatable tests.
- Record listening observations and suitable metrics when clean reference audio is available.
- Document trade-offs between residual noise and desired-signal preservation.

## V1.0.0 — Stable documented release (planned)
Publish a tested release with clear setup instructions, representative examples, and documented validation results. Mark the project stable only after execution and evaluation in the target MATLAB environment.

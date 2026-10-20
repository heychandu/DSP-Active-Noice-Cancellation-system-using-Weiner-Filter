# Version History

## V0.1.0 — Basic audio input
- Select an audio file.
- Print basic audio properties.
- Plot and play the original recording.
- No filtering or source-file modification.

## V0.2.0 — Noise analysis
- Add waveform and average single-sided amplitude-spectrum plots.
- Report peak/RMS amplitude and strongest non-DC spectrum bin.
- No noise reduction or source-file modification.

## V0.3.0 — Initial Wiener-filter baseline
- Estimate noise power from a chosen noise-only section.
- Apply a frame-based Wiener-like gain and overlap-add reconstruction.
- Compare input and processed signals.
- No output saving.

## V0.4.0 — User's full filter pipeline and review workflow

### Included
- Mono conversion and mean removal.
- Butterworth high-pass filter at 55 Hz.
- Optional manual 50 Hz mains-hum harmonics notch filters.
- STFT-based Wiener gain with noise-power estimation, gain smoothing, spectral gate, and a minimum-gain floor.
- RMS loudness control and clipping protection.
- Original/filtered audio playback followed by Save / Refilter / Cancel.
- On first pass, preview the original and filtered result.
- After Refilter, preview the previous denoised result and the newly filtered result.
- Refilter the previous filtered output rather than starting from the original.
- Save the current result without overwriting the selected source file.
- Final waveform and spectrogram comparison.

### Requirements and limitations
- Uses Signal Processing Toolbox functions such as `butter`, `filtfilt`, `stft`, `istft`, and `spectrogram`.
- By default, estimates the noise profile from the first 5 seconds, which should contain little or no wanted speech.
- Converts stereo to mono.
- Repeated filtering can damage desired content; listen before saving.
- This is offline single-recording noise reduction, not adaptive feedforward ANC.

### Validation checklist
- [ ] Runs on the target MATLAB version.
- [ ] High-pass and hum-notch preprocessing runs.
- [ ] Initial preview plays original then filtered audio.
- [ ] Refilter preview plays prior filtered audio then the new result.
- [ ] Refilter processes the prior filtered output.
- [ ] Save writes the selected format successfully.
- [ ] Source file cannot be overwritten.
- [ ] Cancel exits without saving.
- [ ] Waveform and spectrogram plots appear.

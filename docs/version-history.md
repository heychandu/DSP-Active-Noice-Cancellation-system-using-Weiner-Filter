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

## V0.4.0 — Full filter pipeline and review workflow

### Included
- Convert the input to mono and remove its mean.
- Apply a 3rd-order Butterworth high-pass filter at 55 Hz.
- Optionally apply manual notch filters for 50 Hz mains hum and harmonics up to 200 Hz (below Nyquist).
- Estimate a noise profile from the first 5 seconds by default.
- Apply STFT-based Wiener gain, temporal/frequency smoothing, a spectral gate, and a minimum-gain floor.
- Reconstruct with inverse STFT, apply limited RMS level correction, and protect against clipping.
- Preview the original and first-pass result, then show Save / Refilter / Cancel.
- After Refilter, preview the previously denoised output and the new result.
- Refilter from the latest processed signal rather than the original.
- Save the current result as WAV or MP3, with a check preventing overwrite of the selected source.
- Display waveform and spectrogram comparisons.

### Requirements and limitations
- Uses Signal Processing Toolbox functions such as `butter`, `filtfilt`, `stft`, `istft`, and `spectrogram`.
- By default, estimates noise from the first 5 seconds. That section should contain little or no wanted speech/music.
- Converts stereo input to mono, so stereo spatial information is not preserved.
- Repeated filtering may damage wanted speech/music; listen before saving.
- This is offline, single-recording noise reduction, not adaptive feedforward ANC with a separate reference-noise input.
- Runtime behavior must be tested in the user's MATLAB environment.

### Validation checklist
- [ ] Runs on the target MATLAB version.
- [ ] High-pass and hum-notch preprocessing runs.
- [ ] Initial preview plays original then filtered audio.
- [ ] Refilter preview plays the previous filtered signal then the new result.
- [ ] Refilter processes the previous filtered output.
- [ ] Save writes the selected format successfully.
- [ ] Source file cannot be overwritten.
- [ ] Cancel exits without saving.
- [ ] Waveform and spectrogram plots appear.

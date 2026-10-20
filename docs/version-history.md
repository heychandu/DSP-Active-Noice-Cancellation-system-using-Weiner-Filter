# Version History

This document records the implemented milestones and the next planned work for the project.

## V0.1.0 — Basic audio input

**Goal:** Create a repeatable baseline before applying noise reduction.

### Included
- Select and load an audio file.
- Display basic audio properties, including sample rate, duration, sample count, channel count, peak amplitude, and RMS amplitude.
- Plot the original waveform.
- Play the original recording.
- Leave the input file unchanged.

### Validation checklist
- [ ] Script runs without errors.
- [ ] File picker opens and accepts a supported audio file.
- [ ] Waveform plot appears.
- [ ] Audio plays and is audible.
- [ ] Original file remains unchanged.

## V0.2.0 — Waveform and frequency-spectrum analysis

**Goal:** Inspect the input signal in time and frequency before designing the denoising stage.

### Included
- Plot the input waveform.
- Estimate and plot an average single-sided amplitude spectrum.
- Report peak and RMS amplitude for each channel.
- Report the strongest non-DC spectrum bin.
- Play the original recording.
- Leave the input file unchanged.

### Notes
- A prominent spectral peak is not automatically noise; it may be part of the desired signal.
- Spectrum magnitude is not, by itself, an SNR measurement.

### Validation checklist
- [ ] Script runs without errors.
- [ ] Waveform and frequency-spectrum plots appear.
- [ ] Printed audio measurements are plausible.
- [ ] Original audio plays.
- [ ] Original file remains unchanged.

## V0.3.0 — Initial Wiener-filter baseline

**Goal:** Introduce offline Wiener noise reduction using a selected noise-only segment.

### Included
- Estimate noise power from overlapping FFT frames.
- Apply a frame-based Wiener-like gain with gain smoothing.
- Reconstruct the processed signal using inverse FFT and weighted overlap-add.
- Compare the original and processed waveforms and spectra.
- Print input and processed peak/RMS measurements.
- Play the original and processed signals for comparison.
- Do not save or overwrite the input file.

### Known limitations
- The estimated noise region should not contain desired speech or music.
- Desired sound can be attenuated if it overlaps the estimated noise spectrum.
- The output must be reviewed by listening; lower RMS alone does not prove better denoising.

### Validation checklist
- [ ] Script runs without errors.
- [ ] Valid noise-only segment parameters are accepted.
- [ ] Waveform and spectrum comparisons appear.
- [ ] Original and processed audio can be compared.
- [ ] Input file remains unchanged.

## V0.4.0 — Full filtering and review workflow

**Goal:** Integrate preprocessing, Wiener filtering, and the user-controlled preview/save loop.

### Included
- Convert multichannel audio to mono and remove its mean.
- Apply a third-order Butterworth high-pass filter at 55 Hz.
- Optionally apply 50 Hz mains-hum notch filters and selected harmonics.
- Estimate a noise profile from the first `noiseDuration` seconds of the current input (5 seconds by default).
- Apply STFT-based Wiener gain estimation, gain smoothing, spectral gating, and a minimum-gain floor.
- Apply limited RMS level correction and peak protection.
- Play the original/current input first and the processed result second.
- Display a **Save / Refilter / Cancel** decision dialog after the previews.
- On the first pass, compare the original with the first processed result.
- On Refilter, use the previous processed output as the next pass input and preview baseline.
- Save the current processed signal to a new output path and protect the selected source path.
- Display final waveform and spectrogram comparisons.

### Requirements and limitations
- Uses Signal Processing Toolbox functions such as `butter`, `filtfilt`, `stft`, `istft`, and `spectrogram`.
- The default noise-profile region is the first five seconds and should contain little or no wanted speech/music.
- The input is converted to mono.
- Repeated filtering can damage wanted content; review every pass before saving.
- WAV is the most portable output format; other format support may depend on MATLAB and platform.

### Validation checklist
- [ ] Runs on the target MATLAB version.
- [ ] High-pass and optional notch filtering run.
- [ ] First preview plays original then the processed result.
- [ ] Refilter preview plays the previous processed signal then the newly processed result.
- [ ] Refilter starts from the previous processed signal.
- [ ] Save writes the expected output file.
- [ ] Save cannot overwrite the selected source file.
- [ ] Cancelling exits without saving the current result.
- [ ] Waveform and spectrogram plots appear.

## V0.5.0 — Filter tuning and quality evaluation (planned)

**Planned goal:** Make denoising results easier to tune and evaluate.

Possible work:
- Improve selection of the noise-profile region.
- Compare multiple parameter settings systematically.
- Record playback observations and objective metrics where suitable clean reference audio is available.
- Document known trade-offs between residual noise and desired-signal preservation.

## V1.0.0 — Stable documented release (planned)

**Planned goal:** Publish a tested version with consistent usage instructions, final examples, and documented validation results.

The release should only be marked stable after the code is run and evaluated in the target MATLAB environment.

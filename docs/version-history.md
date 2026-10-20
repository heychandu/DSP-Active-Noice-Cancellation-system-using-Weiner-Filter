# Version History

This document records the implemented milestones and the planned next steps for the file-based Wiener-filter project.

## V0.1.0 — Basic audio input

**Goal:** Establish a repeatable baseline before adding noise reduction.

### Included
- Select and load an audio file.
- Display basic audio properties such as sample rate, duration, sample count, channel count, peak amplitude, and RMS amplitude.
- Plot and play the original recording.
- Leave the input file unchanged.

### Validation checklist
- [ ] Script runs without errors.
- [ ] Audio file selection works.
- [ ] Waveform plot appears.
- [ ] Audio plays.
- [ ] Original file remains unchanged.

## V0.2.0 — Waveform and frequency-spectrum analysis

**Goal:** Inspect the input signal in time and frequency before filtering.

### Included
- Plot the input waveform.
- Estimate and plot an average single-sided amplitude spectrum.
- Report peak/RMS amplitude and strongest non-DC spectrum bin.
- Play the original audio.
- Do not modify the source file.

### Notes
- A prominent spectral peak is not automatically noise.
- Spectrum magnitude alone is not an SNR measurement.

### Validation checklist
- [ ] Script runs without errors.
- [ ] Waveform and spectrum plots appear.
- [ ] Printed measurements are plausible.
- [ ] Original audio plays.
- [ ] Source file remains unchanged.

## V0.3.0 — Initial Wiener-filter baseline

**Goal:** Introduce offline Wiener noise reduction from a selected noise-only segment.

### Included
- Estimate noise power from overlapping FFT frames.
- Apply a frame-based Wiener-like gain with smoothing.
- Reconstruct with inverse FFT and weighted overlap-add.
- Plot input and processed waveforms/spectra.
- Print input and processed peak/RMS measurements.
- Preview the original and processed audio.
- Do not save or overwrite the source.

### Known limitations
- Noise estimate depends on the selected noise-only section.
- Desired sound can be attenuated if it overlaps the estimated noise spectrum.
- Lower RMS does not, alone, prove better denoising.

## V0.4.0 — Full preprocessing and review workflow

**Goal:** Integrate the preprocessing filters, STFT Wiener processing, and user-controlled review process.

### Included
- Convert multichannel input to mono and remove the mean.
- Apply a third-order Butterworth high-pass filter at 55 Hz.
- Optionally apply manual hum-notch filters at 50 Hz and selected harmonics.
- Estimate the noise profile from the first five seconds by default.
- Apply STFT-based Wiener gain, gain smoothing, a spectral gate, and a minimum gain.
- Apply limited RMS level correction and peak protection.
- Play comparison signals and show Save / Refilter / Cancel.
- Save the current result to a selected output path, with a source-overwrite check.
- Plot final waveforms and spectrograms.

### Known limitations
- The first five seconds should contain little or no wanted speech/music.
- Repeated filtering can progressively damage wanted content.
- Uses Signal Processing Toolbox functions including `butter`, `filtfilt`, `stft`, `istft`, and `spectrogram`.
- This is offline file-based noise reduction.

## V0.5.0 — Configurable noise profile and improved preview workflow

**Goal:** Make the filter easier to apply to recordings with different durations and make Refilter comparisons more meaningful.

### Changes based on the provided MATLAB implementation
- Keep the existing mono conversion, 55 Hz high-pass filter, optional mains-hum notches, STFT Wiener filter, gain smoothing, spectral gate, level control, and clipping protection.
- Ask the user for the duration of the noise-profile prefix rather than requiring a hard-coded five seconds.
- Keep the noise-profile region at the start of the current input; only its duration is configurable.
- On the first pass, play the original recording and then the first processed result.
- After Refilter, play the previous processed signal and then the new result.
- Use the latest processed signal as the input to the next Refilter pass.
- Use a shared playback gain for both signals in each comparison to avoid independent automatic normalization.
- Prevent the Save action from writing directly over the selected source path.
- Continue to support waveform and spectrogram comparisons.

### Requirements and limitations
- The selected prefix should contain noise with little or no wanted speech/music.
- The filter requires Signal Processing Toolbox functions.
- Refiltering may progressively remove desired content; inspect each pass before saving.
- File-based/offline processing only; no live-microphone feature is included.

### Validation checklist
- [ ] Runs on the target MATLAB version.
- [ ] Noise-profile duration dialog accepts valid values and rejects invalid values.
- [ ] First comparison plays original then filtered audio.
- [ ] Refilter comparison plays the previous processed signal then the new result.
- [ ] Refilter operates on the previously filtered signal.
- [ ] Save writes the selected output format successfully.
- [ ] Source file cannot be overwritten through the Save dialog.
- [ ] Cancel exits without saving the current result.
- [ ] Waveform and spectrogram plots appear.

## V0.6.0 — Filter tuning and repeatable quality evaluation (planned)

**Planned goal:** Improve the ability to assess parameter changes.

Potential work:
- Add a clearer way to select the noise-profile start time as well as duration.
- Compare filter parameter settings in a repeatable test.
- Record listening observations and suitable metrics when clean reference audio is available.
- Document artifacts and the trade-off between residual noise and desired-signal preservation.

## V1.0.0 — Stable documented release (planned)

**Planned goal:** Publish a tested release with clear setup instructions, tested examples, and documented validation results.

Mark the project stable only after running and evaluating it in the target MATLAB environment.

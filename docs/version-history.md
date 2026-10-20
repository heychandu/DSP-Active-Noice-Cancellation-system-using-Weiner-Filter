# Version History

## V0.1.0 — Basic audio input

**Goal:** Establish a repeatable baseline before adding noise reduction.

### Included
- Select an audio file through MATLAB's file picker.
- Read audio and sample rate.
- Display duration, sample rate, channel count, and sample count.
- Plot the original waveform.
- Play the original audio.
- Leave the input file unchanged.

### Validation checklist
- [ ] Script runs without errors.
- [ ] File picker opens and accepts a supported audio file.
- [ ] Waveform plot appears.
- [ ] Audio plays and is audible.
- [ ] Original file remains unchanged.

## V0.2.0 — Noise analysis

**Goal:** Inspect the input in time and frequency before introducing a filter.

### Included
- Print sample rate, channel count, duration, sample count, peak amplitude, and RMS amplitude.
- Plot each input channel's waveform.
- Estimate an average single-sided amplitude spectrum using a Hann window and 50% overlapping frames.
- Report the strongest non-DC spectrum bin for each channel.
- Play the original audio for listening reference.
- Leave the source file unchanged; no noise reduction is applied.

### Validation checklist
- [ ] Script runs without errors.
- [ ] File picker accepts a supported audio file.
- [ ] Waveform and frequency-spectrum plots appear.
- [ ] Printed audio properties are plausible.
- [ ] Original audio plays.
- [ ] Original file remains unchanged.

## V0.3.0 — First Wiener noise-reduction filter

**Goal:** Add an offline spectral Wiener-filter baseline using a noise-only section of the input recording.

### Included
- Ask the user for a noise-only segment start/duration and minimum gain.
- Estimate per-channel noise power by averaging windowed FFT-frame power.
- Apply frame-based spectral Wiener gain with frame-to-frame gain smoothing.
- Reconstruct audio using inverse FFT and weighted overlap-add.
- Plot input and filtered waveforms and compare average magnitude spectra.
- Print input/filtered peak and RMS amplitude.
- Offer playback of original then filtered audio.
- Do not save or overwrite the source audio.

### Known limitations
- The estimated noise section must not contain desired speech/music.
- Filtering may remove desired sound when its frequency content overlaps the estimated noise.
- This is file-based noise reduction, not adaptive reference-signal ANC.
- Listen and validate locally before treating this milestone as a tested release.

### Validation checklist
- [ ] MATLAB script runs without errors.
- [ ] Parameter dialog accepts valid noise-only segment values.
- [ ] Invalid/cancelled parameter input exits safely.
- [ ] Input and filtered waveform/spectrum plots appear.
- [ ] Filtered playback can be compared with original playback.
- [ ] Source file remains unchanged.

## V0.4.0 — Preview, Refilter, Save, or Cancel

**Goal:** Let the user listen to every filtered result before deciding what to do with it.

### Included
- Play the current input first, then the filtered result.
- Show the original/current-pass input and filtered waveforms plus spectrum comparisons.
- Display a Save / Refilter / Cancel popup after preview.
- Save only the currently previewed filtered output to a selected WAV path.
- Prevent overwriting the selected source file.
- On Refilter, use the most recently filtered audio as the next pass input rather than returning to the original.
- Re-prompt for filter parameters on each pass.
- Preserve the source audio and prior versions, and keep the input duration unchanged.

### Known limitations
- Multiple filtering passes can remove wanted content or create artifacts.
- The noise-only segment must exclude wanted speech/music.
- Playback and filtering must be validated locally with the project's intended audio.

### Validation checklist
- [ ] Original/current-pass input plays before the filtered preview.
- [ ] Filtered preview plays before the action popup appears.
- [ ] Save writes a new WAV file without overwriting the source.
- [ ] Refilter processes the previously filtered signal.
- [ ] Cancel exits without saving a new output.
- [ ] Repeated passes can be compared and stopped safely.

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

### Not included in V0.1
- Wiener filtering
- Noise estimation
- Processed-audio preview
- Save / Refilter / Cancel workflow
- Live microphone capture
- Quantitative denoising metrics

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

### Notes
- The peak frequency is descriptive only and may be part of the desired signal.
- Spectrum magnitudes are not an SNR measurement and do not guarantee noise identification.
- V0.2 uses standard MATLAB functions and does not intentionally require Signal Processing Toolbox functions.

### Validation checklist
- [ ] Script runs without errors.
- [ ] File picker accepts a supported audio file.
- [ ] Waveform and frequency-spectrum plots appear.
- [ ] Printed audio properties are plausible.
- [ ] Original audio plays.
- [ ] Original file remains unchanged.

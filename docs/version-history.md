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

### Not included yet
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

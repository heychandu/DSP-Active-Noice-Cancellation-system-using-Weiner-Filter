# Current Version

**Current version:** 0.5.0  
**Status:** Current project version  
**Author:** [heychandur](https://github.com/heychandu)

V0.5 is the latest implemented version in this repository. It processes audio files offline using an STFT-based Wiener filter and provides preview, refilter, and save controls.

The current cleanup pass removes redundant explanatory comments from the versioned MATLAB scripts and updates project documentation. It does not intentionally change the DSP algorithm, parameter values, or user workflow.

## Version files

- [V0.1 — Basic audio input](src/v0.1-basic-audio/v01_load_and_play_audio.m)
- [V0.2 — Noise analysis](src/v0.2-noise-analysis/v02_noise_analysis.m)
- [V0.3 — Wiener-filter baseline](src/v0.3-wiener-filter/v03_wiener_noise_reduction.m)
- [V0.4 — Preview, refilter, and save](src/v0.4-preview-refilter-save/v04_preview_refilter_save.m)
- [V0.5 — Current version](src/v0.5-configurable-noise-profile/v05_wiener_noise_reduction.m)

See [docs/version-history.md](docs/version-history.md) for the development history and the planned validation checklist.

## Release note

V0.5 is the latest implemented milestone, but this repository does not claim a formally tested 1.0 release. Run the script in the target MATLAB installation and complete the validation checklist before treating it as a verified release.

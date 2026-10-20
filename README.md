# Active Noise Cancellation Using a Wiener Filter — V0.1

Version 0.1 is the foundation of the MATLAB audio-processing project. It loads a noisy audio file, displays its waveform, reports basic audio properties, and plays the original signal. No noise reduction is applied in this version; this gives us a baseline to compare against later versions.

## Project status

- **Version:** `v0.1.0`
- **Stage:** Basic audio input and playback
- **Language:** MATLAB
- **Input:** WAV, FLAC, MP3, M4A, and other formats supported by your MATLAB installation
- **Output:** Original audio playback and a waveform plot

## Requirements

- MATLAB
- An audio file that you are allowed to use
- GitHub Desktop (for version control; optional until you want to publish)

## Run the program

1. Download or clone this repository.
2. Open MATLAB.
3. Set MATLAB's Current Folder to `src/v0.1-basic-audio`.
4. Run `v01_load_and_play_audio.m`.
5. In the file picker, choose a noisy audio file.
6. Review the waveform and listen to the original audio.

The script does not overwrite or modify your source audio file.

## Repository structure

```text
active-noise-cancellation-wiener/
├── README.md
├── .gitignore
├── LICENSE
├── docs/
│   └── version-history.md
└── src/
    └── v0.1-basic-audio/
        └── v01_load_and_play_audio.m
```

## Version roadmap

| Version | Planned milestone |
|---|---|
| V0.1 | Load, inspect, and play original audio |
| V0.2 | Waveform and frequency-spectrum analysis |
| V0.3 | First Wiener-filter noise-reduction implementation |
| V0.4 | Original/processed preview, then Save / Refilter / Cancel |
| V0.5 | Live microphone processing experiment |
| V1.0 | Tested and documented project release |

**DSP note:** Wiener filtering of a single noisy recording is commonly used for noise reduction, while adaptive ANC typically uses a reference noise signal and an adaptive filter. The README and results for each version should describe the method actually implemented.

## Troubleshooting

- If `audioread` cannot open a file, try a WAV file first.
- If playback is too loud or too quiet, adjust your system volume; this version intentionally does not normalize the audio.
- If MATLAB reports that `audioread` is unavailable, check your MATLAB version and installed toolboxes.
- Large audio files should generally not be committed to Git. Keep test files small or document where permitted sample audio can be obtained.

## Version history

See [`docs/version-history.md`](docs/version-history.md).

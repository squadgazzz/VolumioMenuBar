# VolumioMenuBar

A native macOS menu bar app for controlling [Volumio](https://volumio.com) music servers on your local network.

<!-- ![VolumioMenuBar Screenshot](screenshot.png) -->

## Features

- **Device Discovery** — automatically finds Volumio devices on your network via Bonjour
- **Playback Control** — play, pause, next, previous, seek, and volume
- **Now Playing** — displays track title, artist, album, format, sample rate, bit depth, and album art
- **FusionDSP EQ Presets** — browse and switch EQ presets from the FusionDSP plugin
- **Volatile Service Support** — works with Spotify Connect, Tidal Connect, and other volatile sources
- **Device Management** — open the web UI, reboot, or shut down your device
- **Launch at Login** — optional automatic startup

## Requirements

- macOS 14.0 (Sonoma) or later
- Swift 5.9+ / Xcode 16.0+

## Build

Using the included build script:

```bash
./build.sh
```

This compiles a release build, creates a signed `.app` bundle, and optionally installs it to `/Applications`.

Alternatively, build with SwiftPM directly:

```bash
swift build -c release
```

## Install

Download the latest `.zip` from [Releases](../../releases), extract it, and drag `VolumioMenuBar.app` to your Applications folder.

Or build from source using the instructions above.

## License

[MIT](LICENSE)

# VolumioMenuBar

A native macOS menu bar app for controlling [Volumio](https://volumio.com) music servers on your local network.

<img width="318" height="487" alt="image" src="https://github.com/user-attachments/assets/34726095-4a62-4409-a25d-6f58e2375f18" />

## Features

### Device Discovery
- Automatically discovers Volumio devices on the local network via Bonjour (`_Volumio._tcp`)
- Shows online/offline status for each device with a green/grey indicator
- Remembers the last connected device and auto-reconnects on launch
- Supports both IPv4 and IPv6 networks

### Now Playing
- Displays track title, artist, and album
- Shows album art (with a fallback icon when unavailable)
- Shows audio format details: codec, sample rate, and bit depth (e.g. `flac | 44100 | 24 bit`)

### Playback Controls
- Play, pause, previous, and next buttons
- Works with volatile services like Spotify Connect and Tidal Connect, which require a different resume mechanism than regular Volumio playback
- Seek bar with real-time progress tracking and drag-to-seek
- The seek bar is greyed out and disabled for volatile services (which don't support external seeking) and when playback is stopped

### FusionDSP Integration
- Detects whether the FusionDSP plugin is installed and active
- Enable/disable the DSP effect with a checkbox (without restarting the plugin)
- Browse and switch between EQ presets via a dropdown
- Quick link to open the full FusionDSP settings page in a browser
- Gracefully handles DSP types that don't support presets (EQ3, purecgui)

### Device Management
- Open the Volumio web UI in a browser
- Reboot the device (with a confirmation prompt; auto-reconnects after restart)
- Shut down the device (with a confirmation prompt)

### General
- Runs in the macOS menu bar with a custom VU-meter-style icon — no Dock icon
- Collapsible UI sections (FusionDSP, Device) that remember their expanded/collapsed state
- Optional launch at login
- Real-time state updates via Socket.IO

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

## Discussion

Questions, feedback, and feature requests: [Volumio Community Forum](https://community.volumio.com/t/macos-app-volumiomenubar-a-native-macos-menu-bar-app-for-volumio/75669)

## Support ☕️

If you enjoy VolumioMenuBar, consider [buying me a coffee](https://buymeacoffee.com/squadgazzz)!

## License

[MIT](LICENSE)

# VolumioMenuBar

A native macOS menu bar app for controlling [Volumio](https://volumio.com) music servers on your local network.

<img width="366" height="672" alt="Screenshot 2026-02-26 at 12 22 53 PM" src="https://github.com/user-attachments/assets/e39fa4b4-9b68-4979-bebe-dbcc2ab26278" /><img width="366" height="363" alt="Screenshot 2026-02-26 at 12 23 15 PM" src="https://github.com/user-attachments/assets/fc7e1a6a-00d2-4feb-8e23-9d93908a183c" />


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

### Playback Queue
- Collapsible "Up Next" section showing upcoming tracks from the queue
- Click any track to jump to it
- Automatically hidden for volatile services (Spotify Connect, Tidal Connect) whose queues are managed externally

### FusionDSP Integration
- Detects whether the FusionDSP plugin is installed and active
- Enable/disable the DSP effect with a checkbox (without restarting the plugin)
- Browse and switch between EQ presets via a dropdown
- Quick link to open the full FusionDSP settings page in a browser
- Gracefully handles DSP types that don't support presets (EQ3, purecgui)

### Device Management
- Inline action buttons on the selected device row: open Web UI, reboot, and shut down
- Reboot and shut down require confirmation before executing
- Reboot auto-reconnects after restart

### Settings
- Collapsible Settings section with toggle switches for:
  - Launch at Login
  - Hide inactive devices
  - Show device IP

### General
- Runs in the macOS menu bar with a custom VU-meter-style icon — no Dock icon
- Collapsible UI sections (FusionDSP, Up Next, Settings) that remember their expanded/collapsed state
- Real-time state updates via Socket.IO

## Requirements

- macOS 14.0 (Sonoma) or later
- Swift 5.9+ (Xcode or Command Line Tools)

## Build

Using the included build script:

```bash
./build.sh
```

This builds a universal binary (arm64 + x86_64), creates a signed `.app` bundle, and optionally installs it to `/Applications`.

## Install

Download the latest `.zip` from [Releases](../../releases), extract it, and drag `VolumioMenuBar.app` to your Applications folder.

Or build from source using the instructions above.

## Discussion

Questions, feedback, and feature requests: [Volumio Community Forum](https://community.volumio.com/t/macos-app-volumiomenubar-a-native-macos-menu-bar-app-for-volumio/75669)

## Support ☕️

If you enjoy VolumioMenuBar, consider [buying me a coffee](https://buymeacoffee.com/squadgazzz)!

## License

[MIT](LICENSE)

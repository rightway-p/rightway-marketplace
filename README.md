# rightway-marketplace

Rivay.Park's personal Claude Code plugin marketplace.

## Install

```
/plugin marketplace add rightway-p/rightway-marketplace
/plugin install turn-beep
```

## Plugins

### turn-beep (Windows only)

Plays a sound the moment a Claude Code turn ends, so you can look away and still
know when Claude is done — or when it needs you.

- **Turn ended (`Stop`)** → rising two-tone (880 Hz → 1320 Hz)
- **Needs attention (`Notification`)** → low single tone (660 Hz)

The sound is produced by calling the Win32 `Beep(frequency, duration)` function
in `kernel32.dll` directly via P/Invoke from PowerShell. Hooks run with
`"async": true`, so the beep never blocks Claude Code.

To change the tones, edit `plugins/turn-beep/scripts/turn-beep.ps1`.

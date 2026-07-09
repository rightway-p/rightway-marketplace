# rightway-marketplace

Rivay.Park's personal Claude Code plugin marketplace.

## Install

```
/plugin marketplace add rightway-p/rightway-marketplace
/plugin install turn-beep
```

## Plugins

### turn-beep (Windows only)

Sound and/or a Windows toast the moment a Claude Code turn ends, so you can look
away and still know when Claude is done — or when it needs you.

**Focus-aware by default:**

| Warp state | sound | toast |
|------------|-------|-------|
| **active** (you're looking at it) | ✅ | ❌ |
| **inactive** (you're in another window) | ✅ | ✅ |

Whether Warp is the foreground window is detected with the Win32 API
`GetForegroundWindow`. Sound uses Windows system sounds; toast uses the Windows
Runtime notification, shown under Warp's own identity (`dev.warp.Warp`). Hooks
run with `"async": true`, so nothing blocks Claude Code.

#### Manage it

```
/turn-beep                      # show current settings
/turn-beep active toast on      # also toast while Warp is focused
/turn-beep inactive sound off   # silent (toast only) when away
/turn-beep stop Hand            # change the turn-end sound
/turn-beep stoptext             # pick/enter turn-end toast text (presets offered)
/turn-beep test                 # play/show both now
```

Valid sound names: `Asterisk`, `Beep`, `Exclamation`, `Hand`, `Question`.

Settings live in `~/.claude/turn-beep.json`:

```json
{
  "whenActive":   { "sound": true, "toast": false },
  "whenInactive": { "sound": true, "toast": true },
  "stopSound": "Asterisk",
  "notifySound": "Exclamation",
  "toastTitle": "Claude Code",
  "stopToast": "턴이 끝났어요",
  "notifyToast": "입력이 필요해요"
}
```

The file is created with these defaults the first time the hook runs.

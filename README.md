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

- **Turn ended (`Stop`)** → `stopSound` + toast `stopToast`
- **Needs attention (`Notification`)** → `notifySound` + toast `notifyToast`

Sound uses Windows system sounds (works on laptops with no internal buzzer).
Toast uses the Windows Runtime notification (shows in Action Center). Sound and
toast are **independent toggles**. Hooks run with `"async": true`, so nothing
blocks Claude Code.

#### Manage it

```
/turn-beep                 # show current settings
/turn-beep sound on|off    # sound toggle
/turn-beep toast on|off    # toast toggle
/turn-beep stop Hand       # change the turn-end sound
/turn-beep stoptext        # pick/enter turn-end toast text (presets offered)
/turn-beep title 🤖 Claude # change toast title
/turn-beep test            # play/show both now
```

Valid sound names: `Asterisk`, `Beep`, `Exclamation`, `Hand`, `Question`.

Settings live in `~/.claude/turn-beep.json`:

```json
{
  "sound": true,
  "toast": false,
  "stopSound": "Asterisk",
  "notifySound": "Exclamation",
  "toastTitle": "Claude Code",
  "stopToast": "턴이 끝났어요",
  "notifyToast": "입력이 필요해요"
}
```

The file is created with these defaults the first time the hook runs. Toast
title and body are free text — edit the file directly or use `/turn-beep`.

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

- **Turn ended (`Stop`)** → `stopSound` (default: Asterisk)
- **Needs attention (`Notification`)** → `notifySound` (default: Exclamation)

Sounds are Windows system sounds played through the sound card, so they work on
laptops that have no internal buzzer. Hooks run with `"async": true`, so the
sound never blocks Claude Code.

#### Manage it

```
/turn-beep            # show current settings
/turn-beep off        # mute
/turn-beep on         # unmute
/turn-beep stop Hand  # change the turn-end sound
/turn-beep test       # play both sounds now
```

Valid sound names: `Asterisk`, `Beep`, `Exclamation`, `Hand`, `Question`.

Settings live in `~/.claude/turn-beep.json`:

```json
{
  "enabled": true,
  "stopSound": "Asterisk",
  "notifySound": "Exclamation"
}
```

The file is created with these defaults the first time the hook runs.

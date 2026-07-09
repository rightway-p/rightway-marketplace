# rightway-marketplace

Rivay.Park's personal Claude Code plugin marketplace.

## Install

```
/plugin marketplace add rightway-p/rightway-marketplace
/plugin install turn-beep
```

## Plugins

### turn-beep (Windows + Warp)

Sound and/or a **Warp desktop notification** the moment a Claude Code turn ends,
so you can look away and still know when Claude is done — or when it needs you.

**Focus-aware by default:**

| Warp state | sound | Warp notification |
|------------|-------|-------------------|
| **active** (you're looking at it) | ✅ | ❌ |
| **inactive** (you're in another window) | ✅ | ✅ |

- **Sound** — Windows system sound, played in a detached process so it never blocks Claude.
- **Notification** — an OSC 777 sequence handed to Warp through Claude Code's
  `terminalSequence` hook output (no `/dev/tty`, so it works on Windows). Only
  emitted when running inside Warp; in other terminals you just get the sound.
- Whether Warp is the foreground window is detected with the Win32 API `GetForegroundWindow`.

Requires Claude Code 2.1.141+ and Warp (which advertises `WARP_CLI_AGENT_PROTOCOL_VERSION`).

#### Manage it

```
/turn-beep                       # show current settings
/turn-beep active notify on      # also notify while Warp is focused
/turn-beep inactive sound off    # notification only (silent) when away
/turn-beep turnsound Hand        # change the turn-end sound
/turn-beep turntext              # pick/enter turn-end notification text (presets offered)
/turn-beep test                  # play the sounds now (notification shows on real turns)
```

Valid sound names: `Asterisk`, `Beep`, `Exclamation`, `Hand`, `Question`.

Settings live in `~/.claude/turn-beep.json`:

```json
{
  "whenActive":   { "sound": true, "warpNotification": false },
  "whenInactive": { "sound": true, "warpNotification": true },
  "turnEndSound": "Asterisk",
  "needInputSound": "Exclamation",
  "notificationTitle": "Claude Code",
  "turnEndText": "턴이 끝났어요",
  "needInputText": "입력이 필요해요"
}
```

The file is created with these defaults the first time the hook runs.

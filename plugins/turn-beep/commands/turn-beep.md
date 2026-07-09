---
description: Manage turn-beep — enable/disable the turn-end sound, change which sound plays, or show status.
---

The user ran `/turn-beep $ARGUMENTS`.

The config file is at `~/.claude/turn-beep.json` (Windows: `%USERPROFILE%\.claude\turn-beep.json`). Its keys:

- `enabled` — `true` or `false`
- `stopSound` — sound for turn end
- `notifySound` — sound when Claude needs attention

Valid sound names: `Asterisk`, `Beep`, `Exclamation`, `Hand`, `Question`.

Interpret `$ARGUMENTS` and act:

- `on` / `off` → set `enabled` to `true` / `false`
- (empty) or `status` → read the file and report the current settings; if the file is missing, say defaults are in effect (`enabled: true`, `stopSound: Asterisk`, `notifySound: Exclamation`)
- `stop <SoundName>` → set `stopSound` (validate the name is in the allowed list; if not, list the valid names and stop)
- `notify <SoundName>` → set `notifySound` (same validation)
- `test` → run the sound script directly so the user hears both tones:
  `powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/scripts/turn-beep.ps1" stop` then the same with `notify`

For write actions: read the current file (create it with the defaults above if missing), change ONLY the relevant key, write it back as JSON, and confirm the change in one short line. Never modify keys you weren't asked to change.

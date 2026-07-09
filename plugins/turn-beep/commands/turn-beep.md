---
description: Manage turn-beep — toggle sound/toast, change the sound or toast text, or show status.
---

The user ran `/turn-beep $ARGUMENTS`.

Config file: `~/.claude/turn-beep.json` (Windows: `%USERPROFILE%\.claude\turn-beep.json`). Keys:

- `sound` (true/false) — play a system sound
- `toast` (true/false) — show a Windows toast
- `stopSound` / `notifySound` — one of: `Asterisk`, `Beep`, `Exclamation`, `Hand`, `Question`
- `toastTitle` — toast title text (any string)
- `stopToast` / `notifyToast` — toast body text (any string)

Interpret `$ARGUMENTS` and act:

- (empty) or `status` → read the file and report every current setting. If the file is missing, say defaults are in effect and list them.
- `sound on` / `sound off` → set `sound`
- `toast on` / `toast off` → set `toast`
- `stop <SoundName>` / `notify <SoundName>` → set `stopSound` / `notifySound` (validate against the allowed list; if invalid, list valid names and stop)
- `title <text...>` → set `toastTitle` to the given text
- `stoptext <text...>` / `notifytext <text...>` → set `stopToast` / `notifyToast` to the given text
- `test` → run the sound/toast script for both events so the user sees/hears them:
  `powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/scripts/turn-beep.ps1" stop` then the same with `notify`

If the user runs `title`, `stoptext`, or `notifytext` **without** providing text, offer these presets and let them pick a number or type their own:

Title presets:
1. `Claude Code`
2. `Claude`
3. `🤖 Claude Code`

Turn-end (stop) body presets:
1. `턴이 끝났어요`
2. `작업 완료 ✅`
3. `Claude 응답 완료`
4. `Done`

Needs-attention (notify) body presets:
1. `입력이 필요해요`
2. `확인이 필요합니다 👀`
3. `Claude가 기다리는 중`
4. `Needs input`

For any write action: read the current file (create it with defaults if missing), change ONLY the relevant key(s), write it back as JSON, and confirm the change in one short line. Never modify keys you weren't asked to change.

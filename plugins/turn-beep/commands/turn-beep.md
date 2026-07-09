---
description: Manage turn-beep — focus-aware sound/toast profiles, sounds, and toast text.
---

The user ran `/turn-beep $ARGUMENTS`.

Config file: `~/.claude/turn-beep.json` (Windows: `%USERPROFILE%\.claude\turn-beep.json`). Structure:

- `whenActive`  — `{ "sound": bool, "toast": bool }` applied when Warp IS the foreground window
- `whenInactive` — `{ "sound": bool, "toast": bool }` applied when Warp is NOT focused
- `stopSound` / `notifySound` — one of: `Asterisk`, `Beep`, `Exclamation`, `Hand`, `Question`
- `toastTitle` — toast title (any string)
- `stopToast` / `notifyToast` — toast body (any string)

Defaults: `whenActive` = sound on, toast off; `whenInactive` = sound on, toast on.

Interpret `$ARGUMENTS` and act:

- (empty) or `status` → read the file and report every setting. If missing, report the defaults above.
- `active sound on|off` / `active toast on|off` → set `whenActive.sound` / `whenActive.toast`
- `inactive sound on|off` / `inactive toast on|off` → set `whenInactive.sound` / `whenInactive.toast`
- `stop <SoundName>` / `notify <SoundName>` → set `stopSound` / `notifySound` (validate against the allowed list; if invalid, list valid names and stop)
- `title <text...>` → set `toastTitle`
- `stoptext <text...>` / `notifytext <text...>` → set `stopToast` / `notifyToast`
- `test` → run the script for both events so the user sees/hears the result:
  `powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/scripts/turn-beep.ps1" stop` then the same with `notify`

If `title`, `stoptext`, or `notifytext` is run **without** text, offer these presets and let the user pick a number or type their own:

- Title: 1) `Claude Code`  2) `Claude`  3) `🤖 Claude Code`
- Turn-end body: 1) `턴이 끝났어요`  2) `작업 완료 ✅`  3) `Claude 응답 완료`  4) `Done`
- Needs-attention body: 1) `입력이 필요해요`  2) `확인이 필요합니다 👀`  3) `Claude가 기다리는 중`  4) `Needs input`

For any write action: read the current file (create it with defaults if missing), change ONLY the relevant key(s), write it back as JSON, and confirm the change in one short line. When editing a nested key like `whenActive.toast`, preserve all other keys and the other profile. Never modify keys you weren't asked to change.

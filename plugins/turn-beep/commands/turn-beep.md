---
description: Manage turn-beep — focus-aware sound + Warp notification profiles, sounds, and notification text.
---

The user ran `/turn-beep $ARGUMENTS`.

Config file: `~/.claude/turn-beep.json` (Windows: `%USERPROFILE%\.claude\turn-beep.json`). Structure:

- `whenActive`   — `{ "sound": bool, "warpNotification": bool }` when Warp IS the foreground window
- `whenInactive` — `{ "sound": bool, "warpNotification": bool }` when Warp is NOT focused
- `turnEndSound` / `needInputSound` — system sound name, one of: `Asterisk`, `Beep`, `Exclamation`, `Hand`, `Question`
- `notificationTitle` — Warp notification title (any string)
- `turnEndText` / `needInputText` — Warp notification body (any string)

Defaults: `whenActive` = sound on, warpNotification off; `whenInactive` = sound on, warpNotification on.

Interpret `$ARGUMENTS` and act:

- (empty) or `status` → read the file and report every setting. If missing, report the defaults above.
- `active sound on|off` / `active notify on|off` → set `whenActive.sound` / `whenActive.warpNotification`
- `inactive sound on|off` / `inactive notify on|off` → set `whenInactive.sound` / `whenInactive.warpNotification`
- `turnsound <SoundName>` / `inputsound <SoundName>` → set `turnEndSound` / `needInputSound` (validate against the allowed list; if invalid, list valid names and stop)
- `title <text...>` → set `notificationTitle`
- `turntext <text...>` / `inputtext <text...>` → set `turnEndText` / `needInputText`
- `test` → play the sound now (both events):
  `powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/scripts/turn-beep.ps1" stop` then the same with `notify`.
  Note: `test` only exercises the SOUND. The Warp notification is delivered through the hook's `terminalSequence` output, which only reaches Warp on a real turn-end / Notification event — so verify the notification by letting a real turn finish.

If `title`, `turntext`, or `inputtext` is run **without** text, offer presets and let the user pick a number or type their own:

- Title: 1) `Claude Code`  2) `Claude`  3) `🤖 Claude Code`
- Turn-end body: 1) `턴이 끝났어요`  2) `작업 완료 ✅`  3) `Claude 응답 완료`  4) `Done`
- Needs-input body: 1) `입력이 필요해요`  2) `확인이 필요합니다 👀`  3) `Claude가 기다리는 중`  4) `Needs input`

For any write action: read the current file (create with defaults if missing), change ONLY the relevant key(s), preserve the other profile and all other keys, write it back as JSON, and confirm the change in one short line.

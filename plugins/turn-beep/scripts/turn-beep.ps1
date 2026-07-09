<#
  turn-beep.ps1 — Claude Code turn-end / notification sound.

  Reads config from ~/.claude/turn-beep.json and plays a Windows system
  sound. If the config is missing it is created with defaults. If
  "enabled" is false, the script exits silently.

  Usage:
    turn-beep.ps1 stop     # turn ended  -> plays stopSound
    turn-beep.ps1 notify   # needs input -> plays notifySound

  Valid sound names: Asterisk, Beep, Exclamation, Hand, Question
#>
param([string]$Event = "stop")

$configPath = Join-Path $env:USERPROFILE ".claude\turn-beep.json"

$cfg = $null
if (Test-Path $configPath) {
    try { $cfg = Get-Content $configPath -Raw | ConvertFrom-Json } catch { $cfg = $null }
}
if (-not $cfg) {
    $cfg = [pscustomobject]@{
        enabled     = $true
        stopSound   = "Asterisk"
        notifySound = "Exclamation"
    }
    $cfg | ConvertTo-Json | Set-Content -Path $configPath -Encoding UTF8
}

# Kill switch: managed via /turn-beep on|off
if (-not $cfg.enabled) { return }

$name = if ($Event -eq "notify") { $cfg.notifySound } else { $cfg.stopSound }

$sound = switch ($name) {
    "Beep"        { [System.Media.SystemSounds]::Beep }
    "Exclamation" { [System.Media.SystemSounds]::Exclamation }
    "Hand"        { [System.Media.SystemSounds]::Hand }
    "Question"    { [System.Media.SystemSounds]::Question }
    default       { [System.Media.SystemSounds]::Asterisk }
}

# .Play() is asynchronous; keep the process alive briefly so the
# system sound isn't cut off when PowerShell exits.
$sound.Play()
Start-Sleep -Milliseconds 800

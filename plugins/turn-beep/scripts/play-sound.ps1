<#
  play-sound.ps1 — plays a single Windows system sound, then exits.
  Launched detached by turn-beep.ps1 so the hook itself never blocks.
#>
param([string]$Name = "Asterisk")

$sound = switch ($Name) {
    "Beep"        { [System.Media.SystemSounds]::Beep }
    "Exclamation" { [System.Media.SystemSounds]::Exclamation }
    "Hand"        { [System.Media.SystemSounds]::Hand }
    "Question"    { [System.Media.SystemSounds]::Question }
    default       { [System.Media.SystemSounds]::Asterisk }
}

# .Play() is asynchronous; keep this process alive briefly so it isn't cut off.
$sound.Play()
Start-Sleep -Milliseconds 800

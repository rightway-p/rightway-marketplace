<#
  turn-beep.ps1 — Claude Code turn-end / notification sound + toast.

  Reads config from ~/.claude/turn-beep.json:
    sound       : true/false  -> play a Windows system sound
    toast       : true/false  -> show a Windows toast notification
    stopSound   : sound name for turn end
    notifySound : sound name when Claude needs attention
    toastTitle  : toast title text
    stopToast   : toast body for turn end
    notifyToast : toast body when Claude needs attention

  If the config is missing it is created with defaults. Sound and toast
  are independent toggles.

  Usage:
    turn-beep.ps1 stop     # turn ended
    turn-beep.ps1 notify   # needs input

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
        sound       = $true
        toast       = $false
        stopSound   = "Asterisk"
        notifySound = "Exclamation"
        toastTitle  = "Claude Code"
        stopToast   = "턴이 끝났어요"
        notifyToast = "입력이 필요해요"
    }
    $cfg | ConvertTo-Json | Set-Content -Path $configPath -Encoding UTF8
}

$props = $cfg.PSObject.Properties.Name
function Get-Cfg($key, $fallback) {
    if ($props -contains $key) { return $cfg.$key } else { return $fallback }
}

# Back-compat: v0.2.0 used "enabled" for the sound toggle.
$soundOn = if ($props -contains 'sound')   { [bool]$cfg.sound }
           elseif ($props -contains 'enabled') { [bool]$cfg.enabled }
           else { $true }
$toastOn = [bool](Get-Cfg 'toast' $false)

$isNotify = ($Event -eq "notify")

# --- Toast (Windows Runtime notification). Wrapped so a failure never breaks the hook. ---
if ($toastOn) {
    try {
        $title = [string](Get-Cfg 'toastTitle' "Claude Code")
        $body  = if ($isNotify) { [string](Get-Cfg 'notifyToast' "입력이 필요해요") }
                 else           { [string](Get-Cfg 'stopToast'   "턴이 끝났어요") }

        [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null
        [Windows.UI.Notifications.ToastNotification, Windows.UI.Notifications, ContentType = WindowsRuntime]        | Out-Null
        [Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime]         | Out-Null

        $template = [Windows.UI.Notifications.ToastNotificationManager]::GetTemplateContent([Windows.UI.Notifications.ToastTemplateType]::ToastText02)
        $texts = $template.GetElementsByTagName("text")
        $texts.Item(0).AppendChild($template.CreateTextNode($title)) | Out-Null
        $texts.Item(1).AppendChild($template.CreateTextNode($body))  | Out-Null

        $appId = '{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\WindowsPowerShell\v1.0\powershell.exe'
        $toast = [Windows.UI.Notifications.ToastNotification]::new($template)
        [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($appId).Show($toast)
    } catch { }
}

# --- Sound (Windows system sound) ---
if ($soundOn) {
    $name = if ($isNotify) { Get-Cfg 'notifySound' "Exclamation" } else { Get-Cfg 'stopSound' "Asterisk" }
    $sound = switch ($name) {
        "Beep"        { [System.Media.SystemSounds]::Beep }
        "Exclamation" { [System.Media.SystemSounds]::Exclamation }
        "Hand"        { [System.Media.SystemSounds]::Hand }
        "Question"    { [System.Media.SystemSounds]::Question }
        default       { [System.Media.SystemSounds]::Asterisk }
    }
    # .Play() is asynchronous; keep the process alive briefly so it isn't cut off.
    $sound.Play()
    Start-Sleep -Milliseconds 800
}

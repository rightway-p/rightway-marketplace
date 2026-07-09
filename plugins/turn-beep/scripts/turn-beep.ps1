<#
  turn-beep.ps1 — Claude Code turn-end / notification feedback.

  Focus-aware: whether Warp is the foreground window decides which profile
  (whenActive / whenInactive) applies. Detected via the Win32 API
  GetForegroundWindow + GetWindowThreadProcessId.

  Config ~/.claude/turn-beep.json:
    whenActive   : { sound, toast }  applied when Warp IS focused
    whenInactive : { sound, toast }  applied when Warp is NOT focused
    stopSound / notifySound : system sound name per event
    toastTitle / stopToast / notifyToast : toast text

  Defaults: Warp active -> sound only; Warp inactive -> sound + toast.
  Toast is shown under Warp's identity (AUMID dev.warp.Warp).

  Usage:
    turn-beep.ps1 stop     # turn ended
    turn-beep.ps1 notify   # needs input

  Valid sound names: Asterisk, Beep, Exclamation, Hand, Question
#>
param([string]$Event = "stop")

$configPath = Join-Path $env:USERPROFILE ".claude\turn-beep.json"

function New-DefaultConfig {
    [pscustomobject]@{
        whenActive   = [pscustomobject]@{ sound = $true; toast = $false }
        whenInactive = [pscustomobject]@{ sound = $true; toast = $true  }
        stopSound    = "Asterisk"
        notifySound  = "Exclamation"
        toastTitle   = "Claude Code"
        stopToast    = "턴이 끝났어요"
        notifyToast  = "입력이 필요해요"
    }
}

$cfg = $null
if (Test-Path $configPath) {
    try { $cfg = Get-Content $configPath -Raw | ConvertFrom-Json } catch { $cfg = $null }
}
if (-not $cfg) {
    $cfg = New-DefaultConfig
    $cfg | ConvertTo-Json | Set-Content -Path $configPath -Encoding UTF8
}

$props = $cfg.PSObject.Properties.Name
function Get-Cfg($key, $fallback) { if ($props -contains $key) { $cfg.$key } else { $fallback } }

# --- Is Warp the foreground window? (Win32 API) ---
$warpActive = $false
try {
    if (-not ('TurnBeep.Fg' -as [type])) {
        Add-Type -Namespace TurnBeep -Name Fg -MemberDefinition @'
[System.Runtime.InteropServices.DllImport("user32.dll")]
public static extern System.IntPtr GetForegroundWindow();
[System.Runtime.InteropServices.DllImport("user32.dll")]
public static extern int GetWindowThreadProcessId(System.IntPtr hWnd, out int pid);
'@
    }
    $hwnd = [TurnBeep.Fg]::GetForegroundWindow()
    $fgPid = 0
    [TurnBeep.Fg]::GetWindowThreadProcessId($hwnd, [ref]$fgPid) | Out-Null
    $fgProc = (Get-Process -Id $fgPid -ErrorAction SilentlyContinue).ProcessName
    $warpActive = ($fgProc -eq 'warp')
} catch { $warpActive = $false }

# Pick the profile for the current focus state.
$mode = if ($warpActive) { Get-Cfg 'whenActive' $null } else { Get-Cfg 'whenInactive' $null }
if ($mode) {
    $soundOn = [bool]$mode.sound
    $toastOn = [bool]$mode.toast
} else {
    # Back-compat with flat v0.3 config (sound/toast at top level).
    $soundOn = [bool](Get-Cfg 'sound' $true)
    $toastOn = if ($warpActive) { $false } else { [bool](Get-Cfg 'toast' $true) }
}

$isNotify = ($Event -eq "notify")

# --- Toast (shown as Warp). Wrapped so a failure never breaks the hook. ---
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

        $toast = [Windows.UI.Notifications.ToastNotification]::new($template)
        [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier('dev.warp.Warp').Show($toast)
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

<#
  turn-beep.ps1 — Claude Code turn-end / needs-input feedback dispatcher.

  Runs SYNCHRONOUSLY as a Stop / Notification hook. It:
    1. reads the hook JSON on stdin (only to honor stop_hook_active),
    2. detects whether Warp is the foreground window (Win32 GetForegroundWindow),
    3. picks the whenActive / whenInactive profile from ~/.claude/turn-beep.json,
    4. plays a system sound in a DETACHED process (so the hook returns fast), and
    5. if enabled + running in Warp, emits an OSC 777 desktop-notification
       escape sequence via Claude Code's `terminalSequence` hook-output field
       (no /dev/tty needed -> works on Windows).

  Usage:  turn-beep.ps1 stop   |   turn-beep.ps1 notify
#>
param([string]$Event = "stop")

$ErrorActionPreference = 'SilentlyContinue'
try { [Console]::OutputEncoding = New-Object System.Text.UTF8Encoding($false) } catch {}

# --- stop_hook_active guard. Only read stdin when it is actually piped
#     (so a manual `test` run does not block waiting for EOF). ---
try {
    if ([Console]::IsInputRedirected) {
        $raw = [Console]::In.ReadToEnd()
        if ($raw -and ($raw | ConvertFrom-Json).stop_hook_active) { exit 0 }
    }
} catch {}

$configPath = Join-Path $env:USERPROFILE ".claude\turn-beep.json"

function New-DefaultConfig {
    [pscustomobject]@{
        whenActive        = [pscustomobject]@{ sound = $true; warpNotification = $false }
        whenInactive      = [pscustomobject]@{ sound = $true; warpNotification = $true  }
        turnEndSound      = "Asterisk"
        needInputSound    = "Exclamation"
        notificationTitle = "Claude Code"
        turnEndText       = "턴이 끝났어요"
        needInputText     = "입력이 필요해요"
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
function Get-Cfg($key, $fallback) {
    if ($cfg.PSObject.Properties.Name -contains $key) { $cfg.$key } else { $fallback }
}

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
    $warpActive = ((Get-Process -Id $fgPid -ErrorAction SilentlyContinue).ProcessName -eq 'warp')
} catch { $warpActive = $false }

$mode = if ($warpActive) { Get-Cfg 'whenActive' $null } else { Get-Cfg 'whenInactive' $null }
if ($mode) {
    $soundOn  = [bool]$mode.sound
    $notifyOn = [bool]$mode.warpNotification
} else {
    $soundOn  = $true
    $notifyOn = (-not $warpActive)
}

$isNotify = ($Event -eq 'notify')

# --- Sound: launch detached so the (synchronous) hook returns immediately ---
if ($soundOn) {
    $sname = if ($isNotify) { Get-Cfg 'needInputSound' "Exclamation" } else { Get-Cfg 'turnEndSound' "Asterisk" }
    if ($sname -notin @('Asterisk','Beep','Exclamation','Hand','Question')) { $sname = 'Asterisk' }
    Start-Process -FilePath 'powershell' -WindowStyle Hidden -ArgumentList @(
        '-NoProfile','-ExecutionPolicy','Bypass','-File',
        (Join-Path $PSScriptRoot 'play-sound.ps1'), $sname
    ) | Out-Null
}

# --- Warp notification via OSC 777 through the terminalSequence hook output ---
if ($notifyOn -and $env:TERM_PROGRAM -eq 'WarpTerminal') {
    function Clean-Text($s) {
        $t = ([string]$s) -replace '[;\r\n]', ' '
        -join ($t.ToCharArray() | Where-Object { $c = [int]$_; $c -ne 27 -and $c -ne 7 })
    }
    $title = Clean-Text (Get-Cfg 'notificationTitle' "Claude Code")
    $body  = if ($isNotify) { Clean-Text (Get-Cfg 'needInputText' "입력이 필요해요") }
             else           { Clean-Text (Get-Cfg 'turnEndText'   "턴이 끝났어요") }

    $esc = [char]27; $bel = [char]7
    $seq = "$esc]777;notify;$title;$body$bel"

    # Emit PURE-ASCII JSON: escape every non-ASCII / control char to \uXXXX so the
    # bytes are identical in any encoding (Korean survives the pipe to Claude Code,
    # which JSON-parses it back and forwards the real chars to Warp).
    function ConvertTo-AsciiJsonString($s) {
        $sb = New-Object System.Text.StringBuilder
        foreach ($ch in $s.ToCharArray()) {
            $code = [int]$ch
            if     ($ch -eq '"')  { [void]$sb.Append('\"') }
            elseif ($ch -eq '\')  { [void]$sb.Append('\\') }
            elseif ($code -lt 32 -or $code -gt 126) { [void]$sb.Append(('\u{0:x4}' -f $code)) }
            else   { [void]$sb.Append($ch) }
        }
        $sb.ToString()
    }
    $out = '{"terminalSequence":"' + (ConvertTo-AsciiJsonString $seq) + '","suppressOutput":true}'
    [Console]::Out.Write($out)
}

exit 0

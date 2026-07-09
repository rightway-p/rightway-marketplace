<#
  turn-beep.ps1 — Claude Code turn-end / notification sound via WinAPI.

  Calls kernel32.dll Beep(frequency, duration) directly through P/Invoke,
  so this is a genuine Win32 API call (not just .NET SystemSounds).

  Usage:
    turn-beep.ps1 stop     # turn ended  -> rising two-tone
    turn-beep.ps1 notify   # needs input -> low single tone
#>
param([string]$Event = "stop")

# Declare the Win32 Beep function once per process.
Add-Type -Name Win -Namespace Native -MemberDefinition @'
[System.Runtime.InteropServices.DllImport("kernel32.dll")]
public static extern bool Beep(uint dwFreq, uint dwDuration);
'@

switch ($Event) {
    "notify" {
        # Claude wants your attention: low, calm single tone.
        [Native.Win]::Beep(660, 250) | Out-Null
    }
    default {
        # Turn ended: rising two-tone = "done".
        [Native.Win]::Beep(880, 120)  | Out-Null
        [Native.Win]::Beep(1320, 150) | Out-Null
    }
}

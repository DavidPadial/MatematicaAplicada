# ==============================================================================
# DESACTIVAR PROXY TOTALMENTE (CONEXIÓN DIRECTA)
# ==============================================================================

$wininetPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings"

Set-ItemProperty -Path $wininetPath -Name "ProxyEnable" -Value 0 -ErrorAction SilentlyContinue
Set-ItemProperty -Path $wininetPath -Name "ProxyServer" -Value "" -ErrorAction SilentlyContinue
Set-ItemProperty -Path $wininetPath -Name "ProxyOverride" -Value "" -ErrorAction SilentlyContinue

$wininet = Add-Type -MemberDefinition @"
[DllImport("wininet.dll", SetLastError = true, CharSet = CharSet.Auto)]
public static extern bool InternetSetOption(IntPtr hInternet, int dwOption, IntPtr lpBuffer, int dwBufferLength);
"@ -Name "WinInetProxyOff" -Namespace "Win32" -PassThru -ErrorAction SilentlyContinue

$wininet::InternetSetOption([IntPtr]::Zero, 39, [IntPtr]::Zero, 0) | Out-Null
$wininet::InternetSetOption([IntPtr]::Zero, 37, [IntPtr]::Zero, 0) | Out-Null

Write-Host "Proxy desactivado por completo." -ForegroundColor Green
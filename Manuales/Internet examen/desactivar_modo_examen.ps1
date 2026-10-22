# ==============================================================================
# DESACTIVAR MODO EXAMEN / PROXY HABITUAL
# ==============================================================================

$wininetPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings"

# 1. Activar el uso de servidor proxy habitual
Set-ItemProperty -Path $wininetPath -Name "ProxyEnable" -Value 1 -ErrorAction SilentlyContinue

# 2. Definir la dirección del proxy y puerto habitual
Set-ItemProperty -Path $wininetPath -Name "ProxyServer" -Value "proxy.satd.uma.es:3128" -ErrorAction SilentlyContinue

# 3. Definir excepciones (*.uma.es y conexiones locales)
Set-ItemProperty -Path $wininetPath -Name "ProxyOverride" -Value "*.uma.es;<local>" -ErrorAction SilentlyContinue

# 4. Notificar a Windows (WinINet) para aplicar los cambios de inmediato en memoria RAM
$wininet = Add-Type -MemberDefinition @"
[DllImport("wininet.dll", SetLastError = true, CharSet = CharSet.Auto)]
public static extern bool InternetSetOption(IntPtr hInternet, int dwOption, IntPtr lpBuffer, int dwBufferLength);
"@ -Name "WinInetProxyDesactivar" -Namespace "Win32" -PassThru -ErrorAction SilentlyContinue

$wininet::InternetSetOption([IntPtr]::Zero, 39, [IntPtr]::Zero, 0) | Out-Null # INTERNET_OPTION_SETTINGS_CHANGED
$wininet::InternetSetOption([IntPtr]::Zero, 37, [IntPtr]::Zero, 0) | Out-Null # INTERNET_OPTION_REFRESH

Write-Host "Modo examen DESHABILITADO. Restablecido Proxy Habitual." -ForegroundColor Yellow
# 1. Configurar la ruta del archivo PAC local en el Registro de Windows (HKCU - Sin permisos de administrador)
$pacPath = "C:\Windows\mat\proxyexamen\industriales\proxy_industriales.pac"
$pacUrl = "file:///" + $pacPath.Replace('\', '/')

$regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings"
Set-ItemProperty -Path $regPath -Name "AutoConfigURL" -Value $pacUrl
Set-ItemProperty -Path $regPath -Name "ProxyEnable" -Value 0

# 2. Refrescar la red en memoria (WinINet) de inmediato
$wininet = Add-Type -MemberDefinition @"
[DllImport("wininet.dll", SetLastError = true, CharSet = CharSet.Auto)]
public static extern bool InternetSetOption(IntPtr hInternet, int dwOption, IntPtr lpBuffer, int dwBufferLength);
"@ -Name "WinInetProxyActivarMatap" -Namespace "Win32" -PassThru -ErrorAction SilentlyContinue

$null = $wininet::InternetSetOption([IntPtr]::Zero, 39, [IntPtr]::Zero, 0)
$null = $wininet::InternetSetOption([IntPtr]::Zero, 37, [IntPtr]::Zero, 0)







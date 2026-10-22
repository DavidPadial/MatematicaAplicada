# ==============================================================================
# ACTIVAR MODO EXAMEN (PARA USUARIO ESTÁNDAR - Matap)
# ==============================================================================

# 1. Configurar Proxy del Sistema (WinINet) en HKCU
$wininetPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings"

Set-ItemProperty -Path $wininetPath -Name "ProxyEnable" -Value 1 -ErrorAction SilentlyContinue
Set-ItemProperty -Path $wininetPath -Name "ProxyServer" -Value "proxy.matapexamen.uma.es:3128" -ErrorAction SilentlyContinue

$excepciones = "*.uma.es;uma.es;150.214.*;*.r-project.org;*.scilab.org;*.mathworks.com;*.sentinelone.net;<local>"
Set-ItemProperty -Path $wininetPath -Name "ProxyOverride" -Value $excepciones -ErrorAction SilentlyContinue

# 2. Refrescar la red en memoria (WinINet) de inmediato
$wininet = Add-Type -MemberDefinition @"
[DllImport("wininet.dll", SetLastError = true, CharSet = CharSet.Auto)]
public static extern bool InternetSetOption(IntPtr hInternet, int dwOption, IntPtr lpBuffer, int dwBufferLength);
"@ -Name "WinInetProxyActivarMatap" -Namespace "Win32" -PassThru -ErrorAction SilentlyContinue

$null = $wininet::InternetSetOption([IntPtr]::Zero, 39, [IntPtr]::Zero, 0)
$null = $wininet::InternetSetOption([IntPtr]::Zero, 37, [IntPtr]::Zero, 0)

# 3. Cerrar Chrome y Edge para destruir conexiones en caché
Stop-Process -Name "chrome", "msedge" -Force -ErrorAction SilentlyContinue

# 4. Abrir Mozilla Firefox
$firefoxPath = "C:\Program Files\Mozilla Firefox\firefox.exe"
if (Test-Path $firefoxPath) {
    Start-Process -FilePath $firefoxPath
}

# 5. Pausa de 3 segundos para dar tiempo a que Firefox se abra y se renderice en pantalla
Start-Sleep -Seconds 3

# 6. Desplegar ventana gráfica de CMD por encima de Firefox
$cmdComandos = '/c "chcp 65001 > nul & color 0C & cls & echo ============================================================================== & echo                        MODO EXAMEN ACTIVADO & echo ============================================================================== & echo. & echo Google no te va a salvar hoy. & echo Todo acceso a Internet ha sido neutralizado. Cualquier intento de evasión quedará registrado. & echo. & echo ============================================================================== & echo Presiona ENTER para aceptar las condiciones del examen... & echo ============================================================================== & pause > nul"'

Start-Process -FilePath "cmd.exe" -ArgumentList $cmdComandos

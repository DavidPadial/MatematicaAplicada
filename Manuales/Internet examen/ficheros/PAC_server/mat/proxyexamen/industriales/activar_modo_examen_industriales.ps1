# 1. Configurar la ruta del archivo PAC local en el Registro de Windows (HKCU - Sin permisos de administrador)
$pacPath = "C:\Windows\mat\proxyexamen\industriales\configuracionproxyexamenindustriales.pac"
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

# 3. Cerrar Chrome y Edge para destruir conexiones en caché
Stop-Process -Name "chrome", "msedge" -Force -ErrorAction SilentlyContinue

# 4. Abrir Mozilla Firefox
$firefoxPath = "C:\Program Files\Mozilla Firefox\firefox.exe"
if (Test-Path $firefoxPath) {
    Start-Process -FilePath $firefoxPath
}

# 5. Pausa de 3 segundos para dar tiempo a que Firefox se abra y se renderice en pantalla
Start-Sleep -Seconds 3

# 6. Desplegar ventana gráfica de CMD por encima de Firefox (Bilingüe)
#$cmdComandos = '/c "color 0C & cls & echo ============================================================================== & echo                    MODO EXAMEN ACTIVADO / EXAM MODE ACTIVATED & echo ============================================================================== & echo. & echo Google no te va a salvar hoy. / Google won''t save you today. & echo Todo acceso a Internet ha sido neutralizado. Cualquier intento de evasion & echo quedara registrado. Cualquier incumplimiento podra afectar a la calificacion & echo del examen. & echo. & echo All Internet access has been neutralized. Any attempt to bypass this & echo will be logged. Any non-compliance may affect your exam grade. & echo. & echo ============================================================================== & echo Presiona ENTER para aceptar las condiciones del examen... & echo Press ENTER to accept the exam conditions... & echo ============================================================================== & pause > nul"'
$cmdComandos = '/k "mode con cols=120 lines=35 & color 0C & cls & echo ======================================================================================================================== & echo                                                        ENTORNO EVALUABLE / EVALUATION ENVIRONMENT & echo ======================================================================================================================== & echo. & echo MODO EXAMEN ACTIVADO / EXAM MODE ACTIVATED & echo. & echo [ES] El entorno de red ha sido configurado para el desarrollo de esta prueba. & echo      El acceso general a Internet se encuentra restringido exclusivamente a & echo      los dominios y recursos autorizados. & echo. & echo      Cualquier intento de evasion de las restricciones o incumplimiento de & echo      la normativa afectara a la calificacion del examen y podra acarrear & echo      la anulacion inmediata de la prueba. & echo. & echo [EN] The network environment has been configured for this evaluation. & echo      General Internet access is strictly restricted to authorized resources. & echo. & echo      Any attempt to bypass network controls or non-compliance with the rules & echo      will affect your final grade and may result in immediate test annulment. & echo. & echo ======================================================================================================================== & echo Presione ENTER para aceptar las condiciones y comenzar la prueba... & echo Press ENTER to accept the conditions and begin the exam... & echo ======================================================================================================================== & set /p dummy= & pause > nul & exit"'
#Start-Process -FilePath "cmd.exe" -ArgumentList $cmdComandos


# Iniciar proceso de CMD en modo maximizado
$cmdProc = Start-Process -FilePath "cmd.exe" -ArgumentList $cmdComandos -WindowStyle Maximized -PassThru

# Dar tiempo a que la ventana se cree y forzar el foco sobre ella
$wshell = New-Object -ComObject WScript.Shell
Start-Sleep -Milliseconds 600
$wshell.AppActivate($cmdProc.Id)

# Enviar Alt + Enter para activar la pantalla completa
Start-Sleep -Milliseconds 200
$wshell.SendKeys('%{ENTER}')
# Manual Técnico de Configuración y Control de Red en Aulas (MATAP - UMA)

Este documento contiene la especificación técnica, scripts de automatización e instrucciones de despliegue para la gestión de conectividad, proxy y personalización del entorno de trabajo en las aulas de laboratorio del Departamento de Matemática Aplicada (MATAP) de la Universidad de Málaga (UMA).

---

## 📋 Tabla de Contenidos

1. [Arquitectura e Infraestructura de Red](#1-arquitectura-e-infraestructura-de-red)
2. [Configuración de Directivas de Grupo (GPO)](#2-configuración-de-directivas-de-grupo-gpo)
3. [Scripts de Gestión de Proxy (PowerShell)](#3-scripts-de-gestión-de-proxy-powershell)
   - [Activar Modo Examen](#31-activar-modo-examen-activar_modo_examenps1)
   - [Desactivar Modo Examen / Proxy Habitual](#32-desactivar-modo-examen--proxy-habitual-desactivar_modo_examenps1)
   - [Desactivar Proxy Totalmente](#33-desactivar-proxy-totalmente-desactivar_proxyps1)
4. [Script de Inicio Unificado (`inicio.bat`)](#4-script-de-inicio-unificado-iniciobat)
5. [Cambio Silencioso de Fondo de Pantalla (`cambiar_fondo.ps1`)](#5-cambio-silencioso-de-fondo-de-pantalla-cambiar_fondops1)
6. [Autoconfiguración de Mozilla Firefox (AutoConfig)](#6-autoconfiguración-de-mozilla-firefox-autoconfig)
   - [`local-settings.js`](#local-settingsjs)
   - [`mozilla.cfg`](#mozillacfg)
7. [Despliegue Masivo con Veyon Master](#7-despliegue-masivo-con-veyon-master)

---

## 1. Arquitectura e Infraestructura de Red

En el entorno de laboratorios de docencia se utilizan tres estados de conexión principales:

* **Modo Examen (`proxy.matapexamen.uma.es:3128`):** Restringe el tráfico general de Internet. Solo permite la navegación por subdominios de la UMA (`*.uma.es`), rangos corporativos de RedIRIS (`150.214.*`), servidores de licencias y repositorios de software científico autorizados (MATLAB, R/CRAN, Scilab, Octave).
* **Modo Habitual / Docente (`proxy.satd.uma.es:3128`):** Servidor proxy institucional para clases y uso habitual en el campus.
* **Sin Proxy (Conexión Directa):** Restablece la comunicación directa a través de la interfaz local sin intermediarios.

### Subredes y Excepciones Clave

* **`150.214.*`:** Bloque de direcciones IP públicas de la UMA (RedIRIS). Su inclusión en la lista de excepciones (`ProxyOverride`) garantiza que la validación de licencias concurrentes por sockets TCP (ej. FlexLM de MATLAB) funcione sin ser desviada al proxy HTTP.
* **`<local>`:** Garantiza la comunicación directa con recursos e impresoras dentro de la LAN de la facultad.

---

## 2. Configuración de Directivas de Grupo (GPO)

Para evitar que los usuarios eludan el proxy o alteren el entorno durante las pruebas, se deben configurar las siguientes políticas en `gpedit.msc`:

| Directiva | Ruta en `gpedit.msc` | Estado Recomendado | Propósito |
| :--- | :--- | :--- | :--- |
| **Prohibir acceso a Configuración y Panel de Control** | `Configuración de usuario > Plantillas administrativas > Panel de control` | **Habilitada** | Bloquea la apertura gráfica de `control.exe` y `systemsettings.exe`. |
| **Impedir acceso a herramientas de edición del Registro** | `Configuración de usuario > Plantillas administrativas > Sistema` | **Habilitada** (Opción *"¿Deshabilitar ejecución silenciosa?"* = **No**) | Bloquea `regedit.exe` para el alumno, pero permite que los scripts `.bat` ejecuten comandos `reg add` silenciosamente. |

> **Nota técnica:** Se recomienda utilizar scripts en **PowerShell (`.ps1`)** para la manipulación del registro. PowerShell interactúa con la API nativa del sistema operativo (`Set-ItemProperty`), lo que le permite escribir en `HKCU` sin importar el estado de bloqueo de `regedit.exe` o `reg.exe`.

---

## 3. Scripts de Gestión de Proxy (PowerShell)

### 3.1. Activar Modo Examen (`activar_modo_examen.ps1`)

```powershell
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
```

---

### 3.2. Desactivar Modo Examen / Proxy Habitual (`desactivar_modo_examen.ps1`)

```powershell
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
```

---

### 3.3. Desactivar Proxy Totalmente (`desactivar_proxy.ps1`)

```powershell
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
```

---

## 4. Script de Inicio Unificado (`inicio.bat`)

Ubicación: `C:\Windows\Mat\inicio.bat`

Este script consolida el saneamiento del entorno, la copia de configuraciones corporativas de Firefox, el cambio de fondo de pantalla, la disposición de los iconos de escritorio y el inicio limpio de Firefox.

```batch
@echo off
:: ==============================================================================
:: SCRIPT UNIFICADO DE INICIO (C:\Windows\Mat\inicio.bat)
:: ==============================================================================

:: 1. CERRAR NAVEGADORES CHROMIUM (Destruye conexiones en caché)
taskkill /F /IM chrome.exe /T >nul 2>&1
taskkill /F /IM msedge.exe /T >nul 2>&1

:: 2. APLICAR CONFIGURACIÓN DE FIREFOX (AutoConfig)
del /Q /F "C:\Users\%USERNAME%\AppData\Roaming\Mozilla\Firefox\Profiles\*\prefs-*.*" >nul 2>&1
copy /Y "C:\Windows\Mat\mozilla.cfg" "C:\Program Files\Mozilla Firefox\" >nul 2>&1
copy /Y "C:\Windows\Mat\local-settings.js" "C:\Program Files\Mozilla Firefox\defaults\pref\" >nul 2>&1


:: 4. CAMBIAR FONDO DE PANTALLA SILENCIOSAMENTE
::if exist "C:\Windows\Mat\cambiar_fondo.ps1" (
::    powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\Windows\Mat\cambiar_fondo.ps1"
)

:: 5. RESTAURAR DISPOSICIÓN DE ICONOS CON DESKTOPOK
if exist "C:\Windows\mat\DesktopOK_x64\DesktopOK_x64.exe" (
    C:\Windows\mat\DesktopOK_x64\DesktopOK_x64.exe /load /silent C:\Windows\mat\layout.dok
)

:: 6. ABRIR MOZILLA FIREFOX
start "" "C:\Program Files\Mozilla Firefox\firefox.exe" "https://www.uma.es"
```

---

## 5. Cambio Silencioso de Fondo de Pantalla (`cambiar_fondo.ps1`) TEST

Ubicación: `C:\Windows\Mat\cambiar_fondo.ps1`

Este script en PowerShell cambia la clave del registro del escritorio y llama a la API `SystemParametersInfo` de `user32.dll` para forzar la actualización del fondo en caliente de forma **100 % silenciosa**.

```powershell
# ==============================================================================
# CAMBIO SILENCIOSO DE FONDO DE PANTALLA (C:\Windows\Mat\cambiar_fondo.ps1)
# ==============================================================================

$RutaImagen = "C:\Windows\Mat\Fondo_2026.jfif"

if (Test-Path $RutaImagen) {
    Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name Wallpaper -Value $RutaImagen -ErrorAction SilentlyContinue
    Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name WallpaperStyle -Value "2" -ErrorAction SilentlyContinue
    Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name TileWallpaper -Value "0" -ErrorAction SilentlyContinue

    $code = @"
using System;
using System.Runtime.InteropServices;

public class Wallpaper {
    [DllImport("user32.dll", CharSet = CharSet.Auto)]
    public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
}
"@

    Add-Type $code -ErrorAction SilentlyContinue
    [Wallpaper]::SystemParametersInfo(20, 0, $RutaImagen, 3) | Out-Null
}
```

---

## 6. Autoconfiguración de Mozilla Firefox (AutoConfig) TEST

Para controlar Mozilla Firefox de forma centralizada sin depender del perfil del usuario, se despliegan dos archivos en el directorio de instalación:

### `local-settings.js`
Ubicación: `C:\Program Files\Mozilla Firefox\defaults\pref\local-settings.js`

```javascript
pref("general.config.obscure_value", 0);
pref("general.config.filename", "mozilla.cfg");
```

### `mozilla.cfg`
Ubicación: `C:\Program Files\Mozilla Firefox\mozilla.cfg`

```javascript
// ==============================================================================
// CONFIGURACIÓN GLOBAL BLOQUEADA DE FIREFOX (MATAP)
// ==============================================================================

// 1. Heredar la configuración de proxy del Sistema Operativo (WinINet)
lockPref("network.proxy.type", 5);

// 2. Página de inicio y comportamiento de arranque
lockPref("browser.startup.homepage", "www.uma.es");
lockPref("browser.shell.checkDefaultBrowser", false);
lockPref("browser.startup.page", 1);
lockPref("browser.sessionstore.resume_from_crash", false);

// 3. Control de actualizaciones (Bloquea descargas automáticas, permite manuales)
lockPref("app.update.auto", false);
lockPref("app.update.background.interval", 0);
lockPref("app.update.service.enabled", true);

// 4. Seguridad e integridad durante exámenes
lockPref("devtools.policy.disabled", true);
lockPref("xpinstall.enabled", false);
lockPref("signon.rememberSignons", false);

// 5. Borrado de datos al cerrar
lockPref("privacy.sanitize.sanitizeOnShutdown", true);
lockPref("privacy.clearOnShutdown.history", true);
lockPref("privacy.clearOnShutdown.cookies", true);
```

---

## 7. Despliegue Masivo con Veyon Master

Para ejecutar las acciones en remoto de manera unificada a través de **Veyon Master**, seleccionar todos los equipos objetivo, abrir la función **"Iniciar aplicación" / "Ejecutar comando"** e ingresar las órdenes según el procedimiento requerido:

### Comandos de Despliegue en Veyon

* **Activar Modo Examen (PowerShell):**
  ```cmd
    powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "C:\Windows\Mat\proxyexamen\activar_modo_examen.ps1"
  ```

* **Desactivar Modo Examen / Restaurar Proxy Habitual (PowerShell):**
  ```cmd
   powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "C:\Windows\Mat\proxyexamen\desactivar_modo_examen.ps1"
  ```

* **Desactivar Proxy por Completo (PowerShell):**
  ```cmd
  powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "C:\Windows\Mat\proxyexamen\desactivar_proxy.ps1"
  ```

* **Ejecutar Inicio Unificado (`inicio.bat`):**
  ```cmd
  cmd.exe /c "C:\Windows\Mat\inicio.bat"
  ```

```cmd
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\Windows\mat\proxyexamen\desactivar_modo_examen.ps1"
```

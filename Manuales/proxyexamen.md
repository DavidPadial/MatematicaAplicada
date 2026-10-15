# Guía de Configuración de Proxys y Directivas de Grupo (`gpedit.msc`)

**Entorno:** Aulas de Informática - Universidad de Málaga (UMA)  
**Objetivo:** Controlar y restringir la navegación en los equipos de las aulas mediante scripts automatizados y politicas de grupo local (`gpedit.msc`).

---

## 1. Scripts de Automatización de Proxy

Los siguientes scripts modifican el Registro de Windows (`HKCU` / `HKLM`) para aplicar o desactivar la configuración del servidor proxy del sistema y sus excepciones para el dominio `uma.es`.

### Script 1: Configurar Proxy 1 (Proxy Falso / Bloqueo Local)
Este script redirige el tráfico a un puerto local no receptivo (`127.0.0.1:8080`), cortando la navegación general salvo para la Universidad de Málaga (`uma.es` y subdominios).

#### Opción PowerShell (`Activar_Proxy1.ps1`):
```powershell
# Configuración de Proxy 1 (Proxy Falso Local)
$RegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings"

# Activar uso de Proxy
Set-ItemProperty -Path $RegPath -Name ProxyEnable -Value 1

# Dirección del Proxy 1
Set-ItemProperty -Path $RegPath -Name ProxyServer -Value "127.0.0.1:8080"

# Excepciones para la UMA y recursos locales
Set-ItemProperty -Path $RegPath -Name ProxyOverride -Value "*.uma.es;uma.es;campusvirtual.uma.es;<local>"

Write-Host "Proxy 1 (Falso/Local) activado correctamente." -ForegroundColor Green
```

#### Opción CMD / Batch (`Activar_Proxy1.bat`):
```cmd
@echo off
:: Activar Proxy 1 (Proxy Falso Local)
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable /t REG_DWORD /d 1 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyServer /t REG_SZ /d "127.0.0.1:8080" /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyOverride /t REG_SZ /d "*.uma.es;uma.es;campusvirtual.uma.es;<local>" /f
echo Proxy 1 (Falso/Local) activado.
```

---

### Script 2: Configurar Proxy 2 (Proxy Servidor Intermedio / Dedicado)
Este script configura un servidor proxy secundario o dedicado en la red (ejemplo: `192.168.1.100:3128` o servidor Squid) manteniendo las excepciones de la UMA.

#### Opción PowerShell (`Activar_Proxy2.ps1`):
```powershell
# Configuración de Proxy 2 (Servidor Proxy Red/Squid)
$RegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings"

# Activar uso de Proxy
Set-ItemProperty -Path $RegPath -Name ProxyEnable -Value 1

# Dirección del Proxy 2 (Sustituir por la IP y puerto reales de tu segundo proxy)
Set-ItemProperty -Path $RegPath -Name ProxyServer -Value "192.168.1.100:3128"

# Excepciones para la UMA y recursos locales
Set-ItemProperty -Path $RegPath -Name ProxyOverride -Value "*.uma.es;uma.es;campusvirtual.uma.es;<local>"

Write-Host "Proxy 2 (Servidor Dedicado) activado correctamente." -ForegroundColor Green
```

#### Opción CMD / Batch (`Activar_Proxy2.bat`):
```cmd
@echo off
:: Activar Proxy 2 (Servidor Dedicado)
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable /t REG_DWORD /d 1 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyServer /t REG_SZ /d "192.168.1.100:3128" /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyOverride /t REG_SZ /d "*.uma.es;uma.es;campusvirtual.uma.es;<local>" /f
echo Proxy 2 (Servidor Dedicado) activado.
```

---

### Script 3: Desactivar Proxy (Restablecer Navegación Normal)
Desactiva el servidor proxy del sistema operativo para permitir la navegación directa a internet.

#### Opción PowerShell (`Desactivar_Proxy.ps1`):
```powershell
# Desactivar Proxy del Sistema
$RegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings"

Set-ItemProperty -Path $RegPath -Name ProxyEnable -Value 0

Write-Host "Proxy desactivado. Navegación libre restablecida." -ForegroundColor Yellow
```

#### Opción CMD / Batch (`Desactivar_Proxy.bat`):
```cmd
@echo off
:: Desactivar Proxy
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable /t REG_DWORD /d 0 /f
echo Proxy desactivado.
```

---

## 2. Configuraciones en el Editor de Directivas de Grupo Local (`gpedit.msc`)

Para acceder al editor, presiona `Win + R`, escribe `gpedit.msc` y pulsa `Enter`.

### A. Bloquear la modificación del Proxy por parte de los alumnos
Evita que los usuarios puedan cambiar o desactivar la configuración del proxy desde la interfaz gráfica de Windows o Microsoft Edge/Chrome.

1. **Impedir cambios en la configuración de proxy:**
   * **Ruta:** `Configuración del equipo` > `Plantillas administrativas` > `Componentes de Windows` > `Internet Explorer`
   * **Directiva:** `Impedir el cambio de configuración de proxy`
   * **Estado:** **Habilitada**
   * *Efecto:* Deshabilita los campos de edición de proxy en las Opciones de Internet del Panel de Control y Ajustes de Windows.

2. **Aplicar la configuración de proxy a nivel de equipo (no por usuario):**
   * **Ruta:** `Configuración del equipo` > `Plantillas administrativas` > `Componentes de Windows` > `Internet Explorer`
   * **Directiva:** `Hacer coincidir la configuración de proxy por equipo (en lugar de por usuario)`
   * **Estado:** **Habilitada**
   * *Efecto:* Garantiza que la regla afecte a cualquier usuario o alumno que inicie sesión en la máquina.

3. **Deshabilitar la pestaña Conexiones:**
   * **Ruta:** `Configuración del usuario` > `Plantillas administrativas` > `Componentes de Windows` > `Internet Explorer` > `Panel de control de Internet`
   * **Directiva:** `Deshabilitar la página Conexiones`
   * **Estado:** **Habilitada**
   * *Efecto:* Oculta por completo la pestaña desde donde se configura la LAN / Proxy.

---

### B. Desactivar el Protocolo QUIC (HTTP/3) y DoH
Navegadores como Chrome y Edge utilizan por defecto el protocolo QUIC (sobre UDP 443), el cual ignora las configuraciones de proxy HTTP tradicionales. Es imprescindible desactivarlo por directiva o por firewall.

#### Opción 1: Bloqueo de QUIC por Directiva de Grupo (Edge/Chrome)
*Si tienes instaladas las plantillas administrativas (ADMX) de Microsoft Edge o Google Chrome:*

* **Microsoft Edge:**
  * **Ruta:** `Configuración del equipo` > `Plantillas administrativas` > `Microsoft Edge`
  * **Directiva:** `Permitir el uso del protocolo QUIC`
  * **Estado:** **Deshabilitado**

* **Google Chrome:**
  * **Ruta:** `Configuración del equipo` > `Plantillas administrativas` > `Google Chrome`
  * **Directiva:** `Permitir el uso del protocolo QUIC`
  * **Estado:** **Deshabilitado**

#### Opción 2: Bloqueo de QUIC vía Firewall (Recomendado y más rápido)
Si no dispones de las plantillas ADMX en los 60 equipos, puedes ejecutar esta regla de Firewall para bloquear todo el tráfico UDP saliente en el puerto 443:

```cmd
netsh advfirewall firewall add rule name="Bloquear_QUIC_UDP443" dir=out action=block protocol=UDP remoteport=443
```

---

### C. Bloquear el acceso a `cmd` y `PowerShell` para alumnos (Opcional)
Para evitar que los alumnos ejecuten scripts manuales de deshabilitación:

1. **Impedir el acceso al Símbolo del Sistema (`cmd`):**
   * **Ruta:** `Configuración del usuario` > `Plantillas administrativas` > `Sistema`
   * **Directiva:** `Impedir el acceso al símbolo del sistema`
   * **Estado:** **Habilitada** (puedes seleccionar *No* en la opción de desactivar la ejecución de archivos `.bat` si lanzas los scripts al inicio del sistema).

---

## 3. Resumen de Flujo de Trabajo en Aulas

1. **Configuración inicial del aula:** Aplicar las directivas de `gpedit.msc` para bloquear el acceso visual a los ajustes de proxy y deshabilitar QUIC.
2. **Durante el examen (desde Veyon Master):** Lanza el comando de ejecución remota con el script `Activar_Proxy1.bat` o `Activar_Proxy2.bat`.
3. **Al finalizar el examen:** Lanza el comando con `Desactivar_Proxy.bat` para restaurar la conectividad total.

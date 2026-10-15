# Manual de Configuración y Automatización de Proxy para Exámenes CON .BAT
**Departamento / Aulas de Informática MATAP - UMA**

Este manual detalla el procedimiento para aplicar y revertir la configuración de proxy de Windows mediante scripts de comandos (`.bat`). La finalidad es restringir el acceso general a Internet durante la realización de exámenes, permitiendo únicamente el acceso a los dominios de la UMA y a los repositorios/licencias de software docente (R/CRAN, Scilab, MathWorks y red local).

---

## 1. Script 1: Activar Proxy para Examen

Este script modifica el Registro de Windows del usuario actual (`HKCU`) para forzar el uso del servidor proxy y definir la lista de excepciones permitidas.

### Archivo: `activar_proxy_examen.bat`

```cmd
@echo off
:: 1. Habilitar uso de proxy
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable /t REG_DWORD /d 1 /f

:: 2. Configurar proxy y puerto
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyServer /t REG_SZ /d "proxy.matapexamen.uma.es:3128" /f

:: 3. Excepciones: UMA, subred UMA (150.214.*), CRAN (R), Scilab, MathWorks y red local
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyOverride /t REG_SZ /d "*.uma.es;uma.es;150.214.*;*.r-project.org;*.scilab.org;*.mathworks.com;<local>" /f

echo Configuración de proxy con excepciones para programas aplicada.
pause
```

### Explicación detallada de las claves del registro

1. **`ProxyEnable = 1`**: Activa el uso global del servidor proxy en las opciones de red de Windows (`inetcpl.cpl`).
2. **`ProxyServer = proxy.matapexamen.uma.es:3128`**: Redirige todo el tráfico HTTP/HTTPS no exceptuado al servidor proxy restringido en el puerto 3128.
3. **`ProxyOverride`**: Lista de dominios e IPs que **omitirán el proxy** y conectarán directamente a la red:
   * `*.uma.es;uma.es`: Permite navegación en el Campus Virtual, webs y servicios de la UMA.
   * `150.214.*`: Garantiza el tráfico directo dentro de la subred pública de la Universidad de Málaga.
   * `*.r-project.org`: Permite descargar y actualizar paquetes de R (CRAN).
   * `*.scilab.org`: Permite el correcto funcionamiento y descargas del entorno Scilab.
   * `*.mathworks.com`: Permite la validación de licencias y acceso a la documentación de MATLAB.
   * `<local>`: Omite el proxy para direcciones de la red local (LAN/intranet).

---

## 2. Script 2: Desactivar Proxy (Restablecer Acceso)

Este script deshabilita la redirección por proxy y limpia las entradas en el Registro de Windows para restaurar la navegación normal tras finalizar la prueba.

### Archivo: `desactivar_proxy.bat`

```cmd
@echo off
:: 1. Deshabilitar el uso de proxy
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable /t REG_DWORD /d 0 /f

:: 2. Limpiar la dirección del servidor proxy
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyServer /t REG_SZ /d "" /f

:: 3. Limpiar la lista de excepciones
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyOverride /t REG_SZ /d "" /f

echo Proxy desactivado correctamente.
pause
```

### Explicación de la limpieza

* **`ProxyEnable = 0`**: Desactiva el paso por proxy en las aplicaciones del sistema.
* **`ProxyServer = ""`**: Elimina la dirección del servidor para evitar conflictos o intentos de reconexión.
* **`ProxyOverride = ""`**: Vacía la lista de excepciones configurada.

---
#FALTA UN SCRITP PARA PONER EL PROXY.SATD.UMA.ES O EL PROXY.UMA.ES
---

## 3. Métodos de Despliegue en Aulas de Informática

Para aplicar o retirar el proxy en los 60 ordenadores del aula sin tener que ejecutar el archivo PC por PC, se recomiendan los siguientes métodos:

### Opción A: Despliegue masivo desde Veyon Master (Recomendado)

1. Guarda los scripts `.bat` en una ruta de red compartida o localmente en las máquinas de las aulas (ejemplo: `C:\Scripts\activar_proxy_examen.bat`).
2. Abre **Veyon Master** en el equipo del profesor.
3. Selecciona los equipos del aula (o haz clic en *Seleccionar todo*).
4. Pulsa en la herramienta **Iniciar aplicación** o **Ejecutar comando**.
5. Introduce el comando de ejecución:
   ```cmd
   cmd.exe /c "C:\Scripts\activar_proxy_examen.bat"
   ```
6. Al finalizar el examen, lanza el mismo comando llamando al script `desactivar_proxy.bat`.

### Opción B: Ejecución mediante Directiva de Grupo (GPO / Script de Inicio o Cierre de Sesión)

1. Abre la consola de gestión de Directivas de Grupo (`gpmc.msc`) en el servidor de dominio.
2. Edita la GPO aplicada a los equipos del aula y navega a:
   * **Configuración del usuario -> Directivas -> Configuración de Windows -> Scripts (Iniciar sesión / Cerrar sesión)**.
3. Asigna `activar_proxy_examen.bat` para que se ejecute de forma automática al iniciar sesión los alumnos.

---

## 4. Configuraciones en el Editor de Directivas de Grupo Local (`gpedit.msc`)

Para acceder al editor, presiona `Win + R`, escribe `gpedit.msc` y pulsa `Enter`.

### A. Bloquear la modificación del Proxy por parte de los alumnos
Evita que los usuarios puedan cambiar o desactivar la configuración del proxy desde la interfaz gráfica de Windows o Microsoft Edge/Chrome.

1. **Impedir cambios en la configuración y panel de control:**
   * **Ruta:** `Configuración del equipo` > `Plantillas administrativas` > `Panel de control` > `Prohibir el acceso a configuración de PC y Panel de control`
   * **Directiva:** `Prohibir el acceso a configuración de PC y Panel de control`
   * **Estado:** **Habilitada**
   * *Efecto:* Deshabilita todos los programas del Panel de control y la aplicación Configuración de PC.

2. **Impedir cambios en la configuración de proxy:**
   * **Ruta:** `Configuración del equipo` > `Plantillas administrativas` > `Componentes de Windows` > `Internet Explorer`
   * **Directiva:** `Impedir el cambio de configuración de proxy`
   * **Estado:** **Habilitada**
   * *Efecto:* Deshabilita los campos de edición de proxy en las Opciones de Internet del Panel de Control y Ajustes de Windows.

3. **Aplicar la configuración de proxy a nivel de equipo (no por usuario) NO RECOMENDABLE. EL ADMIN NO QUIERO QUE TENGA EL PROXY:**
   * **Ruta:** `Configuración del equipo` > `Plantillas administrativas` > `Componentes de Windows` > `Internet Explorer`
   * **Directiva:** `Hacer coincidir la configuración de proxy por equipo (en lugar de por usuario)`
   * **Estado:** **Habilitada**
   * *Efecto:* Garantiza que la regla afecte a cualquier usuario o alumno que inicie sesión en la máquina.

4. **Deshabilitar la pestaña Conexiones:**
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
---

## 5. Verificación y Pruebas del Estado

Para verificar que el filtrado funciona de forma idónea en un equipo del aula:

1. **Comprobación gráfica de la configuración:**
   * Pulsa `Win + R`, escribe `inetcpl.cpl` y pulsa **Enter**.
   * Ve a la pestaña **Conexiones** -> **Configuración de LAN**.
   * Verifica que la casilla *"Usar un servidor proxy para la LAN"* esté marcada y contenga las direcciones e excepciones indicadas.

2. **Prueba de navegación (Bloqueo efectivo):**
   * Abre una ventana de modo incógnito en Edge o Chrome e intenta acceder a `https://www.google.com`.
   * **Resultado esperado:** Debe mostrar un error de conexión (*"No se puede conectar al servidor proxy"* o *"Conexión rechazada"*).

3. **Prueba de excepciones (Acceso permitido):**
   * Navega a `https://www.uma.es` o `https://campusvirtual.uma.es`.
   * **Resultado esperado:** La página debe cargar con normalidad.

---

## 5. Consideraciones Técnicas

* **Protocolo QUIC (HTTP/3):** Navegadores como Chrome o Edge pueden intentar saltarse el proxy HTTP usando el protocolo QUIC sobre UDP (puertos 443 UDP). Si notas que algún equipo sigue navegando a páginas externas, se recomienda deshabilitar QUIC en el navegador mediante la directiva correspondiente o escribiendo `chrome://flags/#enable-quic` -> *Disabled*.
* **Permisos del registro:** Los comandos modifican `HKCU` (HKEY_CURRENT_USER), por lo que se aplican directamente al perfil del usuario autenticado sin requerir elevación estricta de Administrador en el momento de modificar dicha rama.

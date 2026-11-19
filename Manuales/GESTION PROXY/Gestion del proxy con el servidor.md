Servidor Proxy y PAC MAT (Nginx)

Servidor centralizado en Lubuntu 24.04 LTS (192.168.199.199) que utiliza Nginx para distribuir scripts de configuración (.ps1) y reglas de enrutamiento de red (.pac) a los equipos de las aulas de Teleco e Industriales.

Cambio clave de arquitectura: Para las clases normales finalmente no se utilizan proxy_teleco.pac ni proxy_industriales.pac. El proxy habitual se escribe directamente en el Registro de Windows mediante proxy_teleco.ps1 y proxy_industriales.ps1, eliminando la dependencia del servidor durante la docencia ordinaria. El servidor Nginx se utiliza únicamente para los exámenes (y para lanzar órdenes remotas desde Veyon).

1. Despliegue de Ficheros Locales en los PCs (Windows)

Para que los ordenadores funcionen de forma autónoma en el día a día sin depender del servidor y Mozilla Firefox herede siempre el proxy del sistema operativo, cada equipo debe tener los siguientes ficheros locales:

A. Carpeta local de respaldo y despliegue (C:\Windows\mat\)

Equipos de Teleco:

C:\Windows\mat\mozilla.cfg

C:\Windows\mat\proxy_teleco.ps1

Equipos de Industriales:

C:\Windows\mat\mozilla.cfg

C:\Windows\mat\proxy_industriales.ps1

(Nota: si se despliega la configuración de Firefox mediante script de inicio, es recomendable guardar también local-settings.js en C:\Windows\mat\ como copia origen).

B. Instalación de Mozilla Firefox (AutoConfig)

Para obligar a Firefox a utilizar la configuración de proxy del sistema (Windows) y que obedezca tanto al proxy fijo de clase como al .pac de examen, deben copiarse estos dos ficheros en la ruta de instalación del navegador:

Archivo de políticas: C:\Program Files\Mozilla Firefox\mozilla.cfg

Archivo cargador de preferencias: C:\Program Files\Mozilla Firefox\defaults\pref\local-settings.js

2. Arquitectura y Flujo de Llamadas

Modo 1: Docencia Normal (Autónomo / Sin dependencia del servidor Nginx)

[ PC AULA (Windows / Usuario Matap) ]
   │
   ├── Ejecuta proxy_teleco.ps1 (Teleco) o proxy_industriales.ps1 (Industriales)
   │      └── Escribe proxy fijo en el Registro de Windows:
   │          HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings
   │          ProxyEnable = 1  ──►  proxy.satd.uma.es:3128 (+ excepciones UMA/local)
   │
   └── Mozilla Firefox (mozilla.cfg + defaults\pref\local-settings.js)
          └── Lee directamente el proxy configurado en el Registro del sistema


Modo 2: Modo Examen (Dependencia puntual del servidor Nginx)

[ VEYON MASTER (Profesor) ]
       │
       │ 1. Lanza orden remota (PowerShell + curl)
       ▼
[ PCs AULA (Windows / Usuario Matap) ]
       │
       ├── 2. Descarga y ejecuta en RAM (.ps1) ──┐
       │                                         ▼
       │                              ┌─────────────────────┐
       │                              │   SERVIDOR NGINX    │
       ├── 3. Consulta reglas (.pac) ─┤   192.168.199.199   │
       │      (Solo proxyexamen_*.pac)└──────────┬──────────┘
       │                                         │ Sirve archivos desde:
       │                              /opt/mat/proxy/
       │                              ├── ps1/
       │                              │   ├── activar_modo_examen_teleco.ps1
       │                              │   ├── desactivar_modo_examen_teleco.ps1
       │                              │   ├── proxy_teleco.ps1
       │                              │   ├── activar_modo_examen_industriales.ps1
       │                              │   ├── desactivar_modo_examen_industriales.ps1
       │                              │   └── proxy_industriales.ps1
       │                              └── pac/
       │                                  ├── teleco/
       │                                  │   ├── proxyexamen_teleco.pac
       │                                  │   └── proxy_teleco.pac (almacenado, sin uso en clase)
       │                                  └── industriales/
       │                                      ├── proxyexamen_industriales.pac
       │                                      └── proxy_industriales.pac (almacenado, sin uso en clase)
       │
       ▼ 4. Enrutamiento del tráfico web durante el examen
proxy.matapexamen.uma.es:3128 (Tráfico restringido + UMA directo + repositorios autorizados vía SATD)


¿Cómo interactúan los ficheros?

Clases normales (proxy_teleco.ps1 / proxy_industriales.ps1):

No utilizan ficheros .pac.

Eliminan cualquier AutoConfigURL previa y escriben directamente en el Registro del usuario activo (HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings) el proxy habitual proxy.satd.uma.es:3128 con sus excepciones (*.uma.es, 150.214.*, <local>, etc.).

Al quedar guardado en el Registro del PC (y contar con copia local en C:\Windows\mat\), los equipos funcionan con total independencia aunque el servidor Nginx esté apagado o inaccesible.

Activación del Modo Examen (activar_modo_examen_*.ps1):

Desde Veyon Master se ordena a los PCs descargar el script .ps1 correspondiente por HTTP desde Nginx y ejecutarlo directamente en RAM (Invoke-Expression).

El .ps1 desactiva el proxy fijo (ProxyEnable = 0), apunta AutoConfigURL a la URL del proxyexamen_*.pac en el servidor y limpia la caché de conexiones de los navegadores.

Filtrado dinámico en examen (proxyexamen_*.pac):

El navegador consulta proxyexamen_teleco.pac o proxyexamen_industriales.pac en Nginx: conecta directo (DIRECT) a uma.es / 150.214.0.0/16, permite repositorios y herramientas docentes autorizadas (R, Scilab, MathWorks, SentinelOne, jsDelivr, MathJax) a través de proxy.satd.uma.es:3128 y bloquea el resto enviándolo a proxy.matapexamen.uma.es:3128.

Fin de examen / Restauración (desactivar_modo_examen_*.ps1 o proxy_*.ps1):

Elimina la lectura de .pac (AutoConfigURL) y vuelve a fijar proxy.satd.uma.es:3128 directamente en el Registro de Windows. Si el servidor Nginx está apagado o inaccesible, se lanza desde Veyon (o en local) el fichero C:\Windows\mat\proxy_teleco.ps1 o C:\Windows\mat\proxy_industriales.ps1.

3. Configuración de Nginx

Archivo de configuración: /etc/nginx/sites-available/default

location /pac/ {
    alias /opt/mat/proxy/pac/;
    autoindex on;
    add_header Cache-Control "no-cache";

    types {
        application/x-ns-proxy-autoconfig pac;
    }
}

location /ps1/ {
    alias /opt/mat/proxy/ps1/;
    autoindex on;
    add_header Cache-Control "no-cache";
    default_type text/plain;
}


add_header Cache-Control "no-cache"; evita que Windows o los navegadores guarden versiones antiguas de los scripts tras editarlos.

4. Comandos para Veyon Master

Aula de Teleco

Activar modo examen (desde servidor):

powershell -ExecutionPolicy Bypass -Command "Invoke-Expression (curl.exe -s http://192.168.199.199/ps1/activar_modo_examen_teleco.ps1 | Out-String)"


Desactivar modo examen (desde servidor):

powershell -ExecutionPolicy Bypass -Command "Invoke-Expression (curl.exe -s http://192.168.199.199/ps1/desactivar_modo_examen_teleco.ps1 | Out-String)"


Restaurar proxy normal SIN servidor (usando fichero local en C:\Windows\mat\):

powershell -ExecutionPolicy Bypass -Command "Get-Content 'C:\Windows\mat\proxy_teleco.ps1' -Raw | Invoke-Expression"


Restaurar proxy normal desde servidor (alternativa):

powershell -ExecutionPolicy Bypass -Command "Invoke-Expression (curl.exe -s http://192.168.199.199/ps1/proxy_teleco.ps1 | Out-String)"


Aula de Industriales

Activar modo examen (desde servidor):

powershell -ExecutionPolicy Bypass -Command "Invoke-Expression (curl.exe -s http://192.168.199.199/ps1/activar_modo_examen_industriales.ps1 | Out-String)"


Desactivar modo examen (desde servidor):

powershell -ExecutionPolicy Bypass -Command "Invoke-Expression (curl.exe -s http://192.168.199.199/ps1/desactivar_modo_examen_industriales.ps1 | Out-String)"


Restaurar proxy normal SIN servidor (usando fichero local en C:\Windows\mat\):

powershell -ExecutionPolicy Bypass -Command "Get-Content 'C:\Windows\mat\proxy_industriales.ps1' -Raw | Invoke-Expression"


Restaurar proxy normal desde servidor (alternativa):

powershell -ExecutionPolicy Bypass -Command "Invoke-Expression (curl.exe -s http://192.168.199.199/ps1/proxy_industriales.ps1 | Out-String)"


5. Restauración Manual en un PC Individual (Sin Servidor ni Veyon)

Si necesitas restaurar el proxy habitual directamente en un equipo aislado (sin red hacia el servidor y sin usar Veyon Master) desde la sesión del usuario Matap:

Desde Ejecutar (Win + R) o consola (CMD / PowerShell):

Teleco: powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Windows\mat\proxy_teleco.ps1"

Industriales: powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Windows\mat\proxy_industriales.ps1"

Desde el Explorador de archivos:

Escribe C:\Windows\mat en la barra de direcciones (la carpeta puede estar oculta en C:\Windows\).

Haz clic derecho sobre proxy_teleco.ps1 (o proxy_industriales.ps1) y selecciona Ejecutar con PowerShell.

6. Mantenimiento del Servidor Nginx

Editar scripts .ps1 o .pac: Los cambios en /opt/mat/proxy/ tienen efecto inmediato al guardar. No es necesario reiniciar Nginx.

Permisos tras crear archivos nuevos: Asegurar que Nginx pueda leerlos:

sudo chmod -R 755 /opt/mat/proxy


Modificar configuración de Nginx: Validar siempre la sintaxis antes de recargar para evitar caídas del servicio:

sudo nginx -t && sudo systemctl reload nginx


Estado y reinicio del servicio:

sudo systemctl status nginx
sudo systemctl restart nginx


Monitorización en tiempo real (logs):

sudo tail -f /var/log/nginx/access.log   # Comprobar descargas (código 200) de los PCs
sudo tail -f /var/log/nginx/error.log    # Detectar errores de permisos o rutas (403/404)


Actualizaciones del sistema:

sudo apt update && sudo apt upgrade -y

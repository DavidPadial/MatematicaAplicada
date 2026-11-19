# Servidor Proxy y PAC MAT (Nginx)

Servidor centralizado en **Lubuntu 24.04 LTS** (`192.168.199.199`) que utiliza **Nginx** para distribuir scripts de configuración (`.ps1`) y reglas de enrutamiento de red (`.pac`) a los equipos de las aulas de **Teleco** e **Industriales**.

---

## 1. Arquitectura y Flujo de Llamadas

```text
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
       │                              └──────────┬──────────┘
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
       │                                  │   ├── proxy_teleco.pac
       │                                  │   └── proxyexamen_teleco.pac
       │                                  └── industriales/
       │                                      ├── proxy_industriales.pac
       │                                      └── proxyexamen_industriales.pac
       │
       ▼ 4. Enrutamiento del tráfico web según el .pac activo
┌──────┴──────────────────────────────────────┐
│                                             │
▼ (Modo Normal: proxy_*.pac)                  ▼ (Modo Examen: proxyexamen_*.pac)
proxy.satd.uma.es:3128                        proxy.matapexamen.uma.es:3128
(Internet general + UMA directo)              (Tráfico restringido + UMA directo)
```

### ¿Cómo interactúan los ficheros?
1. **Ejecución en memoria (`.ps1`):** Desde Veyon Master se ordena a los PCs descargar el script `.ps1` correspondiente por HTTP y ejecutarlo directamente en RAM (`Invoke-Expression`), sin guardar archivos locales en el cliente.
2. **Cambio en Windows:** El `.ps1` modifica el registro del usuario activo (`HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings`) para apuntar a la URL del `.pac` adecuado y limpia la caché de conexiones de los navegadores.
3. **Filtrado dinámico (`.pac`):** El navegador consulta el `.pac` en cada petición web:
   * **`proxy_*.pac` (Docencia normal):** Conecta directo (`DIRECT`) a `uma.es` / `150.214.0.0/16` y envía el resto de Internet a `proxy.satd.uma.es:3128`.
   * **`proxyexamen_*.pac` (Examen):** Conecta directo a la UMA, permite solo repositorios/herramientas docentes (R, Scilab, MathWorks, SentinelOne, jsDelivr) vía SATD y bloquea el resto enviándolo a `proxy.matapexamen.uma.es:3128`.
   * **`proxy_*.ps1` (Restauración / Contingencia):** Elimina la lectura de `.pac` (`AutoConfigURL`) y fija `proxy.satd.uma.es:3128` directamente en Windows si se necesita restaurar la red o ante una caída del servidor Nginx.

---

## 2. Configuración de Nginx

Archivo de configuración: `/etc/nginx/sites-available/default`

```nginx
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
```

* `add_header Cache-Control "no-cache";` evita que Windows o los navegadores guarden versiones antiguas de los scripts tras editarlos.

---

## 3. Comandos para Veyon Master

### Aula de Teleco

* **Activar modo examen:**
  ```powershell
  powershell -ExecutionPolicy Bypass -Command "Invoke-Expression (curl.exe -s http://192.168.199.199/ps1/activar_modo_examen_teleco.ps1 | Out-String)"
  ```
* **Desactivar modo examen:**
  ```powershell
  powershell -ExecutionPolicy Bypass -Command "Invoke-Expression (curl.exe -s http://192.168.199.199/ps1/desactivar_modo_examen_teleco.ps1 | Out-String)"
  ```
* **Restaurar o cambiar proxy:**
  ```powershell
  powershell -ExecutionPolicy Bypass -Command "Invoke-Expression (curl.exe -s http://192.168.199.199/ps1/proxy_teleco.ps1 | Out-String)"
  ```

### Aula de Industriales

* **Activar modo examen:**
  ```powershell
  powershell -ExecutionPolicy Bypass -Command "Invoke-Expression (curl.exe -s http://192.168.199.199/ps1/activar_modo_examen_industriales.ps1 | Out-String)"
  ```
* **Desactivar modo examen:**
  ```powershell
  powershell -ExecutionPolicy Bypass -Command "Invoke-Expression (curl.exe -s http://192.168.199.199/ps1/desactivar_modo_examen_industriales.ps1 | Out-String)"
  ```
* **Restaurar o cambiar proxy:**
  ```powershell
  powershell -ExecutionPolicy Bypass -Command "Invoke-Expression (curl.exe -s http://192.168.199.199/ps1/proxy_industriales.ps1 | Out-String)"
  ```

---

## 4. Mantenimiento del Servidor Nginx

* **Editar scripts `.ps1` o `.pac`:** Los cambios en `/opt/mat/proxy/` tienen efecto **inmediato** al guardar. No es necesario reiniciar Nginx.
* **Permisos tras crear archivos nuevos:** Asegurar que Nginx pueda leerlos:
  ```bash
  sudo chmod -R 755 /opt/mat/proxy
  ```
* **Modificar configuración de Nginx:** Validar siempre la sintaxis antes de recargar para evitar caídas del servicio:
  ```bash
  sudo nginx -t && sudo systemctl reload nginx
  ```
* **Estado y reinicio del servicio:**
  ```bash
  sudo systemctl status nginx
  sudo systemctl restart nginx
  ```
* **Monitorización en tiempo real (logs):**
  ```bash
  sudo tail -f /var/log/nginx/access.log   # Comprobar descargas (código 200) de los PCs
  sudo tail -f /var/log/nginx/error.log    # Detectar errores de permisos o rutas (403/404)
  ```
* **Actualizaciones del sistema:**
  ```bash
  sudo apt update && sudo apt upgrade -y
  ```
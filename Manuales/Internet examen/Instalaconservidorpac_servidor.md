# Servidor PAC MAT

## Objetivo

Disponer de un servidor centralizado para alojar y distribuir archivos PAC (Proxy Auto Configuration) a los equipos de las aulas de prácticas y exámenes.

Servidor:

- Sistema operativo: Lubuntu 24.04 LTS
- IP: 192.168.199.199
- Servicio web: Nginx

---

# Instalación de Nginx

Actualizar el sistema:

```bash
sudo apt update
sudo apt upgrade -y
```

Instalar Nginx:

```bash
sudo apt install nginx -y
```

Comprobar estado:

```bash
sudo systemctl status nginx
```

Comprobar funcionamiento:

```bash
curl http://localhost
```

Debe aparecer la página:

```text
Welcome to nginx!
```

---

# Estructura de directorios

Se ha definido la siguiente estructura:

```text
/opt/mat
├── proxy
│   └── pac
│       ├── teleco
│       └── industriales
└── compartido
    ├── teleco
    └── industriales
```

Creación:

```bash
sudo mkdir -p /opt/mat/proxy/pac/teleco
sudo mkdir -p /opt/mat/proxy/pac/industriales
sudo mkdir -p /opt/mat/compartido/teleco
sudo mkdir -p /opt/mat/compartido/industriales
```

---

# Configuración de Nginx

Editar:

```bash
sudo nano /etc/nginx/sites-available/default
```

Añadir dentro del bloque `server {}`:

```nginx
location /pac/ {
    alias /opt/mat/proxy/pac/;
    autoindex on;

    types {
        application/x-ns-proxy-autoconfig pac;
    }
}
```

Validar la configuración:

```bash
sudo nginx -t
```

Aplicar cambios:

```bash
sudo systemctl reload nginx
```

---

# Ubicación de los archivos PAC

Teleco:

```text
/opt/mat/proxy/pac/teleco/
```

Industriales:

```text
/opt/mat/proxy/pac/industriales/
```

Ejemplos:

```text
/opt/mat/proxy/pac/teleco/proxyexamen_teleco.pac

/opt/mat/proxy/pac/industriales/proxyexamen_industriales.pac
```

---

# URLs disponibles

Teleco:

```text
http://192.168.199.199/pac/teleco/proxyexamen_teleco.pac
```

Industriales:

```text
http://192.168.199.199/pac/industriales/proxyexamen_industriales.pac
```

---

# Editar un archivo PAC

Ejemplo:

```bash
sudo nano /opt/mat/proxy/pac/teleco/proxyexamen_teleco.pac
```

Guardar:

```text
Ctrl + O
Enter
Ctrl + X
```

Los cambios son inmediatos.

No es necesario reiniciar Nginx para modificar el contenido de un archivo PAC.

---

# Comprobar contenido del PAC

Desde el servidor:

```bash
cat /opt/mat/proxy/pac/teleco/proxyexamen_teleco.pac
```

o

```bash
curl http://localhost/pac/teleco/proxyexamen_teleco.pac
```

---

# Comprobar acceso desde Windows

Abrir CMD:

```cmd
curl http://192.168.199.199/pac/teleco/proxyexamen_teleco.pac
```

Debe mostrarse el contenido JavaScript del PAC.

---

# Configuración en Windows

Abrir:

```cmd
inetcpl.cpl
```

Ir a:

```text
Conexiones
→ Configuración LAN
```

Marcar:

```text
Usar script de configuración automática
```

Introducir:

```text
http://192.168.199.199/pac/teleco/proxyexamen_teleco.pac
```

o

```text
http://192.168.199.199/pac/industriales/proxyexamen_industriales.pac
```

según corresponda.

---

# Monitorización

Ver quién descarga los PAC:

```bash
sudo tail -f /var/log/nginx/access.log
```

Ejemplo:

```text
192.168.199.25 - - "GET /pac/teleco/proxyexamen_teleco.pac HTTP/1.1" 200
```

---

# Reinicio de servicios

Reiniciar Nginx:

```bash
sudo systemctl restart nginx
```

Recargar configuración:

```bash
sudo systemctl reload nginx
```

Comprobar estado:

```bash
sudo systemctl status nginx
```

---

# Resumen

Servidor PAC:

```text
192.168.199.199
```

PAC Teleco:

```text
http://192.168.199.199/pac/teleco/proxyexamen_teleco.pac
```

PAC Industriales:

```text
http://192.168.199.199/pac/industriales/proxyexamen_industriales.pac
```

Directorio raíz del proyecto:

```text
/opt/mat
```

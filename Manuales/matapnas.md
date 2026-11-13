Documentación del Servidor matapnas

Documentación técnica del equipo físico matapnas, su sistema operativo, la estructura de ficheros alojada en /opt/mat/ y la configuración del servidor web Nginx encargado de publicar dichos recursos en la red local.

1. Ficha Técnica del Equipo (matapnas)

Parámetro

Detalle

Nombre de equipo (Hostname)

matapnas-allseries (matapnas-allser.matap.local)

Hardware

Procesador Intel Core i5 (4.ª gen.) / 4 GB RAM

Sistema Operativo

Lubuntu 24.04 LTS (Escritorio LXQt)

Dirección IP Estática

192.168.199.199

Usuario Local / Admin

matapnas

Contraseña

M@tap27

Salida a Internet del Servidor

Configurada vía http://proxy.satd.uma.es:3128/ (/etc/environment y /etc/apt/apt.conf.d/99proxy)

Servicios Activos

Nginx (puerto 80), SSH (puerto 22), Cockpit (puerto 9090)

Servicios Pendientes / Inactivos

Samba (instalado/aprovisionado inicialmente, pero no está trabajando ni en servicio todavía)

Ajustes Específicos del Sistema Base

Energía: Suspensión automática y apagado de pantalla deshabilitados en LXQt para garantizar disponibilidad continua en red.

Resolución DNS (systemd-resolved): Servicio desactivado y enmascarado (mask) durante la preparación inicial del equipo para dejar libre el puerto 53.

Administración Remota:

Terminal SSH: ssh matapnas@192.168.199.199

Panel Web Cockpit: https://192.168.199.199:9090 (monitorización visual de CPU, RAM, discos y servicios).

2. Estructura de Ficheros en /opt/mat/

Todo el repositorio de archivos que aloja matapnas para las aulas se organiza bajo /opt/mat/:

/opt/mat/
├── compartido/                                        # Carpeta reservada para intercambio de archivos en red
└── proxy/
    ├── ps1/                                           # Propietario: matapnas:matapnas | Permisos: 755 (-rwxr-xr-x)
    │   ├── activar_modo_examen_teleco.ps1
    │   ├── desactivar_modo_examen_teleco.ps1
    │   ├── proxy_teleco.ps1
    │   ├── activar_modo_examen_industriales.ps1
    │   ├── desactivar_modo_examen_industriales.ps1
    │   └── proxy_industriales.ps1
    └── pac/                                           # Propietario: root:root | Permisos: 644 (-rw-r--r--)
        ├── teleco/
        │   ├── proxy_teleco.pac
        │   └── proxyexamen_teleco.pac
        └── industriales/
            ├── proxy_industriales.pac
            └── proxyexamen_industriales.pac


Detalle de los Directorios

/opt/mat/proxy/ps1/

Contiene los 6 ficheros .ps1 separados por aula (teleco e industriales).

Propietario y permisos: Pertenecen al usuario matapnas:matapnas con permisos 755 (-rwxr-xr-x), lo que permite editarlos directamente sin sudo mientras Nginx puede leerlos y servirlos.

/opt/mat/proxy/pac/

Subdividido en dos carpetas por aula (teleco/ e industriales/), cada una con dos ficheros .pac.

Propietario y permisos: Pertenecen a root:root con permisos 644 (-rw-r--r--), por lo que requieren sudo para ser editados y son legibles por Nginx.

/opt/mat/compartido/

¿Por qué no aparece al ejecutar find /opt/mat/ -type f -ls? El parámetro -type f lista únicamente ficheros regulares. Al estar /opt/mat/compartido/ vacía actualmente, find la omite.

¿Para qué sirve? Es un directorio creado para alojar archivos de intercambio en red (materiales, instaladores o plantillas de configuración como inicio.bat, mozilla.cfg o fondos de pantalla) sin depender de memorias USB.

Estado actual: Como Samba no está funcionando todavía, esta carpeta no se está compartiendo por red SMB. Mientras tanto, si necesitas descargar archivos desde ella hacia los PCs de las aulas, puedes publicarla por HTTP añadiendo una ruta en Nginx (ver sección 3).

(Nota: En el disco también existen los directorios /srv/samba/ —imagenes_clonezilla, entregas, materiales— preparados durante la instalación inicial de Samba, actualmente sin uso al estar el servicio inactivo).

3. Servidor Web Nginx

Nginx es el servicio que está trabajando actualmente para entregar los ficheros a los equipos de las aulas por HTTP en el puerto 80 de 192.168.199.199:

[ Petición HTTP en Red Local ]                      [ Directorio Físico en matapnas ]
http://192.168.199.199/ps1/<fichero>.ps1      ───►  /opt/mat/proxy/ps1/<fichero>.ps1
http://192.168.199.199/pac/<aula>/<fich>.pac  ───►  /opt/mat/proxy/pac/<aula>/<fich>.pac
http://192.168.199.199/compartido/ (opcional) ───►  /opt/mat/compartido/


Archivo de Configuración (/etc/nginx/sites-available/default)

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


alias: Redirige la URL solicitada directamente a la ruta física en /opt/mat/proxy/.

autoindex on;: Habilita el listado de directorio al navegar a http://192.168.199.199/ps1/ o http://192.168.199.199/pac/ desde un navegador para comprobar qué ficheros están publicados.

Cache-Control "no-cache";: Obliga a los clientes a consultar siempre la última versión guardada en el disco del servidor cada vez que se edita un fichero.

types / default_type: Define la cabecera MIME con la que Nginx entrega los .pac (application/x-ns-proxy-autoconfig) y los .ps1 (text/plain).

Publicar /opt/mat/compartido/ por HTTP en Nginx (Opcional)

Dado que Samba aún no está activo, si quieres servir el contenido de /opt/mat/compartido/ vía web (http://192.168.199.199/compartido/), añade este bloque dentro de server { ... } en /etc/nginx/sites-available/default:

location /compartido/ {
    alias /opt/mat/compartido/;
    autoindex on;
    add_header Cache-Control "no-cache";
}


4. Mantenimiento del Servidor Nginx y /opt/mat/

Editar ficheros existentes: Cualquier modificación dentro de /opt/mat/ se sirve al instante. No es necesario reiniciar ni recargar Nginx.

Ajustar permisos al añadir ficheros nuevos:

sudo chown -R matapnas:matapnas /opt/mat/proxy/ps1
sudo chmod -R 755 /opt/mat/proxy/ps1
sudo chmod -R 644 /opt/mat/proxy/pac/*/*.pac
sudo chmod -R 755 /opt/mat/compartido


Validar y aplicar cambios tras editar /etc/nginx/sites-available/default:

sudo nginx -t && sudo systemctl reload nginx


Comprobar estado o reiniciar Nginx:

sudo systemctl status nginx
sudo systemctl restart nginx


Monitorizar accesos y errores de Nginx en tiempo real:

sudo tail -f /var/log/nginx/access.log   # Muestra qué IP descarga qué fichero y el código HTTP (200 OK)
sudo tail -f /var/log/nginx/error.log    # Muestra errores de permisos (403 Forbidden) o rutas (404 Not Found)

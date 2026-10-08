# Guía de Configuración SSH, Claves RSA y SCP en Windows (PowerShell) (solo necesario primera vez)

Esta guía documenta los pasos requeridos para generar un par de claves SSH en Windows, copiarlas a un servidor Linux remoto, configurar el acceso rápido y transferir archivos de forma segura.

---

## 1. Crear el directorio `.ssh` en Windows
Para evitar errores de *"No such file or directory"* al generar o buscar claves, asegúrate de crear la carpeta contenedora dentro de tu perfil de usuario.

```powershell
New-Item -ItemType Directory -Path "$env:USERPROFILE\.ssh" -Force
```

---

## 2. Generar el par de claves RSA (4096 bits) 
Crea la clave privada (`id_rsa_matap101_20250625`) y la clave pública (`id_rsa_matap101_20250625.pub`).

> **Nota:** No agregues la extensión `.pub` al parámetro `-f`. El comando la añadirá automáticamente para la clave pública.

```powershell
ssh-keygen -t rsa -b 4096 -f "$env:USERPROFILE\.ssh\id_rsa_matap101_20250625"
```

---

## 3. Copiar la clave pública al servidor remoto

### Opción A: Sobrescribir o crear el archivo `authorized_keys` (hecha esta)
Copia el archivo reemplazando completamente el `authorized_keys` destino (método directo si no existen otras claves guardadas):

```powershell
scp $env:USERPROFILE\.ssh\id_rsa_matap101_20250625.pub telab-matap@192.168.199.245:/home/telab-matap/.ssh/authorized_keys
```

### Opción B: Añadir la clave sin borrar claves existentes (Recomendado)
Concatena el contenido de la clave pública al final del archivo `authorized_keys` remoto:

ETSI:
```powershell
Get-Content $env:USERPROFILE\.ssh\id_rsa_matap101_20250625.pub | ssh telab-matap@192.168.199.245 "cat >> /home/telab-matap/.ssh/authorized_keys"
```
INDUSTRIALES:
```powershell
Get-Content $env:USERPROFILE\.ssh\id_rsa_matap101_20250625.pub | ssh telab-matap@192.168.201.245 "cat >> /home/telab-matap/.ssh/authorized_keys"
```
---

## 4. Probar la conexión por clave privada
Como la clave tiene un nombre personalizado (no el por defecto `id_rsa`), debes especificar su ruta explícitamente con el parámetro `-i`:


ETSI 
```powershell
ssh -i $env:USERPROFILE\.ssh\id_rsa_matap101_ETSI20261007 telab-matap@192.168.199.245
```
Contraseña: 952012David$


Industriales:
```powershell
ssh -i $env:USERPROFILE\.ssh\id_rsa_matap101_20250625 telab-matap@192.168.201.245
```
Contraseña:952012David

---

## 5. Configurar un alias SSH para acceso rápido (Opcional) (no realizado)
Para evitar escribir la ruta de la clave, el usuario y la dirección IP en cada conexión:

1. Abre o crea el archivo de configuración en PowerShell:
   ```powershell
   notepad $env:USERPROFILE\.ssh\config
   ```

2. Añade las siguientes líneas y guarda el archivo:
   ```text
   Host smatap01
       HostName 192.168.199.245
       User telab-matap
       IdentityFile ~/.ssh/id_rsa_matap101_20250625
   ```

3. A partir de este momento, podrás conectarte directamente con:
   ```powershell
   ssh smatap01
   ```

---

## 6. Copiar el paquete SentinelAgent al servidor remoto (no realizado)
Transfiere el instalador desde la carpeta donde te encuentres en PowerShell hacia la carpeta del usuario en el servidor:

teleco
```powershell
scp SentinelAgent_linux_x86_64_v25_1_2_17.deb telab-matap@192.168.199.245:/home/telab-matap/
```
Industriales
```powershell
scp SentinelAgent_linux_x86_64_v25_1_2_17.deb telab-matap@192.168.201.245:/home/telab-matap/
```
---

## 7. Ejecutar wake on lan del pc master del aula. 

INDUSTRIALES:
```powershell
./88_wol_up.sh
```

ETSI (pendiente crear fichero de arranque)
```powershell
wakeonlan -i 192.168.199.255 A8:5E:45:12:F6:49
```

---

## 8. Entrar por escritorio demoto o RDP al pc y abrir Veyond. 
INDUSTRIALES
```
192.168.201.88
```
Usuario: ```alumnos```     
Contraseña: ```alumnos```

ETSI
```
192.168.199.129
```
Usuario: ```matap```    
Contraseña: ```matap```

---


##IMPORTANTE
---
VEYON no funciona para encender los pcs desde el portatil. Es necesario hacer conectarse a un pc del aula o al servidor y arrancar los pcs




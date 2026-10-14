# Guía Completa de Restauración de Imagen con Clonezilla (Modo Beginner)

**Equipo:** matap213  
**Disco de destino:** WDC WD500LPLX-08ZANTT0 (500 GB)  
**Acción:** Restauración desde unidad externa (`restoredisk`)

---

## 1. Prerrequisitos
* Pendrive ejecutable con **Clonezilla Live** (arrancado en modo UEFI).
* Disco duro externo o pendrive que contiene la imagen capturada previamente.
* Equipo **matap213** conectado a la alimentación eléctrica.

---

## 2. Paso a Paso para la Restauración

### Paso 1: Arranque e Inicio
1. Conecta el USB de Clonezilla y el disco externo donde guardaste la imagen con el PC apagado.
2. Enciende el equipo y presiona repetidamente la tecla del menú de arranque (**F8**, **F12**, **F11** o **F2**).
3. Selecciona la unidad USB con el prefijo **UEFI** (ej. `UEFI Kingston`).
4. En el menú de GRUB, elige la opción por defecto: `Clonezilla live (Default settings, VGA 1024x768)`.

### Paso 2: Configuración de Idioma
1. Selecciona el idioma: `es_ES.UTF-8 Spanish | Español`.
2. En el mapa de teclado, selecciona **Keep** (*No cambiar el mapa de teclado*).
3. Selecciona **Start_Clonezilla** para iniciar el asistente.

### Paso 3: Montaje de Almacenamiento (`local-dev`)
1. Selecciona **device-image** (*Trabajar con archivos de imagen*).
2. Selecciona **local-dev** (*Usar dispositivo de almacenamiento local*).
3. Presiona `Enter` para confirmar que el disco externo está conectado.
4. Selecciona la partición de tu unidad externa donde está la carpeta de la imagen.
5. En la comprobación del sistema de archivos, elige `skip` (*Omitir revisión*).
6. Selecciona el directorio donde está la copia de seguridad y presiona `Enter`.

### Paso 4: Configuración de Restauración (`restoredisk`)
1. Selecciona el modo de ejecución **Beginner** (*Modo principiante*).
2. Selecciona la opción **restoredisk** (*Restaurar una imagen a un disco local*).
3. **Selección de Imagen:** Elige el nombre de la carpeta de la imagen que quieres volcar.
4. **Selección de Disco Destino:** Selecciona el disco interno del equipo: **`WDC WD500LPLX-08ZANTT0`** (habitualmente identificado como `sda`).
   > ⚠️ **ATENCIÓN:** Todos los datos existentes en el disco `WDC WD500LPLX-08ZANTT0` serán sobrescritos permanentemente.
5. **Comprobación de la imagen:** Elige `skip` para iniciar directamente la restauración (o `-checkdoc` si deseas verificar la integridad previa del fichero).
6. **Acción al terminar:** Selecciona `poweroff` (*Apagar*) o `reboot` (*Reiniciar*).

### Paso 5: Confirmación y Ejecución
1. Presiona `Enter` para avanzar hasta la consola con texto de advertencia en color amarillo/rojo.
2. Escribe **`y`** (*Yes*) y presiona `Enter` para confirmar el borrado del disco de destino.
3. Escribe nuevamente **`y`** y presiona `Enter` ante la segunda confirmación de seguridad.
4. Espera a que la barra de progreso complete el 100%.
5. Retira el pendrive y apaga/reinicia el equipo.

### Paso 6: Configuración personalizada de cada equipo

#### 1. Cambio de nombre del equipo
Para cambiar el nombre del equipo de forma visual y rápida:
1. Abre el **CMD** (Símbolo del sistema) como administrador.
2. Ejecuta el siguiente comando para abrir las propiedades del sistema:
   ```cmd
   sysdm.cpl
   ```
3. En la pestaña *Nombre de equipo*, haz clic en *Cambiar*, introduce el nuevo nombre y reinicia el equipo.

#### 2. Cambiar dirección IP
Si las opciones de red están restringidas por directivas de grupo:
1. Abre la ventana de Ejecutar (`Win + R`) o el CMD y escribe:
   ```cmd
   gpedit.msc
   ```
2. Navega hasta la directiva correspondiente para **desactivar el bloqueo de configuración de red** y permitir la modificación de las propiedades del adaptador (IP, máscara y puerta de enlace).

#### 3. Configurar Proxy desde el Registro
Para forzar o automatizar la configuración del servidor proxy del sistema:
1. Abre el Editor del Registro ejecutando:
   ```cmd
   regedit
   ```
2. Navega hasta la ruta del registro encargada de los parámetros de red de Internet Explorer/Windows (`HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings`) y modifica los valores de configuración del proxy según los requerimientos de la red.

#### 4. Configurar Antivirus y Desbloqueo de Directivas
Para asegurar los permisos correctos antes de la instalación o ajuste del software de seguridad:
1. Inicia sesión en el equipo con una cuenta de **usuario administrador**.
2. Abre de nuevo el editor de directivas:
   ```cmd
   gpedit.msc
   ```
3. Accede a las plantillas administrativas para **desactivar la prohibición que impide el cambio de configuración del proxy**, garantizando que el antivirus o el tráfico del sistema puedan reportarse correctamente.
4. Instalar sentinel desde el servicio del sci


---

## 3. Resolución de Problemas: Disco de destino más pequeño

Si intentas desplegar una imagen tomada de un disco de 512 GB en un disco de 500 GB, Clonezilla detendrá el proceso con el mensaje de error: *"Target disk size is too small"*[cite: 2].

### Opción A: Ignorar el control de tamaño (Modo Expert)
Si el espacio ocupado por la imagen no supera los 500 GB reales, puedes forzar el volcado[cite: 2]:
1. En el **Paso 4**, selecciona el modo **Expert** en lugar de *Beginner*[cite: 2].
2. Avanza con las opciones por defecto hasta el menú de parámetros de clonación y marca la opción **`-icds`** (*Ignore disk size check*)[cite: 2].
3. Continúa el proceso normalmente.
* **Verificación:** El proceso finalizará al 100% sin mostrar mensajes de error en rojo y el sistema operativo iniciará correctamente[cite: 2].

### Opción B: Solución definitiva a largo plazo (Reducir partición)
Para evitar tener que usar el modo *Expert* en futuras clonaciones[cite: 2]:
1. En el PC maestro original, abre el **Administrador de discos** de Windows (o `gparted` en Linux)[cite: 2].
2. Haz clic derecho sobre la partición principal (C:) y selecciona **Reducir volumen**[cite: 2].
3. Deja entre **30 GB y 50 GB de espacio no asignado** al final del disco[cite: 2].
4. Vuelve a capturar la imagen. Esta nueva copia se podrá restaurar en cualquier disco de 500 GB o superior sin modificar parámetros[cite: 2].

---

## 4. Resolución de Problemas: acceso a web
el usuario administrador no tiene acceso a internet. es necesario entrar al gpedit.msc y activar la configuracion y habilitar el proxy

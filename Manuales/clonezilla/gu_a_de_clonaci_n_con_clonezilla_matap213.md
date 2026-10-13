# Guía Paso a Paso: Captura de Imagen con Clonezilla (Modo Beginner)

Esta guía detalla el procedimiento para realizar una copia de seguridad completa (captura de imagen del disco entero) del equipo **matap213** utilizando **Clonezilla Live** en modo **Beginner**.

---

## 📋 Datos del Equipo y Componentes

* **Nombre del equipo:** `matap213`
* **Disco de origen (interno):** `WDC WD500LPLX-08ZANTT0` (500 GB) — Aparecerá en Clonezilla identificado como `sda` o `nvme0n1`.
* **Disco de destino (externo):** Pendrive o Disco Duro Externo USB donde se guardará el archivo `.img` / carpeta de imagen.
* **Modo de Clonezilla:** `Beginner` (Principiante).

---

## 🛠️ Prerrequisitos

1. Pendrive booteable con **Clonezilla Live**.
2. Disco duro externo o pendrive secundario con formato NTFS/exFAT formateado y con suficiente espacio libre (mínimo 50-100 GB libres según la ocupación del disco original).
3. Ambos dispositivos USB conectados al equipo **matap213** antes de encenderlo.

---

## 🚀 Pasos de Ejecución

### Paso 1: Arranque desde el USB de Clonezilla
1. Enciende el equipo **matap213** y pulsa repetidamente la tecla de menú de arranque (**F8**, **F12**, **F11** o **F2** según el modelo).
2. En el menú de arranque, selecciona la opción con prefijo **UEFI** correspondiente al USB de Clonezilla (ejemplo: `UEFI Kingston`).
3. En el menú de inicio de Clonezilla (GRUB):
   * Selecciona `Clonezilla live (Default settings, VGA 1024x768)`
   * *(Opcional)* Si hay problemas de pantalla, ve a `Other modes of Clonezilla live` y elige la resolución `1024x768`.

---

### Paso 2: Idioma y Teclado
1. **Language:** Selecciona `es_ES.UTF-8 Spanish | Español`.
2. **Keyboard:** Selecciona **Keep** (*No cambiar el mapa de teclado*).
3. En el menú principal, selecciona **Start_Clonezilla** (*Iniciar Clonezilla*).

---

### Paso 3: Selección del Modo de Trabajo y Montaje de Destino
1. Selecciona la opción **`device-image`** (*Trabajar con archivos de imagen*).
2. Selecciona **`local-dev`** (*Usar un dispositivo de almacenamiento local montado por USB/SATA*).
3. Presiona `Enter` cuando el asistente confirme que la unidad externa de destino está conectada.
4. **Selección del disco de destino:** 
   * ⚠️ **MUY IMPORTANTE:** Elige la partición de tu **disco duro externo USB** donde se guardará la copia (ejemplo: `sdb1` o `sdc1`). 
   * ❌ **NO** selecciones en este paso el disco `WDC WD500LPLX-08ZANTT0`.
5. En la comprobación del sistema de archivos del disco destino, elige **`skip`** (*Omitir revisión*).
6. Selecciona el directorio raíz **`/`** (o una carpeta específica) donde se creará la carpeta con la imagen.
7. Pulsa `Enter` para continuar tras ver el resumen de espacio libre en pantalla.

---

### Paso 4: Configuración de la Captura (Modo Beginner)
1. **Modo de ejecución:** Selecciona **`Beginner`** (*Modo principiante*).
2. **Acción a realizar:** Selecciona **`save-disk`** (*Guardar el disco local entero como una imagen*).
3. **Nombre de la imagen:** Introduce un nombre identificativo o acepta el nombre por defecto generado con la fecha (ejemplo: `2026-10-13-10-img_matap213`).
4. **Selección del disco de origen (a clonar):**
   * Marca el disco interno de tu PC: **`sda`** asociado al modelo **`WDC_WD500LPLX-08ZANTT0`**.
   * Usa la **barra espaciadora** para marcarlo con un asterisco (`[*]`) y presiona `Enter`.
5. **Método de compresión:**
   * Selecciona **`-z1p`** (*Use parallel gzip compression*). Es la opción recomendada por defecto para equilibrar rapidez y tamaño.
6. **Comprobación del sistema de archivos de origen:**
   * Selecciona **`-sfsck`** (*Skip checking/repairing source file system*). Esto omitirá la revisión previa acelerando el proceso.
7. **Verificación de la imagen creada:**
   * Selecciona **`-senc`** (*Omitir comprobación de la imagen guardada*) o `-enc` si deseas verificar que se ha escrito correctamente al finalizar.
8. **Acción al terminar:**
   * Selecciona **`poweroff`** (*Apagar el equipo tras finalizar*) o **`p`-`choose`** (*Elegir acción al terminar*).
   * Cuando pregunte si deseas guardar archivos de log en el USB, selecciona **No**.

---

### Paso 5: Confirmación y Proceso de Grabación
1. Clonezilla mostrará una pantalla de consola con texto en **color amarillo** con el resumen de la operación.
2. Escribe **`y`** (*Yes*) y pulsa `Enter` para confirmar.
3. Si solicita una segunda confirmación para clonar la tabla de particiones, escribe nuevamente **`y`** y pulsa `Enter`.
4. Espera a que la barra de progreso alcance el **100%**.
5. Una vez completado, retira los pendrives/discos externos cuando el sistema lo indique y apaga el PC.

---

## 📌 Notas para Restauraciones Futuras

* **Despliegue en discos idénticos o mayores:** La imagen guardada se podrá restaurar sin problemas en discos de 500 GB o superiores.
* **Error de destino más pequeño (Ej. SSD de 480 GB / 500 GB estricto):** Si al restaurar esta imagen en otro equipo Clonezilla indica *"Target disk size is too small"*, deberás realizar la restauración en **Modo Expert** y activar el parámetro **`-icds`** (*Ignore disk size checking*).
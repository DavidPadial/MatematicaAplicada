# Guía de Instalación y Configuración de Veyon Master

Esta guía detalla los pasos para instalar y configurar el equipo de control (**Veyon Master**) en el puesto del profesor/técnico, importar las claves de autenticación y cargar la estructura de aulas y equipos.

---

## 1. Descarga e Instalación

1. **Descargar el instalador:**  
   Acceder a la web oficial de Veyon: [https://veyon.io/en/download/](https://veyon.io/en/download/) y descargar la versión correspondiente para Windows (64-bit).

2. **Ejecutar el asistente de instalación:**  
   Durante el proceso de selección de componentes:
   - **En el PC del Profesor / Máster:** Marcar la casilla **Veyon Master** y **Veyon Configurator**.
   - ⚠️ **IMPORTANTE:** **NO instalar Veyon Master en los PCs de los alumnos.** En los equipos de los alumnos únicamente se debe instalar el servicio (*Veyon Service*).

---

## 2. Configuración de Claves de Autenticación

Para que el equipo máster pueda conectarse y controlar los ordenadores de los alumnos, debe compartir el mismo par de claves criptográficas.

1. Abrir la aplicación **Veyon Configurator** (como Administrador).
2. Ir a la sección **Autenticación** (*Authentication*).
3. Asegurarse de que el método seleccionado sea **Claves de autenticación** (*Key file authentication*).
4. Hacer clic en **Importar clave** (*Import key*) e indicar la ruta de la clave guardada en el pendrive:

```text
F:\000_Kingston_KN10_Veyon_BKP\20230928_Veyon_4.8.2.0_instalacion\NEW_pair_keys\20231124_Exported_from_pcmat-ind10_Admin_OK
```

> **Nota alternativa:** Si no se dispone del pendrive, las claves también se pueden exportar/extraer desde la configuración de otro equipo que ya tenga un **Veyon Master** totalmente funcional.

---

## 3. Importación y Ajuste de la Configuración de Aulas

Para no tener que dar de alta la lista de ordenadores y aulas manualmente, se puede clonar la configuración desde un equipo de referencia:

### Paso 3.1: Exportar configuración desde el PC de origen
1. Iniciar sesión o conectarse remotamente a un PC de control existente.
2. Abrir **Veyon Configurator**.
3. En el menú superior, seleccionar **Veyon Configurator** > **Exportar configuración a archivo...** (*Export configuration to file...*).
4. Guardar el archivo JSON generador en una unidad accesible o pendrive.

### Paso 3.2: Importar configuración en el PC nuevo
1. En el nuevo PC Máster, abrir **Veyon Configurator**.
2. Seleccionar **Veyon Configurator** > **Importar configuración desde archivo...** (*Import configuration from file...*).
3. Seleccionar el archivo guardado en el paso anterior y aplicar los cambios.

### Paso 3.3: Añadir el PC de origen/máster
1. Ir al apartado **Ubicaciones y equipos** (*Locations & Computers*).
2. Revisar la lista de ordenadores de la ubicación actual.
3. **Añadir manualmente el PC desde el cual se extrajo la configuración** (ya que la configuración exportada suele omitir la entrada del propio equipo desde donde se realizó el respaldo).
4. Indicar el nombre del equipo y su dirección IP / Hostname correspondiente.

---

## 4. Finalización y Aplicación de Cambios

1. Hacer clic en el botón **Aplicar** (*Apply*) en la esquina inferior derecha de Veyon Configurator.
2. Confirmar el reinicio de los servicios de Veyon si el programa lo solicita.
3. Abrir la aplicación **Veyon Master** y comprobar que las aulas y ordenadores cargan correctamente en el panel de monitorización.

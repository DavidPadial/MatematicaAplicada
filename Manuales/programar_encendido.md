# Guía Rápida: Programar Encendido del Aula en Ubuntu Server

Este documento explica cómo programar el script `encender_aula.sh` para enviar paquetes Wake-on-LAN a todos los equipos de forma automática.

---

## 1. Requisito Previo

Asegúrate de que el script tiene permisos de ejecución:

```bash
chmod +x /home/telab-matap/encender_aula.sh
```

---

## 2. Opción A: Programar una Ejecución Única (Comando `at`)

Ideal para encender el aula un día y a una hora específicos (por ejemplo, para un examen puntual).

### Sintaxis básica:
```bash
echo "/home/telab-matap/encender_aula.sh" | at HH:MM DD.MM.AAAA
```

### Ejemplos:
- **Hoy a las 11:30:**
  ```bash
  echo "/home/telab-matap/encender_aula.sh" | at 11:30
  ```
- **Un día concreto (ej. 29 de octubre a las 08:30):**
  ```bash
  echo "/home/telab-matap/encender_aula.sh" | at 08:30 29.10.2026
  ```

### Comandos útiles para `at`:
- Ver tareas pendientes en cola:
  ```bash
  atq
  ```
- Cancelar una tarea programada (usando el ID que muestra `atq`):
  ```bash
  atrm ID_DE_LA_TAREA
  ```

---

## 3. Opción B: Programar Encendido Periódico (Comando `cron`)

Ideal si quieres que los ordenadores se enciendan automáticamente de forma recurrente (por ejemplo, de lunes a viernes a las 08:00 AM).

### Pasos:
1. Abre el editor de tareas programadas:
   ```bash
   crontab -e
   ```
2. Añade la línea al final del archivo:

```text
# Minuto Hora DíaMes Mes DíaSemana Comando
0 8 * * 1-5 /home/telab-matap/encender_aula.sh
```

> **Ejemplo explicado:** `0 8 * * 1-5` ejecutará el script a las **08:00 AM** de **Lunes a Viernes** (1-5).

3. Guarda los cambios (`Ctrl + O`, `Enter`) y sal (`Ctrl + X`).

---

## 4. Verificaciones de Seguridad

- **Comprobar hora del servidor:**
  ```bash
  date
  ```
- **Asegurar zona horaria correcta (España):**
  ```bash
  sudo timedatectl set-timezone Europe/Madrid
  ```

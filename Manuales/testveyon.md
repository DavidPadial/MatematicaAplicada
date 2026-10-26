# Ejecución de scripts PowerShell mediante Veyon

## Problema

Al ejecutar un script PowerShell (`.ps1`) desde **Win + R**, el comando funciona correctamente. Sin embargo, al ejecutar el mismo comando desde **Veyon**, no funciona.

El comando utilizado es:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "C:\Windows\Mat\proxyexamen\activar_modo_examen.ps1"
```

El problema probablemente no está en el script `.ps1`, sino en **cómo Veyon ejecuta los comandos en los equipos remotos**.

Cuando se ejecuta desde `Win + R`, PowerShell se inicia en la sesión del usuario. En cambio, Veyon puede ejecutar los comandos desde el servicio **Veyon Service**, que normalmente utiliza la cuenta `NT AUTHORITY\SYSTEM`.

Esto puede provocar diferencias en:

- Permisos de ejecución.
- Sesión de usuario.
- Directorio de trabajo.
- Acceso a recursos del sistema.
- Configuraciones específicas del usuario.

## 1. Primera prueba: ejecutar el comando desde Veyon

Probar con la ruta completa de PowerShell:

```cmd
C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File "C:\Windows\Mat\proxyexamen\activar_modo_examen.ps1"
```

Se ha eliminado temporalmente el parámetro `-WindowStyle Hidden` para facilitar el diagnóstico.

## 2. Comprobar si Veyon ejecuta el comando

Desde Veyon, enviar el siguiente comando:

```cmd
cmd.exe /c whoami > C:\Windows\Temp\veyon_usuario.txt 2>&1
```

Después, comprobar si se ha creado el archivo:

```text
C:\Windows\Temp\veyon_usuario.txt
```

### Interpretación de los resultados

| Resultado | Interpretación |
|---|---|
| `nt authority\system` | Veyon ejecuta el comando como SYSTEM. |
| Otro usuario | El comando se ejecuta bajo otra cuenta de usuario. |
| No se crea el archivo | Puede existir un problema de ejecución, permisos o configuración de Veyon. |

## 3. Registrar los errores del script

Si la prueba anterior funciona, ejecutar desde Veyon:

```cmd
C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File "C:\Windows\Mat\proxyexamen\activar_modo_examen.ps1" > C:\Windows\Temp\veyon_error.txt 2>&1
```

Los mensajes de salida y error se redirigen al archivo:

```text
C:\Windows\Temp\veyon_error.txt
```

Esto permite comprobar si el script falla al acceder a algún recurso.

**Nota:** La redirección `>` y `2>&1` requiere que el comando se interprete mediante un shell. Si Veyon no interpreta estas redirecciones directamente, utilizar:

```cmd
cmd.exe /c "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File C:\Windows\Mat\proxyexamen\activar_modo_examen.ps1 > C:\Windows\Temp\veyon_error.txt 2>&1"
```

## 4. Diferencias entre el contexto SYSTEM y el usuario

Al utilizar Veyon para activar un **modo examen**, es importante distinguir dos situaciones.

### 4.1. Modificaciones del sistema

Operaciones que normalmente pueden realizarse desde la cuenta `SYSTEM`:

- Modificación de servicios de Windows.
- Configuración del firewall.
- Modificación del proxy del sistema.
- Cambios en el registro de Windows a nivel de equipo (`HKLM`).
- Administración de configuraciones globales.

### 4.2. Modificaciones del usuario

Operaciones que pueden requerir ejecutar el script dentro de la sesión del alumno:

- Configuración del proxy de Windows por usuario.
- Modificación de aplicaciones abiertas.
- Cambios en el registro del usuario (`HKCU`).
- Modificación de configuraciones específicas del perfil.

**Importante:** Cuando un proceso se ejecuta como `SYSTEM`, la clave `HKCU` corresponde al contexto de esa cuenta, no necesariamente al usuario que tiene la sesión iniciada.

Por tanto, un script que funciona correctamente desde `Win + R` puede no producir los mismos resultados cuando se ejecuta desde Veyon.

## 5. Información necesaria para continuar el diagnóstico

Para identificar la causa del problema, es necesario comprobar:

1. El contenido del script `activar_modo_examen.ps1`.
2. La opción de Veyon utilizada para ejecutar el comando, por ejemplo, **Ejecutar programa** desde Veyon Master.
3. El resultado del comando `whoami`.
4. Los posibles errores registrados en `veyon_error.txt`.

Con esta información se puede determinar si el problema se debe al contexto de ejecución de Veyon, a los permisos o al acceso a recursos, evitando modificar innecesariamente el script.

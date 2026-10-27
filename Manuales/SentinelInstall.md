
# Guía de Instalación y Desinstalación de SentinelOne

Documentación de despliegue y eliminación del agente SentinelOne en equipos de las aulas informáticas bajo Windows.

---

## 1. Instalación de SentinelOne

### Parámetros de Configuración
* **Token de Sitio:** `eyJ1cmwiOiAiaHR0cHM6Ly9ldWNlMS0xMDYuc2VudGluZWxvbmUubmV0IiwgInNpdGVfa2V5IjogIjA2ODY0MjllYjIwZDk2Mjc4MTI3MjYzMWZhZDJkM3YzYmI0ODg2ZWNiODNlMjBjOTRhOTM1YzRhN2E1ZjE3MmEifQ==`
* **Servidor Proxy:** `http://proxy.satd.uma.es:3128`
* **Ruta del Instalador:** `C:\Windows\mat\SentinelOneInstaller_windows_64bit_v26_2_3_158.exe`

---

### Opción A: Ejecución Directa desde la Consola Local (CMD / PowerShell)

Ejecutar la siguiente orden desde una consola con permisos de **Administrador**:

```cmd
start /wait "" "C:\Windows\mat\SentinelOneInstaller_windows_64bit_v25_1_3_334.exe" -q -a "SERVER_PROXY=http://proxy.satd.uma.es:3128" -t "eyJ1cmwiOiAiaHR0cHM6Ly9ldWNlMS0xMDYuc2VudGluZWxvbmUubmV0IiwgInNpdGVfa2V5IjogIjA2ODY0MjllYjIwZDk2Mjc4MTI3MjYzMWZhZDJkM3YzYmI0ODg2ZWNiODNlMjBjOTRhOTM1YzRhN2E1ZjE3MmEifQ=="
```
Comprobar que se está ejecutando la instalacion

```cmd
tasklist /FI "IMAGENAME eq SentinelOneInstaller_windows_64bit_v25_1_3_334.exe"
```

---

### Opción B: Despliegue Masivo mediante Veyon

#### 1. Crear el Script Batch de Instalación
Guardar el siguiente código en la ruta `C:\Windows\mat\instalar_sentinel.bat`:

```cmd
@echo off
:: ==============================================================================
:: INSTALACIÓN SILENCIOSA DE SENTINELONE CON PROXY Y TOKEN
:: Ruta: C:\Windows\mat\instalar_sentinel.bat
:: ==============================================================================

echo [1/3] Comprobando ejecutable del instalador...
if not exist "C:\Windows\mat\SentinelOneInstaller_windows_64bit_v26_2_3_158.exe" (
    echo [ERROR] No se encuentra el archivo SentinelOneInstaller_windows_64bit_v26_2_3_158.exe en C:\Windows\mat\
    pause
    exit /b 1
)

echo [2/3] Ejecutando la instalacion de SentinelOne... Por favor, espere.
start /wait "" "C:\Windows\mat\SentinelOneInstaller_windows_64bit_v26_2_3_158.exe" -a "SERVER_PROXY=http://proxy.satd.uma.es:3128" -t "eyJ1cmwiOiAiaHR0cHM6Ly9ldWNlMS0xMDYuc2VudGluZWxvbmUubmV0IiwgInNpdGVfa2V5IjogIjA2ODY0MjllYjIwZDk2Mjc4MTI3MjYzMWZhZDJkM3YzYmI0ODg2ZWNiODNlMjBjOTRhOTM1YzRhN2E1ZjE3MmEifQ=="

if %ERRORLEVEL% equ 0 (
    echo [OK] La instalacion ha finalizado correctamente (Codigo de salida: 0).
) else (
    echo [ERROR] La instalacion ha fallado con el codigo: %ERRORLEVEL%
)

echo [3/3] Verificando el estado del servicio SentinelAgent...
sc query SentinelAgent

echo.
echo Proceso finalizado.
pause
```

#### 2. Lanzamiento desde Veyon Master
Para lanzar la instalación en todos los equipos simultáneamente, enviar la siguiente orden desde **Veyon Master** (*Ejecutar comando*):

```cmd
cmd.exe /c "C:\Windows\mat\instalar_sentinel.bat"
```

---

## 2. Desinstalación de SentinelOne

### Parámetros de Desinstalación
* **Token / Passphrase de Desinstalación:** `HOWE GALE SEC LORE COT BOAT ARGO POP WADE MADE STAY ECHO`
* **Herramienta:** `sentinelctl.exe`
* **Ruta Habitual de `sentinelctl`:**  
  `C:\Program Files\SentinelOne\Sentinel Agent <versión>\sentinelctl.exe`

---

### Comando de Desinstalación

Ejecutar desde el Símbolo del Sistema (**CMD como Administrador**):
> **Nota:** Si la variable de entorno no reconoce `sentinelctl` de forma directa, acude primero a la carpeta de instalación del agente:
```cmd
start /wait "" "C:\Windows\mat\SentinelOneInstaller_windows_64bit_v25_1_3_334.exe" -c -t "eyJ1cmwiOiAiaHR0cHM6Ly9ldWNlMS0xMDYuc2VudGluZWxvbmUubmV0IiwgInNpdGVfa2V5IjogIjA2ODY0MjllYjIwZDk2Mjc4MTI3MjYzMWZhZDJkM3YzYmI0ODg2ZWNiODNlMjBjOTRhOTM1YzRhN2E1ZjE3MmEifQ==" -k "HOWE GALE SEC LORE COT BOAT ARGO POP WADE MADE STAY ECHO"
```



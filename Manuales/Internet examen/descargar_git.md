ejecutar en administrador como administrador


```poweshell


# 1. Configurar protocolo de seguridad TLS 1.2 y definir el proxy de la UMA
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$proxy       = "http://proxy.satd.uma.es:3128"
$zipPath     = "$env:USERPROFILE\Downloads\repo_temp.zip"
$extractPath = "$env:USERPROFILE\Downloads\repo_temp"
$destinoFile = "C:\Windows\mat\mozilla.cfg"

# 2. Probar descarga de ramas (master / main) desde GitHub
$urls = @(
    "https://github.com/DavidPadial/MatematicaAplicada/archive/refs/heads/master.zip",
    "https://github.com/DavidPadial/MatematicaAplicada/archive/refs/heads/main.zip"
)

$descargado = $false
foreach ($url in $urls) {
    try {
        Invoke-WebRequest -Uri $url -OutFile $zipPath -Proxy $proxy -UseBasicParsing -ErrorAction Stop
        $descargado = $true
        break
    } catch {
        try {
            # Intento secundario sin especificar el proxy por si la máquina no lo requiere
            Invoke-WebRequest -Uri $url -OutFile $zipPath -UseBasicParsing -ErrorAction Stop
            $descargado = $true
            break
        } catch {}
    }
}

# 3. Extraer y sobrescribir el archivo mozilla.cfg
if ($descargado) {
    Expand-Archive -Path $zipPath -DestinationPath $extractPath -Force

    $repoFolder = (Get-ChildItem -Path $extractPath | Select-Object -First 1).FullName
    $cfgOrigen  = Join-Path $repoFolder "Manuales\Internet examen\ficheros\mat\mozilla.cfg"

    if (Test-Path $cfgOrigen) {
        if (-not (Test-Path "C:\Windows\mat")) { New-Item -ItemType Directory -Path "C:\Windows\mat" -Force }

        # Sobrescribir forzadamente el archivo local
        Copy-Item -Path $cfgOrigen -Destination $destinoFile -Force
        Write-Host "¡El archivo mozilla.cfg se ha sobrescrito con éxito en C:\Windows\mat!" -ForegroundColor Green
    } else {
        Write-Host "Error: No se encontró el archivo mozilla.cfg en el repositorio." -ForegroundColor Red
    }

    # 4. Limpiar los archivos temporales de Descargas
    Remove-Item -Path $zipPath -Force -ErrorAction SilentlyContinue
    Remove-Item -Path $extractPath -Recurse -Force -ErrorAction SilentlyContinue
} else {
    Write-Host "Error: No se pudo conectar a GitHub para descargar el archivo." -ForegroundColor Red
}

```


Pegar en veyon


```
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; $proxy = 'http://proxy.satd.uma.es:3128'; $zipUrl = 'https://github.com/DavidPadial/MatematicaAplicada/archive/refs/heads/main.zip'; $zipPath = 'C:\Windows\Temp\repo.zip'; $temp = 'C:\Windows\Temp\repo_temp'; $destino = 'C:\Windows\mat'; try { Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath -Proxy $proxy -UseBasicParsing } catch { Invoke-WebRequest -Uri 'https://github.com/DavidPadial/MatematicaAplicada/archive/refs/heads/master.zip' -OutFile $zipPath -Proxy $proxy -UseBasicParsing }; Expand-Archive -Path $zipPath -DestinationPath $temp -Force; if (-not (Test-Path $destino)) { New-Item -ItemType Directory -Path $destino -Force }; $repoFolder = (Get-ChildItem -Path $temp | Select-Object -First 1).FullName; $origen = Join-Path $repoFolder 'Manuales\Internet examen\ficheros\mat\*'; Copy-Item -Path $origen -Destination $destino -Recurse -Force; Remove-Item $zipPath -Force -ErrorAction SilentlyContinue; Remove-Item $temp -Recurse -Force -ErrorAction SilentlyContinue"
```


# 1. Configurar protocolo de seguridad TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# 2. Definir variables principales
$proxy       = "http://proxy.satd.uma.es:3128"
$zipPath     = "$env:USERPROFILE\Downloads\repo.zip"
$extractPath = "$env:USERPROFILE\Downloads\repo_temp"
$destino     = "C:\Windows\mat"

# 3. Lista de URLs candidatas (main y master)
$urls = @(
    "https://github.com/DavidPadial/MatematicaAplicada/archive/refs/heads/master.zip",
    "https://github.com/DavidPadial/MatematicaAplicada/archive/refs/heads/main.zip"
)

$descargado = $false

foreach ($url in $urls) {
    try {
        Write-Host "Probando descarga desde: $url" -ForegroundColor Cyan
        Invoke-WebRequest -Uri $url -OutFile $zipPath -Proxy $proxy -UseBasicParsing -ErrorAction Stop
        $descargado = $true
        Write-Host "¡Descarga completada con éxito!" -ForegroundColor Green
        break
    } catch {
        Write-Host "No disponible en esta ruta (Error 404 / Conexión), probando la siguiente..." -ForegroundColor Yellow
    }
}

# 4. Descomprimir y copiar si se completó la descarga
if ($descargado) {
    # Descomprimir ZIP temporal
    Expand-Archive -Path $zipPath -DestinationPath $extractPath -Force

    # Detectar automáticamente la carpeta raíz generada (MatematicaAplicada-master o MatematicaAplicada-main)
    $repoFolder = (Get-ChildItem -Path $extractPath | Select-Object -First 1).FullName
    $origen = Join-Path $repoFolder "Manuales\Internet examen\ficheros\mat"

    if (Test-Path $origen) {
        if (-not (Test-Path $destino)) { New-Item -ItemType Directory -Path $destino -Force }
        Copy-Item -Path "$origen\*" -Destination $destino -Recurse -Force
        Write-Host "¡Ficheros copiados correctamente a $destino!" -ForegroundColor Green
    } else {
        Write-Host "No se encontró la subcarpeta interna: $origen" -ForegroundColor Red
    }

    # Limpiar los archivos descargados en la carpeta Descargas
    Remove-Item -Path $zipPath -Force -ErrorAction SilentlyContinue
    Remove-Item -Path $extractPath -Recurse -Force -ErrorAction SilentlyContinue
} else {
    Write-Host "Error: No se pudo descargar el repositorio. Comprueba la conexión al proxy o la existencia del repositorio." -ForegroundColor Red
}


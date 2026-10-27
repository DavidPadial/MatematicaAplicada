# Gestión de Paquetes de R para Exámenes (Veyon / CMD)

Este documento contiene los comandos necesarios para la instalación masiva, comprobación y mantenimiento de los paquetes de R a través de la consola de comandos de Windows (CMD), optimizado para su despliegue remoto en aulas mediante **Veyon**.

## 1. Instalación Completa (Todos los paquetes de CRAN)

Descarga e instala de forma binaria todos los paquetes disponibles en el repositorio oficial que no se encuentren ya instalados en el sistema, utilizando la máxima cantidad de núcleos hilos disponibles menos uno.

```cmd
"C:\Program Files\(\R\R-\)4.5.1\bin\Rscript.exe" -e "pkgs <- available.packages(repos='https://cloud.r-project.org')[, 'Package']; installed <- rownames(installed.packages()); install.packages(setdiff(pkgs, installed), repos='https://cloud.r-project.org', type='binary', Ncpus=max(1, parallel::detectCores()-1))"
```

* **URL de referencia:** `https://cloud.r-project.org/bin/windows/contrib/4.5/PACKAGES`

---

## 2. Instalación de Selección Específica (Desde Veyon)

Comando optimizado para lanzar de forma masiva a las máquinas a través de Veyon. Incluye una lista explícita de paquetes esenciales y el paquete `e1071` (para evitar los problemas surgidos en el examen anterior).

```cmd
cmd.exe /c ""C:\Program Files\(\R\R-\)4.5.1\bin\Rscript.exe" -e "pkgs <- c('rlang','Rcpp','cli','vctrs','lifecycle','cpp11','glue','pkgconfig','tidyverse','data.table','readxl','haven','ggplot2','ggpubr','patchwork','scales','car','lme4','glmmTMB','mgcv','quantreg','robustbase','pscl','nlme','rms','gamlss','brms','rstan','rstanarm','bayesplot','MCMCpack','loo','forecast','fable','tseries','vars','urca','plm','lmtest','sandwich','rugarch','zoo','FactoMineR','factoextra','cluster','mclust','dbscan','e1071','pROC','caret','survival','survminer','lavaan','psych','metafor','mice','MatchIt','boot','coin'); install.packages(unique(pkgs), repos='https://cloud.r-project.org', type='binary', Ncpus=max(1, parallel::detectCores()-1))""
```

---

## 3. Comprobaciones de Estado

### Ver todos los paquetes instalados en R
Para ver la lista directamente dentro de una sesión de R:
```R
rownames(installed.packages())
```

### Listar e imprimir instalados (CMD con pausa)
Muestra en la consola de Windows todos los paquetes instalados en el equipo actual y mantiene la ventana abierta para su revisión.
```cmd
cmd.exe /c ""C:\Program Files\(\R\R-\)4.5.1\bin\Rscript.exe" -e "writeLines(rownames(installed.packages()))" & pause"
```

### Comprobar paquetes críticos (`rlang` y `e1071`)
Devuelve de forma explícita el estado `INSTALADO` o `NO INSTALADO` para los dos paquetes que suelen generar conflictos.
```cmd
cmd.exe /c ""C:\Program Files\(\R\R-\)4.5.1\bin\Rscript.exe" -e "pkgs <- c('e1071', 'rlang'); inst <- rownames(installed.packages()); writeLines(paste(pkgs, ':', ifelse(pkgs %in% inst, 'INSTALADO', 'NO INSTALADO')))" & pause"
```

---

## 4. Diagnóstico y Corrección bajo demanda

### Comprobar e instalar una lista específica si falta alguno
Verifica de forma selectiva un grupo de paquetes (`stats`, `tidyverse`, `rlang`, `e1071`) e inicia la instalación automática únicamente de aquellos que falten en el sistema.

```cmd
cmd.exe /c ""C:\Program Files\(\R\R-\)4.5.1\bin\Rscript.exe" -e "pkgs <- c('stats', 'tidyverse', 'rlang', 'e1071'); inst <- rownames(installed.packages()); faltan <- pkgs[!pkgs %in% inst]; if(length(faltan) > 0) { install.packages(faltan, repos='https://cloud.r-project.org', type='binary', Ncpus=max(1, parallel::detectCores()-1)) }" & pause"
```

---

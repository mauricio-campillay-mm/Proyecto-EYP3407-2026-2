# Instalación y ejecución

Guía para reproducir el proyecto en un equipo nuevo. El análisis completo se ejecuta
con un solo comando; los documentos también pueden generarse sin repetirlo.

## 1. Requisitos

| Componente | Versión | Notas |
|---|---|---|
| R | 4.6.2 recomendada | Otra versión muestra un aviso y continúa. Probada también con 4.4.1 |
| Paquetes de R | Los de `renv.lock` (129) | Se instalan con `instalar.R`; no hace falta instalarlos a mano |
| Quarto | 1.11.9 (mínimo 1.8.13) | Genera los PDF |
| LaTeX | TinyTeX | Se instala con `quarto install tinytex` |
| Memoria | 8 GB mínimo, 16 GB recomendado | El ajuste de modelos usa cerca de 2 GB |
| Tiempo | ~20 min de análisis | Más ~1 min de instalación de paquetes |
| Internet | Sólo durante la instalación | Para descargar paquetes y LaTeX |

Entornos probados:

| Sistema | R | Resultado |
|---|---|---|
| Windows 11 x64 | 4.6.2 | Instalación y análisis completos desde un clon limpio |
| Windows 11 x64 | 4.4.1 | Análisis completo con aviso de versión; tablas idénticas a R 4.6.2 |
| Ubuntu 24.04 y Windows (GitHub Actions) | 4.6.2 | Ver la pestaña *Actions* del repositorio |

macOS no está probado. El repositorio de paquetes fijado no ofrece binarios para
macOS, por lo que `renv` compilaría desde el código fuente: se necesitan las
*Command Line Tools* de Xcode (`xcode-select --install`) y `gfortran`.

## 2. Instalación paso a paso

1. Instale [R](https://cran.r-project.org/) y [Quarto](https://quarto.org/docs/get-started/).
2. Clone el repositorio (o descomprima la copia de la entrega) y abra una terminal en su raíz.
3. Instale los paquetes con las versiones exactas:
   ```bash
   Rscript --vanilla instalar.R
   ```
4. Instale LaTeX, si no lo tiene:
   ```bash
   quarto install tinytex
   ```

En Windows, si `Rscript` no se reconoce, use la ruta completa, por ejemplo
`"C:\Program Files\R\R-4.6.2\bin\Rscript.exe"`. No se necesita Rtools.

En Linux, los paquetes se descargan ya compilados desde Posit Package Manager. Si
alguno debiera compilarse, instale las herramientas habituales, por ejemplo en
Ubuntu: `sudo apt install build-essential gfortran libcurl4-openssl-dev libssl-dev`.

## 3. Ejecución completa

```bash
Rscript --vanilla analisis.R
```

Primero `R/00_entorno.R` comprueba la versión de R, los paquetes, el MD5 de
`datos/caso08_nyc311.zip`, Quarto y LaTeX, y se detiene con un mensaje claro si algo falta.
Después se ejecutan los scripts `R/01` a `R/06`, se guarda `insumos_qmd.RData` y se
generan `informe.pdf` y `presentacion.pdf`. Todos los resultados quedan en `output/`.

Para que el resultado no dependa del equipo se fijan la semilla (3407), el generador
aleatorio, el orden alfabético de las categorías y el número de hilos de `xgboost` (4).

## 4. Generar los documentos sin repetir el análisis

`insumos_qmd.RData` guarda las tablas, figuras y resultados de la última ejecución
completa, sin la base con direcciones. Si `output/` no existe, los documentos lo
restauran desde ese archivo:

```bash
quarto render informe.qmd
```
```bash
quarto render presentacion.qmd
```

Para trabajar con los resultados en R:

```r
source("R/cargar_insumos.R")   # restaura output/ si hace falta
load("insumos_qmd.RData")      # crea los objetos tablas y meta
names(tablas)                  # tablas disponibles
tablas$comparacion_reserva     # comparación de modelos en 2023
readRDS("output/predicciones_reserva.rds")  # predicciones de cada modelo
```

Esto sirve para redactar y revisar. La prueba de reproducibilidad exigida por el
curso es la ejecución completa de la sección 3.

## 5. Comprobar que se obtuvieron los mismos resultados

Antes de ejecutar, guarde una copia del archivo publicado y compárela con el nuevo:

```bash
cp insumos_qmd.RData referencia.RData
Rscript --vanilla analisis.R
Rscript --vanilla pruebas/comparar_resultados.R referencia.RData insumos_qmd.RData
```

El script compara todas las tablas (ignorando los tiempos de cómputo) y termina con
error si alguna difiere en más de 0,000001.

## 6. Problemas frecuentes

| Mensaje | Solución |
|---|---|
| `Paquetes faltantes o con otra versión` | Ejecute `Rscript --vanilla instalar.R` |
| `El informe se generó con R 4.6.2 y se está usando R ...` | Aviso: el análisis continúa. Para cifras idénticas, use R 4.6.2 |
| `No se encontró Quarto` | Instale Quarto y abra una terminal nueva |
| `No se encontró LaTeX` | `quarto install tinytex` |
| `no coincide con la copia entregada (MD5 distinto)` | Reemplace `datos/caso08_nyc311.zip` por la copia original |
| Error de Quarto al generar los PDF | Cierre cualquier vista previa de Quarto abierta (por ejemplo en VS Code) y repita |
| Falta de memoria | Cierre otros programas; el análisis usa cerca de 2 GB |

# Instructivo: trabajar el informe y la presentación sin correr el análisis

Para redactar `informe.qmd` y `presentacion.qmd` **no hace falta ejecutar los ~20 minutos
de modelos**. Todos los resultados (tablas, figuras y predicciones) vienen guardados en
`insumos_qmd.RData`, y los documentos los cargan solos.

`insumos_qmd.RData` no contiene la base con direcciones: sólo resultados agregados.

## Paso 1. Instalar los programas (una sola vez, ~10 min)

1. **R 4.6.2**: <https://cran.r-project.org/bin/windows/base/> (otra versión de R
   también funciona, sólo muestra un aviso).
2. **Quarto**: <https://quarto.org/docs/get-started/>.
3. Opcional: **RStudio** o **VS Code** para editar.

## Paso 2. Obtener el proyecto

Necesita la rama `avance-fases-3-6` completa, no sólo el `.RData`: los `.qmd` y el
archivo `R/cargar_insumos.R` de esa rama son los que saben leerlo. El repositorio de
la versión original (`main`) no sirve para esto.

**Opción A, sin Git:** descargue y descomprima

<https://github.com/mauricio-campillay-mm/Proyecto-EYP3407-2026-2/archive/refs/heads/avance-fases-3-6.zip>

**Opción B, con Git:**

```bash
git clone -b avance-fases-3-6 https://github.com/mauricio-campillay-mm/Proyecto-EYP3407-2026-2
```

Ambas opciones ya traen `insumos_qmd.RData` en la carpeta principal. Si un compañero
le envía una versión más nueva de ese archivo, **reemplácelo en la carpeta principal
del proyecto** (junto a `informe.qmd`) y borre la carpeta `output/` si existe.

## Paso 3. Instalar LaTeX y los paquetes (una sola vez, ~5 min)

Abra una terminal **en la carpeta del proyecto** (en Windows: abra la carpeta en el
Explorador, escriba `powershell` en la barra de direcciones y presione Enter) y ejecute,
en este orden:

```bash
quarto install tinytex
```

```bash
Rscript --vanilla instalar.R
```

El primero instala LaTeX; el segundo instala los paquetes de R con las versiones exactas
del proyecto y los paquetes de LaTeX que usan los documentos. Debe terminar con
`Instalación terminada`.

Si `Rscript` no se reconoce, use la ruta completa:

```powershell
& "C:\Program Files\R\R-4.6.2\bin\Rscript.exe" --vanilla instalar.R
```

## Paso 4. Generar los documentos (~1-2 min cada uno)

```bash
quarto render informe.qmd
```

```bash
quarto render presentacion.qmd
```

La primera vez aparece el mensaje *Resultados restaurados desde insumos_qmd.RData*: se
creó la carpeta `output/` con todo lo necesario. Se obtienen `informe.pdf` y
`presentacion.pdf`, idénticos a los de la ejecución completa.

En RStudio también sirve abrir `Proyecto-EYP3407-2026-2.Rproj`, luego el `.qmd`, y
presionar **Render**.

## Paso 5. Redactar

Los lugares que completa el equipo están marcados en cursiva entre paréntesis. En
`informe.qmd`:

| Sección | Qué escribir |
|---|---|
| Resumen ejecutivo | Respuesta breve a la pregunta, con las cifras principales |
| Resultados → Comparación en desarrollo | Tamaño de la mejora frente a la referencia y estabilidad entre ventanas |
| Resultados → Matriz de confusión | Qué significan la sensibilidad y el VPP para priorizar seguimiento |
| Resultados → Análisis de errores | Subgrupos con peor desempeño, sus tamaños y extremos |
| Resultados → Análisis de sensibilidad | Qué decisión cambia y si cambia la conclusión |
| Discusión → Respuesta a la pregunta | Conclusión con los resultados finales |
| Discusión → Condiciones de uso | Cuándo la recomendación es confiable y cuándo no |
| Reproducibilidad → Aportes y Declaración de IA | Aporte de cada integrante y comprobaciones realizadas |

En `presentacion.qmd`, ajustar la diapositiva de **Recomendación** (marcada como borrador).

Recomendaciones:

- Escriba sólo en el texto; **no modifique los bloques de código** (entre ```` ```{r} ```` y
  ```` ``` ````) ni el encabezado YAML.
- Genere el PDF seguido para detectar errores a tiempo.
- Las cifras de las tablas se actualizan solas; no las copie a mano en el texto si
  puede citarlas desde la tabla.

## Consultar los resultados en R

Para revisar números al redactar, en la consola de R abierta en la carpeta del proyecto:

```r
source("R/cargar_insumos.R")   # crea output/ si falta
load("insumos_qmd.RData")      # crea los objetos tablas y meta
names(tablas)                  # lista de las 28 tablas
tablas$comparacion_reserva     # modelos en la reserva 2023
tablas$incertidumbre_reserva   # intervalos bootstrap
tablas$matriz_confusion_reserva  # matriz de confusión al umbral
tablas$sensibilidad            # análisis de sensibilidad
meta                           # versión de R, fecha y tiempo de la ejecución
```

Las figuras están en `output/figuras/` y las tablas como `.csv` en `output/tablas/`.

## Problemas frecuentes

| Mensaje | Solución |
|---|---|
| `Faltan los resultados: ejecute ... o copie insumos_qmd.RData` | Falta el `.RData` en la carpeta principal: cópielo junto a `informe.qmd` |
| `there is no package called ...` | Ejecute `Rscript --vanilla instalar.R` desde la carpeta del proyecto |
| `No se encontró LaTeX` o error de `lualatex` | `quarto install tinytex` y luego otra vez `instalar.R` |
| La generación queda detenida en `updating existing packages` | Cancele (Ctrl+C) y ejecute `Rscript --vanilla instalar.R` |
| El PDF muestra resultados antiguos | Borre `output/` y vuelva a generar con el `.RData` nuevo |
| Error de archivo bloqueado | Cierre la vista previa de Quarto y el PDF abierto en el visor, y repita |

## Enviar los cambios

Al terminar, envíe su `informe.qmd` / `presentacion.qmd` editado a quien integra la
versión final (o súbalo a la rama si tiene acceso). No hace falta enviar `output/`
ni los PDF: se regeneran.

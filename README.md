# EYP3407 — Caso 08: Plazos de cierre de solicitudes NYC 311

Trabajo final de *Tópicos Aplicados en Estadística* (EYP3407, 2.º semestre 2026).
Este repositorio contiene el análisis reproducible: con un solo comando se construye la
base analítica, se ajustan y comparan los modelos y se generan todas las tablas y figuras
que usan el informe y la presentación.

## Integrantes
- Diego Barrios (@nickname1)
- Renato Bazaes [@RenatoBazaesS](https://github.com/RenatoBazaesS)
- Mauricio Campillay [@mauricio-campillay-mm](https://github.com/mauricio-campillay-mm)
- Bruno Zavala (@nickname4)

## Pregunta
Al ingresar una solicitud de la agencia HPD con categoría PLUMBING (2021–2023), ¿cuál es
la probabilidad de que siga **sin cierre administrativo al cumplirse 7 días** (168 horas)?

- **Audiencia y decisión:** equipos de HPD que priorizan el seguimiento de solicitudes.
- **Unidad:** una solicitud, identificada por `unique_key`.
- **Respuesta:** `Y = 1` si no hay cierre registrado en las primeras 168 h desde
  `created_date`; `Y = 0` si el cierre ocurre dentro de ese plazo.
- **Momento de la predicción:** al ingreso; sólo se usa información conocida en ese instante.
- **Alcance:** evaluación retrospectiva con la copia entregada. El cierre administrativo
  no equivale a resolución material del problema, y una asociación predictiva no es un
  efecto causal. Detalle en [docs/00_definicion_problema.md](docs/00_definicion_problema.md).

## Contenido del repositorio

```text
├── README.md                 # este archivo: datos, entorno, ejecución, código y consideraciones
├── analisis.R                # punto de entrada único: ejecuta todo el análisis
├── instalar.R                # instala las versiones exactas de los paquetes (renv.lock)
├── renv.lock                 # versión de R y de los 129 paquetes
├── informe.pdf               # informe final
├── presentacion.pdf          # presentación final
├── R/
│   ├── 00_entorno.R          # verifica R, paquetes y datos; fija opciones deterministas
│   ├── 01_preparacion.R      # auditoría, construcción de Y y base analítica
│   ├── 02_particiones.R      # predictores, historial sin fuga y particiones temporales
│   ├── 03_modelos.R          # M1, M2, M3 y búsqueda de hiperparámetros
│   ├── 04_evaluacion.R       # comparación con la referencia, selección y umbral
│   ├── 05_diagnostico.R      # dos sensibilidades y estabilidad (sólo desarrollo)
│   └── 06_reserva.R          # evaluación única en 2023, incertidumbre y errores
├── datos/
│   ├── caso08_nyc311.zip     # paquete original del curso, sin editar (MD5 verificado)
│   ├── diccionario.csv       # diccionario de variables
│   └── LEEME.txt             # descripción de la copia entregada
├── docs/
│   └── 00_definicion_problema.md
├── .github/workflows/
│   └── reproducibilidad.yml  # prueba automática desde cero en Linux y Windows
└── output/                   # lo crea analisis.R (no se versiona)
    ├── tablas/*.csv
    ├── figuras/*.png
    ├── *.rds
    └── sessionInfo.txt
```

`informe.pdf` y `presentacion.pdf` se redactan en LaTeX a partir de las tablas y figuras de
`output/` (ver [Informe y presentación](#informe-y-presentación)).

## Datos

| Aspecto | Detalle |
|---|---|
| Archivo | `datos/caso08_nyc311.zip`, incluido en el repositorio |
| Contenido | `datos.csv` (170 808 solicitudes), `diccionario.csv`, `LEEME.txt` |
| Fuente | NYC Open Data, *311 Service Requests from 2020 to Present* (ID `erm2-nwe9`) |
| Copia | Preparada por el curso el 12 de octubre de 2026 (Canvas, "Proyecto Final: Caso 08") |
| Filtro | `agency = HPD`, `complaint_type = PLUMBING`, `created_date` entre 2021-01-01 y 2023-12-31 |
| MD5 del zip | `42a7931a2a2b19fdfa04b73823c85903` |

### Cómo se cargan
No hay pasos manuales. `R/01_preparacion.R` extrae `datos.csv` del zip a `datos/` si no
está, y lo lee con `readr::read_csv` (UTF-8, coma separadora, punto decimal), junto con
`datos/diccionario.csv`. Antes, `R/00_entorno.R` comprueba el MD5: si el zip fue modificado, el análisis se
detiene. `datos/datos.csv` no se versiona porque se regenera desde el zip.

Si el zip no estuviera, descárguelo de Canvas (curso EYP3407, Caso 08) y cópielo sin
descomprimir en `datos/`. No hace falta descargar nada desde NYC Open Data: la consulta
original está en `datos/LEEME.txt`.

### Uso responsable
La base contiene direcciones e identificadores de inmuebles (`bbl`). Se usan sólo para
agrupar y construir el historial, nunca para publicar listados. Por eso `output/` no se
sube al repositorio: `output/datos_auditados.rds` tiene una fila por solicitud con esas
direcciones. Las tablas y figuras publicadas son agregadas.

## Requisitos e instalación

| Componente | Versión | Notas |
|---|---|---|
| R | 4.6.2 | Con otra versión, el análisis avisa y continúa; probado también con 4.4.1 |
| Paquetes | Los de `renv.lock` | Se instalan con `instalar.R` |
| Memoria | 8 GB mínimo, 16 GB recomendado | El ajuste usa cerca de 2 GB |
| Tiempo | ~20–25 min | Más ~2 min de instalación |
| Internet | Sólo durante la instalación | |

1. Instale [R 4.6.2](https://cran.r-project.org/). En Windows no se necesita Rtools.
2. Clone el repositorio (o descomprima la copia de la entrega) y abra una terminal en su raíz.
3. Instale los paquetes:
   ```bash
   Rscript --vanilla instalar.R
   ```
   `renv` crea una biblioteca propia del proyecto (`renv/library`) con las versiones
   exactas, sin tocar los paquetes que ya tenga instalados. El repositorio de paquetes está
   fijado a Posit Package Manager del 6 de noviembre de 2026, que ofrece binarios para
   Windows y Linux.

Si `Rscript` no se reconoce, use la ruta completa, por ejemplo
`"C:\Program Files\R\R-4.6.2\bin\Rscript.exe"`. En Linux, si algún paquete debiera
compilarse: `sudo apt install build-essential gfortran libcurl4-openssl-dev libssl-dev`.
macOS no está probado: el repositorio fijado no trae binarios para macOS y `renv`
compilaría desde el código fuente (requiere `xcode-select --install` y `gfortran`).

## Ejecución

```bash
Rscript --vanilla analisis.R
```

Este único comando ejecuta, en orden, `R/00_entorno.R` a `R/06_reserva.R`, guarda todas las
tablas y figuras en `output/` e imprime al final la comparación de modelos en 2023 y el
tiempo total. `--vanilla` garantiza que no se usen objetos de una sesión previa; el propio
`analisis.R` activa `renv`.

## Explicación del código

Cada script deja en memoria los objetos que usa el siguiente, por lo que deben ejecutarse
en orden a través de `analisis.R`. Todos están comentados paso a paso.

### `R/00_entorno.R` — entorno
- Fija el orden alfabético (`LC_COLLATE = C`) y el generador aleatorio, para que los
  factores y las semillas no dependan del idioma ni del sistema.
- Compara la versión de R con `renv.lock` (sólo avisa) y la de cada paquete instalado
  (se detiene si alguno falta o difiere).
- Verifica que el zip de datos exista y tenga el MD5 de la copia entregada.

### `R/01_preparacion.R` — base analítica
1. Lee `datos.csv` y el diccionario.
2. Comprueba que `unique_key` identifica una sola fila (`auditoria_clave.csv`).
3. Asigna la zona horaria de Nueva York a las fechas. Las fechas exactamente a medianoche
   y las del cambio de horario se convierten sin perder ninguna.
4. Construye `Y`: duración = `closed_date − created_date`; `Y = 1` si no hay cierre o si
   la duración supera 168 h. Un cierre ausente cuenta como "sin cierre registrado al corte"
   y no se recodifica como 0. Las duraciones negativas se excluirían; no hay ninguna.
5. Documenta cada exclusión (`construccion_muestra.csv`, `diagrama_muestra.png`) y la
   calidad de fechas por separado (`calidad_fechas.csv`).
6. Clasifica cada variable como admisible, excluida o identificador, con su interpretación,
   tipo y disponibilidad (`variables.csv`). Excluye `closed_date`, `status`,
   `resolution_description`, fechas de actualización, `due_date` y `unique_key`.
7. Mide faltantes y cardinalidad, y describe la muestra (`descripcion.csv`,
   `cobertura_anio_borough.csv`).

### `R/02_particiones.R` — predictores y particiones
- **Predictores de ingreso:** mes, día de la semana, hora, canal, `descriptor`,
  `descriptor_2`, borough, distrito comunitario, distrito del concejo, precinto y código
  postal. El año se omite porque 2023 no se observa en entrenamiento.
- **Historial sin fuga** (calculado con `findInterval`, por distrito o inmueble):
  - volumen de solicitudes del distrito en los 7 días previos;
  - tasa del distrito sin cierre a 7 días en los 90 días previos, usando **sólo**
    solicitudes cuyo horizonte de 168 h ya terminó al ingreso;
  - volumen de solicitudes del mismo inmueble en los 90 días previos.
- **Particiones temporales de origen creciente**, con un hueco de 7 días: cada
  entrenamiento sólo incluye solicitudes cuya respuesta ya se conocía en el origen.

  | Partición | Entrenamiento hasta | Validación | n entrenamiento | n validación |
  |---|---|---|---|---|
  | V1 | 2021-12-24 | 2022-01-01 a 2022-04-30 | 51 032 | 20 083 |
  | V2 | 2022-04-23 | 2022-05-01 a 2022-08-31 | 71 001 | 17 152 |
  | V3 | 2022-08-24 | 2022-09-01 a 2022-12-31 | 88 057 | 20 315 |
  | Reserva | 2022-12-24 | 2023-01-01 a 2023-12-31 | 107 640 | 61 344 |

  Se guardan las claves de cada partición en `output/particiones.rds`.

### `R/03_modelos.R` — modelos e hiperparámetros
- **Preprocesamiento** (se estima dentro del entrenamiento de cada ventana): nivel para
  categorías nuevas y para faltantes, agrupación de categorías con menos de 0,5 % de las
  filas, imputación por mediana, variables indicadoras y retiro de columnas constantes.
  Sólo M1 normaliza, porque la penalización depende de la escala.
- **M1, regresión logística lasso** (`glmnet`): 20 valores de penalización.
- **M2, árbol podado** (`rpart`, `min_n = 50`): 20 valores de `cost_complexity`. La poda
  se elige con las ventanas temporales (`xval = 0`), no con la validación interna de rpart.
- **M3, boosting** (`xgboost`, 4 hilos fijos): 20 configuraciones de número de árboles,
  profundidad, tasa de aprendizaje y tamaño mínimo de nodo, con 80 % de filas y columnas.
- Cada familia elige la configuración de menor log-loss medio en V1–V3
  (`hiperparametros.csv`, `grillas_log_loss.csv`).

### `R/04_evaluacion.R` — comparación, selección y umbral
- **Referencia:** tasa de `Y = 1` en el entrenamiento de cada ventana.
- Compara los cuatro procedimientos sobre las mismas filas de validación con log-loss
  (principal), Brier y AUC (`comparacion_desarrollo.csv`, `desarrollo_por_ventana.csv`).
- **Regla de selección,** fijada antes de ver 2023: menor log-loss medio; si un modelo más
  simple queda a menos de 0,002, se prefiere el más simple. Resultado: M1.
- **Umbral:** índice de Youden en las predicciones de validación (`seleccion.csv`).

### `R/05_diagnostico.R` — sensibilidad (sólo desarrollo)
Con los hiperparámetros ya elegidos:
- **S1, representación:** se retiran las tres variables de historial.
- **S2, población:** se colapsan solicitudes repetidas del mismo inmueble y descriptor
  en 7 días (retira 22 % de las filas).
- **Estabilidad** del modelo elegido entre boroughs.
Salidas: `sensibilidad.csv`, `sensibilidad_por_ventana.csv`, `estabilidad_borough_desarrollo.csv`.

### `R/06_reserva.R` — evaluación final única en 2023
- Reajusta cada modelo con todo lo permitido (respuestas conocidas al 2022-12-24) y
  predice 2023 **una sola vez**. Nada se elige aquí.
- Métricas y diferencia frente a la referencia (`comparacion_reserva.csv`), matriz de
  confusión al umbral de desarrollo con sensibilidad y VPP, y calibración por deciles.
- **Incertidumbre:** bootstrap por conglomerados de la diferencia de log-loss (M1 menos
  referencia), con 2 000 réplicas y predicciones fijas, remuestreando por separado
  inmuebles, distritos comunitarios, semanas y meses (`incertidumbre_reserva.csv`).
- **Errores** por distrito, mes, canal y detalle con sus tamaños, colas de probabilidad
  predicha y detalles poco frecuentes (`errores_subgrupos_reserva.csv`,
  `extremos_reserva.csv`, `detalles_raros_reserva.csv`).
- Guarda las predicciones de todos los modelos en `output/predicciones_reserva.rds`.

## Correspondencia con la pauta

| Exigencia de la pauta | Dónde se cumple |
|---|---|
| §2.2 Procedencia, clave, respuesta, auditoría de predictores y calidad | `01_preparacion.R` → `auditoria_clave`, `auditoria_Y`, `variables`, `calidad_na`, `calidad_fechas`, `construccion_muestra` |
| §3.1 Referencia y tres procedimientos | `03_modelos.R`, `04_evaluacion.R` |
| §3.2 Hasta 20 configuraciones y 3 particiones; preprocesamiento interno | `03_modelos.R` |
| §3.3 Dos análisis de sensibilidad | `05_diagnostico.R` (S1 representación, S2 población) |
| §4.1 Desarrollo/prueba separados, hueco de 7 días, prueba una vez | `02_particiones.R`, `06_reserva.R` |
| §4.2 Prevalencia, log-loss, Brier, AUC, matriz de confusión, sensibilidad y VPP | `04_evaluacion.R`, `06_reserva.R` |
| §4.3 Incertidumbre con unidades dependientes | `06_reserva.R` (bootstrap por conglomerados) |
| §4.4 Subgrupos, extremos y situación no confiable | `06_reserva.R` |
| §5.1 Un único comando desde copia limpia | `Rscript --vanilla analisis.R` |
| §5.4 Semilla, tiempo, sistema y prueba registrada | `analisis.R`, `output/sessionInfo.txt`, esta página |

## Resultados que se generan

| Archivo en `output/` | Uso |
|---|---|
| `tablas/construccion_muestra.csv`, `figuras/diagrama_muestra.png` | Construcción de la muestra |
| `tablas/variables.csv` | Variables admisibles y excluidas |
| `tablas/particiones.csv`, `figuras/diagrama_temporal.png` | Diseño de evaluación |
| `tablas/comparacion_desarrollo.csv`, `tablas/hiperparametros.csv` | Comparación en desarrollo |
| `tablas/comparacion_reserva.csv`, `tablas/matriz_confusion_reserva.csv` | Evaluación en 2023 |
| `figuras/calibracion.png`, `tablas/calibracion_resumen.csv` | Calibración |
| `tablas/incertidumbre_reserva.csv` | Intervalos bootstrap |
| `figuras/diagnostico_subgrupos.png`, `tablas/errores_subgrupos_reserva.csv` | Diagnóstico por subgrupo |
| `tablas/sensibilidad.csv` | Análisis de sensibilidad |
| `sessionInfo.txt`, `tablas/tiempo_ejecucion_min.txt` | Registro de la ejecución |

Para revisarlos en R después de ejecutar:

```r
readr::read_csv("output/tablas/comparacion_reserva.csv")
readRDS("output/predicciones_reserva.rds")   # probabilidades de cada modelo en 2023
```

## Informe y presentación
`informe.pdf` y `presentacion.pdf` se escriben en LaTeX con las tablas de `output/tablas`
y las figuras de `output/figuras`. Toda cifra o gráfico de esos documentos debe provenir de
una ejecución de `analisis.R`. Si el código cambia, hay que volver a ejecutarlo y
actualizar las cifras del informe y la presentación con los nuevos archivos.

## Consideraciones
- **Determinismo:** semilla 3407, generador aleatorio y orden alfabético fijos, y 4 hilos
  para `xgboost`. Dos ejecuciones en el mismo sistema dan tablas idénticas; entre sistemas
  operativos pueden aparecer diferencias en el último decimal.
- **Reserva 2023:** se evalúa una sola vez y no se usa para elegir modelos, variables ni
  umbrales. Si se corrige un error después de verla, el informe debe explicarlo (§4.1).
- **Información admisible:** el historial sólo usa solicitudes cuya respuesta a 7 días ya
  se conocía. Se supone que los atributos de ingreso no cambiaron después del ingreso; la
  fuente puede tener campos corregidos y eso no se puede verificar con la copia.
- **Respuesta:** depende del estado administrativo de la copia descargada; un cierre
  tardío en el sistema puede existir sin estar registrado.
- **Incertidumbre:** el bootstrap con predicciones fijas es condicional a los modelos
  ajustados; no incorpora la incertidumbre de selección y entrenamiento.
- **Datos personales:** no publicar `output/` ni la base con direcciones (ver
  [Uso responsable](#uso-responsable)).

### Problemas frecuentes
| Mensaje | Solución |
|---|---|
| `Paquetes faltantes o con otra versión` | Ejecute `Rscript --vanilla instalar.R` |
| `El informe se generó con R 4.6.2 y se está usando R ...` | Aviso; el análisis continúa. Para cifras idénticas, use R 4.6.2 |
| `Falta datos/caso08_nyc311.zip` | Copie el zip del curso en `datos/` |
| `no coincide con la copia entregada (MD5 distinto)` | Reemplace el zip por la copia original |
| Falta de memoria | Cierre otros programas; el análisis usa cerca de 2 GB |

## Reproducibilidad y costo
- Semilla: `set.seed(3407)` en `analisis.R`, más semillas fijas en cada ajuste.
- Tiempo: ~20–25 minutos (19,6 min en el equipo de referencia; 22–24 min en GitHub Actions).
- Sistema de referencia: Windows 11 x64, R 4.6.2, 16 GB de RAM, 4 hilos.
- La sesión completa queda en `output/sessionInfo.txt`.

## Prueba desde una copia limpia
- **10 de noviembre de 2026, equipo de desarrollo:** clon limpio, Windows 11 x64, R 4.6.2.
  `Rscript --vanilla instalar.R` y `Rscript --vanilla analisis.R`: ejecución completa sin
  error; las 28 tablas coinciden exactamente con las de la ejecución anterior.
- **10 de noviembre de 2026, GitHub Actions:** equipos nuevos con Ubuntu 24.04 y Windows
  Server, R 4.6.2, instalación desde cero: ejecución completa sin error en ambos y tablas
  idénticas a las publicadas. Registro en la pestaña *Actions* del repositorio.
- **8 de noviembre de 2026, R 4.4.1:** análisis completo con aviso de versión; tablas
  idénticas a las de R 4.6.2.
- **Computador de otro integrante:** <fecha, sistema, comando y resultado>.

## Aportes del equipo
- Diego Barrios: <aporte>.
- Renato Bazaes: <aporte>.
- Mauricio Campillay: <aporte>.
- Bruno Zavala: <aporte>.

## Declaración de uso de IA
- Herramienta y fecha: Claude Code (modelo Claude Opus 5.5), 8–10 de noviembre de 2026. <agregar otras herramientas usadas por el equipo>.
- Propósito: programación, depuración, entorno reproducible, documentación y borradores de secciones descriptivas.
- Partes afectadas: `analisis.R`, `instalar.R`, `R/00_entorno.R` a `R/06_reserva.R`, este archivo y borradores del informe y la presentación.
- Comprobaciones realizadas: ejecución completa desde un clon limpio y en GitHub Actions. <agregar la revisión manual y verificación hecha por el equipo>.

## Referencias
- NYC Open Data. *311 Service Requests from 2020 to Present*. ID `erm2-nwe9`.
  https://data.cityofnewyork.us/Social-Services/311-Service-Requests-from-2020-to-Present/erm2-nwe9
- Alvarado, E. (2026). *Trabajo final: análisis estadístico reproducible*. EYP3407, Pontificia Universidad Católica de Chile.
- Chen, T. y Guestrin, C. (2016). XGBoost: A Scalable Tree Boosting System. *Proceedings of KDD 2016*.
- Friedman, J., Hastie, T. y Tibshirani, R. (2010). Regularization Paths for Generalized Linear Models via Coordinate Descent. *Journal of Statistical Software*, 33(1).
- James, G., Witten, D., Hastie, T. y Tibshirani, R. (2021). *An Introduction to Statistical Learning* (2.ª ed.). Springer.
- Kuhn, M. y Silge, J. (2022). *Tidy Modeling with R*. O'Reilly.

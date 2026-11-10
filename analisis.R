# analisis.R — punto de entrada único del proyecto (Caso 08, NYC 311)
#
# Uso, desde la raíz del repositorio y después de instalar (ver README.md):
#   Rscript --vanilla analisis.R
#
# Qué hace, en orden. Cada script usa los objetos que deja el anterior:
#   00_entorno       comprueba R, paquetes y datos; fija opciones deterministas
#   01_preparacion   lee el .zip, audita la clave, construye Y y la base analítica
#   02_particiones   crea predictores de ingreso e historial, y las particiones temporales
#   03_modelos       busca hiperparámetros de M1, M2 y M3 en las ventanas de desarrollo
#   04_evaluacion    compara con la referencia, elige el modelo y fija el umbral
#   05_diagnostico   dos análisis de sensibilidad y estabilidad, sólo en desarrollo
#   06_reserva       evaluación única en 2023: métricas, calibración, bootstrap, subgrupos
#
# Resultados (todo en output/, que no se versiona):
#   output/tablas/*.csv    las tablas del informe y la presentación
#   output/figuras/*.png   las figuras del informe y la presentación
#   output/*.rds           particiones, modelo elegido, predicciones de la reserva y
#                          base analítica (esta última tiene direcciones: no publicar)
#   output/sessionInfo.txt versiones exactas usadas en la ejecución
# Duración aproximada: 20 minutos en un equipo con 4 núcleos y 16 GB de RAM.

# --vanilla omite .Rprofile, así que renv se activa aquí para usar las versiones
# exactas de los paquetes de renv.lock.
source("renv/activate.R")
source("R/00_entorno.R")

t0 <- Sys.time()
set.seed(3407)

dir.create("output/tablas",  recursive = TRUE, showWarnings = FALSE)
dir.create("output/figuras", recursive = TRUE, showWarnings = FALSE)

# --- Análisis --------------------------------------------------------------
source("R/01_preparacion.R")
source("R/02_particiones.R")
source("R/03_modelos.R")
source("R/04_evaluacion.R")
source("R/05_diagnostico.R")
source("R/06_reserva.R")      # la reserva 2023 se evalúa sólo aquí, una vez

# --- Registro de la ejecución ----------------------------------------------
writeLines(capture.output(sessionInfo()), "output/sessionInfo.txt")
tiempo_min <- as.numeric(difftime(Sys.time(), t0, units = "mins"))
writeLines(sprintf("%.1f", tiempo_min), "output/tablas/tiempo_ejecucion_min.txt")

# --- Resumen en consola ----------------------------------------------------
# Sirve para comprobar de un vistazo que las cifras coinciden con el informe.
cat("\nEvaluación en la reserva 2023 (output/tablas/comparacion_reserva.csv):\n")
print(as.data.frame(readr::read_csv("output/tablas/comparacion_reserva.csv", show_col_types = FALSE)),
      row.names = FALSE, digits = 4)
cat("\nTablas:", length(list.files("output/tablas")), " Figuras:", length(list.files("output/figuras")),
    "\nTiempo total:", sprintf("%.1f", tiempo_min), "minutos\n")

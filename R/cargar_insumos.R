# cargar_insumos.R — restaura output/ desde insumos_qmd.RData cuando falta
#
# Lo ejecutan informe.qmd y presentacion.qmd al comenzar. También puede usarse a
# mano para trabajar con los resultados sin correr el análisis:
#
#   source("R/cargar_insumos.R")        # restaura output/ si hace falta
#   load("insumos_qmd.RData")           # objetos tablas y meta
#   tablas$comparacion_reserva          # cualquier tabla, como data frame
#   readRDS("output/predicciones_reserva.rds")
#
# Regla: si output/ ya tiene los resultados (por ejemplo, tras ejecutar
# analisis.R), no se toca nada. Así una ejecución nueva nunca queda reemplazada
# por resultados guardados anteriormente.

local({
  completo <- file.exists("output/tablas/comparacion_reserva.csv")
  if (!completo && file.exists("insumos_qmd.RData")) {
    e <- new.env()
    load("insumos_qmd.RData", envir = e)
    for (ruta in names(e$insumos_qmd)) {
      dir.create(dirname(ruta), recursive = TRUE, showWarnings = FALSE)
      writeBin(e$insumos_qmd[[ruta]], ruta)
    }
    message("Resultados restaurados desde insumos_qmd.RData (generados el ", e$insumos_generados, ").")
  } else if (!completo) {
    stop("Faltan los resultados: ejecute Rscript --vanilla analisis.R ",
         "o copie insumos_qmd.RData en la raíz del proyecto.", call. = FALSE)
  }
})

# cargar_insumos.R — lo usan informe.qmd y presentacion.qmd al comenzar
#
# Si output/ no tiene los resultados (por ejemplo, en un clon recién descargado),
# los restaura desde insumos_qmd.RData. Si ya existen, no toca nada: así una
# ejecución de analisis.R nunca queda reemplazada por resultados guardados.

if (!file.exists("output/tablas/comparacion_reserva.csv") && file.exists("insumos_qmd.RData")) {
  load("insumos_qmd.RData")
  for (ruta in names(insumos_qmd)) {
    dir.create(dirname(ruta), recursive = TRUE, showWarnings = FALSE)
    writeBin(insumos_qmd[[ruta]], ruta)
  }
  message("Resultados restaurados desde insumos_qmd.RData (generados el ", insumos_generados, ").")
}

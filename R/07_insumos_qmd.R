# 07_insumos_qmd.R — guarda los resultados procesados en insumos_qmd.RData
#
# Para qué sirve:
#   Permite generar informe.pdf y presentacion.pdf, o revisar los resultados, en
#   otro computador sin repetir el análisis completo (unos 20 minutos).
#
# Qué guarda (tres objetos):
#   insumos_qmd  copia exacta, byte a byte, de los archivos de output/ que usan los
#                documentos: tablas (.csv), figuras (.png), sessionInfo y los
#                resultados en .rds. R/cargar_insumos.R los restaura en output/.
#   tablas       las mismas tablas como data frames, para trabajar con ellas
#                directamente en R: tablas$comparacion_reserva, etc.
#   meta         versión de R del análisis, tiempo de ejecución y fecha.
#
# Qué NO guarda: output/datos_auditados.rds, la base solicitud por solicitud, que
# contiene direcciones. Por eso tampoco se publica en el repositorio.
#
# Importante: es un atajo para redactar y revisar. La reproducción exigida por el
# curso es ejecutar Rscript --vanilla analisis.R, que regenera todo desde los datos.

suppressPackageStartupMessages(library(readr))

# --- 1. Archivos que se copian ---------------------------------------------
archivos_insumo <- c(
  list.files("output/tablas", full.names = TRUE),
  list.files("output/figuras", full.names = TRUE),
  "output/sessionInfo.txt",
  "output/particiones.rds",          # claves unique_key de cada partición
  "output/seleccion.rds",            # modelo elegido, umbral y regla de selección
  "output/predicciones_reserva.rds"  # probabilidades de cada modelo en la reserva 2023
)
archivos_insumo <- archivos_insumo[file.exists(archivos_insumo)]
stopifnot(
  "no se puede empaquetar la base con direcciones" = !any(grepl("datos_auditados", archivos_insumo))
)

insumos_qmd <- lapply(archivos_insumo, function(f) readBin(f, "raw", file.info(f)$size))
names(insumos_qmd) <- archivos_insumo

# --- 2. Tablas como data frames --------------------------------------------
csv <- list.files("output/tablas", pattern = "\\.csv$", full.names = TRUE)
tablas <- lapply(csv, read_csv, show_col_types = FALSE)
names(tablas) <- sub("\\.csv$", "", basename(csv))

# --- 3. Metadatos ------------------------------------------------------------
ruta_tiempo <- "output/tablas/tiempo_ejecucion_min.txt"
meta <- list(
  version_r  = paste(R.version$major, R.version$minor, sep = "."),
  tiempo_min = if (file.exists(ruta_tiempo)) readLines(ruta_tiempo) else NA_character_,
  generado   = format(Sys.time(), "%Y-%m-%d %H:%M %Z")
)
# Se deja también como archivo para que el informe cite la versión del análisis.
writeLines(meta$version_r, "output/tablas/version_r_analisis.txt")
insumos_qmd[["output/tablas/version_r_analisis.txt"]] <- charToRaw(paste0(meta$version_r, "\n"))

# Nombre que usaba la versión anterior; se conserva para compatibilidad.
insumos_generados <- meta$generado

save(insumos_qmd, tablas, meta, insumos_generados, file = "insumos_qmd.RData", compress = "xz")
message("insumos_qmd.RData: ", length(insumos_qmd), " archivos y ", length(tablas), " tablas, ",
        round(file.info("insumos_qmd.RData")$size / 1024), " KB")

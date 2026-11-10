# 07_insumos_qmd.R — empaqueta los resultados que leen informe.qmd y presentacion.qmd
#
# Guarda en insumos_qmd.RData una copia exacta (byte a byte) de output/tablas y
# output/figuras. Con ese archivo, otro computador puede generar los documentos sin
# repetir el análisis: R/cargar_insumos.R restaura los archivos si faltan.
# No incluye output/datos_auditados.rds, que contiene direcciones.
#
# Es sólo un atajo para redactar. La reproducción exigida por el curso es
# ejecutar Rscript --vanilla analisis.R, que vuelve a generar todo desde los datos.

# Versión de R con que se obtuvieron los resultados, para citarla en el informe
# aunque los documentos se generen después en otro equipo.
writeLines(paste(R.version$major, R.version$minor, sep = "."), "output/tablas/version_r_analisis.txt")

archivos_insumo <- c(
  list.files("output/tablas", full.names = TRUE),
  list.files("output/figuras", full.names = TRUE)
)
insumos_qmd <- lapply(archivos_insumo, function(f) readBin(f, "raw", file.info(f)$size))
names(insumos_qmd) <- archivos_insumo
insumos_generados <- format(Sys.time(), "%Y-%m-%d %H:%M %Z")

save(insumos_qmd, insumos_generados, file = "insumos_qmd.RData", compress = "xz")
message("insumos_qmd.RData: ", length(insumos_qmd), " archivos, ",
        round(file.info("insumos_qmd.RData")$size / 1024), " KB")

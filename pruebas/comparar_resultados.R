# pruebas/comparar_resultados.R — compara los resultados de dos ejecuciones
#
# Uso:
#   Rscript --vanilla pruebas/comparar_resultados.R referencia.RData nueva.RData
#
# Cada archivo es un insumos_qmd.RData generado por analisis.R. Se comparan todas
# las tablas: columnas de texto deben ser idénticas y las numéricas se informan con
# su mayor diferencia absoluta. Se ignoran los tiempos de cómputo, que dependen del
# equipo. Termina con error si alguna diferencia supera la tolerancia.

suppressPackageStartupMessages(library(readr))
argumentos <- commandArgs(trailingOnly = TRUE)
if (length(argumentos) < 2) stop("Indique dos archivos .RData: referencia y nueva.", call. = FALSE)
TOLERANCIA <- 1e-6

# Obtiene las tablas de un .RData. Los archivos antiguos sólo traen insumos_qmd.
leer_tablas <- function(ruta) {
  e <- new.env()
  load(ruta, envir = e)
  if (!is.null(e$tablas)) return(e$tablas)
  csv <- grep("\\.csv$", names(e$insumos_qmd), value = TRUE)
  out <- lapply(csv, function(f) read_csv(I(rawToChar(e$insumos_qmd[[f]])), show_col_types = FALSE))
  setNames(out, sub("\\.csv$", "", basename(csv)))
}

ref <- leer_tablas(argumentos[1])
nva <- leer_tablas(argumentos[2])
ignorar_columnas <- c("minutos_busqueda")   # tiempo de cómputo

informe <- do.call(rbind, lapply(union(names(ref), names(nva)), function(n) {
  a <- ref[[n]]; b <- nva[[n]]
  if (is.null(a) || is.null(b)) return(data.frame(tabla = n, estado = "falta en una", max_dif = NA))
  a <- a[, setdiff(names(a), ignorar_columnas), drop = FALSE]
  b <- b[, setdiff(names(b), ignorar_columnas), drop = FALSE]
  if (!identical(dim(a), dim(b)) || !identical(names(a), names(b))) {
    return(data.frame(tabla = n, estado = "estructura distinta", max_dif = NA))
  }
  max_dif <- 0; texto_igual <- TRUE
  for (col in names(a)) {
    if (is.numeric(a[[col]]) && is.numeric(b[[col]])) {
      d <- abs(a[[col]] - b[[col]])
      d[is.na(a[[col]]) & is.na(b[[col]])] <- 0
      max_dif <- max(max_dif, d, na.rm = FALSE)
    } else {
      texto_igual <- texto_igual && identical(as.character(a[[col]]), as.character(b[[col]]))
    }
  }
  estado <- if (!texto_igual) "texto distinto" else if (is.na(max_dif) || max_dif > TOLERANCIA) "difiere" else "igual"
  data.frame(tabla = n, estado = estado, max_dif = max_dif)
}))

informe$estado[informe$tabla == "tiempo_ejecucion_min"] <- "ignorada (tiempo)"
print(informe, row.names = FALSE)
problemas <- informe$estado %in% c("falta en una", "estructura distinta", "texto distinto", "difiere")
if (any(problemas)) {
  stop(sum(problemas), " tabla(s) con diferencias sobre la tolerancia ", TOLERANCIA, ".", call. = FALSE)
}
message("Todas las tablas coinciden (tolerancia ", TOLERANCIA, ").")

# 00_entorno.R — comprueba el entorno y fija lo que no debe depender del equipo
# Se detiene con un mensaje claro antes de empezar un análisis que fallaría o cambiaría.

# --- 1. Determinismo ------------------------------------------------------
# El orden de los factores depende del idioma del sistema si no se fija.
invisible(Sys.setlocale("LC_COLLATE", "C"))
RNGkind(kind = "Mersenne-Twister", normal.kind = "Inversion", sample.kind = "Rejection")
options(digits = 7, OutDec = ".", scipen = 0, stringsAsFactors = FALSE, warn = 1)

# --- 2. Versión de R ------------------------------------------------------
version_lock <- renv::lockfile_read("renv.lock")$R$Version
mm <- function(v) paste(strsplit(as.character(v), ".", fixed = TRUE)[[1]][1:2], collapse = ".")
if (mm(getRversion()) != mm(version_lock)) {
  stop(
    "Este proyecto requiere R ", mm(version_lock), ".x y se está usando R ", getRversion(), ".\n",
    "Instale R ", version_lock, " desde https://cran.r-project.org/ y vuelva a ejecutar.",
    call. = FALSE
  )
}

# --- 3. Paquetes ----------------------------------------------------------
estado <- suppressMessages(renv::status(dev = FALSE))
if (!isTRUE(estado$synchronized)) {
  stop("Los paquetes no coinciden con renv.lock. Ejecute primero: Rscript --vanilla instalar.R", call. = FALSE)
}

# --- 4. Datos -------------------------------------------------------------
MD5_ZIP <- "42a7931a2a2b19fdfa04b73823c85903"
ruta_zip <- "datos/caso08_nyc311.zip"
if (!file.exists(ruta_zip)) stop("Falta ", ruta_zip, " (ver README.md, sección Datos).", call. = FALSE)
if (unname(tools::md5sum(ruta_zip)) != MD5_ZIP) {
  stop(ruta_zip, " no coincide con la copia entregada (MD5 distinto).", call. = FALSE)
}

# --- 5. Quarto y LaTeX ----------------------------------------------------
if (is.null(quarto::quarto_path())) {
  stop("No se encontró Quarto. Instálelo desde https://quarto.org/docs/get-started/", call. = FALSE)
}
hay_latex <- tinytex::is_tinytex() || nzchar(Sys.which("lualatex")) || nzchar(Sys.which("xelatex"))
if (!hay_latex) stop("No se encontró LaTeX. Ejecute: quarto install tinytex", call. = FALSE)

# Quarto debe usar este mismo R aunque el equipo tenga varias versiones instaladas.
Sys.setenv(QUARTO_R = R.home("bin"))

message("Entorno verificado: R ", getRversion(), ", ", estado$library$Packages |> length(), " paquetes, Quarto ",
        quarto::quarto_version())

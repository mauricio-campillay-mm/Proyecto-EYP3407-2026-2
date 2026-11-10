# instalar.R — instala las versiones exactas de los paquetes de renv.lock
#
# Ejecutar una vez, desde la raíz del proyecto:
#   Rscript --vanilla instalar.R
#
# renv crea una biblioteca propia del proyecto (renv/library), separada de los
# paquetes que el equipo tenga instalados, y descarga cada paquete en la versión
# registrada. El repositorio del lockfile está fijado al 6 de noviembre de 2026,
# por lo que en Windows y Linux se instalan binarios sin compilar.
# Detalle de requisitos y problemas frecuentes: INSTALACION.md.

source("renv/activate.R")
renv::restore(prompt = FALSE)

# Quarto y LaTeX no son paquetes de R: se comprueba que estén y, si no, se indica cómo instalarlos.
if (is.null(quarto::quarto_path())) {
  message("Falta Quarto: https://quarto.org/docs/get-started/")
} else if (!(tinytex::is_tinytex() || nzchar(Sys.which("lualatex")) || nzchar(Sys.which("xelatex")))) {
  message("Falta LaTeX. Ejecute: quarto install tinytex")
}
message("Instalación terminada. Ahora ejecute: Rscript --vanilla analisis.R")
